-- Map bootstrap. Activity content is registered by the catalogue modules.
JTG = JTG or {}

function JTG.RestoreLoadedGame()
    if JTG.restoringLoadedGame then return end
    JTG.restoringLoadedGame = true
    JTG.loadRestoreCount = (JTG.loadRestoreCount or 0) + 1
    local controller = JTG.Controller
    local session = controller and controller.session
    local savedControllerState = controller and controller.state or "idle"
    local savedView = JTG.UI and JTG.UI.currentView or {kind = "root"}
    -- Loading can complete while either Warcraft or an exercise menu has the
    -- simulation paused. Rebuild immediately from EVENT_GAME_LOADED; a
    -- game-time timer would wait forever for the player to unpause first.
    PauseGame(false)
    if session ~= nil then
        if session.activity ~= nil and
                session.activity.discardPresentationForLoad ~= nil then
            session.activity:discardPresentationForLoad()
        end
        JTG.AbandonScope(session.presentationScope)
        session.presentationScope = JTG.CreateScope("presentation:" .. session.id)
    end
    if JTG.UI then JTG.UI.AbandonForLoad() end
    local ok, message = pcall(function()
        JTG.UI.Initialize(true)
        -- Leave the engine clock running only while Warcraft tears down the
        -- native Load interface and the replacement custom frames settle.
        JTG.UI.deferGlobalPause = true
        if session ~= nil and session.activity ~= nil and
                session.activity.rebuildPresentation ~= nil then
            session.activity:rebuildPresentation()
        end
        if controller ~= nil then controller.state = savedControllerState end
        JTG.UI.RestoreLoadedView(savedView)
        JTG.UI.QueuePostLoadViewRestore(savedView)
    end)
    JTG.restoringLoadedGame = false
    if not ok then
        if controller ~= nil then controller.state = "faulted" end
        if JTG.UI then JTG.UI.deferGlobalPause = false end
        PauseGame(false)
        print("JTG load restoration warning: " .. tostring(message))
    end
end

local function InstallLoadObserver()
    if JTG.loadObserver ~= nil then return end
    JTG.loadObserver = CreateTrigger()
    TriggerRegisterGameEvent(JTG.loadObserver, EVENT_GAME_LOADED)
    TriggerAddAction(JTG.loadObserver, JTG.RestoreLoadedGame)
end

function JTG.Initialize()
    -- Capture the player's configured starting distance before an exercise
    -- moves the camera. Later zooming must not change this default.
    if GetLocalPlayer() == Player(0) then
        JTG.defaultCameraDistance = GetCameraField(CAMERA_FIELD_TARGET_DISTANCE)
    end
    FogEnable(true)
    FogMaskEnable(true)
    BlzChangeMinimapTerrainTex("war3mapMap_ingame.blp")
    JTG.UI.Initialize()
    if not JTG.startupSoundPlayed then
        JTG.startupSoundPlayed=true
        JTG.UI.PlayFeedbackSound("startup")
    end
    for _, initializer in ipairs(JTG.BootstrapInitializers or {}) do
        local ok, message = pcall(initializer)
        if not ok then
            print("JTG optional-module initialization warning: " ..
                tostring(message))
        end
    end
end

function InitTrig_Infrastructure()
    -- Register synchronously. A save opened from Warcraft's front end can fire
    -- EVENT_GAME_LOADED before the ordinary delayed map bootstrap runs.
    InstallLoadObserver()
    gg_trg_Infrastructure = CreateTrigger()
    TriggerAddAction(gg_trg_Infrastructure, function()
        local timer = CreateTimer()
        TimerStart(timer, 0.10, false, function()
            DestroyTimer(timer)
            JTG.Initialize()
        end)
    end)
end
