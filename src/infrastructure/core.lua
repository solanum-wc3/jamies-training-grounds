-- Shared lifecycle infrastructure. Activities own their temporary state through
-- a scope; the map owns navigation, registry data and the controller itself.
JTG = JTG or {}

JTG.Registry = {byId = {}, ordered = {}}
JTG.Scenes = {}

function JTG.RegisterScene(scene)
    assert(type(scene) == "table", "Scene descriptor must be a table")
    assert(type(scene.id) == "string" and scene.id ~= "", "Scene ID is required")
    assert(JTG.Scenes[scene.id] == nil, "Duplicate scene ID: " .. scene.id)
    JTG.Scenes[scene.id] = scene
    return scene
end

function JTG.RegisterActivity(descriptor)
    assert(type(descriptor) == "table", "Activity descriptor must be a table")
    assert(type(descriptor.id) == "string" and descriptor.id ~= "", "Activity ID is required")
    assert(JTG.Registry.byId[descriptor.id] == nil, "Duplicate activity ID: " .. descriptor.id)
    descriptor.status = descriptor.status or "planned"
    descriptor.capabilities = descriptor.capabilities or {}
    JTG.Registry.byId[descriptor.id] = descriptor
    table.insert(JTG.Registry.ordered, descriptor)
    return descriptor
end

function JTG.GetActivities(category)
    local result = {}
    for _, descriptor in ipairs(JTG.Registry.ordered) do
        if descriptor.category == category and not descriptor.hidden then
            table.insert(result, descriptor)
        end
    end
    return result
end

function JTG.CreateScope(label)
    return {label = label, disposed = false, disposers = {}}
end

function JTG.ScopeAdd(scope, disposer)
    assert(not scope.disposed, "Cannot add a resource to a disposed scope")
    table.insert(scope.disposers, disposer)
    return disposer
end

function JTG.ScopeTrackUnit(scope, unit)
    JTG.ScopeAdd(scope, function()
        if unit ~= nil then RemoveUnit(unit) end
    end)
    return unit
end

function JTG.ScopeTrackTimer(scope, timer)
    JTG.ScopeAdd(scope, function()
        if timer ~= nil then
            PauseTimer(timer)
            DestroyTimer(timer)
        end
    end)
    return timer
end

function JTG.ScopeTrackTrigger(scope, trigger)
    JTG.ScopeAdd(scope, function()
        if trigger ~= nil then
            DisableTrigger(trigger)
            DestroyTrigger(trigger)
        end
    end)
    return trigger
end

function JTG.BorrowCamera(scope, player)
    -- Camera reads are local state. The captured values are only consumed inside
    -- the matching local-player branch, so this does not alter synchronized play.
    local x = GetCameraTargetPositionX()
    local y = GetCameraTargetPositionY()
    local distance = GetCameraField(CAMERA_FIELD_TARGET_DISTANCE)
    -- Warcraft returns angular camera fields in radians, while SetCameraField
    -- expects degrees.
    local angle = math.deg(GetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK))
    local rotation = math.deg(GetCameraField(CAMERA_FIELD_ROTATION))
    JTG.ScopeAdd(scope, function()
        if GetLocalPlayer() == player then
            PanCameraToTimed(x, y, 0)
            SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, distance, 0)
            SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, angle, 0)
            SetCameraField(CAMERA_FIELD_ROTATION, rotation, 0)
        end
    end)
end

function JTG.MaskScene(scene, player)
    if scene == nil or scene.minX == nil then return end
    local area = Rect(scene.minX, scene.minY, scene.maxX, scene.maxY)
    SetFogStateRect(player, FOG_OF_WAR_MASKED, area, true)
    RemoveRect(area)
end

function JTG.ResetWorldFog(player)
    FogEnable(true)
    FogMaskEnable(true)
    SetFogStateRect(player, FOG_OF_WAR_MASKED, bj_mapInitialPlayableArea, true)
end

function JTG.DisposeScope(scope)
    if scope == nil or scope.disposed then return true end
    scope.disposed = true
    local ok = true
    for index = #scope.disposers, 1, -1 do
        local success, message = pcall(scope.disposers[index])
        if not success then
            ok = false
            print("JTG cleanup warning (" .. scope.label .. "): " .. tostring(message))
        end
    end
    scope.disposers = {}
    return ok
end

JTG.Stats = {attempts = {}, completions = {}}

function JTG.RecordAttempt(id)
    JTG.Stats.attempts[id] = (JTG.Stats.attempts[id] or 0) + 1
end

function JTG.RecordCompletion(id)
    JTG.Stats.completions[id] = (JTG.Stats.completions[id] or 0) + 1
end

JTG.Controller = {
    state = "idle",
    generation = 0,
    session = nil,
    lastCategory = "learn",
}

function JTG.IsCurrentSession(session)
    return session ~= nil and JTG.Controller.session == session and
        session.active and session.generation == JTG.Controller.generation
end

function JTG.GuardSession(session, callback)
    return function(...)
        if JTG.IsCurrentSession(session) then return callback(...) end
    end
end

local function ControllerFailure(message)
    JTG.Controller.state = "faulted"
    print("JTG activity error: " .. tostring(message))
    DisplayTimedTextToPlayer(Player(0), 0, 0, 12,
        "|cffff4040The activity could not be started.|r The training menu has been restored.")
end

function JTG.StopActivity(reason)
    local controller = JTG.Controller
    local session = controller.session
    if session == nil then
        controller.state = "idle"
        JTG.ResetWorldFog(Player(0))
        if JTG.UI then JTG.UI.HideToolbar() end
        return true
    end

    controller.state = "stopping"
    controller.generation = controller.generation + 1
    session.active = false
    local ok = true
    if session.activity and session.activity.cleanup then
        local success, message = pcall(session.activity.cleanup, session.activity, session, reason)
        if not success then
            ok = false
            print("JTG semantic cleanup warning: " .. tostring(message))
        end
    end
    if not JTG.DisposeScope(session.scope) then ok = false end
    JTG.ResetWorldFog(Player(0))
    controller.session = nil
    controller.state = "idle"
    if JTG.UI then JTG.UI.HideToolbar() end
    return ok
end

function JTG.StartActivity(id, originCategory)
    local controller = JTG.Controller
    local descriptor = JTG.Registry.byId[id]
    if descriptor == nil or descriptor.status ~= "available" or type(descriptor.factory) ~= "function" then
        return false, "Activity is unavailable: " .. tostring(id)
    end
    local scene = nil
    if descriptor.sceneId ~= nil then
        scene = JTG.Scenes[descriptor.sceneId]
        if scene == nil then return false, "Activity scene is unavailable: " .. descriptor.sceneId end
    end
    if controller.session ~= nil then JTG.StopActivity("replace") end

    controller.generation = controller.generation + 1
    controller.lastCategory = originCategory or descriptor.category or controller.lastCategory
    local session = {
        id = id,
        descriptor = descriptor,
        scene = scene,
        generation = controller.generation,
        active = true,
        scope = JTG.CreateScope("activity:" .. id),
    }
    controller.session = session
    controller.state = "setting_up"
    JTG.RecordAttempt(id)

    local made, activity = pcall(descriptor.factory, session)
    if not made then
        ControllerFailure(activity)
        JTG.StopActivity("factory-failed")
        if JTG.UI then JTG.UI.ShowCategory(controller.lastCategory) end
        return false, activity
    end
    session.activity = activity or {}
    local setupOk, setupMessage = true, nil
    if session.activity.setup then
        setupOk, setupMessage = pcall(session.activity.setup, session.activity, session)
    end
    if not setupOk then
        ControllerFailure(setupMessage)
        JTG.StopActivity("setup-failed")
        if JTG.UI then JTG.UI.ShowCategory(controller.lastCategory) end
        return false, setupMessage
    end

    controller.state = "running"
    if JTG.UI then
        JTG.UI.HideAllPanels()
        JTG.UI.ShowToolbar(descriptor.capabilities)
    end
    if session.activity.start then
        local started, startMessage = pcall(session.activity.start, session.activity, session)
        if not started then
            ControllerFailure(startMessage)
            JTG.StopActivity("start-failed")
            if JTG.UI then JTG.UI.ShowCategory(controller.lastCategory) end
            return false, startMessage
        end
    end
    return true
end

function JTG.ResetActivity()
    local session = JTG.Controller.session
    if session == nil then return false end
    local id, category = session.id, JTG.Controller.lastCategory
    JTG.StopActivity("reset")
    return JTG.StartActivity(id, category)
end

function JTG.ExitActivity()
    local category = JTG.Controller.lastCategory
    JTG.StopActivity("exit")
    if JTG.UI then JTG.UI.ShowCategory(category) end
end

function JTG.OpenTrainingMenu()
    local controller = JTG.Controller
    if controller.session == nil then
        if JTG.UI then JTG.UI.ShowCategory(controller.lastCategory) end
        return
    end
    if JTG.UI then JTG.UI.ShowActivityMenu(controller.lastCategory) end
end

function JTG.ResumeActivity()
    local session = JTG.Controller.session
    if session == nil then
        if JTG.UI then JTG.UI.ShowCategory(JTG.Controller.lastCategory) end
        return
    end
    if JTG.UI then
        JTG.UI.HideAllPanels()
        JTG.UI.ShowToolbar(session.descriptor.capabilities)
    end
end
