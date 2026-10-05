-- Body Blocking: first legacy activity port.
-- Core movement, timing and failure rules follow v0.92, but all positions are
-- derived from the assigned successor scene and all resources belong to the
-- current activity scope.
JTG = JTG or {}

local BODY_BLOCKING_QUEST_TEXT =
    "The game does not keep every moving unit's path perfectly up to date. " ..
    "Instead, units receive short movement instructions that tell them which " ..
    "direction and distance they can currently move.|n|n" ..
    "If a unit collides with another unit, its instruction is interrupted, " ..
    "which makes it stop shortly.|n|n" ..
    "The unit then has to receive a pathfinding update before it can move " ..
    "around the obstacle.|n|n" ..
    "Every player gets up to 50 such pathfinding instructions per second for " ..
    "all of their moving units, which includes the repeated movements of " ..
    "workers.|n|n" ..
    "This explains why big armies become more and more unwieldy, as more and " ..
    "more units block each other and require more and more instructions.|n|n" ..
    "When trying to body block a unit, this explains part of why the unit " ..
    "stands still for a moment.|n|n" ..
    "The other half is that the unit now has to navigate around the obstacle, " ..
    "which requires it to turn left or right.|n|n" ..
    "Turning in Warcraft takes time, with every unit having its own turn " ..
    "speed.|n|n" ..
    "So a blocked unit has to wait for new movement instructions, and then " ..
    "turn on the spot to start moving along the new path.|n|n" ..
    "In the time this takes, a keen-eyed player can predict where the new " ..
    "path is going to go, and move their blocker into position again.|n|n" ..
    "Press the |cffffcc00Squares|r button to display the areas that units " ..
    "obstruct. These areas snap to a 32x32 in-game unit grid, so they do not " ..
    "move seamlessly like the units do. You can also display the snap points " ..
    "and a finer 8x8 grid."

local TRAINING_ROSTERS = {
    human = {
        {FourCC("hpea"), "Peasant"}, {FourCC("hmtm"), "Mortar Team"},
        {FourCC("hfoo"), "Footman"}, {FourCC("hsor"), "Sorceress"},
        {FourCC("hspt"), "Spell Breaker"}, {FourCC("hkni"), "Knight"},
    },
    orc = {
        {FourCC("opeo"), "Peon"}, {FourCC("okod"), "Kodo Beast"},
        {FourCC("ogru"), "Grunt"}, {FourCC("oshm"), "Shaman"},
        {FourCC("otau"), "Tauren"}, {FourCC("orai"), "Raider"},
    },
    undead = {
        {FourCC("uaco"), "Acolyte"}, {FourCC("uabo"), "Abomination"},
        {FourCC("ucry"), "Crypt Fiend"}, {FourCC("ugho"), "Ghoul"},
        {FourCC("uban"), "Banshee"},
    },
    nightelf = {
        {FourCC("ewsp"), "Wisp"}, {FourCC("emtg"), "Mountain Giant"},
        {FourCC("earc"), "Archer"},
        {FourCC("esen"), "Huntress"}, {FourCC("edry"), "Dryad"},
    },
}

local RACE_CHOICES = {
    {key = "human", label = "Human",
        artwork = "UI\\Glues\\Loading\\Backgrounds\\Campaigns\\HumanSymbol.dds"},
    {key = "orc", label = "Orc",
        artwork = "UI\\Glues\\Loading\\Backgrounds\\Campaigns\\OrcSymbol.dds"},
    {key = "nightelf", label = "Night Elf",
        artwork = "UI\\Glues\\Loading\\Backgrounds\\Campaigns\\NightElfSymbol.dds"},
    {key = "undead", label = "Undead",
        artwork = "UI\\Glues\\Loading\\Backgrounds\\Campaigns\\UndeadSymbol.dds"},
}

local CUSTOM_RACE_CHOICES = {
    RACE_CHOICES[1], RACE_CHOICES[2], RACE_CHOICES[3], RACE_CHOICES[4],
    {key = "neutral", label = "Neutral",
        artwork = "ReplaceableTextures\\CommandButtons\\BTNTavern.blp",
        iconScale = 0.6},
}

-- Standard ground rosters plus heroes. Flying forms and flying units are
-- deliberately absent; Neutral is limited to the tavern heroes.
local CUSTOM_UNITS = {
    human = {
        {FourCC("hpea"), "Peasant"}, {FourCC("hmil"), "Militia"},
        {FourCC("hfoo"), "Footman"}, {FourCC("hrif"), "Rifleman"},
        {FourCC("hkni"), "Knight"}, {FourCC("hmpr"), "Priest"},
        {FourCC("hsor"), "Sorceress"}, {FourCC("hspt"), "Spell Breaker"},
        {FourCC("hmtm"), "Mortar Team"}, {FourCC("hmtt"), "Siege Engine"},
        {FourCC("Hpal"), "Paladin"}, {FourCC("Hamg"), "Archmage"},
        {FourCC("Hmkg"), "Mountain King"}, {FourCC("Hblm"), "Blood Mage"},
    },
    orc = {
        {FourCC("opeo"), "Peon"}, {FourCC("ogru"), "Grunt"},
        {FourCC("ohun"), "Headhunter"}, {FourCC("otbk"), "Berserker"},
        {FourCC("ocat"), "Demolisher"}, {FourCC("orai"), "Raider"},
        {FourCC("okod"), "Kodo Beast"}, {FourCC("oshm"), "Shaman"},
        {FourCC("odoc"), "Witch Doctor"}, {FourCC("ospw"), "Spirit Walker"},
        {FourCC("otau"), "Tauren"}, {FourCC("Obla"), "Blademaster"},
        {FourCC("Ofar"), "Far Seer"}, {FourCC("Otch"), "Tauren Chieftain"},
        {FourCC("Oshd"), "Shadow Hunter"},
    },
    undead = {
        {FourCC("uaco"), "Acolyte"}, {FourCC("ugho"), "Ghoul"},
        {FourCC("ucry"), "Crypt Fiend"}, {FourCC("uabo"), "Abomination"},
        {FourCC("umtw"), "Meat Wagon"}, {FourCC("unec"), "Necromancer"},
        {FourCC("uban"), "Banshee"}, {FourCC("ushd"), "Shade"},
        {FourCC("uobs"), "Obsidian Statue"}, {FourCC("Udea"), "Death Knight"},
        {FourCC("Udre"), "Dreadlord"}, {FourCC("Ulic"), "Lich"},
        {FourCC("Ucrl"), "Crypt Lord"},
    },
    nightelf = {
        {FourCC("ewsp"), "Wisp"}, {FourCC("earc"), "Archer"},
        {FourCC("esen"), "Huntress"}, {FourCC("ebal"), "Glaive Thrower"},
        {FourCC("edry"), "Dryad"}, {FourCC("edoc"), "Druid of the Claw"},
        {FourCC("edot"), "Druid of the Talon"}, {FourCC("emtg"), "Mountain Giant"},
        {FourCC("Edem"), "Demon Hunter"}, {FourCC("Ekee"), "Keeper of the Grove"},
        {FourCC("Emoo"), "Priestess of the Moon"}, {FourCC("Ewar"), "Warden"},
    },
    neutral = {
        {FourCC("Nngs"), "Naga Sea Witch"}, {FourCC("Nbrn"), "Dark Ranger"},
        {FourCC("Npbm"), "Pandaren Brewmaster"}, {FourCC("Nbst"), "Beastmaster"},
        {FourCC("Nplh"), "Pit Lord"}, {FourCC("Nfir"), "Firelord"},
        {FourCC("Ntin"), "Goblin Tinker"}, {FourCC("Nalc"), "Goblin Alchemist"},
        {FourCC("Npal"), "Forsaken Paladin"},
    },
}

-- The reference uses Warcraft III's Ghostly Archmage campaign unit. Locust,
-- disabled pathing and invulnerability keep it visible without allowing it
-- to receive clicks, collide with either participant or affect the exercise.
local REFERENCE_RUNNER_ID = FourCC("Hgam")
local REFERENCE_LANE_OFFSET = 300.0

local BODY_BLOCKING_INTRO =
    "Sometimes a valid strategy is simply to stand in the way of your opponent, to stop them from getting where they are going. Be it to get more hits in on them, or to stop them from effectively doing anything.|n|n" ..
    "This exercise trains you in blocking the movement of other units. You control a Footman, and using the Move, Stop and Hold Position commands, try to stay in front of a series of units, for as long as possible.|n|n" ..
    "The usual |cffffcc00Training|r has you choose between the race of the units you want to practice against, and you will encounter a series of that race's units.|nAlternatively, you can freely customize which unit you want to practice blocking with which."

function JTG.OpenBodyBlockingMenu(originCategory, pauseGame, restorePage, restoreData)
    local selection = {
        mode = nil, difficulty = 1, race = "human", runnerIndex = 1,
        runnerId = nil, runnerName = nil, blockerRace = "human",
        blockerId = FourCC("hfoo"), blockerName = "Footman",
    }
    for key, value in pairs(restoreData or {}) do selection[key] = value end
    local function releaseMenuPause()
        if JTG.UI then JTG.UI.SetGameplayMenuPaused(false) end
    end
    local function leaveMenu()
        if pauseGame then
            if JTG.UI then JTG.UI.ShowCategory(originCategory or "skills") end
        else
            releaseMenuPause()
            if JTG.UI then JTG.UI.ShowCategory(originCategory or "skills") end
        end
    end
    local function resumeCurrentRun()
        releaseMenuPause()
        JTG.ResumeActivity()
    end
    local function launch()
        releaseMenuPause()
        JTG.StartActivity("skills.body_blocking", originCategory or "skills", selection)
    end
    local showRoot, showTrainingRace, showTrainingDifficulty
    local showCustomRace, showCustomRunner, showCustomBlockerRace
    local showCustomBlocker, showCustomDifficulty
    local function show(spec, pageId)
        spec.title = "Body Blocking"
        spec.activityId = "skills.body_blocking"
        spec.originCategory = originCategory or "skills"
        spec.headingArtwork = "JTGMenu\\BodyBlockingBriefing.dds"
        spec.pauseGame = pauseGame == true
        spec.pageId = pageId
        spec.restoreData = selection
        if pauseGame then
            spec.resumeAction = resumeCurrentRun
            spec.exitAction = function()
                JTG.StopActivity("menu-exit")
                pauseGame = false
                showRoot()
            end
        end
        JTG.UI.ShowActivityBriefing(spec)
    end
    showRoot = function()
        show({
            body = BODY_BLOCKING_INTRO,
            choices = {
                {label = "Start Training", primary = true,
                    tooltip = "Choose a race and practice against its sequence of units.",
                    action = function() selection.mode = "training"; showTrainingRace() end},
                {label = "Custom", tooltip = "Choose both the runner and the unit you control.",
                    action = function() selection.mode = "custom"; showCustomRace() end},
            },
            backAction = leaveMenu,
        }, "root")
    end
    showTrainingRace = function()
        local choices = {}
        for _, race in ipairs(RACE_CHOICES) do
            local key, label = race.key, race.label
            table.insert(choices, {label = label, icon = race.artwork,
                iconScale = race.iconScale,
                tooltip = "Practice against " .. label .. " units.",
                action = function()
                    selection.race = key
                    selection.runnerIndex = 1
                    selection.blockerId = FourCC("hfoo")
                    selection.blockerName = "Footman"
                    showTrainingDifficulty()
                end})
        end
        show({body = "Choose the race whose units you want to practice blocking.",
            choices = choices, backAction = showRoot}, "training_race")
    end
    showTrainingDifficulty = function()
        show({body = "Choose a difficulty. Hard runners take a less predictable route.", choices = {
            {label = "Normal", tooltip = "The runner follows the direct course.",
                action = function() selection.difficulty = 1; launch() end},
            {label = "Hard", tooltip = "The runner changes its route more often.",
                action = function() selection.difficulty = 2; launch() end},
        }, backAction = showTrainingRace}, "training_difficulty")
    end
    showCustomRace = function()
        local choices = {}
        for _, race in ipairs(CUSTOM_RACE_CHOICES) do
            local key, label = race.key, race.label
            table.insert(choices, {label = label, icon = race.artwork,
                iconScale = race.iconScale,
                tooltip = "Choose a " .. label .. " runner.",
                action = function() selection.race = key; showCustomRunner() end})
        end
        show({body = "Choose the race of the runner you want to block.", choices = choices,
            backAction = showRoot}, "custom_race")
    end
    showCustomRunner = function()
        local choices = {}
        for _, runner in ipairs(CUSTOM_UNITS[selection.race]) do
            local unitId, unitName = runner[1], runner[2]
            table.insert(choices, {label = unitName, tooltip = "Use " .. unitName .. " as the runner.",
                action = function()
                    selection.runnerId = unitId
                    selection.runnerName = unitName
                    showCustomBlockerRace()
                end})
        end
        show({body = "Choose the unit you want to block.", choices = choices,
            compactChoices = true,
            backAction = showCustomRace}, "custom_runner")
    end
    showCustomBlockerRace = function()
        local choices = {}
        for _, race in ipairs(CUSTOM_RACE_CHOICES) do
            local key, label = race.key, race.label
            table.insert(choices, {label = label, icon = race.artwork,
                iconScale = race.iconScale,
                action = function() selection.blockerRace = key; showCustomBlocker() end})
        end
        show({body = "Choose the race of the unit you want to control.", choices = choices,
            backAction = showCustomRunner}, "custom_blocker_race")
    end
    showCustomBlocker = function()
        local choices = {}
        for _, blocker in ipairs(CUSTOM_UNITS[selection.blockerRace]) do
            local unitId, unitName = blocker[1], blocker[2]
            table.insert(choices, {label = unitName, tooltip = "Control a " .. unitName .. ".",
                action = function()
                    selection.blockerId = unitId
                    selection.blockerName = unitName
                    showCustomDifficulty()
                end})
        end
        show({body = "Choose the unit you want to use for blocking.", choices = choices,
            compactChoices = true,
            backAction = showCustomBlockerRace}, "custom_blocker")
    end
    showCustomDifficulty = function()
        show({body = "Choose a difficulty. Hard runners take a less predictable route.", choices = {
            {label = "Normal", tooltip = "The runner follows the direct course.",
                action = function() selection.difficulty = 1; launch() end},
            {label = "Hard", tooltip = "The runner changes its route more often.",
                action = function() selection.difficulty = 2; launch() end},
        }, backAction = showCustomBlocker}, "custom_difficulty")
    end
    local pages = {
        root = showRoot,
        training_race = showTrainingRace,
        training_difficulty = showTrainingDifficulty,
        custom_race = showCustomRace,
        custom_runner = showCustomRunner,
        custom_blocker_race = showCustomBlockerRace,
        custom_blocker = showCustomBlocker,
        custom_difficulty = showCustomDifficulty,
    }
    (pages[restorePage] or showRoot)()
end

function JTG.CreateBodyBlockingActivity(session)
    local activity = {
        mode = nil,
        difficulty = 1,
        race = "human",
        runnerIndex = 1,
        runnerId = nil,
        runnerName = nil,
        blockerId = FourCC("hfoo"),
        blockerName = "Footman",
        running = false,
        finished = false,
        advancePending = false,
        nextRunnerRequested = false,
        elapsed = 0.0,
        addedDelay = 0.0,
        collisionCount = 0,
        blockingActive = false,
        successfulBlock = false,
        maxDelay = 15.0,
        failGap = 300.0,
        tickCount = 0,
        sampleTicks = 0,
        streak = 0.0,
        streakBreak = 0.0,
        courseTags = {},
        bestStreak = 0.0,
        streakLevel = 0,
        raceResults = {},
        routeTemplate = nil,
        squaresVisible = false,
        squareGridVisible = false,
        squareEntries = {},
        navigationDotsImages = {},
        navigationGridImages = {},
        presentationVisible = true,
    }

    local carry = session.restartData
    if carry ~= nil then
        activity.mode = carry.mode
        activity.difficulty = carry.difficulty or 1
        activity.race = carry.race or "human"
        activity.runnerIndex = carry.runnerIndex or 1
        activity.runnerId = carry.runnerId
        activity.runnerName = carry.runnerName
        activity.blockerId = carry.blockerId or FourCC("hfoo")
        activity.blockerName = carry.blockerName or "Footman"
        activity.raceResults = carry.raceResults or {}
        activity.routeTemplate = carry.routeTemplate
        activity.squaresVisible = carry.squaresVisible == true
        activity.squareGridVisible = carry.squareGridVisible == true
    end

    function activity:addSquareOverlay(unit, texture)
        if unit == nil then return end
        local half = JTG.UnitObstructionHalfSize(BlzGetUnitCollisionSize(unit))
        local centerX = JTG.UnitObstructionGridCenter(GetUnitX(unit))
        local centerY = JTG.UnitObstructionGridCenter(GetUnitY(unit))
        local image = JTG.ScopeTrackImage(session.presentationScope,
            CreateImage(texture, half * 2.0, half * 2.0, 0,
                centerX - half, centerY - half, 2, 0, 0, 0, 2))
        SetImageRenderAlways(image, true)
        SetImageAboveWater(image, true, true)
        self.squareEntries[#self.squareEntries + 1] = {
            unit = unit, image = image, half = half,
        }
    end

    function activity:updateSquareOverlays()
        local visible = self.squaresVisible and self.presentationVisible
        JTG.ShowNavigationGrid(self.navigationGridImages,
            self.squareGridVisible and self.presentationVisible)
        for _, entry in ipairs(self.squareEntries) do
            if entry.unit ~= nil and GetUnitTypeId(entry.unit) ~= 0 then
                local centerX = JTG.UnitObstructionGridCenter(GetUnitX(entry.unit))
                local centerY = JTG.UnitObstructionGridCenter(GetUnitY(entry.unit))
                SetImagePosition(entry.image, centerX - entry.half,
                    centerY - entry.half, 2)
                ShowImage(entry.image, visible)
            end
        end
        JTG.ShowNavigationGrid(self.navigationDotsImages, visible)
    end

    function activity:createSquareOverlays()
        self.squareEntries = {}
        self:addSquareOverlay(self.blocker, JTG.UnitSquarePlayerTexture)
        self:addSquareOverlay(self.runner, JTG.UnitSquareEnemyTexture)
        self:updateSquareOverlays()
    end

    function activity:toggleSquares()
        if not self.squaresVisible then
            self.squaresVisible = true
            self.squareGridVisible = false
        elseif not self.squareGridVisible then
            self.squareGridVisible = true
        else
            self.squaresVisible = false
            self.squareGridVisible = false
        end
        self:updateSquareOverlays()
        if JTG.UI and JTG.UI.SetSquaresActive then
            JTG.UI.SetSquaresActive(self.squaresVisible)
        end
    end

    function activity:makeTimer(period, repeating, callback)
        return JTG.StartScopedTimer(session, session.scope, period, repeating,
            callback)
    end

    activity.resultActions = {
        next = function(self)
            if self.raceComplete then JTG.ExitActivity()
            else JTG.ResetActivity() end
        end,
        replay = function(self) self:startReplay() end,
        retry = function(self)
            self.advancePending = false
            JTG.ResetActivity()
        end,
    }

    function activity:createResultUI()
        self.resultCard = JTG.UI.CreateResultCard(session, {
            name = "JTGBodyBlockResult", width = 0.42,
            detailsHeight = 0.155, titleScale = 1.35,
            detailsScale = 1.04,
        })
        self.resultBackdrop = self.resultCard.panel
    end

    function activity:createCountdownUI()
        local gameUI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        self.countdownFrame = JTG.ScopeTrackFrame(session.presentationScope,
            BlzCreateFrameByType("TEXT", "JTGBodyBlockCountdown", gameUI, "", 0))
        BlzFrameSetSize(self.countdownFrame, 0.20, 0.08)
        BlzFrameSetAbsPoint(self.countdownFrame, FRAMEPOINT_CENTER, 0.40, 0.38)
        BlzFrameSetTextAlignment(self.countdownFrame, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
        BlzFrameSetScale(self.countdownFrame, 2.45)
        BlzFrameSetEnable(self.countdownFrame, false)
        BlzFrameSetVisible(self.countdownFrame, false)
    end

    function activity:createSpeedUI()
        local gameUI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        self.speedFrame = JTG.ScopeTrackFrame(session.presentationScope,
            BlzCreateFrameByType("TEXT", "JTGBodyBlockRunnerSpeed", gameUI, "", 0))
        local scale = 1.45
        BlzFrameSetSize(self.speedFrame, 0.38 / scale, 0.040 / scale)
        BlzFrameSetAbsPoint(self.speedFrame, FRAMEPOINT_TOP, 0.40, 0.505)
        BlzFrameSetTextAlignment(self.speedFrame, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
        BlzFrameSetScale(self.speedFrame, scale)
        BlzFrameSetEnable(self.speedFrame, false)
        BlzFrameSetVisible(self.speedFrame, false)
    end

    function activity:setOverlayVisible(visible)
        local show = visible == true and (not self.finished or self.replaying)
        if self.speedFrame ~= nil then BlzFrameSetVisible(self.speedFrame, show) end
        if self.countdownFrame ~= nil then
            BlzFrameSetVisible(self.countdownFrame, show and self.countdownActive == true)
        end
        for _, tag in ipairs(self.courseTags or {}) do
            if tag ~= nil then SetTextTagVisibility(tag, show) end
        end
    end

    function activity:createCourseMarkers()
        local y = self.laneY
        self.startLine = JTG.ScopeTrackLightning(session.presentationScope,
            AddLightning("DRAL", false, self.startX, self.arenaMinY, self.startX, self.arenaMaxY))
        self.finishLine = JTG.ScopeTrackLightning(session.presentationScope,
            AddLightning("DRAL", false, self.finishX, self.arenaMinY, self.finishX, self.arenaMaxY))
        if self.startLine ~= nil then SetLightningColor(self.startLine, 0.25, 1.0, 0.25, 0.90) end
        if self.finishLine ~= nil then SetLightningColor(self.finishLine, 1.0, 0.20, 0.20, 0.90) end
        self.startTag = JTG.ScopeTrackTextTag(session.presentationScope, CreateTextTag())
        table.insert(self.courseTags, self.startTag)
        SetTextTagText(self.startTag, "|cff80ff80START|r", 0.032)
        SetTextTagPos(self.startTag, self.startX - 120, y + 440, 20)
        SetTextTagPermanent(self.startTag, true)
        self.finishTag = JTG.ScopeTrackTextTag(session.presentationScope, CreateTextTag())
        table.insert(self.courseTags, self.finishTag)
        SetTextTagText(self.finishTag, "|cffff5555FINISH|r", 0.032)
        SetTextTagPos(self.finishTag, self.finishX - 130, y + 440, 20)
        SetTextTagPermanent(self.finishTag, true)
    end

    function activity:currentRunner()
        if self.mode == "custom" then return self.runnerId, self.runnerName end
        local roster = TRAINING_ROSTERS[self.race]
        if self.runnerIndex < 1 or self.runnerIndex > #roster then self.runnerIndex = 1 end
        return roster[self.runnerIndex][1], roster[self.runnerIndex][2]
    end

    function activity:buildRoute()
        self.referenceRoute = {}
        self.referenceWaypoint = 1
        if self.difficulty == 2 then
            if self.routeTemplate == nil then
                self.routeTemplate = {}
                local side = GetRandomInt(0, 1) == 0 and -1 or 1
                local remainingX = self.finishX + 256 - self.startX
                while remainingX > 0 do
                    local forward = math.min(remainingX, GetRandomInt(100, 400))
                    -- Bias the magnitude upward while retaining occasional
                    -- nearly straight legs and the full zero-to-220 range.
                    local vertical = math.sqrt(GetRandomReal(0, 1)) * 220
                    table.insert(self.routeTemplate, {
                        deltaX = forward,
                        deltaY = side * vertical,
                    })
                    remainingX = remainingX - forward
                    side = -side
                end
            end
            self.referenceRoute = self.routeTemplate
            local first = self.referenceRoute[1]
            self.referenceTargetX = GetUnitX(self.referenceRunner) + first.deltaX
            self.referenceTargetY = GetUnitY(self.referenceRunner) + first.deltaY
            self.referenceClosestDistance = math.huge
            self.runnerTargetX = GetUnitX(self.runner) + first.deltaX
            self.runnerTargetY = GetUnitY(self.runner) + first.deltaY
        else
            self.runnerTargetX = self.finishX + 256
            self.runnerTargetY = self.laneY
            self.referenceTargetX = self.finishX + 256
            self.referenceTargetY = self.laneY + REFERENCE_LANE_OFFSET
        end
    end

    function activity:createNextHardWaypoint()
        if self.referenceWaypoint >= #self.referenceRoute then return end
        self.referenceWaypoint = self.referenceWaypoint + 1
        local fixedReferenceTarget = self.referenceRoute[self.referenceWaypoint]
        self.referenceTargetX = GetUnitX(self.referenceRunner) + fixedReferenceTarget.deltaX
        self.referenceTargetY = GetUnitY(self.referenceRunner) + fixedReferenceTarget.deltaY
        self.runnerTargetX = GetUnitX(self.runner) + fixedReferenceTarget.deltaX
        self.runnerTargetY = GetUnitY(self.runner) + fixedReferenceTarget.deltaY
        self.referenceClosestDistance = math.huge
        self:issueRunnerOrder()
        IssuePointOrder(self.referenceRunner, "move",
            self.referenceTargetX, self.referenceTargetY)
    end

    function activity:createRound()
        local runnerId, runnerName = self:currentRunner()
        self.runnerId, self.runnerName = runnerId, runnerName
        self.finished = false
        self.running = false
        self.advancePending = false
        if JTG.UI then
            JTG.UI.HideActivityBriefing()
            JTG.UI.ShowToolbar(session.descriptor.capabilities)
            JTG.UI.SetLastRunnerEnabled(self.mode == "training" and self.runnerIndex > 1)
            JTG.UI.SetNextText("Next Runner")
            JTG.UI.SetNextEnabled(self.mode == "training" and
                self.runnerIndex < #TRAINING_ROSTERS[self.race])
            JTG.UI.SetSquaresActive(self.squaresVisible)
        end
        self:createCourseMarkers()

        self.starter = JTG.ScopeTrackUnit(session.scope,
            BlzCreateUnitWithSkin(Player(PLAYER_NEUTRAL_PASSIVE), FourCC("hrif"),
                self.startX - 190, self.laneY + 410, 315, FourCC("hrif")))
        SetUnitAcquireRange(self.starter, 0)
        SetUnitInvulnerable(self.starter, true)
        SetUnitPathing(self.starter, false)
        UnitAddAbility(self.starter, FourCC("Aloc"))

        self.runner = JTG.ScopeTrackUnit(session.scope,
            BlzCreateUnitWithSkin(Player(1), runnerId, self.startX, self.laneY, 0, runnerId))
        SetUnitAcquireRange(self.runner, 0)
        SetUnitInvulnerable(self.runner, true)
        PauseUnit(self.runner, true)
        self.moveSpeed = math.max(1, GetUnitMoveSpeed(self.runner))
        self.turnRate = GetUnitTurnSpeed(self.runner)
        -- Antonidas is both the visible reference and the timing source. Giving
        -- him the runner's owner avoids Neutral Passive guard-return orders;
        -- Locust, no pathing and invulnerability keep him noninteractive.
        self.referenceRunner = JTG.ScopeTrackUnit(session.scope,
            BlzCreateUnitWithSkin(Player(1), REFERENCE_RUNNER_ID,
                self.startX, self.laneY + REFERENCE_LANE_OFFSET, 0, REFERENCE_RUNNER_ID))
        self.referenceBaseMoveSpeed = math.max(1, GetUnitMoveSpeed(self.referenceRunner))
        SetUnitAcquireRange(self.referenceRunner, 0)
        SetUnitInvulnerable(self.referenceRunner, true)
        SetUnitPathing(self.referenceRunner, false)
        UnitAddAbility(self.referenceRunner, FourCC("Aloc"))
        SetUnitMoveSpeed(self.referenceRunner, self.moveSpeed)
        SetUnitTurnSpeed(self.referenceRunner, GetUnitTurnSpeed(self.runner))
        SetUnitPropWindow(self.referenceRunner, GetUnitPropWindow(self.runner))
        PauseUnit(self.referenceRunner, true)
        self:buildRoute()
        BlzFrameSetText(self.speedFrame, "|cffffcc00" .. runnerName ..
            "|r  Movement Speed " ..
            tostring(math.floor(self.moveSpeed + 0.5)) ..
            "   Turn Rate " .. string.format("%.2f", self.turnRate))
        BlzFrameSetVisible(self.speedFrame, true)

        self.blocker = JTG.ScopeTrackUnit(session.scope,
            BlzCreateUnitWithSkin(Player(0), self.blockerId,
                self.startX + 650, self.laneY - 450, 90, self.blockerId))
        SetUnitInvulnerable(self.blocker, true)
        self:createSquareOverlays()
        -- Neutral ownership makes pre-countdown commands impossible without
        -- repeatedly correcting the unit's position or orders.
        SetUnitOwner(self.blocker, Player(PLAYER_NEUTRAL_PASSIVE), true)
        self.countdownActive = true
        if JTG.UI then JTG.UI.SetRestartText("Redo") end
        self.countdownValue = 3
        BlzFrameSetText(self.countdownFrame, "|cffffcc003|r")
        BlzFrameSetVisible(self.countdownFrame, true)
        self.countdownTimer = self:makeTimer(1.0, true, function() self:countdownTick() end)
        DisplayTimedTextToPlayer(Player(0), 0, 0, 5,
            "|cffffcc00" .. self.blockerName .. " vs " .. runnerName .. "|r  Stay in front and delay the runner.")
    end

    function activity:countdownTick()
        if self.locallyPaused then return end
        if self.countdownValue > 1 then
            self.countdownValue = self.countdownValue - 1
            BlzFrameSetText(self.countdownFrame, "|cffffcc00" .. tostring(self.countdownValue) .. "|r")
            return
        end
        PauseTimer(self.countdownTimer)
        self.countdownValue = 0
        self.countdownActive = false
        BlzFrameSetText(self.countdownFrame, "|cff80ff80GO!|r")
        SetUnitAnimation(self.starter, "attack")
        QueueUnitAnimation(self.starter, "stand")
        SetUnitOwner(self.blocker, Player(0), true)
        PauseUnit(self.blocker, false)
        if GetLocalPlayer() == Player(0) then
            ClearSelection()
            SelectUnit(self.blocker, true)
            EnableUserControl(true)
            EnableUserUI(true)
        end
        self:beginRun()
        self:makeTimer(0.65, false, function() BlzFrameSetVisible(self.countdownFrame, false) end)
    end

    function activity:issueRunnerOrder()
        if self.runnerFinished then return end
        if self.runnerTargetX ~= nil then
            IssuePointOrder(self.runner, "move", self.runnerTargetX, self.runnerTargetY)
        end
    end

    function activity:issueReferenceOrder()
        if self.referenceFinished then return end
        IssuePointOrder(self.referenceRunner, "move",
            self.referenceTargetX, self.referenceTargetY)
    end

    function activity:advanceReferenceRunner()
        if self.referenceFinished or self.difficulty ~= 2 then return end
        local dx = self.referenceTargetX - GetUnitX(self.referenceRunner)
        local dy = self.referenceTargetY - GetUnitY(self.referenceRunner)
        local distance = dx * dx + dy * dy
        local orderComplete = GetUnitCurrentOrder(self.referenceRunner) == 0
        local passed = self.referenceClosestDistance <= 4096 and
            distance > self.referenceClosestDistance + 1
        if distance < self.referenceClosestDistance then
            self.referenceClosestDistance = distance
        end
        -- Warcraft may complete a Move order outside an exact coordinate.
        -- Prefer its own order-complete state, with proximity/passed checks as
        -- safeguards for unusually shaped pathing footprints.
        if (orderComplete or distance <= 256 or passed) and
            self.referenceWaypoint < #self.referenceRoute then
            self:createNextHardWaypoint()
        end
    end

    function activity:beginRun()
        if self.finished then return end
        PauseUnit(self.runner, false)
        PauseUnit(self.referenceRunner, false)
        PauseUnit(self.blocker, false)
        SetUnitMoveSpeed(self.referenceRunner, self.moveSpeed)
        SetUnitTurnSpeed(self.referenceRunner, GetUnitTurnSpeed(self.runner))
        SetUnitPropWindow(self.referenceRunner, GetUnitPropWindow(self.runner))
        SetUnitTimeScale(self.referenceRunner, self.moveSpeed / self.referenceBaseMoveSpeed)
        SetUnitAnimation(self.referenceRunner, "walk")
        self:buildRoute()
        self.referenceFinishElapsed = nil
        self.referenceFinished = false
        self.runnerFinishElapsed = nil
        self.runnerFinished = false
        self.elapsed = 0.0
        self.addedDelay = 0.0
        self.collisionCount = 0
        self.blockingActive = false
        self.successfulBlock = false
        self.tickCount = 0
        self.sampleTicks = 0
        self.streak = 0.0
        self.streakBreak = 0.0
        self.bestStreak = 0.0
        self.streakLevel = 0
        self.lastRunnerX = GetUnitX(self.runner)
        self.replaySamples = {}
        self.running = true
        self:issueRunnerOrder()
        self:issueReferenceOrder()
        self.routeTimer = self:makeTimer(0.01, true, function()
            if not self.locallyPaused and self.running and not self.referenceFinished then
                self:advanceReferenceRunner()
            end
        end)
        self:captureReplaySample()
        self.runTimer = self:makeTimer(0.05, true, function() self:runTick() end)
    end

    function activity:captureReplaySample()
        table.insert(self.replaySamples, {
            blockerX = GetUnitX(self.blocker), blockerY = GetUnitY(self.blocker),
            blockerFacing = GetUnitFacing(self.blocker),
            runnerX = GetUnitX(self.runner), runnerY = GetUnitY(self.runner),
            runnerFacing = GetUnitFacing(self.runner),
            referenceX = GetUnitX(self.referenceRunner), referenceY = GetUnitY(self.referenceRunner),
            referenceFacing = GetUnitFacing(self.referenceRunner),
        })
    end

    function activity:applyReplaySample(sample)
        SetUnitX(self.blocker, sample.blockerX)
        SetUnitY(self.blocker, sample.blockerY)
        BlzSetUnitFacingEx(self.blocker, sample.blockerFacing)
        SetUnitX(self.runner, sample.runnerX)
        SetUnitY(self.runner, sample.runnerY)
        BlzSetUnitFacingEx(self.runner, sample.runnerFacing)
        SetUnitX(self.referenceRunner, sample.referenceX)
        SetUnitY(self.referenceRunner, sample.referenceY)
        BlzSetUnitFacingEx(self.referenceRunner, sample.referenceFacing)
    end

    function activity:applyInterpolatedReplay(position)
        local firstIndex = math.floor(position)
        local secondIndex = math.min(#self.replaySamples, firstIndex + 1)
        local amount = position - firstIndex
        local first = self.replaySamples[firstIndex]
        local second = self.replaySamples[secondIndex]
        if first == nil then return false end
        if firstIndex == secondIndex then
            self:applyReplaySample(first)
            return true
        end
        local function mix(a, b) return a + (b - a) * amount end
        local function mixFacing(a, b)
            local difference = (b - a + 540) % 360 - 180
            return a + difference * amount
        end
        self:applyReplaySample({
            blockerX = mix(first.blockerX, second.blockerX),
            blockerY = mix(first.blockerY, second.blockerY),
            blockerFacing = mixFacing(first.blockerFacing, second.blockerFacing),
            runnerX = mix(first.runnerX, second.runnerX),
            runnerY = mix(first.runnerY, second.runnerY),
            runnerFacing = mixFacing(first.runnerFacing, second.runnerFacing),
            referenceX = mix(first.referenceX, second.referenceX),
            referenceY = mix(first.referenceY, second.referenceY),
            referenceFacing = mixFacing(first.referenceFacing, second.referenceFacing),
        })
        return true
    end

    function activity:finishReplay()
        if not self.replaying then return end
        self.replaying = false
        if self.replayTimer ~= nil then PauseTimer(self.replayTimer) end
        PauseUnit(self.blocker, true)
        PauseUnit(self.runner, true)
        PauseUnit(self.referenceRunner, true)
        SetUnitAnimation(self.blocker, "stand")
        SetUnitAnimation(self.runner, "stand")
        SetUnitAnimation(self.referenceRunner, "stand")
        self:renderResultPresentation()
        self:setOverlayVisible(false)
        if JTG.UI then JTG.UI.HideToolbar() end
    end

    function activity:startReplay()
        if self.replaying or self.replaySamples == nil or #self.replaySamples == 0 then return end
        BlzFrameSetVisible(self.resultBackdrop, false)
        self.countdownActive = false
        PauseUnit(self.blocker, false)
        PauseUnit(self.runner, false)
        PauseUnit(self.referenceRunner, false)
        IssueImmediateOrder(self.blocker, "stop")
        IssueImmediateOrder(self.runner, "stop")
        SetUnitAnimation(self.blocker, "walk")
        SetUnitAnimation(self.runner, "walk")
        SetUnitAnimation(self.referenceRunner, "walk")
        self.replaying = true
        self:setOverlayVisible(true)
        self.replayPosition = 1.0
        self:applyReplaySample(self.replaySamples[1])
        if JTG.UI then
            JTG.UI.ShowToolbar(session.descriptor.capabilities)
            JTG.UI.SetSquaresActive(self.squaresVisible)
            JTG.UI.SetNextText("Next Runner")
            JTG.UI.SetNextEnabled(self.mode == "training" and
                self.runnerIndex < #TRAINING_ROSTERS[self.race])
        end
        self.replayTimer = self:makeTimer(0.025, true, function()
            if self.locallyPaused or not self.replaying then return end
            self.replayPosition = self.replayPosition + 0.5
            if self.replayPosition > #self.replaySamples then
                self:finishReplay()
            else
                self:applyInterpolatedReplay(self.replayPosition)
            end
        end)
    end

    function activity:clearFeedback()
        if self.feedbackEffect ~= nil then
            DestroyEffect(self.feedbackEffect)
            self.feedbackEffect = nil
        end
        if self.blocker ~= nil then SetUnitVertexColor(self.blocker, 255, 255, 255, 255) end
        self.streak = 0.0
        self.streakBreak = 0.0
        self.streakLevel = 0
    end

    function activity:updateFeedback()
        local runnerX, runnerY = GetUnitX(self.runner), GetUnitY(self.runner)
        local dx = GetUnitX(self.blocker) - runnerX
        local dy = GetUnitY(self.blocker) - runnerY
        local actualForward = math.max(0, runnerX - self.lastRunnerX)
        local expectedForward = self.moveSpeed * 0.05
        self.lastRunnerX = runnerX
        local blocking = dx * dx + dy * dy <= 57600 and actualForward <= expectedForward * 0.65
        if blocking then
            if not self.blockingActive then
                self.blockingActive = true
                self.collisionCount = self.collisionCount + 1
            end
            self.streakBreak = 0.0
            self.streak = self.streak + 0.05
            self.bestStreak = math.max(self.bestStreak, self.streak)
            if self.collisionCount >= 2 or self.bestStreak >= 1.0 then self.successfulBlock = true end
            if self.streak >= 0.5 then SetUnitVertexColor(self.blocker, 255, 215, 80, 255) end
            local nextLevel = self.streak >= 6 and 3 or self.streak >= 4 and 2 or self.streak >= 2 and 1 or 0
            if nextLevel > self.streakLevel then
                self.streakLevel = nextLevel
                DisplayTimedTextToPlayer(Player(0), 0, 0, 1.5,
                    "|cffffcc00" .. tostring(nextLevel * 2) .. ".0s BLOCK STREAK!|r")
                if nextLevel == 1 then
                    self.feedbackEffect = AddSpecialEffectTarget(
                        "Abilities\\Spells\\Human\\InnerFire\\InnerFireTarget.mdl", self.blocker, "overhead")
                end
            end
        else
            self.blockingActive = false
            self.streakBreak = self.streakBreak + 0.05
            if self.streakBreak >= 0.5 then self:clearFeedback() end
        end
    end

    function activity:runTick()
        if self.locallyPaused or not self.running or self.finished then return end
        self.elapsed = self.elapsed + 0.05
        self:captureReplaySample()
        if not self.referenceFinished then
            if GetUnitX(self.referenceRunner) >= self.finishX then
                self.referenceFinished = true
                self.referenceFinishElapsed = self.elapsed
                SetUnitAnimation(self.referenceRunner, "stand")
                PauseUnit(self.referenceRunner, true)
                if self.routeTimer ~= nil then PauseTimer(self.routeTimer) end
                if not self.runnerFinished then
                    self.runnerTargetX = self.finishX + 256
                    self.runnerTargetY = GetUnitY(self.runner)
                    self:issueRunnerOrder()
                end
            end
        end
        self.tickCount = self.tickCount + 1
        if not self.runnerFinished then
            if GetWidgetLife(self.blocker) <= 0.405 or
                (not self.successfulBlock and GetUnitX(self.runner) - GetUnitX(self.blocker) >= self.failGap) then
                self:failRun()
                return
            end
            self:updateFeedback()
            if GetUnitX(self.runner) >= self.finishX then
                self.runnerFinished = true
                self.runnerFinishElapsed = self.elapsed
                PauseUnit(self.runner, true)
            end
        end
        if self.runnerFinished and self.referenceFinished then
            self:finishRun(false)
            return
        end
        if self.referenceFinished and not self.runnerFinished and
            self.elapsed >= self.referenceFinishElapsed + self.maxDelay then
            self:finishRun(true)
            return
        end
    end

    function activity:pauseRound()
        self.running = false
        if self.runTimer ~= nil then PauseTimer(self.runTimer) end
        if self.routeTimer ~= nil then PauseTimer(self.routeTimer) end
        if self.runner ~= nil then PauseUnit(self.runner, true) end
        if self.referenceRunner ~= nil then PauseUnit(self.referenceRunner, true) end
        if self.blocker ~= nil then PauseUnit(self.blocker, true) end
        self:clearFeedback()
    end

    function activity:setPaused(paused)
        local nextState = paused == true
        if self.locallyPaused == nextState then return end
        self.locallyPaused = nextState
    end

    function activity:renderResultPresentation()
        if self.resultCard == nil or self.resultTitleText == nil then return end
        local hasReplay = self.replaySamples ~= nil and #self.replaySamples > 0
        JTG.UI.ShowResultCard(self.resultCard, {
            title = self.resultTitleText,
            tone = self.resultTone,
            details = self.resultDetailsText or "",
            actions = {
                replay = {enabled = hasReplay},
                retry = {},
                next = self.mode == "training" and
                    {label = "Next Runner", enabled = not self.raceComplete} or nil,
                menu = {},
            },
        })
    end

    function activity:finishRun(maxed)
        if self.finished then return end
        self.finished = true
        self:pauseRound()
        if maxed then
            self.addedDelay = self.maxDelay
        else
            self.addedDelay = math.min(self.maxDelay, math.max(0,
                self.runnerFinishElapsed - self.referenceFinishElapsed))
        end
        local score = math.min(100, math.floor((self.addedDelay / self.maxDelay) * 100 + 0.5))
        self.advancePending = self.mode == "training"
        if self.mode == "training" then
            self.raceResults[self.runnerIndex] = {
                name = self.runnerName, score = score, delay = self.addedDelay,
                contacts = self.collisionCount, streak = self.bestStreak,
            }
            self.raceComplete = self.runnerIndex >= #TRAINING_ROSTERS[self.race]
        end
        self.resultTitleText = self.raceComplete and
            (string.upper(self.race) .. " ROSTER COMPLETE") or
            (maxed and "MAXIMUM DELAY!" or "RUN COMPLETE")
        self.resultTone = self.raceComplete and "neutral" or
            (maxed and "success" or "neutral")
        local nextText = self.mode == "training" and
            '|cffccccccPress |r|cffd7bd6aNext Runner|r|cffcccccc to advance!|r' or
            'Press "Redo" to retry this custom matchup.'
        local details = self.blockerName .. " vs " .. self.runnerName .. "|n" ..
            "Added delay: |cff80ff80+" .. string.format("%.1f", self.addedDelay) .. "s|r   Score: " .. score .. "/100|n" ..
            "Blocking contacts: " .. tostring(self.collisionCount) .. "   Best streak: " .. string.format("%.1f", self.bestStreak) .. "s|n" ..
            (self.mode == "training" and nextText or "|cffcccccc" .. nextText .. "|r")
        if self.raceComplete then
            details = "|cffccccccResults against the " .. self.race .. " roster:|r|n"
            for _, result in ipairs(self.raceResults) do
                details = details .. result.name .. ": |cff80ff80+" .. string.format("%.1f", result.delay) ..
                    "s|r  " .. tostring(result.score) .. "/100  " .. tostring(result.contacts) .. " contacts|n"
            end
            details = details .. "|cffccccccPress |r|cffd7bd6aMenu|r|cffcccccc to choose another format.|r"
        end
        self.resultDetailsText = details
        self:renderResultPresentation()
        BlzFrameSetVisible(self.speedFrame, false)
        self:setOverlayVisible(false)
        if JTG.UI then JTG.UI.HideToolbar() end
    end

    function activity:restorePresentation()
        self.presentationVisible = true
        self:updateSquareOverlays()
        if self.replaying then
            BlzFrameSetVisible(self.resultBackdrop, false)
            if JTG.UI then
                JTG.UI.ShowToolbar(session.descriptor.capabilities)
                JTG.UI.SetNextText("Next Runner")
                JTG.UI.SetNextEnabled(self.mode == "training" and
                    self.runnerIndex < #TRAINING_ROSTERS[self.race])
            end
        elseif self.finished then
            self:setOverlayVisible(false)
            self:renderResultPresentation()
            if JTG.UI then JTG.UI.HideToolbar() end
        elseif JTG.UI then
            self:setOverlayVisible(true)
            JTG.UI.ShowToolbar(session.descriptor.capabilities)
            JTG.UI.SetSquaresActive(self.squaresVisible)
            JTG.UI.SetLastRunnerEnabled(self.mode == "training" and self.runnerIndex > 1)
            JTG.UI.SetNextText("Next Runner")
            JTG.UI.SetNextEnabled(self.mode == "training" and
                self.runnerIndex < #TRAINING_ROSTERS[self.race])
        end
    end

    function activity:hidePresentationForMenu()
        self.presentationVisible = false
        self:updateSquareOverlays()
        self:setOverlayVisible(false)
        if self.resultBackdrop ~= nil then
            BlzFrameSetVisible(self.resultBackdrop, false)
        end
    end

    function activity:rebuildPresentation()
        self.resultCard = nil
        self.resultBackdrop = nil
        self.countdownFrame = nil
        self.speedFrame = nil
        self.startLine = nil
        self.finishLine = nil
        self.startTag = nil
        self.finishTag = nil
        self.courseTags = {}
        self.squareEntries = {}
        self.navigationGridImages = JTG.CreateNavigationGridOverlay(
            session.presentationScope, session.scene)
        self.navigationDotsImages = JTG.CreateNavigationDotsOverlay(
            session.presentationScope, session.scene)
        self:createCountdownUI()
        self:createSpeedUI()
        self:createResultUI()
        if self.startX ~= nil and self.finishX ~= nil and self.laneY ~= nil then
            self:createCourseMarkers()
        end
        if self.runnerName ~= nil and self.moveSpeed ~= nil and
                self.turnRate ~= nil then
            BlzFrameSetText(self.speedFrame, "|cffffcc00" .. self.runnerName ..
                "|r  Movement Speed " ..
                tostring(math.floor(self.moveSpeed + 0.5)) ..
                "   Turn Rate " .. string.format("%.2f", self.turnRate))
        end
        if self.countdownActive then
            BlzFrameSetText(self.countdownFrame, "|cffffcc00" ..
                tostring(self.countdownValue or 3) .. "|r")
        end
        if self.finished and not self.replaying then
            self:renderResultPresentation()
            self:setOverlayVisible(false)
        else
            self:setOverlayVisible(true)
        end
        self.presentationVisible = true
        self:createSquareOverlays()
    end

    function activity:discardPresentationForLoad()
        self.resultCard = nil
        self.resultBackdrop = nil
        if self.startLine ~= nil then DestroyLightning(self.startLine) end
        if self.finishLine ~= nil then DestroyLightning(self.finishLine) end
        for _, tag in ipairs(self.courseTags or {}) do
            if tag ~= nil then DestroyTextTag(tag) end
        end
        self.startLine = nil
        self.finishLine = nil
        self.startTag = nil
        self.finishTag = nil
        self.courseTags = {}
        for _, entry in ipairs(self.squareEntries or {}) do
            if entry.image ~= nil then DestroyImage(entry.image) end
        end
        for _, image in ipairs(self.navigationGridImages or {}) do
            DestroyImage(image)
        end
        for _, image in ipairs(self.navigationDotsImages or {}) do
            DestroyImage(image)
        end
        self.squareEntries = {}
        self.navigationGridImages = {}
        self.navigationDotsImages = {}
    end

    function activity:failRun()
        if self.finished then return end
        self.finished = true
        self.advancePending = false
        self:pauseRound()
        SetUnitFacingToFaceUnitTimed(self.starter, self.blocker, 0)
        SetUnitAnimation(self.starter, "attack")
        QueueUnitAnimation(self.starter, "stand")
        SetUnitInvulnerable(self.blocker, false)
        UnitDamageTarget(self.starter, self.blocker, 100000, true, false,
            ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
        if GetWidgetLife(self.blocker) > 0.405 then KillUnit(self.blocker) end
        DisplayTimedTextToPlayer(Player(0), 0, 0, 2,
            "|cffff6060BLOCKER FELL BEHIND|r  Resetting in 2 seconds.")
        self:makeTimer(2.0, false, function() JTG.ResetActivity() end)
    end

    function activity:setup(current)
        local scene = current.scene
        self.startX = scene.centerX - 1200
        self.finishX = scene.centerX + 1200
        self.laneY = scene.centerY
        self.arenaMinY = scene.minY
        self.arenaMaxY = scene.maxY
        self.navigationGridImages = JTG.CreateNavigationGridOverlay(
            session.presentationScope, scene)
        self.navigationDotsImages = JTG.CreateNavigationDotsOverlay(
            session.presentationScope, scene)
        self.squareUpdateTimer = self:makeTimer(0.03, true,
            function() self:updateSquareOverlays() end)

        local quest = JTG.ScopeTrackQuest(current.scope, CreateQuest())
        QuestSetTitle(quest, "On Pathfinding and Movement")
        QuestSetDescription(quest, BODY_BLOCKING_QUEST_TEXT)
        QuestSetIconPath(quest,
            "ReplaceableTextures\\CommandButtons\\BTNManual3.blp")
        QuestSetRequired(quest, false)
        QuestSetDiscovered(quest, true)
        QuestSetEnabled(quest, true)
        JTG.BorrowCamera(current.scope, Player(0))
        local oldTime = GetFloatGameState(GAME_STATE_TIME_OF_DAY)
        JTG.ScopeBorrow(current.scope, function() SetFloatGameState(GAME_STATE_TIME_OF_DAY, oldTime) end)
        local p0, p1 = Player(0), Player(1)
        local passive01 = GetPlayerAlliance(p0, p1, ALLIANCE_PASSIVE)
        local passive10 = GetPlayerAlliance(p1, p0, ALLIANCE_PASSIVE)
        local oldColor = GetPlayerColor(p1)
        JTG.ScopeBorrow(current.scope, function()
            SetPlayerAlliance(p0, p1, ALLIANCE_PASSIVE, passive01)
            SetPlayerAlliance(p1, p0, ALLIANCE_PASSIVE, passive10)
            SetPlayerColor(p1, oldColor)
        end)
        SetPlayerAlliance(p0, p1, ALLIANCE_PASSIVE, false)
        SetPlayerAlliance(p1, p0, ALLIANCE_PASSIVE, false)
        SetPlayerColor(p1, ConvertPlayerColor(1))
        SetFloatGameState(GAME_STATE_TIME_OF_DAY, 12)

        JTG.ResetWorldFog(p0)
        JTG.ScopeRevealScene(current.scope, scene, p0)
        self:createCountdownUI()
        self:createSpeedUI()
        self:createResultUI()
    end

    function activity:start(current)
        if GetLocalPlayer() == Player(0) then
            SetCameraPosition(current.scene.centerX, current.scene.centerY)
        end
        if self.mode == "training" or (self.mode == "custom" and self.runnerId ~= nil) then self:createRound()
        else JTG.OpenActivityMenu(session.id, JTG.Controller.lastCategory) end
    end

    function activity:captureResetState()
        local nextIndex = self.runnerIndex
        local routeTemplate = self.routeTemplate
        if self.mode == "training" and (self.nextRunnerRequested or
                (self.advancePending and not self.replaying)) then
            local roster = TRAINING_ROSTERS[self.race]
            nextIndex = nextIndex + 1
            if nextIndex > #roster then nextIndex = 1 end
            routeTemplate = nil
        end
        return {
            mode = self.mode, difficulty = self.difficulty, race = self.race,
            runnerIndex = nextIndex, runnerId = self.runnerId, runnerName = self.runnerName,
            blockerId = self.blockerId, blockerName = self.blockerName,
            raceResults = self.raceResults,
            routeTemplate = routeTemplate,
            squaresVisible = self.squaresVisible,
            squareGridVisible = self.squareGridVisible,
        }
    end

    function activity:nextStage()
        if self.mode ~= "training" or
                self.runnerIndex >= #TRAINING_ROSTERS[self.race] then
            return false
        end
        self.nextRunnerRequested = true
        JTG.ResetActivity()
        return true
    end

    function activity:captureLastRunnerState()
        if self.mode ~= "training" or self.runnerIndex <= 1 then return nil end
        return {
            mode = self.mode, difficulty = self.difficulty, race = self.race,
            runnerIndex = self.runnerIndex - 1,
            blockerId = self.blockerId, blockerName = self.blockerName,
            raceResults = self.raceResults,
            routeTemplate = nil,
        }
    end

    function activity:cleanup()
        self.replaying = false
        self:clearFeedback()
        if JTG.UI then JTG.UI.HideActivityBriefing() end
        self.runner = nil
        self.referenceRunner = nil
        self.blocker = nil
        self.starter = nil
    end

    return activity
end
