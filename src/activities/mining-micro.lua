-- Mining Micro: compare an optimized four-worker mine against fixed four- and
-- five-worker references. Human and Orc catalogue entries share this activity;
-- the selected race is carried through the briefing and every restart.
JTG = JTG or {}

local RACES = {
    human = {race = RACE_HUMAN, hall = FourCC("htow"), worker = FourCC("hpea")},
    orc = {race = RACE_ORC, hall = FourCC("ogre"), worker = FourCC("opeo")},
}

local MINING_MICRO_INTRO =
    "When mining with less than 5 workers, the game slows down the movement speed of Human and Orc gold workers, to normalize gold income.\n\nBy manually giving mining orders, you can temporarily bypass that slowdown.\n\nWith four workers - especially on short, diagonal mine positions - this can recover much of the income you'd normally need five workers for, freeing up a worker to build, or to harvest lumber, which can give you an edge in the early game.\n\nHere, you can train this micro skill, while your income is compared to mines that do not micro their workers.\n\nCheck the {Button: Quest Log} for explanations on how to do it!"

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
            "second time, this will reset the cycle, and delay the slowdown." ..
            "|n|nThis slowdown only happens for mines with less than 5 workers, " ..
            "and it only happens for Humans and Orcs. You cannot raise " ..
            "efficiency in Undead or Night Elf gold mines, nor in Human " ..
            "or Orc gold mines with five workers.",
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
            "This method consists of the player {Input: box-selecting two workers} in " ..
            "a gathering cycle, one carrying gold, one not carrying gold, " ..
            "and giving them the shared command.|n|n" ..
            "Since the player gives the command to two workers, they only " ..
            "have to do this half as often as with the individual method.",
    },
    {
        title = "Master Class",
        humanIcon = "humanMaster",
        orcIcon = "orcMaster",
        text = "When mining gold, workers have no collision.|n" ..
            "However a unit that has no collision regains collision instantly " ..
            "when given a command. If this happens while they are inside " ..
            "another unit, both will regain collision, and it will make them " ..
            "push away from each other.|n|n" ..
            "Using this with perfect timing allows the player to further " ..
            "raise worker efficiency by effectively teleporting them part " ..
            "of the trip.|nBad timing however can cost efficiency, by making " ..
            "workers run into each other or moving them away from their target.",
    },
}

local function FormatQuestText(text)
    local formatted = string.gsub(text, "{Term:%s*(.-)}", "|cffff9933%1|r")
    return string.gsub(formatted, "{Input:%s*(.-)}", "|cffffcc00%1|r")
end

local STARTING_MINE_GOLD = 12500
local TRAINING_TREE_LIFE = 1000.0
local ARENA_CENTER_X = 4864.0
local ARENA_CENTER_Y = 6016.0
-- Every lane is an exact copy of one mine-anchored Twisted Meadows layout.
-- Keeping the mines fixed and rotating all other pieces together avoids the
-- small placement corrections made by Warcraft's melee-start generator.
local MINE_ANCHORS = {
    {x = 3456.0, y = 5888.0},
    {x = 4864.0, y = 5888.0},
    {x = 6272.0, y = 5888.0},
}
local HALL_OFFSET = {x = 512.0, y = -576.0}
local TREE_OFFSET = {x = 704.0, y = 128.0}
local TREE_OFFSETS = {TREE_OFFSET,{x=832.0,y=128.0},{x=704.0,y=256.0}}
-- Five evenly spaced workers sit on the mine-to-hall line used by a normal
-- melee opening. Their order is stable; worker 1 becomes the lumber worker in
-- the two four-worker comparison lanes.
local WORKER_OFFSETS = {
    {x = 117.0, y = -324.0},
    {x = 165.0, y = -282.0},
    {x = 213.0, y = -239.0},
    {x = 261.0, y = -197.0},
    {x = 309.0, y = -154.0},
}

local function RotateOffset(x, y, orientation)
    if orientation == 1 then return y, -x end
    if orientation == 2 then return -x, -y end
    if orientation == 3 then return -y, x end
    return x, y
end

local function ResolveLaneLayout(anchor, orientation)
    local hallOffsetX, hallOffsetY = RotateOffset(
        HALL_OFFSET.x, HALL_OFFSET.y, orientation)
    local layout = {
        mineX = anchor.x,
        mineY = anchor.y,
        hallX = anchor.x + hallOffsetX,
        hallY = anchor.y + hallOffsetY,
        workers = {},
        trees = {},
    }
    for _,offset in ipairs(TREE_OFFSETS) do
        local x,y=RotateOffset(offset.x,offset.y,orientation)
        layout.trees[#layout.trees+1]={x=anchor.x+x,y=anchor.y+y}
    end
    for index, offset in ipairs(WORKER_OFFSETS) do
        local workerOffsetX, workerOffsetY = RotateOffset(
            offset.x, offset.y, orientation)
        layout.workers[index] = {
            x = anchor.x + workerOffsetX,
            y = anchor.y + workerOffsetY,
        }
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
            duration = selection.duration,
            baseBuild = selection.baseBuild,
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
    local showBriefing
    showBriefing = function(page)
        local spec = {
            title = "Mining Micro",
            activityId = "skills.gold_mine",
            originCategory = originCategory or "skills",
            headingArtwork = "JTGMenu\\GoldMineMicroBriefing.dds",
            headingArtworkWidth = 0.176,
            headingArtworkHeight = 0.086,
            body = JTG.Tutorial.FormatNarration(MINING_MICRO_INTRO),
            choices = {
                {label="Human",action=function() selection.race="human"; showBriefing('duration') end},
                {label="Orc",action=function() selection.race="orc"; showBriefing('duration') end},
            },
            backAction = function() JTG.UI.ShowCategory("skills") end,
            pauseGame = pauseGame == true,
            pageId = "root",
            restoreData = selection,
        }
        if page=='duration' then
            spec.body='Choose a practice mode.'
            spec.pageId='duration'
            spec.choices={
                {label='One Minute',tooltip='Try mitigating as much of the lost mining potential as possible in one minute.',action=function() selection.baseBuild=false;selection.duration=60;launch() end},
                {label='Unlimited',tooltip='Train mining micro for as long as you want.',action=function() selection.baseBuild=false;selection.duration=nil;launch() end},
                {label='Build Order',tooltip='Start with regular starting resources and try to use mining micro while following your regular build order. The exercise ends once you send a fifth worker into the gold mine.',action=function() selection.baseBuild=true;selection.duration=nil;launch() end}}
            spec.backAction=function() showBriefing('root') end
        end
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
    showBriefing(restorePage)
end

function JTG.CreateMiningMicroActivity(session)
    local selection = session.restartData or {}
    local activity = {
        race = RACES[selection.race] and selection.race or "human",
        orientation = math.floor(tonumber(selection.orientation) or 0) % 4,
        lanes = {},
        playerGoldMined = 0,
        baseBuild = selection.baseBuild==true,
        duration = selection.baseBuild~=true and selection.duration==60 and 60 or nil,
        elapsed = 0,
        playerLumberMined = 0,
        presentationVisible = true,
        finished = false,
        gatheringStart = {},
        goldWorkers = {},
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
        else gold = self.baseBuild and self.referenceGoldMined or GetPlayerState(lane.owner, PLAYER_STATE_RESOURCE_GOLD) end
        local lumber = index==2 and self.playerLumberMined or
            (self.baseBuild and self.referenceLumberMined or GetPlayerState(lane.owner, PLAYER_STATE_RESOURCE_LUMBER))
        local comparison = ""
        local differencePercent = 0.0
        if index >= 2 then
            local referenceGold = self.baseBuild and self.referenceGoldMined or GetPlayerState(
                self.lanes[1].owner, PLAYER_STATE_RESOURCE_GOLD)
            if referenceGold > 0 then
                differencePercent = (gold - referenceGold) * 100.0 /
                    referenceGold
            end
            comparison = string.format(" (%+.1f%%)", differencePercent)
        end
        if index==2 and self.minePercentTag then
            SetTextTagText(self.minePercentTag,string.format('|cffffcc00%+.1f%%|r',differencePercent),.030)
            SetTextTagVisibility(self.minePercentTag,self.presentationVisible)
        end
        BlzFrameSetText(lane.counterFrame,
            "|cff40c8ff" .. tostring(lane.miningWorkers) .. " Workers Mining|r|n|n" ..
            "|cffffcc00Gold Mined: " .. tostring(gold) .. comparison .. "|r|n|n" ..
            "|cff80ff80Lumber Harvested: " .. tostring(lumber) .. "|r")
    end

    function activity:updateCounters()
        if self.locallyPaused or self.finished then return end
        -- Native cumulative gathering totals exclude the starting bank and do
        -- not lose deposits when the player spends or receives a build refund.
        self.playerGoldMined=math.max(0,GetPlayerState(Player(0),PLAYER_STATE_GOLD_GATHERED)-(self.gatheringStart.gold or 0))
        self.playerLumberMined=math.max(0,GetPlayerState(Player(0),PLAYER_STATE_LUMBER_GATHERED)-(self.gatheringStart.lumber or 0))
        if self.baseBuild then
            self.referenceGoldMined=math.max(0,GetPlayerState(self.lanes[1].owner,PLAYER_STATE_GOLD_GATHERED)-self.referenceStart.gold)
            self.referenceLumberMined=math.max(0,GetPlayerState(self.lanes[1].owner,PLAYER_STATE_LUMBER_GATHERED)-self.referenceStart.lumber)
            self:updateBuildMirror()
        end
        for index = 1, 3 do self:updateLaneCounter(index) end
        if self.running then
            self.elapsed=self.elapsed+0.10
            if self.duration then self.elapsed=math.min(self.duration,self.elapsed) end
            self:refreshTimer()
            if self.duration and self.elapsed>=self.duration-0.00001 then self:finishTimedRun()
            elseif self.baseBuild then self:checkFifthGoldWorker() end
        end
    end

    function activity:refreshTimer()
        if self.timeFrame then
            BlzFrameSetText(self.timeFrame,string.format('|cffffcc00Time: %.1fs|r',self.baseBuild and self.elapsed or math.max(0,60-self.elapsed)))
            BlzFrameSetVisible(self.timeFrame,self.presentationVisible and not self.finished)
        end
    end
    function activity:createTimedPresentation()
        if not self.duration and not self.baseBuild then return end
        self.timeFrame=JTG.ScopeTrackFrame(session.presentationScope,
            BlzCreateFrameByType('TEXT','JTGMiningTime',BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0),'',0))
        BlzFrameSetSize(self.timeFrame,0.30,0.03)
        BlzFrameSetAbsPoint(self.timeFrame,FRAMEPOINT_TOPLEFT,0.012,0.55)
        BlzFrameSetScale(self.timeFrame,1.48);BlzFrameSetEnable(self.timeFrame,false)
        self.resultCard=JTG.UI.CreateResultCard(session,{name='JTGMiningResult',width=0.44,detailsHeight=self.baseBuild and 0.18 or 0.12})
        if self.baseBuild then
            self.extraGoldFrame=JTG.ScopeTrackFrame(session.presentationScope,
                BlzCreateFrameByType('TEXT','JTGMiningExtraGold',self.resultCard.panel,'',0))
            BlzFrameSetSize(self.extraGoldFrame,.35,.04)
            BlzFrameSetPoint(self.extraGoldFrame,FRAMEPOINT_TOP,self.resultCard.details,FRAMEPOINT_TOP,0,-.09)
            BlzFrameSetTextAlignment(self.extraGoldFrame,TEXT_JUSTIFY_TOP,TEXT_JUSTIFY_CENTER)
            BlzFrameSetScale(self.extraGoldFrame,1.5);BlzFrameSetEnable(self.extraGoldFrame,false)
        end
        self:refreshTimer()
    end
    function activity:showTimedResult()
        JTG.UI.HideToolbar()
        local details
        if self.baseBuild then
            details=string.format('Total Gold mined: %d\nTotal Lumber mined: %d\nTime Elapsed: %.1fs',
                self.playerGoldMined,self.playerLumberMined,self.elapsed)
            BlzFrameSetText(self.extraGoldFrame,string.format('|cffffcc00Extra Gold mined: %d|r',self.recoveredGold))
        else
            local expected=self.expectedLoss
            local percent=expected>0 and string.format('%.1f%%',self.recoveredGold*100/expected) or 'N/A (no reference loss)'
            details='Expected gold loss mitigated: '..percent..'\nLumber harvested: '..self.playerLumberMined..
                '\nGold recovered: '..self.recoveredGold..' / '..expected
        end
        JTG.UI.ShowResultCard(self.resultCard,{title=self.baseBuild and 'BUILD ORDER COMPLETE' or 'ONE MINUTE COMPLETE',tone='success',
            details=details,visible=self.presentationVisible,
            actions={retry={},menu={}}})
    end
    function activity:finishTimedRun()
        if self.finished then return end
        self.finished=true
        if self.baseBuild then self.recoveredGold=self.playerGoldMined-self.referenceGoldMined
        else
            local full=GetPlayerState(self.lanes[1].owner,PLAYER_STATE_RESOURCE_GOLD)
            local baseline=GetPlayerState(self.lanes[3].owner,PLAYER_STATE_RESOURCE_GOLD)
            self.expectedLoss=full-baseline;self.recoveredGold=self.playerGoldMined-baseline
            self.actualLoss=full-self.playerGoldMined
        end
        for _,lane in ipairs(self.lanes) do
            for _,worker in ipairs(lane.workers) do PauseUnit(worker,true) end
            PauseUnit(lane.hall,true)
        end
        for unit in pairs(self.baseActors or {}) do if GetUnitTypeId(unit)~=0 then PauseUnit(unit,true) end end
        for unit in pairs(self.buildMirror and self.buildMirror.actors or {}) do if GetUnitTypeId(unit)~=0 then PauseUnit(unit,true) end end
        self:refreshTimer();self:showTimedResult()
    end

    function activity:setOverlayVisible(visible)
        for _, lane in ipairs(self.lanes) do
            if lane.counterFrame ~= nil then
                BlzFrameSetVisible(lane.counterFrame, visible == true)
            end
        end
        if self.playerHeading then BlzFrameSetVisible(self.playerHeading,visible==true) end
        if self.minePercentTag then SetTextTagVisibility(self.minePercentTag,visible==true) end
    end

    function activity:createLaneCounter(lane, index)
        local gameUI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        lane.counterFrame = JTG.ScopeTrackFrame(session.presentationScope,
            BlzCreateFrameByType("TEXT", "JTGMiningCounter" .. tostring(index),
                gameUI, "", 0))
        BlzFrameSetSize(lane.counterFrame, 0.220, index == 2 and 0.120 or 0.105)
        BlzFrameSetAbsPoint(lane.counterFrame, FRAMEPOINT_TOPLEFT,
            index==2 and 0.024 or 0.012, index==2 and .355 or 0.505 - (index - 1) * 0.125)
        BlzFrameSetTextAlignment(lane.counterFrame,
            TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
        BlzFrameSetScale(lane.counterFrame, 1.48)
        BlzFrameSetEnable(lane.counterFrame, false)
        BlzFrameSetVisible(lane.counterFrame, true)
        if index==2 then
            self.playerHeading=JTG.ScopeTrackFrame(session.presentationScope,
                BlzCreateFrameByType('TEXT','JTGMiningYou',gameUI,'',0))
            BlzFrameSetSize(self.playerHeading,.22,.035)
            BlzFrameSetAbsPoint(self.playerHeading,FRAMEPOINT_TOPLEFT,.024,.395)
            BlzFrameSetTextAlignment(self.playerHeading,TEXT_JUSTIFY_TOP,TEXT_JUSTIFY_LEFT)
            BlzFrameSetScale(self.playerHeading,1.48)
            BlzFrameSetText(self.playerHeading,'|cffff0000YOU|r');BlzFrameSetEnable(self.playerHeading,false)
            self.minePercentTag=JTG.ScopeTrackTextTag(session.presentationScope,CreateTextTag())
            SetTextTagPermanent(self.minePercentTag,true)
            SetTextTagPos(self.minePercentTag,lane.mineX-85,lane.mineY+210,80)
        end
        self:updateLaneCounter(index)
    end

    function activity:issueOpeningOrders()
        -- Match an ordinary opening first, then redirect only the rightmost
        -- worker in the middle and right comparisons to lumber.
        for _, lane in ipairs(self.lanes) do
            for _, worker in ipairs(lane.workers) do
                IssueTargetOrder(worker, "harvest", lane.mine)
            end
        end
        for index = self.baseBuild and 1 or 2, self.baseBuild and 2 or 3 do
            local lane = self.lanes[index]
            IssueTargetOrder(lane.workers[1], "harvest", lane.tree)
        end
    end

    function activity:createScenario()
        local owners = {Player(1), Player(0), Player(2)}
        local miningWorkers = {5, 4, 4}
        for index = 1, self.baseBuild and 2 or 3 do
            local layout = ResolveLaneLayout(MINE_ANCHORS[self.baseBuild and index==1 and 3 or index], self.orientation)
            local lane = {
                owner = self.baseBuild and index==1 and Player(2) or owners[index],
                mineX = layout.mineX, mineY = layout.mineY,
                miningWorkers = self.baseBuild and 4 or miningWorkers[index], workers = {},
            }
            lane.mine = JTG.ScopeTrackUnit(session.scope,
                CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), FourCC("ngol"),
                    lane.mineX, lane.mineY, 270.0))
            SetResourceAmount(lane.mine, STARTING_MINE_GOLD)
            lane.hall = JTG.ScopeTrackUnit(session.scope,
                CreateUnit(lane.owner, race.hall,
                    layout.hallX, layout.hallY, 270.0))
            for _, workerPosition in ipairs(layout.workers) do
                table.insert(lane.workers, JTG.ScopeTrackUnit(session.scope,
                    CreateUnit(lane.owner, race.worker,
                        workerPosition.x, workerPosition.y, 90.0)))
            end
            lane.trees={}
            for _,position in ipairs(layout.trees) do
                local tree=JTG.ScopeTrackDestructable(session.scope,
                    CreateDestructable(FourCC('JTtr'),position.x,position.y,270.0,1.0,0))
                SetTrainingTreeLife(tree);lane.trees[#lane.trees+1]=tree
            end
            lane.tree=lane.trees[1]
            self.lanes[index] = lane
        end
        for index, lane in ipairs(self.lanes) do self:createLaneCounter(lane, index) end
        ClearSelection()
        self:issueOpeningOrders()
    end

    function activity:trackBaseActor(unit)
        if unit==nil or GetOwningPlayer(unit)~=Player(0) then return end
        if self.baseActors[unit] then return end
        self.baseActors[unit]=true
        JTG.ScopeTrackUnit(session.scope,unit)
        if GetUnitTypeId(unit)==race.worker then self.goldWorkers[unit]={gold=false,entered=false} end
    end

    function activity:setupBaseBuild()
        self.baseActors={}
        local lane=self.lanes[2]
        self:trackBaseActor(lane.hall)
        for index,worker in ipairs(lane.workers) do
            self:trackBaseActor(worker)
            self.goldWorkers[worker].gold=index>1
        end
        local created=JTG.ScopeTrackTrigger(session.scope,CreateTrigger())
        TriggerRegisterPlayerUnitEvent(created,Player(0),EVENT_PLAYER_UNIT_TRAIN_FINISH,nil)
        TriggerRegisterPlayerUnitEvent(created,Player(0),EVENT_PLAYER_UNIT_CONSTRUCT_START,nil)
        TriggerAddAction(created,JTG.GuardSession(session,function()
            self:trackBaseActor(GetTriggerEventId()==EVENT_PLAYER_UNIT_TRAIN_FINISH and GetTrainedUnit() or GetConstructingStructure())
        end))
        local orders=JTG.ScopeTrackTrigger(session.scope,CreateTrigger())
        for _,event in ipairs({EVENT_PLAYER_UNIT_ISSUED_ORDER,EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER,EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER}) do
            TriggerRegisterPlayerUnitEvent(orders,Player(0),event,nil)
        end
        TriggerAddAction(orders,JTG.GuardSession(session,function()
            if self.finished then return end
            local worker=GetTriggerUnit()
            if GetUnitTypeId(worker)~=race.worker then return end
            self:trackBaseActor(worker)
            local state=self.goldWorkers[worker]
            local order=GetIssuedOrderId()
            local target=GetTriggerEventId()==EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER and GetOrderTargetUnit() or nil
            if target==lane.mine and (order==OrderId('harvest') or order==OrderId('smart')) then
                state.gold=true
            elseif order==OrderId('returnresources') or order==OrderId('returngold') or
                    order==OrderId('resumeharvesting') or
                    (target==nil and order==OrderId('harvest')) or
                    (target==lane.hall and order==OrderId('smart')) then
                -- A normal drop-off is still part of the current mining task.
            else
                state.gold=false;state.entered=false
            end
        end))
    end

    function activity:checkFifthGoldWorker()
        local lane=self.lanes[2]
        local count,newEntry=0,false
        for worker,state in pairs(self.goldWorkers) do
            if state.gold and GetUnitTypeId(worker)==race.worker and GetOwningPlayer(worker)==Player(0) and GetWidgetLife(worker)>.405 then
                -- Like Economy's in-mine protection, use the native hidden
                -- worker state. An accepted order alone must not finish play.
                if not state.entered and IsUnitHidden(worker) and
                        (GetUnitX(worker)-lane.mineX)^2+(GetUnitY(worker)-lane.mineY)^2<400^2 then
                    state.entered=true;newEntry=true
                end
                if state.entered then count=count+1 end
            end
        end
        if newEntry and count>=5 then self:finishTimedRun() end
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
                heroTokens = self.baseBuild and GetPlayerState(owner,PLAYER_STATE_RESOURCE_HERO_TOKENS) or nil,
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
                if self.baseBuild then SetPlayerState(owner,PLAYER_STATE_RESOURCE_HERO_TOKENS,state.heroTokens) end
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
            SetPlayerState(owner, PLAYER_STATE_RESOURCE_GOLD, self.baseBuild and 500 or 0)
            SetPlayerState(owner, PLAYER_STATE_RESOURCE_LUMBER, self.baseBuild and 150 or 0)
            SetPlayerTechMaxAllowed(owner, race.worker, self.baseBuild and -1 or 5)
            if self.baseBuild and (ownerIndex==0 or ownerIndex==2) then
                -- Standard melee hero setup, scoped to these two fresh bases.
                -- Do not use the Hotkey Trainer's Castle context workaround.
                SetPlayerState(owner,PLAYER_STATE_RESOURCE_HERO_TOKENS,1)
                for _,raw in ipairs(self.race=='human' and {'HERO','Hpal','Hamg','Hmkg','Hblm'} or {'HERO','Obla','Ofar','Otch','Oshd'}) do
                    local id=FourCC(raw);local old=GetPlayerTechMaxAllowed(owner,id)
                    JTG.ScopeBorrow(current.scope,function() SetPlayerTechMaxAllowed(owner,id,old) end)
                    SetPlayerTechMaxAllowed(owner,id,raw=='HERO' and 3 or 1)
                end
            end
            for otherIndex = 0, 2 do
                SetPlayerAlliance(owner, Player(otherIndex), ALLIANCE_PASSIVE, true)
            end
        end

        JTG.ResetWorldFog(p0)
        JTG.ScopeRevealScene(current.scope, current.scene, p0)

        self.gatheringStart={gold=GetPlayerState(p0,PLAYER_STATE_GOLD_GATHERED),lumber=GetPlayerState(p0,PLAYER_STATE_LUMBER_GATHERED)}
        self.referenceStart={gold=GetPlayerState(Player(2),PLAYER_STATE_GOLD_GATHERED),lumber=GetPlayerState(Player(2),PLAYER_STATE_LUMBER_GATHERED)}
        self.referenceGoldMined,self.referenceLumberMined=0,0
        self:createScenario()
        if self.baseBuild then self:setupBaseBuild();JTG.InstallMiningBuildOrder(self,current,race) end
        self:createTrainingQuests()
        self:createTimedPresentation()
        self.updateTimer = JTG.StartScopedTimer(current, current.scope,
            0.10, true, function() self:updateCounters() end)
    end

    function activity:start(current)
        self.running=true
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
            duration = self.duration,
            baseBuild = self.baseBuild,
            orientation = self.orientation,
            skipQuestHighlight = true,
        }
    end

    function activity:captureRotatedState()
        return {
            race = self.race,
            duration = self.duration,
            baseBuild = self.baseBuild,
            orientation = (self.orientation + 1) % 4,
            skipQuestHighlight = true,
        }
    end

    function activity:restorePresentation()
        self.presentationVisible=true
        self:setOverlayVisible(true)
        self:refreshTimer()
        if self.finished then self:showTimedResult();return end
        if JTG.UI then JTG.UI.ShowToolbar(session.descriptor.capabilities) end
    end

    function activity:hidePresentationForMenu()
        self.presentationVisible=false
        self:setOverlayVisible(false)
        self:refreshTimer()
        if self.resultCard then JTG.UI.HideResultCard(self.resultCard) end
    end

    function activity:rebuildPresentation()
        if self.minePercentTag then DestroyTextTag(self.minePercentTag);self.minePercentTag=nil end
        self:createTimedPresentation()
        for index, lane in ipairs(self.lanes) do
            lane.counterFrame = nil
            self:createLaneCounter(lane, index)
        end
    end

    function activity:discardPresentationForLoad()
        if self.playerHeading then BlzDestroyFrame(self.playerHeading);self.playerHeading=nil end
        if self.minePercentTag then DestroyTextTag(self.minePercentTag);self.minePercentTag=nil end
        self.timeFrame=nil;self.resultCard=nil;self.extraGoldFrame=nil
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
