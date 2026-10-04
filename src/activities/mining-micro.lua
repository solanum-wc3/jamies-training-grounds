-- Mining Micro: compare an optimized four-worker mine against fixed four- and
-- five-worker references. Human and Orc catalogue entries share this activity;
-- the selected race is carried through the briefing and every restart.
JTG = JTG or {}

local RACES = {
    human = {race = RACE_HUMAN, hall = FourCC("htow"), worker = FourCC("hpea")},
    orc = {race = RACE_ORC, hall = FourCC("ogre"), worker = FourCC("opeo")},
}

local MINING_MICRO_INTRO =
    "In some situations, such as when mining with less than 5 workers, " ..
    "the game slows down the movement speed of Human and Orc gold " ..
    "workers, to normalize gold income.|n|n" ..
    "By manually giving mining orders, you can temporarily bypass that " ..
    "slowdown.|n|n" ..
    "With four workers - especially on short, diagonal mine positions - " ..
    "this can recover much of the income you'd normally need five workers " ..
    "for, freeing up a worker to build or to harvest lumber, which can give " ..
    "you an edge in the early game.|n|n" ..
    "Here, you can train this micro skill.|n" ..
    "Check the Quest log for tips on how to do it!"

local QUEST_ICONS = {
    slowdown = "ReplaceableTextures\\CommandButtons\\BTNMove.blp",
    humanIndividual = "ReplaceableTextures\\CommandButtons\\BTNPeasant.blp",
    orcIndividual = "ReplaceableTextures\\CommandButtons\\BTNPeon.blp",
    humanPairs = "ReplaceableTextures\\CommandButtons\\BTNMilitia.blp",
    orcPairs = "ReplaceableTextures\\CommandButtons\\BTNPillage.blp",
    humanMaster = "ReplaceableTextures\\CommandButtons\\BTNHolyBolt.blp",
    orcMaster = "ReplaceableTextures\\CommandButtons\\BTNCommand.blp",
}

local QUESTS = {
    {
        title = "The Slowdown Mechanic",
        icon = "slowdown",
        text = "Your worker gets slowed down after his first mining cycle - " ..
            "the trip from the gold mine to the main building and back to " ..
            "the gold mine - is completed. Once he comes out of the mine " ..
            "again, he is slowed.|n|n" ..
            "If you give the slowed worker a manual {Term: Gather} or " ..
            "{Term: Return Resource} command, the slow stops until another " ..
            "cycle is completed.|n|n" ..
            "If you give the command before he enters the mine for the " ..
            "second time, this will reset the cycle, and delay the slowdown.",
    },
    {
        title = "The Individual Method",
        humanIcon = "humanIndividual",
        orcIcon = "orcIndividual",
        text = "After a worker drops off his gold, select him, and right-click " ..
            "the Gold Mine.|nAlternatively, before he drops off his gold, " ..
            "right-click the main building, or give him a {Term: Return " ..
            "Resource} command.|n|n" ..
            "This resets the gather cycle and delays the slowdown.|n|n" ..
            "It has to be done for every worker on every trip, to " ..
            "consistently keep them at maximum speed.",
    },
    {
        title = "Two-worker pairs",
        humanIcon = "humanPairs",
        orcIcon = "orcPairs",
        text = "When you have selected several workers, some of whom carry " ..
            "gold, and some of whom do not, they share the same button and " ..
            "hotkey for the {Term: Gather} and {Term: Return Resource} " ..
            "commands.|nThe game remembers what the next action in their " ..
            "gather cycle was, so when you give the command, the one with " ..
            "the gold will return it to the main building, and the one " ..
            "without will enter the gold mine.|n|n" ..
            "This method consists of the player box-selecting two workers in " ..
            "a gathering cycle, one carrying gold, one not carrying gold, " ..
            "and giving them the shared command.|n|n" ..
            "Since the player gives the command to two workers, they only " ..
            "have to do this half as often as with the individual method.",
    },
    {
        title = "Master Class",
        humanIcon = "humanMaster",
        orcIcon = "orcMaster",
        text = "When mining, workers do not collide with each other.|nWhen " ..
            "workers are given manual commands however, they gain collision " ..
            "again for a moment, which can make them instantly push away " ..
            "from other workers.|n|n" ..
            "With perfect timing, this allows the player to further speed up " ..
            "the worker's movement, by basically teleporting them part of " ..
            "the way.|nWith bad timing, it can move the workers away from " ..
            "their goal, and make them collide with each other.",
    },
}

local function FormatQuestText(text)
    return string.gsub(text, "{Term:%s*(.-)}", "|cffff9933%1|r")
end

local STARTING_MINE_GOLD = 12500
local TRAINING_TREE_LIFE = 1000.0
local ARENA_CENTER_X = 4864.0
local ARENA_CENTER_Y = 6016.0
-- Twisted Meadows' top-left start is (-3584, 4480), with its closest mine at
-- (-4096, 5056): the mine is exactly 512 left and 576 above the start.
-- Its nearest tree in the top-right lumber line is 192 right and 704 above
-- the start, which supplies the matching realistic tree offset used below.
local LANE_LAYOUT = {
    {startX = 3840.0, startY = 5824.0, mineX = 3328.0, mineY = 6400.0},
    {startX = 4992.0, startY = 5824.0, mineX = 4480.0, mineY = 6400.0,
        treeX = 5184.0, treeY = 6528.0},
    {startX = 6144.0, startY = 5824.0, mineX = 5632.0, mineY = 6400.0,
        treeX = 6336.0, treeY = 6528.0},
}

local function RotateOffset(x, y, orientation)
    if orientation == 1 then return y, -x end
    if orientation == 2 then return -x, -y end
    if orientation == 3 then return -y, x end
    return x, y
end

local function ResolveLaneLayout(base, orientation)
    local mineOffsetX, mineOffsetY = RotateOffset(
        base.mineX - base.startX, base.mineY - base.startY, orientation)
    local layout = {
        startX = base.startX,
        startY = base.startY,
        mineX = base.startX + mineOffsetX,
        mineY = base.startY + mineOffsetY,
    }
    if base.treeX ~= nil then
        local treeOffsetX, treeOffsetY = RotateOffset(
            base.treeX - base.startX, base.treeY - base.startY, orientation)
        layout.treeX = base.startX + treeOffsetX
        layout.treeY = base.startY + treeOffsetY
    end
    return layout
end

local function SetTrainingTreeLife(tree)
    -- JTtr is a map-owned Lordaeron Summer Tree whose object data gives it
    -- 1,000 maximum life. Set current life as well for deterministic restarts.
    SetDestructableLife(tree, TRAINING_TREE_LIFE)
end

function JTG.OpenMiningMicroMenu(originCategory, pauseGame, restorePage, restoreData)
    local active = JTG.Controller.session
    local returningFromActiveRun = active ~= nil and
        active.id == "skills.gold_mine"
    local activeData = active and active.id == "skills.gold_mine" and
        active.restartData or nil
    local selection = {race = "human"}
    for key, value in pairs(activeData or {}) do selection[key] = value end
    for key, value in pairs(restoreData or {}) do selection[key] = value end
    -- A complete exit starts a new exercise session and should show the Quest
    -- prompt again. Only a restart launched from the current run suppresses it.
    selection.skipQuestHighlight = nil
    if RACES[selection.race] == nil then selection.race = "human" end

    local function releaseMenuPause()
        if JTG.UI then JTG.UI.SetGameplayMenuPaused(false) end
    end
    local function resumeCurrentRun()
        releaseMenuPause()
        JTG.ResumeActivity()
    end
    local function launch()
        releaseMenuPause()
        local restartData = {
            race = selection.race,
            orientation = GetRandomInt(0, 3),
            skipQuestHighlight = returningFromActiveRun,
        }
        if JTG.Controller.session ~= nil then
            JTG.StartActivityAfterCleanup("skills.gold_mine",
                originCategory or "skills", restartData, nil,
                "briefing-restart")
        else
            JTG.StartActivity("skills.gold_mine",
                originCategory or "skills", restartData)
        end
    end
    local function showBriefing()
        local spec = {
            title = "Mining Micro",
            activityId = "skills.gold_mine",
            originCategory = originCategory or "skills",
            headingArtwork = "JTGMenu\\GoldMineMicroBriefing.dds",
            headingArtworkWidth = 0.176,
            headingArtworkHeight = 0.086,
            body = MINING_MICRO_INTRO,
            choices = {{label = "Start Training", primary = true, action = launch}},
            centerSingleChoice = true,
            backAction = function() JTG.UI.ShowSkillRace(selection.race) end,
            pauseGame = pauseGame == true,
            pageId = "root",
            restoreData = selection,
        }
        if pauseGame then
            spec.resumeAction = resumeCurrentRun
            spec.exitAction = function()
                JTG.StopActivity("menu-exit")
                returningFromActiveRun = false
                pauseGame = false
                showBriefing()
            end
        end
        JTG.UI.ShowActivityBriefing(spec)
    end
    showBriefing()
end

function JTG.CreateMiningMicroActivity(session)
    local selection = session.restartData or {}
    local activity = {
        race = RACES[selection.race] and selection.race or "human",
        orientation = math.floor(tonumber(selection.orientation) or 0) % 4,
        lanes = {},
        playerGoldMined = 0,
        previousPlayerGold = 0,
        locallyPaused = false,
        highlightQuestOnStart = selection.skipQuestHighlight ~= true,
    }
    local race = RACES[activity.race]

    function activity:setPaused(paused)
        self.locallyPaused = paused == true
    end

    function activity:createTrainingQuests()
        self.quests = {}
        for index, data in ipairs(QUESTS) do
            local quest = JTG.ScopeTrackQuest(session.scope, CreateQuest())
            local iconKey = data.icon or
                (self.race == "human" and data.humanIcon or data.orcIcon)
            QuestSetTitle(quest, data.title)
            QuestSetDescription(quest, FormatQuestText(data.text))
            QuestSetIconPath(quest, QUEST_ICONS[iconKey])
            QuestSetRequired(quest, index == 1)
            QuestSetDiscovered(quest, true)
            QuestSetEnabled(quest, true)
            table.insert(self.quests, quest)
        end
    end

    function activity:updateLaneCounter(index)
        local lane = self.lanes[index]
        if lane == nil or lane.counterFrame == nil then return end
        local gold
        if index == 2 then gold = self.playerGoldMined
        else gold = GetPlayerState(lane.owner, PLAYER_STATE_RESOURCE_GOLD) end
        local lumber = GetPlayerState(lane.owner, PLAYER_STATE_RESOURCE_LUMBER)
        local heading = index == 2 and "   |cffffffffYou|r|n|n" or ""
        local comparison = ""
        if index >= 2 then
            local referenceGold = GetPlayerState(
                self.lanes[1].owner, PLAYER_STATE_RESOURCE_GOLD)
            local differencePercent = 0.0
            if referenceGold > 0 then
                differencePercent = (gold - referenceGold) * 100.0 /
                    referenceGold
            end
            comparison = string.format(" (%+.1f%%)", differencePercent)
        end
        BlzFrameSetText(lane.counterFrame,
            heading .. "|cff40c8ff" .. tostring(lane.miningWorkers) .. " Workers Mining|r|n|n" ..
            "|cffffcc00Gold Mined: " .. tostring(gold) .. comparison .. "|r|n|n" ..
            "|cff80ff80Lumber Harvested: " .. tostring(lumber) .. "|r")
    end

    function activity:updateCounters()
        if self.locallyPaused then return end
        local currentGold = GetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD)
        if currentGold > self.previousPlayerGold then
            self.playerGoldMined = self.playerGoldMined +
                (currentGold - self.previousPlayerGold)
        end
        self.previousPlayerGold = currentGold
        for index = 1, 3 do self:updateLaneCounter(index) end
    end

    function activity:setOverlayVisible(visible)
        for _, lane in ipairs(self.lanes) do
            if lane.counterFrame ~= nil then
                BlzFrameSetVisible(lane.counterFrame, visible == true)
            end
        end
    end

    function activity:createLaneCounter(lane, index)
        local gameUI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        lane.counterFrame = JTG.ScopeTrackFrame(session.presentationScope,
            BlzCreateFrameByType("TEXT", "JTGMiningCounter" .. tostring(index),
                gameUI, "", 0))
        BlzFrameSetSize(lane.counterFrame, 0.220, index == 2 and 0.120 or 0.105)
        BlzFrameSetAbsPoint(lane.counterFrame, FRAMEPOINT_TOPLEFT,
            0.012, 0.505 - (index - 1) * 0.125)
        BlzFrameSetTextAlignment(lane.counterFrame,
            TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
        BlzFrameSetScale(lane.counterFrame, 1.48)
        BlzFrameSetEnable(lane.counterFrame, false)
        BlzFrameSetVisible(lane.counterFrame, true)
        self:updateLaneCounter(index)
    end

    function activity:captureMeleeStart(lane)
        local group = CreateGroup()
        GroupEnumUnitsInRange(group, lane.startX, lane.startY, 700.0, nil)
        while true do
            local unit = FirstOfGroup(group)
            if unit == nil then break end
            GroupRemoveUnit(group, unit)
            if GetOwningPlayer(unit) == lane.owner then
                local unitType = GetUnitTypeId(unit)
                if unitType == race.hall then
                    lane.hall = JTG.ScopeTrackUnit(session.scope, unit)
                elseif unitType == race.worker then
                    table.insert(lane.workers,
                        JTG.ScopeTrackUnit(session.scope, unit))
                end
            end
        end
        DestroyGroup(group)
        table.sort(lane.workers, function(left, right)
            return GetUnitX(left) > GetUnitX(right)
        end)
        assert(lane.hall ~= nil, "Melee start did not create a main building")
        assert(#lane.workers == 5, "Melee start did not create five workers")
    end

    function activity:issueOpeningOrders()
        -- Match an ordinary opening first, then redirect only the rightmost
        -- worker in the middle and right comparisons to lumber.
        for _, lane in ipairs(self.lanes) do
            for _, worker in ipairs(lane.workers) do
                IssueTargetOrder(worker, "harvest", lane.mine)
            end
        end
        for index = 2, 3 do
            local lane = self.lanes[index]
            IssueTargetOrder(lane.workers[1], "harvest", lane.tree)
        end
    end

    function activity:createScenario()
        local owners = {Player(1), Player(0), Player(2)}
        local miningWorkers = {5, 4, 4}

        local previousStarts = {}
        for index = 1, 3 do
            local layout = ResolveLaneLayout(LANE_LAYOUT[index], self.orientation)
            local owner = owners[index]
            local startIndex = GetPlayerId(owner)
            previousStarts[index] = {
                startIndex = startIndex,
                x = GetStartLocationX(startIndex),
                y = GetStartLocationY(startIndex),
                assigned = GetPlayerStartLocation(owner),
            }
            DefineStartLocation(startIndex, layout.startX, layout.startY)
            SetPlayerStartLocation(owner, startIndex)
        end
        JTG.ScopeBorrow(session.scope, function()
            for index = 1, 3 do
                local owner = owners[index]
                local previous = previousStarts[index]
                DefineStartLocation(previous.startIndex, previous.x, previous.y)
                SetPlayerStartLocation(owner, previous.assigned)
            end
        end)

        -- Mines must exist before Warcraft resolves the closest mine for each
        -- start. No workers or halls exist yet, so their fixed footprints are
        -- never displaced by the other exercise units.
        for index = 1, 3 do
            local layout = ResolveLaneLayout(LANE_LAYOUT[index], self.orientation)
            local lane = {
                owner = owners[index], startX = layout.startX,
                startY = layout.startY,
                mineX = layout.mineX, mineY = layout.mineY,
                miningWorkers = miningWorkers[index], workers = {},
            }
            lane.mine = JTG.ScopeTrackUnit(session.scope,
                CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), FourCC("ngol"),
                    lane.mineX, lane.mineY, 270.0))
            SetResourceAmount(lane.mine, STARTING_MINE_GOLD)
            self.lanes[index] = lane
        end

        for index = 1, 3 do
            local layout = ResolveLaneLayout(LANE_LAYOUT[index], self.orientation)
            local lane = self.lanes[index]
            local startLocation = Location(lane.startX, lane.startY)
            MeleeStartingUnitsForPlayer(race.race, lane.owner,
                startLocation, false)
            RemoveLocation(startLocation)
            self:captureMeleeStart(lane)
            if index >= 2 then
                lane.tree = JTG.ScopeTrackDestructable(session.scope,
                    CreateDestructable(FourCC("JTtr"),
                        layout.treeX, layout.treeY,
                        270.0, 1.0, 0))
                SetTrainingTreeLife(lane.tree)
            end
        end
        for index, lane in ipairs(self.lanes) do self:createLaneCounter(lane, index) end
        ClearSelection()
        self:issueOpeningOrders()
    end

    function activity:setup(current)
        local p0 = Player(0)
        JTG.BorrowCamera(current.scope, p0)

        local saved = {}
        for ownerIndex = 0, 2 do
            local owner = Player(ownerIndex)
            saved[ownerIndex] = {
                gold = GetPlayerState(owner, PLAYER_STATE_RESOURCE_GOLD),
                lumber = GetPlayerState(owner, PLAYER_STATE_RESOURCE_LUMBER),
                controller = GetPlayerController(owner),
                workerLimit = GetPlayerTechMaxAllowed(owner, race.worker),
                alliances = {},
            }
            for otherIndex = 0, 2 do
                saved[ownerIndex].alliances[otherIndex] = GetPlayerAlliance(
                    owner, Player(otherIndex), ALLIANCE_PASSIVE)
            end
        end
        JTG.ScopeBorrow(current.scope, function()
            for ownerIndex = 0, 2 do
                local owner = Player(ownerIndex)
                local state = saved[ownerIndex]
                SetPlayerState(owner, PLAYER_STATE_RESOURCE_GOLD, state.gold)
                SetPlayerState(owner, PLAYER_STATE_RESOURCE_LUMBER, state.lumber)
                SetPlayerController(owner, state.controller)
                SetPlayerTechMaxAllowed(owner, race.worker, state.workerLimit)
                for otherIndex = 0, 2 do
                    SetPlayerAlliance(owner, Player(otherIndex), ALLIANCE_PASSIVE,
                        state.alliances[otherIndex])
                end
            end
        end)
        SetPlayerController(Player(1), MAP_CONTROL_COMPUTER)
        SetPlayerController(Player(2), MAP_CONTROL_COMPUTER)
        for ownerIndex = 0, 2 do
            local owner = Player(ownerIndex)
            SetPlayerState(owner, PLAYER_STATE_RESOURCE_GOLD, 0)
            SetPlayerState(owner, PLAYER_STATE_RESOURCE_LUMBER, 0)
            SetPlayerTechMaxAllowed(owner, race.worker, 5)
            for otherIndex = 0, 2 do
                SetPlayerAlliance(owner, Player(otherIndex), ALLIANCE_PASSIVE, true)
            end
        end

        JTG.ResetWorldFog(p0)
        JTG.ScopeRevealScene(current.scope, current.scene, p0)

        self.previousPlayerGold = 0
        self:createScenario()
        self:createTrainingQuests()
        self.updateTimer = JTG.StartScopedTimer(current, current.scope,
            0.10, true, function() self:updateCounters() end)
    end

    function activity:start(current)
        if GetLocalPlayer() == Player(0) then
            SetCameraPosition(ARENA_CENTER_X, ARENA_CENTER_Y)
        end
        if self.highlightQuestOnStart and JTG.UI and
                JTG.UI.HighlightQuestButton then
            JTG.UI.HighlightQuestButton(5.0)
        end
    end

    function activity:captureResetState()
        return {
            race = self.race,
            orientation = self.orientation,
            skipQuestHighlight = true,
        }
    end

    function activity:captureRotatedState()
        return {
            race = self.race,
            orientation = (self.orientation + 1) % 4,
            skipQuestHighlight = true,
        }
    end

    function activity:restorePresentation()
        self:setOverlayVisible(true)
        if JTG.UI then JTG.UI.ShowToolbar(session.descriptor.capabilities) end
    end

    function activity:hidePresentationForMenu()
        self:setOverlayVisible(false)
    end

    function activity:rebuildPresentation()
        for index, lane in ipairs(self.lanes) do
            lane.counterFrame = nil
            self:createLaneCounter(lane, index)
        end
    end

    function activity:discardPresentationForLoad()
        for _, lane in ipairs(self.lanes) do
            if lane.counterFrame ~= nil then BlzDestroyFrame(lane.counterFrame) end
            lane.counterFrame = nil
        end
    end

    function activity:cleanup()
        if JTG.UI then JTG.UI.HideActivityBriefing() end
        self.lanes = {}
    end

    return activity
end
