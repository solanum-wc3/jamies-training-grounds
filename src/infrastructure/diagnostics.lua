-- Development-only lifecycle proof. It is deliberately absent from catalogues.
JTG = JTG or {}

JTG.RegisterActivity({
    id = "dev.lifecycle",
    category = "skills",
    title = "Lifecycle Diagnostic",
    description = "Hidden resource ownership and stale-callback test.",
    status = "available",
    hidden = true,
    sceneId = "arena.south",
    capabilities = {restart = true, menu = true},
    factory = function(session)
        local activity = {}

        function activity:setup(current)
            JTG.BorrowCamera(current.scope, Player(0))
            JTG.MaskScene(current.scene, Player(0))
            JTG.ScopeAdd(current.scope, function()
                JTG.MaskScene(current.scene, Player(0))
            end)
            local unit = CreateUnit(Player(0), FourCC("hfoo"),
                current.scene.centerX, current.scene.centerY, 270)
            SetUnitInvulnerable(unit, true)
            JTG.ScopeTrackUnit(current.scope, unit)
            self.unit = unit
            self.pulses = 0

            local pulse = JTG.ScopeTrackTimer(current.scope, CreateTimer())
            TimerStart(pulse, 1.0, true, JTG.GuardSession(current, function()
                self.pulses = self.pulses + 1
            end))
        end

        function activity:start(current)
            if GetLocalPlayer() == Player(0) then
                SetCameraPosition(current.scene.centerX, current.scene.centerY)
                if JTG.defaultCameraDistance ~= nil then
                    SetCameraField(CAMERA_FIELD_TARGET_DISTANCE,
                        JTG.defaultCameraDistance, 0)
                end
                ClearSelection()
                SelectUnit(self.unit, true)
            end
            DisplayTimedTextToPlayer(Player(0), 0, 0, 15,
                "|cffffcc00Lifecycle diagnostic active.|r Restart must replace the unit; Training Menu must preserve it. " ..
                "Use -diag-status to inspect controller state.")
        end

        function activity:cleanup(current, reason)
            self.unit = nil
            self.pulses = nil
            print("JTG diagnostic cleanup: " .. tostring(reason))
        end

        return activity
    end,
})

function JTG.InitializeDiagnostics()
    local trigger = CreateTrigger()
    local commands = {"-diag-start", "-diag-reset", "-diag-exit", "-diag-status"}
    for _, command in ipairs(commands) do
        TriggerRegisterPlayerChatEvent(trigger, Player(0), command, true)
    end
    TriggerAddAction(trigger, function()
        local command = GetEventPlayerChatString()
        if command == "-diag-start" then
            JTG.StartActivity("dev.lifecycle", "skills")
        elseif command == "-diag-reset" then
            JTG.ResetActivity()
        elseif command == "-diag-exit" then
            JTG.ExitActivity()
        else
            local session = JTG.Controller.session
            local pulseText = ""
            if session and session.activity and session.activity.pulses ~= nil then
                pulseText = ", timer pulses: " .. tostring(session.activity.pulses)
            end
            DisplayTimedTextToPlayer(Player(0), 0, 0, 10,
                "JTG state: " .. JTG.Controller.state .. ", lifecycle generation: " ..
                tostring(JTG.Controller.generation) .. ", activity: " ..
                (session and session.id or "none") .. ", load restores: " ..
                tostring(JTG.loadRestoreCount or 0) .. pulseText)
        end
    end)
end
