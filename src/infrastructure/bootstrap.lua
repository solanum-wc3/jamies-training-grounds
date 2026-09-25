-- Map bootstrap. No exercise or tutorial content belongs here.
JTG = JTG or {}

local function CreateInfrastructureQuests()
    local overview = CreateQuest()
    QuestSetTitle(overview, "Shared infrastructure test")
    QuestSetDescription(overview,
        "This development build tests the new Training Grounds navigation and activity lifecycle.\n\n" ..
        "Browse the four catalogues, Patch Notes and Credits. Planned content is visible but unavailable. " ..
        "Player Stats is intentionally deferred. The standard Quest window and F9 remain available.\n\n" ..
        "Developer commands:\n" ..
        "-diag-start: launch the hidden lifecycle test\n" ..
        "-diag-reset: rebuild its temporary resources\n" ..
        "-diag-exit: clean up and return to Skill Training\n" ..
        "-diag-status: show controller state\n\n" ..
        "No legacy profile is loaded or changed, and no exercise or tutorial is included.")
    QuestSetRequired(overview, false)
    QuestSetDiscovered(overview, true)
    QuestSetEnabled(overview, true)

    local credits = CreateQuest()
    QuestSetTitle(credits, "Credits")
    QuestSetDescription(credits,
        "Training project by Jamie and Solanum.\n" ..
        "Foundation terrain adapted from Twisted Meadows by McCandlish, MMC and W3Champions.")
    QuestSetRequired(credits, false)
    QuestSetDiscovered(credits, true)
    QuestSetEnabled(credits, true)
end

function JTG.Initialize()
    FogEnable(true)
    FogMaskEnable(true)
    BlzChangeMinimapTerrainTex("war3mapMap_ingame.blp")
    CreateInfrastructureQuests()
    JTG.UI.Initialize()
    JTG.InitializeDiagnostics()
    DisplayTimedTextToPlayer(Player(0), 0, 0, 12,
        "|cffffcc00Jamie's Training Grounds v0.0.2-alpha.31|r\nMenu and shared-infrastructure test. Choose a category from the Training Grounds menu.")
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
