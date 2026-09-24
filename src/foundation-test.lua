-- Temporary inspection harness for the terrain foundation, not the exercise system.
-- Keep this in the editor's custom-text trigger as well as the compiled map script.
-- All unit creation/movement is synchronized; camera and selection changes are local.
local foundationTestUnits = {}

local function FoundationHelp(p)
    DisplayTimedTextToPlayer(p, 0, 0, 25,
        "|cffffcc00Jamie's Training Grounds - v0.0.1-alpha.5|r\n" ..
        "Two empty practice spaces are in the northeast. Select the Grunt or Wind Rider to test movement.\n" ..
        "Chat: -arena1 / -arena2 / -south moves your test units; -help repeats this.\n" ..
        "The Quest menu contains these instructions. Exercise menus come later.")
end

local function FoundationVisitArena(p, which)
    local x, y = 4864, (which == 1 and 3456 or 6016)
    local pair = foundationTestUnits[GetPlayerId(p)]
    if pair then
        SetUnitPosition(pair[1], x - 160 + GetPlayerId(p) * 96, y)
        SetUnitPosition(pair[2], x + 160 + GetPlayerId(p) * 96, y)
    end
    if GetLocalPlayer() == p then
        PanCameraToTimed(x, y, 0)
        ClearSelection()
        if pair then SelectUnit(pair[1], true) end
    end
end

local function FoundationVisitSouth(p)
    local x, y = -4672, -3840
    local pair = foundationTestUnits[GetPlayerId(p)]
    if pair then
        SetUnitPosition(pair[1], x - 160, y)
        SetUnitPosition(pair[2], x + 160, y)
    end
    if GetLocalPlayer() == p then
        PanCameraToTimed(x, y, 0)
        ClearSelection()
        if pair then SelectUnit(pair[1], true) end
    end
end

function FoundationStart()
    -- No melee bases, starting workers/resources, AI, or victory/defeat registration.
    -- Standard fog and unexplored-map masking remain active for tutorial testing.
    FogEnable(true)
    FogMaskEnable(true)
    -- Reforged uses war3mapMap.blp for the browser thumbnail. Restore the real
    -- terrain minimap as soon as the playable map has initialized.
    BlzChangeMinimapTerrainTex("war3mapMap_ingame.blp")
    local q = CreateQuest()
    QuestSetTitle(q, "Foundation map test")
    QuestSetDescription(q,
        "The northeast contains two empty practice spaces with varied grass and earth terrain, " ..
        "surrounded by a raised perimeter. " ..
        "The perimeter blocks ground movement, flight, and construction. The strip between " ..
        "the two spaces is walkable so they can also be used as one larger arena.\n\n" ..
        "Select your Grunt to test ground movement and your Wind Rider to test flight.\n" ..
        "-arena1: move your test units to the southern practice space\n" ..
        "-arena2: move your test units to the northern practice space\n" ..
        "-south: move your test units to the preserved southwest area\n" ..
        "-help: repeat the instructions\n\n" ..
        "Normal fog of war and unexplored-map masking are active. There are no exercises or " ..
        "custom menus yet. Standard melee starting armies and automatic victory/defeat are disabled. " ..
        "The custom-game lobby contains one trainee slot with a selectable race. Exit with the normal game menu. " ..
        "Original terrain and placed objects outside the northeast work area are preserved.")
    QuestSetRequired(q, false)
    QuestSetDiscovered(q, true)
    QuestSetEnabled(q, true)
    local credits = CreateQuest()
    QuestSetTitle(credits, "Credits")
    QuestSetDescription(credits,
        "Training project by Jamie and Solanum.\n" ..
        "Foundation terrain adapted from Twisted Meadows by McCandlish, MMC and W3Champions.")
    QuestSetRequired(credits, false)
    QuestSetDiscovered(credits, true)
    QuestSetEnabled(credits, true)
    local commands = CreateTrigger()
    for i = 0, 0 do
        local p = Player(i)
        if GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING and
           GetPlayerController(p) == MAP_CONTROL_USER then
            local grunt = CreateUnit(p, FourCC("ogru"), 4704 + i * 96, 3456, 90)
            local flyer = CreateUnit(p, FourCC("owyv"), 5024 + i * 96, 3456, 90)
            SetUnitInvulnerable(grunt, true)
            SetUnitInvulnerable(flyer, true)
            foundationTestUnits[i] = {grunt, flyer}
            for _, command in ipairs({"-arena1", "-arena2", "-south", "-help"}) do
                TriggerRegisterPlayerChatEvent(commands, p, command, true)
            end
            FoundationVisitArena(p, 1)
            FoundationHelp(p)
        end
    end
    TriggerAddAction(commands, function()
        local p = GetTriggerPlayer()
        local command = GetEventPlayerChatString()
        if command == "-arena1" then FoundationVisitArena(p, 1)
        elseif command == "-arena2" then FoundationVisitArena(p, 2)
        elseif command == "-south" then FoundationVisitSouth(p)
        else FoundationHelp(p) end
    end)
end

function InitTrig_Foundation_Test()
    gg_trg_Foundation_Test = CreateTrigger()
    TriggerAddAction(gg_trg_Foundation_Test, function()
        -- Defer camera/selection work until the loading sequence has completed.
        local timer = CreateTimer()
        TimerStart(timer, 0.10, false, function()
            DestroyTimer(timer)
            FoundationStart()
        end)
    end)
end
