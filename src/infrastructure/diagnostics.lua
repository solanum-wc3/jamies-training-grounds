-- Development-only lifecycle probes and commands. This entire module is
-- omitted from release builds rather than merely hidden from their menus.
JTG = JTG or {}
JTG.Dev = JTG.Dev or {}

local PLAYER = Player(0)
local PROBE_A = "dev.lifecycle"
local PROBE_B = "dev.lifecycle_replacement"

local function IsProbeSession(session)
    return session ~= nil and
        (session.id == PROBE_A or session.id == PROBE_B)
end

local function CreateProbeFactory(unitId, label)
    return function(session)
        local activity = {
            label = label,
            pulses = 0,
            guardCalls = 0,
            cleanupReason = nil,
        }

        function activity:setup(current)
            local lifecycle = JTG.Dev.lifecycle
            if lifecycle == nil then
                lifecycle = {
                    running = false,
                    created = 0,
                    started = 0,
                    cleaned = 0,
                    disposed = 0,
                    presentationDisposed = 0,
                    cleanupReasons = {},
                    failures = {},
                }
                JTG.Dev.lifecycle = lifecycle
            end
            lifecycle.created = lifecycle.created + 1

            self.unit = JTG.ScopeTrackUnit(current.scope,
                CreateUnit(PLAYER, FourCC(unitId),
                    current.scene.centerX, current.scene.centerY, 270))
            SetUnitInvulnerable(self.unit, true)

            self.trigger = JTG.ScopeTrackTrigger(current.scope,
                CreateTrigger())
            TriggerRegisterUnitEvent(self.trigger, self.unit,
                EVENT_UNIT_SELECTED)

            self.guardedCallback = JTG.GuardSession(current, function()
                self.guardCalls = self.guardCalls + 1
            end)
            self.pulseTimer = JTG.ScopeTrackTimer(current.scope, CreateTimer())
            TimerStart(self.pulseTimer, 0.05, true,
                JTG.GuardSession(current, function()
                    self.pulses = self.pulses + 1
                end))

            JTG.ScopeAdd(current.scope, function()
                lifecycle.disposed = lifecycle.disposed + 1
            end)
            JTG.ScopeAdd(current.presentationScope, function()
                lifecycle.presentationDisposed =
                    lifecycle.presentationDisposed + 1
            end)
        end

        function activity:start()
            JTG.Dev.lifecycle.started = JTG.Dev.lifecycle.started + 1
        end

        function activity:cleanup(_, reason)
            self.cleanupReason = reason
            local lifecycle = JTG.Dev.lifecycle
            lifecycle.cleaned = lifecycle.cleaned + 1
            table.insert(lifecycle.cleanupReasons, tostring(reason))
        end

        return activity
    end
end

JTG.RegisterActivity({
    id = PROBE_A,
    category = "skills",
    title = "Lifecycle Diagnostic",
    description = "Development-only resource ownership probe.",
    status = "available",
    hidden = true,
    sceneId = "arena.south",
    capabilities = {},
    factory = CreateProbeFactory("hfoo", "primary"),
})

JTG.RegisterActivity({
    id = PROBE_B,
    category = "skills",
    title = "Lifecycle Replacement Diagnostic",
    description = "Development-only activity replacement probe.",
    status = "available",
    hidden = true,
    sceneId = "arena.south",
    capabilities = {},
    factory = CreateProbeFactory("ogru", "replacement"),
})

local function CopyView(view)
    if view == nil then return {kind = "root"} end
    return {
        kind = view.kind,
        id = view.id,
        category = view.category,
        page = view.page,
        data = view.data,
    }
end

local function RestoreDiagnosticView(lifecycle)
    if JTG.UI == nil then return end
    JTG.UI.RestoreLoadedView(lifecycle.savedView or {kind = "root"})
end

local function FinishLifecycleCheck(lifecycle)
    if lifecycle.timer ~= nil then
        PauseTimer(lifecycle.timer)
        DestroyTimer(lifecycle.timer)
        lifecycle.timer = nil
    end
    lifecycle.running = false
    local passed = #lifecycle.failures == 0
    lifecycle.lastPassed = passed
    lifecycle.lastReport = passed and
        "PASS: start, reset, replacement, exit, disposal and stale callbacks" or
        ("FAIL: " .. table.concat(lifecycle.failures, "; "))
    local color = passed and "|cff40ff40" or "|cffff4040"
    local heading = passed and "Lifecycle check passed" or
        "Lifecycle check failed"
    print("JTG automated lifecycle check " .. lifecycle.lastReport)
    DisplayTimedTextToPlayer(PLAYER, 0, 0, 20,
        color .. heading .. ".|r " .. lifecycle.lastReport)
    RestoreDiagnosticView(lifecycle)
end

local function RecordFailure(lifecycle, message)
    table.insert(lifecycle.failures, message)
end

local function Expect(lifecycle, condition, message)
    if not condition then RecordFailure(lifecycle, message) end
    return condition
end

local function AbortLifecycleCheck(lifecycle, message)
    RecordFailure(lifecycle, message)
    if IsProbeSession(JTG.Controller.session) then
        JTG.StopActivity("diagnostic-abort")
    end
    FinishLifecycleCheck(lifecycle)
end

local function AdvanceLifecycleCheck()
    local lifecycle = JTG.Dev.lifecycle
    if lifecycle == nil or not lifecycle.running then return end

    local ok, message = pcall(function()
        if lifecycle.step == 1 then
            local started, startMessage = JTG.StartActivity(PROBE_A, "skills")
            if not started then
                error("initial start failed: " .. tostring(startMessage))
            end
            lifecycle.firstSession = JTG.Controller.session
            lifecycle.firstActivity = lifecycle.firstSession.activity
            lifecycle.step = 2
        elseif lifecycle.step == 2 then
            Expect(lifecycle, JTG.Controller.state == "running",
                "initial activity did not enter running state")
            Expect(lifecycle, lifecycle.firstActivity.pulses > 0,
                "guarded activity timer did not run")
            local reset = JTG.ResetActivity()
            if not reset then error("reset command was rejected") end
            lifecycle.firstPulsesAfterReset =
                lifecycle.firstActivity.pulses
            lifecycle.step = 3
        elseif lifecycle.step == 3 then
            local first = lifecycle.firstActivity
            Expect(lifecycle, first.cleanupReason == "reset",
                "reset did not call semantic cleanup")
            Expect(lifecycle, GetUnitTypeId(first.unit) == 0,
                "reset left its tracked unit alive")
            Expect(lifecycle, first.pulses ==
                lifecycle.firstPulsesAfterReset,
                "reset left its tracked timer running")
            local calls = first.guardCalls
            first.guardedCallback()
            Expect(lifecycle, first.guardCalls == calls,
                "a stale guarded callback still ran after reset")
            local current = JTG.Controller.session
            Expect(lifecycle, current ~= nil and current ~= lifecycle.firstSession and
                current.id == PROBE_A and JTG.Controller.state == "running",
                "reset did not create a fresh session")
            lifecycle.secondSession = current
            lifecycle.secondActivity = current and current.activity or nil
            local replaced, replaceMessage = JTG.StartActivity(PROBE_B, "skills")
            if not replaced then
                error("replacement start failed: " .. tostring(replaceMessage))
            end
            lifecycle.replacementSession = JTG.Controller.session
            lifecycle.replacementActivity = lifecycle.replacementSession.activity
            lifecycle.secondPulsesAfterReplacement =
                lifecycle.secondActivity.pulses
            lifecycle.step = 4
        elseif lifecycle.step == 4 then
            local second = lifecycle.secondActivity
            Expect(lifecycle, second ~= nil and second.cleanupReason == "replace",
                "activity replacement did not call semantic cleanup")
            Expect(lifecycle, second ~= nil and GetUnitTypeId(second.unit) == 0,
                "activity replacement left its tracked unit alive")
            Expect(lifecycle, second ~= nil and second.pulses ==
                lifecycle.secondPulsesAfterReplacement,
                "activity replacement left its tracked timer running")
            Expect(lifecycle, JTG.Controller.session ==
                lifecycle.replacementSession and
                JTG.Controller.session.id == PROBE_B and
                JTG.Controller.state == "running",
                "replacement activity did not enter running state")
            Expect(lifecycle, lifecycle.replacementActivity.pulses > 0,
                "replacement activity timer did not run")
            JTG.StopActivity("diagnostic-finished")
            lifecycle.replacementPulsesAfterExit =
                lifecycle.replacementActivity.pulses
            lifecycle.step = 5
        elseif lifecycle.step == 5 then
            local replacement = lifecycle.replacementActivity
            Expect(lifecycle, replacement.cleanupReason ==
                "diagnostic-finished",
                "exit did not call semantic cleanup")
            Expect(lifecycle, GetUnitTypeId(replacement.unit) == 0,
                "exit left its tracked unit alive")
            Expect(lifecycle, replacement.pulses ==
                lifecycle.replacementPulsesAfterExit,
                "exit left its tracked timer running")
            Expect(lifecycle, JTG.Controller.session == nil and
                JTG.Controller.state == "idle",
                "controller did not return to idle")
            Expect(lifecycle, lifecycle.created == 3 and
                lifecycle.started == 3 and lifecycle.cleaned == 3 and
                lifecycle.disposed == 3 and
                lifecycle.presentationDisposed == 3,
                "lifecycle callback counts did not balance")
            FinishLifecycleCheck(lifecycle)
        end
    end)
    if not ok then AbortLifecycleCheck(lifecycle, tostring(message)) end
end

function JTG.RunAutomatedLifecycleCheck()
    local existing = JTG.Dev.lifecycle
    if existing ~= nil and existing.running then
        DisplayTimedTextToPlayer(PLAYER, 0, 0, 8,
            "|cffffcc00Lifecycle check is already running.|r")
        return false
    end
    if JTG.Controller.session ~= nil then
        DisplayTimedTextToPlayer(PLAYER, 0, 0, 10,
            "|cffffcc00Exit the current activity before running the lifecycle check.|r")
        return false
    end

    local lifecycle = {
        running = true,
        step = 1,
        created = 0,
        started = 0,
        cleaned = 0,
        disposed = 0,
        presentationDisposed = 0,
        cleanupReasons = {},
        failures = {},
        savedView = CopyView(JTG.UI and JTG.UI.currentView),
    }
    JTG.Dev.lifecycle = lifecycle
    lifecycle.timer = CreateTimer()
    TimerStart(lifecycle.timer, 0.20, true, AdvanceLifecycleCheck)
    DisplayTimedTextToPlayer(PLAYER, 0, 0, 8,
        "|cffffcc00Automated lifecycle check started.|r")
    return true
end

function JTG.CancelAutomatedLifecycleCheck()
    local lifecycle = JTG.Dev.lifecycle
    if lifecycle == nil or not lifecycle.running then return false end
    if IsProbeSession(JTG.Controller.session) then
        JTG.StopActivity("diagnostic-cancelled")
    end
    RecordFailure(lifecycle, "cancelled")
    FinishLifecycleCheck(lifecycle)
    return true
end

local function ShowDiagnosticStatus()
    local lifecycle = JTG.Dev.lifecycle
    local lifecycleText = "not run"
    if lifecycle ~= nil then
        if lifecycle.running then
            lifecycleText = "running step " .. tostring(lifecycle.step)
        elseif lifecycle.lastReport ~= nil then
            lifecycleText = lifecycle.lastReport
        end
    end
    local session = JTG.Controller.session
    DisplayTimedTextToPlayer(PLAYER, 0, 0, 15,
        "JTG development build | controller: " ..
        tostring(JTG.Controller.state) .. " | generation: " ..
        tostring(JTG.Controller.generation) .. " | activity: " ..
        (session and session.id or "none") .. " | lifecycle: " ..
        lifecycleText)
end

function JTG.InitializeDiagnostics()
    local trigger = CreateTrigger()
    local commands = {
        "-diag-start", "-diag-reset", "-diag-exit", "-diag-status",
        "-diag-lifecycle", "-diag-cancel",
    }
    for _, command in ipairs(commands) do
        TriggerRegisterPlayerChatEvent(trigger, PLAYER, command, true)
    end
    TriggerAddAction(trigger, function()
        local command = GetEventPlayerChatString()
        if command == "-diag-start" then
            JTG.StartActivity(PROBE_A, "skills")
        elseif command == "-diag-reset" then
            JTG.ResetActivity()
        elseif command == "-diag-exit" then
            JTG.ExitActivity()
        elseif command == "-diag-lifecycle" then
            JTG.RunAutomatedLifecycleCheck()
        elseif command == "-diag-cancel" then
            JTG.CancelAutomatedLifecycleCheck()
        else
            ShowDiagnosticStatus()
        end
    end)
    JTG.Dev.commandTrigger = trigger
    DisplayTimedTextToPlayer(PLAYER, 0, 0, 12,
        "|cffffcc00Development build.|r Enter -diag-lifecycle to run " ..
        "the automated lifecycle check.")
end

JTG.RegisterBootstrapInitializer(JTG.InitializeDiagnostics)
