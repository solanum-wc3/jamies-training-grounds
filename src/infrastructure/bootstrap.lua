-- Map bootstrap. Activity content is registered by the catalogue modules.
JTG = JTG or {}

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
    JTG.InitializeDiagnostics()
end

function InitTrig_Infrastructure()
    gg_trg_Infrastructure = CreateTrigger()
    TriggerAddAction(gg_trg_Infrastructure, function()
        local timer = CreateTimer()
        TimerStart(timer, 0.10, false, function()
            DestroyTimer(timer)
            JTG.Initialize()
        end)
    end)
end
