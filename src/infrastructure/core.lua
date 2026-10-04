-- Shared lifecycle infrastructure. Activities own their temporary state through
-- a scope; the map owns navigation, registry data and the controller itself.
JTG = JTG or {}

JTG.UnitSquarePlayerTexture = "JTGOverlay\\UnitSquaresPlayer.dds"
JTG.UnitSquareEnemyTexture = "JTGOverlay\\UnitSquaresEnemy.dds"

-- Calibration found one stable display adjustment per 16-unit collision
-- category. Keeping this category-based lets future units inherit the correct
-- overlay without a unit-ID table.
function JTG.UnitObstructionHalfSize(collision)
    return math.floor((collision or 0) / 16) * 16 + 12
end

-- Tutorial checkpoint panels share a 0.026-high button, 0.003 spacing, the
-- established 0.041 top inset and a dedicated footer for Close. Growing the
-- frame from this count keeps later checkpoints from colliding with Close.
function JTG.TutorialMenuHeight(buttonCount)
    return 0.095 + math.max(0, buttonCount or 0) * 0.029
end

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
    descriptor.registrationOrder = #JTG.Registry.ordered + 1
    JTG.Registry.byId[descriptor.id] = descriptor
    table.insert(JTG.Registry.ordered, descriptor)
    return descriptor
end

function JTG.GetActivities(category, skillRace)
    local result = {}
    for _, descriptor in ipairs(JTG.Registry.ordered) do
        local matchesRace = skillRace == nil
        if skillRace ~= nil and descriptor.skillRaces ~= nil then
            for _, race in ipairs(descriptor.skillRaces) do
                if race == skillRace then matchesRace = true end
            end
        end
        local belongsOnGeneralPage = skillRace ~= nil or descriptor.skillRaces == nil
        if descriptor.category == category and not descriptor.hidden and
                matchesRace and belongsOnGeneralPage then
            table.insert(result, descriptor)
        end
    end
    table.sort(result, function(left, right)
        local leftOrder = left.menuOrder or (10000 + left.registrationOrder)
        local rightOrder = right.menuOrder or (10000 + right.registrationOrder)
        return leftOrder < rightOrder
    end)
    return result
end

function JTG.CreateScope(label)
    return {label = label, disposed = false, disposers = {}, loadDisposers = {}}
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
    local dispose = function()
        if timer ~= nil then
            PauseTimer(timer)
            DestroyTimer(timer)
        end
    end
    JTG.ScopeAdd(scope, dispose)
    table.insert(scope.loadDisposers, dispose)
    return timer
end

function JTG.ScopeTrackTrigger(scope, trigger)
    local dispose = function()
        if trigger ~= nil then
            DisableTrigger(trigger)
            DestroyTrigger(trigger)
        end
    end
    JTG.ScopeAdd(scope, dispose)
    table.insert(scope.loadDisposers, dispose)
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

-- Regular-map tutorials normally begin with the terrain explored, while
-- ordinary unit sight still determines what is currently visible. Activities
-- with a different teaching requirement can explicitly choose another state.
function JTG.UseExploredWorldFog(player)
    FogEnable(true)
    FogMaskEnable(true)
    SetFogStateRect(player, FOG_OF_WAR_FOGGED,
        bj_mapInitialPlayableArea, true)
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
    scope.loadDisposers = {}
    return ok
end

-- Loaded custom-frame handles are invalid. Abandon their disposer closures
-- without invoking frame natives; gameplay resources live in a separate scope.
function JTG.AbandonScope(scope)
    if scope == nil then return end
    for index = #(scope.loadDisposers or {}), 1, -1 do
        pcall(scope.loadDisposers[index])
    end
    scope.disposed = true
    scope.disposers = {}
    scope.loadDisposers = {}
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
    if JTG.UI then
        JTG.UI.SetGameplayMenuPaused(false)
        JTG.UI.SetExercisePaused(false)
        JTG.UI.SetQuestAvailable(false)
    end
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
    if not JTG.DisposeScope(session.presentationScope) then ok = false end
    if not JTG.DisposeScope(session.scope) then ok = false end
    JTG.ResetWorldFog(Player(0))
    controller.session = nil
    controller.state = "idle"
    if JTG.UI then
        JTG.UI.HideToolbar()
        JTG.UI.SetQuestAvailable(false)
    end
    return ok
end

function JTG.StartActivity(id, originCategory, restartData, preservedCameraDistance)
    local controller = JTG.Controller
    local descriptor = JTG.Registry.byId[id]
    if descriptor == nil or descriptor.status ~= "available" or type(descriptor.factory) ~= "function" then
        return false, "Activity is unavailable: " .. tostring(id)
    end
    local entryCameraDistance = preservedCameraDistance
    if entryCameraDistance == nil and GetLocalPlayer() == Player(0) then
        entryCameraDistance = GetCameraField(CAMERA_FIELD_TARGET_DISTANCE)
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
        restartData = restartData,
        scope = JTG.CreateScope("activity:" .. id),
        presentationScope = JTG.CreateScope("presentation:" .. id),
    }
    controller.session = session
    controller.state = "setting_up"
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
        JTG.UI.ReleaseGameplayControl()
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
    -- Camera distance belongs to the player. Activities may recenter the
    -- camera, but retain the distance present when they were entered or reset
    -- unless their descriptor explicitly requests a particular distance.
    if GetLocalPlayer() == Player(0) then
        local requestedDistance = descriptor.cameraDistance or entryCameraDistance
        if requestedDistance ~= nil then
            SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, requestedDistance, 0)
        end
    end
    return true
end

-- Some exercises recreate pathing-heavy objects at identical coordinates.
-- Starting them in the same callback that removes the previous run can make
-- Warcraft resolve the new melee start against stale unit footprints.
function JTG.StartActivityAfterCleanup(id, originCategory, restartData,
        preservedCameraDistance, reason)
    local cameraDistance = preservedCameraDistance
    if cameraDistance == nil and GetLocalPlayer() == Player(0) then
        cameraDistance = GetCameraField(CAMERA_FIELD_TARGET_DISTANCE)
    end
    JTG.StopActivity(reason or "replace")
    local stoppedGeneration = JTG.Controller.generation
    local timer = CreateTimer()
    TimerStart(timer, 0.00, false, function()
        DestroyTimer(timer)
        if JTG.Controller.session == nil and
                JTG.Controller.generation == stoppedGeneration then
            JTG.StartActivity(id, originCategory, restartData, cameraDistance)
        end
    end)
    return true
end

function JTG.ResetActivity()
    local session = JTG.Controller.session
    if session == nil then return false end
    local cameraDistance = nil
    if GetLocalPlayer() == Player(0) then
        cameraDistance = GetCameraField(CAMERA_FIELD_TARGET_DISTANCE)
    end
    local id, category = session.id, JTG.Controller.lastCategory
    local restartData = nil
    if session.activity and session.activity.captureResetState then
        local captured, data = pcall(session.activity.captureResetState, session.activity, session)
        if captured then restartData = data
        else print("JTG reset-state warning: " .. tostring(data)) end
    end
    -- Exercises that recreate collision-sensitive setups at identical
    -- coordinates get one frame for Warcraft to retire the old footprints.
    -- Rebuilding directly in the click callback can otherwise make the next
    -- setup inherit stale placement or collision state.
    if id == "skills.gold_mine" or id == "skills.windwalk" or
            id == "skills.surround" then
        return JTG.StartActivityAfterCleanup(id, category, restartData,
            cameraDistance, "reset")
    end
    JTG.StopActivity("reset")
    return JTG.StartActivity(id, category, restartData, cameraDistance)
end

function JTG.RotateActivity()
    local session = JTG.Controller.session
    if session == nil or session.activity == nil or
            session.activity.captureRotatedState == nil then return false end
    local captured, restartData = pcall(
        session.activity.captureRotatedState, session.activity, session)
    if not captured or restartData == nil then
        if not captured then
            print("JTG rotate-state warning: " .. tostring(restartData))
        end
        return false
    end
    local cameraDistance = nil
    if GetLocalPlayer() == Player(0) then
        cameraDistance = GetCameraField(CAMERA_FIELD_TARGET_DISTANCE)
    end
    return JTG.StartActivityAfterCleanup(session.id,
        JTG.Controller.lastCategory, restartData, cameraDistance, "rotate")
end

function JTG.ToggleActivitySetups()
    local session = JTG.Controller.session
    if session == nil or session.activity == nil or
            session.activity.toggleSetups == nil then return false end
    local ok, message = pcall(session.activity.toggleSetups, session.activity)
    if not ok then
        print("JTG setup-menu warning: " .. tostring(message))
        return false
    end
    return true
end

function JTG.NextActivityStage()
    local session = JTG.Controller.session
    if session == nil or session.activity == nil or
            session.activity.nextStage == nil then return false end
    local ok, result = pcall(session.activity.nextStage, session.activity)
    if not ok then
        print("JTG next-stage warning: " .. tostring(result))
        return false
    end
    return result == true
end

function JTG.ToggleActivitySquares()
    local session = JTG.Controller.session
    if session == nil or session.activity == nil or
            session.activity.toggleSquares == nil then return false end
    local ok, message = pcall(session.activity.toggleSquares, session.activity)
    if not ok then
        print("JTG square-overlay warning: " .. tostring(message))
        return false
    end
    return true
end

function JTG.LastRunnerActivity()
    local session = JTG.Controller.session
    if session == nil or session.activity == nil or
        session.activity.captureLastRunnerState == nil then return false end
    local captured, restartData = pcall(session.activity.captureLastRunnerState,
        session.activity, session)
    if not captured or restartData == nil then return false end
    local id, category = session.id, JTG.Controller.lastCategory
    local cameraDistance = nil
    if GetLocalPlayer() == Player(0) then
        cameraDistance = GetCameraField(CAMERA_FIELD_TARGET_DISTANCE)
    end
    JTG.StopActivity("last-runner")
    return JTG.StartActivity(id, category, restartData, cameraDistance)
end

function JTG.ExitActivity()
    local category = JTG.Controller.lastCategory
    JTG.StopActivity("exit")
    if JTG.UI then JTG.UI.ShowCategory(category) end
end

-- End an activity while preserving the menu page the player is currently
-- browsing. This is separate from the exercise/result Exit action, which
-- intentionally returns to the originating catalogue.
function JTG.ExitActivityFromMenu()
    local restoreBriefing = JTG.UI and JTG.UI.IsActivityBriefingOpen and
        JTG.UI.IsActivityBriefingOpen()
    JTG.StopActivity("menu-exit")
    if JTG.UI and JTG.UI.OnActivityExitedInMenu then
        JTG.UI.OnActivityExitedInMenu(restoreBriefing)
    end
end

function JTG.OpenActivityMenu(id, originCategory, restorePage, restoreData)
    local controller = JTG.Controller
    local session = controller.session
    local targetId = id or (session and session.id)
    local descriptor = targetId and JTG.Registry.byId[targetId] or nil
    if descriptor == nil or descriptor.status ~= "available" then return false end
    local category = originCategory or descriptor.category or controller.lastCategory
    controller.lastCategory = category
    if descriptor.menu ~= nil then
        descriptor.menu(category, session ~= nil, restorePage, restoreData)
    elseif JTG.UI then
        JTG.UI.ShowCategory(category)
    end
    return true
end

function JTG.OpenTrainingMenu()
    return JTG.OpenActivityMenu()
end

function JTG.ResumeActivity()
    local session = JTG.Controller.session
    if session == nil then
        if JTG.UI then JTG.UI.ShowCategory(JTG.Controller.lastCategory) end
        return
    end
    if JTG.UI then
        JTG.UI.SetGameplayMenuPaused(false)
        JTG.UI.HideAllPanels()
        if session.activity.restorePresentation then
            session.activity:restorePresentation()
        else
            JTG.UI.ShowToolbar(session.descriptor.capabilities)
        end
    end
end
