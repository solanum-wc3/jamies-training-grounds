-- Shared lifecycle infrastructure. Activities own their temporary state through
-- a scope; the map owns navigation, registry data and the controller itself.
JTG = JTG or {}

JTG.UnitSquarePlayerTexture = "JTGOverlay\\UnitSquaresPlayer.dds"
JTG.UnitSquareEnemyTexture = "JTGOverlay\\UnitSquaresEnemy.dds"
JTG.NavigationDotsTexture = "JTGOverlay\\32x32NavigationGridDots.dds"
JTG.NavigationGridTexture = "JTGOverlay\\8x8NavigationGrid.dds"

-- Collision-aware placement probing found three effective footprint widths:
-- 48, 80 and 112 for collision categories 16/31, 32 and 48. Footprints are
-- anchored to the center of the containing 32-unit world-grid cell.
function JTG.UnitObstructionHalfSize(collision)
    return math.floor((collision or 0) / 16) * 16 + 8
end

function JTG.UnitObstructionGridCenter(coordinate)
    return math.floor((coordinate or 0) / 32) * 32 + 16
end

function JTG.CreateNavigationOverlay(scope, scene, texture)
    local images = {}
    if scene == nil then return images end
    local tileSize = 1024.0
    -- Slightly overlap adjacent terrain-projected images so camera
    -- perspective cannot expose a seam between otherwise contiguous tiles.
    -- Tile origins still advance by exactly 1024 world units.
    local renderSize = tileSize + 1.0
    local minX = math.floor(scene.minX / tileSize) * tileSize
    local minY = math.floor(scene.minY / tileSize) * tileSize
    local maxX = math.ceil(scene.maxX / tileSize) * tileSize
    local maxY = math.ceil(scene.maxY / tileSize) * tileSize
    local x = minX
    while x < maxX do
        local y = minY
        while y < maxY do
            local image = JTG.ScopeTrackImage(scope,
                CreateImage(texture,
                    renderSize, renderSize, 0, x, y, 1,
                    0, 0, 0, 2))
            SetImageRenderAlways(image, true)
            SetImageAboveWater(image, true, true)
            ShowImage(image, false)
            images[#images + 1] = image
            y = y + tileSize
        end
        x = x + tileSize
    end
    return images
end

function JTG.CreateNavigationDotsOverlay(scope, scene)
    return JTG.CreateNavigationOverlay(scope, scene,
        JTG.NavigationDotsTexture)
end

function JTG.CreateNavigationGridOverlay(scope, scene)
    return JTG.CreateNavigationOverlay(scope, scene,
        JTG.NavigationGridTexture)
end

function JTG.ShowNavigationGrid(images, visible)
    for _, image in ipairs(images or {}) do
        ShowImage(image, visible == true)
    end
end

-- Tutorial checkpoint panels share a 0.026-high button, 0.003 spacing, the
-- established 0.041 top inset and a dedicated footer for Close. Growing the
-- frame from this count keeps later checkpoints from colliding with Close.
function JTG.TutorialMenuHeight(buttonCount)
    return 0.095 + math.max(0, buttonCount or 0) * 0.029
end

JTG.Registry = {byId = {}, ordered = {}}
JTG.Scenes = {}
JTG.BootstrapInitializers = {}

-- Optional modules register startup work here. Release builds can omit those
-- modules entirely without leaving direct references to development code in
-- the permanent bootstrap.
function JTG.RegisterBootstrapInitializer(initializer)
    assert(type(initializer) == "function",
        "Bootstrap initializer must be a function")
    table.insert(JTG.BootstrapInitializers, initializer)
end

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

function JTG.GetActivities(category, raceId)
    local result = {}
    for _, descriptor in ipairs(JTG.Registry.ordered) do
        local raceIds = descriptor.races or descriptor.skillRaces
        local matchesRace = raceId == nil
        if raceId ~= nil and raceIds ~= nil then
            for _, race in ipairs(raceIds) do
                if race == raceId then matchesRace = true end
            end
        end
        local belongsOnGeneralPage = category == "skills" or raceId ~= nil or raceIds == nil
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
    return {
        label = label,
        disposed = false,
        disposers = {},
        loadDisposers = {},
    }
end

function JTG.ScopeAdd(scope, disposer)
    assert(type(scope) == "table", "Resource scope is required")
    assert(type(disposer) == "function", "Resource disposer must be a function")
    assert(not scope.disposed, "Cannot add a resource to a disposed scope")
    table.insert(scope.disposers, disposer)
    return disposer
end

-- Borrowed state remains owned by the map or player. Register only the
-- operation that restores it, keeping that distinct from owned handles.
function JTG.ScopeBorrow(scope, restore)
    return JTG.ScopeAdd(scope, restore)
end

local function ScopeTrack(scope, resource, disposer, disposeOnLoad)
    local disposed = false
    local dispose = function()
        if disposed then return end
        disposed = true
        if resource ~= nil then disposer(resource) end
    end
    JTG.ScopeAdd(scope, dispose)
    if disposeOnLoad then table.insert(scope.loadDisposers, dispose) end
    return resource
end

local unitScopes = {}
function JTG.ScopeTrackUnit(scope, unit)
    if unit~=nil and not unitScopes[unit] then unitScopes[unit]=scope end
    return ScopeTrack(scope, unit, function(value)
        if unitScopes[value]==scope then unitScopes[value]=nil end
        RemoveUnit(value)
    end, false)
end

local function SnapshotWorldUnits()
    local group=CreateGroup()
    if group==nil then return nil end
    local area=GetWorldBounds()
    if area==nil then DestroyGroup(group);return nil end
    GroupEnumUnitsInRect(group,area,nil)
    local result={}
    local size=BlzGroupGetSize(group)
    if type(size)~='number' then DestroyGroup(group);RemoveRect(area);return nil end
    for index=0,size-1 do
        local unit=BlzGroupUnitAt(group,index)
        if unit~=nil then result[unit]=true end
    end
    DestroyGroup(group);RemoveRect(area)
    return result
end

-- Summons have their own native event. Only engine replacement abilities
-- need a deferred scan; ordinary casts must not enumerate the entire map.
local replacementAbilities = {}
for _,raw in ipairs({'Acoa','Aco2','Aco3','Acoh','Adec','AOmi',
    'AEme','Abrf','Arav','Aave','Astn','Amil','Amic','ANrg'}) do
    replacementAbilities[FourCC(raw)]=true
end

-- Native summons and split/merge results can create handles that activity
-- code never receives. Keep them under the same ownership rules as their caster.
function JTG.TrackSessionGeneratedUnits(session)
    session.existingUnits=SnapshotWorldUnits()
    local trigger=JTG.ScopeTrackTrigger(session.scope,CreateTrigger())
    local slots=type(bj_MAX_PLAYER_SLOTS)=='number' and bj_MAX_PLAYER_SLOTS or 28
    for index=0,slots-1 do
        TriggerRegisterPlayerUnitEvent(trigger,Player(index),EVENT_PLAYER_UNIT_SUMMON,nil)
        TriggerRegisterPlayerUnitEvent(trigger,Player(index),EVENT_PLAYER_UNIT_SPELL_EFFECT,nil)
    end
    TriggerAddAction(trigger,JTG.GuardSession(session,function()
        if GetTriggerEventId()==EVENT_PLAYER_UNIT_SUMMON then
            local parent,child=GetSummoningUnit(),GetSummonedUnit()
            local scope=parent and unitScopes[parent]
            if child and scope and not unitScopes[child] then
                if scope.disposed then RemoveUnit(child) else JTG.ScopeTrackUnit(scope,child) end
            end
            return
        end
        local caster=GetTriggerUnit()
        local scope=caster and unitScopes[caster]
        if not scope or not session.existingUnits or not replacementAbilities[GetSpellAbilityId()] then return end
        local x,y,owner=GetUnitX(caster),GetUnitY(caster),GetOwningPlayer(caster)
        -- Engine morph/merge products may appear after the effect callback.
        -- Use the session scope so a disposed child scope still gets cleanup.
        local function collectProducts()
            for unit in pairs(SnapshotWorldUnits() or {}) do
                if not session.existingUnits[unit] and not unitScopes[unit] and GetOwningPlayer(unit)==owner then
                    local dx,dy=GetUnitX(unit)-x,GetUnitY(unit)-y
                    if dx*dx+dy*dy<=600*600 then
                        if scope.disposed then RemoveUnit(unit) else JTG.ScopeTrackUnit(scope,unit) end
                    end
                end
            end
        end
        JTG.StartScopedTimer(session,session.scope,0.00,false,collectProducts)
        JTG.StartScopedTimer(session,session.scope,0.10,false,collectProducts)
    end))
end

function JTG.CleanupSessionGeneratedUnits(session)
    if not session.existingUnits then return end
    for unit in pairs(SnapshotWorldUnits() or {}) do
        if not session.existingUnits[unit] and not unitScopes[unit] then RemoveUnit(unit) end
    end
end

function JTG.ScopeTrackTimer(scope, timer)
    return ScopeTrack(scope, timer, function(value)
        PauseTimer(value)
        DestroyTimer(value)
    end, true)
end

function JTG.ScopeTrackTrigger(scope, trigger)
    return ScopeTrack(scope, trigger, function(value)
        DisableTrigger(value)
        DestroyTrigger(value)
    end, true)
end

function JTG.ScopeTrackFrame(scope, frame)
    return ScopeTrack(scope, frame, function(value)
        BlzDestroyFrame(value)
    end, false)
end

function JTG.ScopeTrackLightning(scope, lightning)
    return ScopeTrack(scope, lightning, function(value)
        DestroyLightning(value)
    end, false)
end

function JTG.ScopeTrackTextTag(scope, tag)
    return ScopeTrack(scope, tag, function(value)
        DestroyTextTag(value)
    end, false)
end

function JTG.ScopeTrackEffect(scope, effect)
    return ScopeTrack(scope, effect, function(value)
        DestroyEffect(value)
    end, false)
end

function JTG.ScopeTrackImage(scope, image)
    return ScopeTrack(scope, image, function(value)
        DestroyImage(value)
    end, false)
end

function JTG.ScopeTrackQuest(scope, quest)
    return ScopeTrack(scope, quest, function(value)
        DestroyQuest(value)
    end, false)
end

function JTG.ScopeTrackDestructable(scope, destructable)
    return ScopeTrack(scope, destructable, function(value)
        RemoveDestructable(value)
    end, false)
end

function JTG.ScopeTrackGroup(scope, group)
    return ScopeTrack(scope, group, function(value)
        DestroyGroup(value)
    end, false)
end

function JTG.ScopeTrackFogModifier(scope, modifier)
    return ScopeTrack(scope, modifier, function(value)
        FogModifierStop(value)
        DestroyFogModifier(value)
    end, false)
end

-- Create and start a timer whose callback becomes inert as soon as its session
-- is invalidated. The timer itself remains scope-owned and is always destroyed
-- during cleanup. Existing exercise timing values remain unchanged.
function JTG.StartScopedTimer(session, scope, timeout, periodic, callback)
    assert(type(callback) == "function", "Timer callback must be a function")
    local timer = JTG.ScopeTrackTimer(scope, CreateTimer())
    TimerStart(timer, timeout, periodic, JTG.GuardSession(session, callback))
    return timer
end

function JTG.ScopeRevealRect(scope, player, minX, minY, maxX, maxY)
    local area = Rect(minX, minY, maxX, maxY)
    SetFogStateRect(player, FOG_OF_WAR_VISIBLE, area, true)
    local modifier = CreateFogModifierRect(player, FOG_OF_WAR_VISIBLE,
        area, false, false)
    FogModifierStart(modifier)
    RemoveRect(area)
    return JTG.ScopeTrackFogModifier(scope, modifier)
end

function JTG.ScopeRevealScene(scope, scene, player)
    if scene == nil or scene.minX == nil then return nil end
    return JTG.ScopeRevealRect(scope, player, scene.minX, scene.minY,
        scene.maxX, scene.maxY)
end

function JTG.AddActivityFinalizer(session, finalizer)
    assert(type(session) == "table", "Activity session is required")
    assert(type(finalizer) == "function", "Activity finalizer must be a function")
    assert(not session.finalized,
        "Cannot add a finalizer after activity resources were disposed")
    table.insert(session.finalizers, finalizer)
    return finalizer
end

-- Blight applied by Undead buildings can be recreated by the engine while
-- those buildings still exist. Register its removal in the post-disposal
-- stage so the final clear happens after every activity-owned unit is gone.
function JTG.ClearBlightAfterActivity(session, player, x, y, radius)
    local clear = function()
        SetBlight(player, x, y, radius, false)
    end
    JTG.AddActivityFinalizer(session, clear)
    return clear
end

local function RunActivityFinalizers(session, reason)
    if session == nil or session.finalized then return true end
    session.finalized = true
    local ok = true
    if session.activity and session.activity.afterCleanup then
        local success, message = pcall(session.activity.afterCleanup,
            session.activity, session, reason)
        if not success then
            ok = false
            print("JTG final cleanup warning: " .. tostring(message))
        end
    end
    for index = #session.finalizers, 1, -1 do
        local success, message = pcall(session.finalizers[index], reason)
        if not success then
            ok = false
            print("JTG final cleanup warning: " .. tostring(message))
        end
    end
    session.finalizers = {}
    return ok
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
    -- Sweep orphaned native products before borrowed map state is restored.
    local swept, sweepMessage=pcall(JTG.CleanupSessionGeneratedUnits,session)
    if not swept then ok=false;print('JTG generated-unit cleanup warning: '..tostring(sweepMessage)) end
    if not JTG.DisposeScope(session.scope) then ok = false end
    if not RunActivityFinalizers(session, reason) then ok = false end
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
        finalizers = {},
        finalized = false,
    }
    controller.session = session
    controller.state = "setting_up"
    JTG.TrackSessionGeneratedUnits(session)
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
    if JTG.Training and JTG.Training.ResumeQuestHint then
        JTG.Training.ResumeQuestHint(session.activity,session)
    end
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
    local previous=JTG.Controller.session
    if previous and previous.id==id and reason~='briefing-restart' and reason~='new-crowd' then
        restartData=restartData or {}
        restartData._setupVisits=previous.restartData and previous.restartData._setupVisits
        restartData._questHelp=previous.restartData and previous.restartData._questHelp
    end
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
    restartData=restartData or {}
    restartData._setupVisits=session.restartData and session.restartData._setupVisits
    if id=='skills.body_blocking' and JTG.Training and JTG.Training.RecordBodyBlockingRedo then
        JTG.Training.RecordBodyBlockingRedo(session.activity,session,restartData)
    elseif (id=='skills.surround' or id=='skills.gargoyle') and JTG.Training and JTG.Training.RecordFailure then
        local movingToNext=session.activity.setupProgressionRequested==true
        local sameSetup=restartData.setupIndex==session.activity.setupIndex and
            restartData.runnerIndex==session.activity.runnerIndex
        if not movingToNext and sameSetup then JTG.Training.RecordFailure(session.activity,session,false) end
    end
    restartData._questHelp=session.restartData and session.restartData._questHelp
    -- Carry first-visit labels through direct and deferred resets alike.
    -- Exercises that recreate collision-sensitive setups at identical
    -- coordinates get one frame for Warcraft to retire the old footprints.
    -- Rebuilding directly in the click callback can otherwise make the next
    -- setup inherit stale placement or collision state.
    if id == "skills.gold_mine" or id == "skills.windwalk" or
            id == "skills.surround" or id == "skills.bat_splitter" or
            id == "skills.missile_dodging" then
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
    if session and session.activity and session.activity.previousStage then
        local ok, result = pcall(session.activity.previousStage, session.activity)
        return ok and result == true
    end
    if session == nil or session.activity == nil or
        session.activity.captureLastRunnerState == nil then return false end
    local captured, restartData = pcall(session.activity.captureLastRunnerState,
        session.activity, session)
    if not captured or restartData == nil then return false end
    local id, category = session.id, JTG.Controller.lastCategory
    restartData._setupVisits=session.restartData and session.restartData._setupVisits
    restartData._questHelp=session.restartData and session.restartData._questHelp
    local cameraDistance = nil
    if GetLocalPlayer() == Player(0) then
        cameraDistance = GetCameraField(CAMERA_FIELD_TARGET_DISTANCE)
    end
    if id == "skills.windwalk" then
        return JTG.StartActivityAfterCleanup(id, category, restartData,
            cameraDistance, "last-runner")
    end
    JTG.StopActivity("last-runner")
    return JTG.StartActivity(id, category, restartData, cameraDistance)
end

-- Result cards share their controls, while each activity decides what a
-- replay, redo or next step means for its own rules. Replay is reserved for
-- recorded playback; Redo resets the current exercise.
function JTG.ActivateResultAction(action)
    local session = JTG.Controller.session
    if session == nil or session.activity == nil then return false end
    local activity = session.activity
    local callback = activity.resultActions and activity.resultActions[action]
    if callback ~= nil then
        local ok, result = pcall(callback, activity, session)
        if not ok then
            print("JTG result-action warning: " .. tostring(result))
            return false
        end
        return result ~= false
    end
    if action == "menu" then
        return JTG.OpenTrainingMenu()
    elseif action == "retry" then
        return JTG.ResetActivity()
    elseif action == "hide" then
        if activity.restoreToolbarAfterResultHide ~= nil then
            activity:restoreToolbarAfterResultHide()
        elseif JTG.UI ~= nil then
            JTG.UI.ShowToolbar(session.descriptor.capabilities)
        end
        return true
    end
    return false
end

function JTG.ExitActivity()
    local category = JTG.Controller.lastCategory
    JTG.StopActivity("exit")
    if JTG.UI then JTG.UI.ShowCategory(category) end
end

-- Exit disposes gameplay but preserves the exact currently browsed menu page.
function JTG.ExitActivityFromMenu()
    local session=JTG.Controller.session
    local category=JTG.Controller.lastCategory or
        (session and session.descriptor and session.descriptor.category) or 'skills'
    local view=JTG.UI and JTG.UI.currentView
    JTG.StopActivity("menu-exit")
    if JTG.UI then JTG.UI.RestoreLoadedView(view or {kind='category',id=category}) end
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
