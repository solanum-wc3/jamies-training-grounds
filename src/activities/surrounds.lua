-- Surround Training: trap a runner with practical, race-specific armies.
JTG = JTG or {}

local INTRO =
    "Sometimes the best thing to do in a fight, is to run away, since any " ..
    "unit that survives the battle can be healed and fight again.\n" ..
    "Units have to stand still for a moment to do an attack, so they are " ..
    "much less effective when having to chase an enemy.\n\n" ..
    "By blocking a unit on all four sides, you can box them in and stop " ..
    "their movement completely.\n" ..
    "This can allow you to freely finish off enemy units, especially " ..
    "important ones like heroes.\n\n" ..
    "In this exercise you can practice using both abilities and units to " ..
    "surround units."

JTG.SurroundHowToQuestText =
    "To surround an enemy, you have to block them in all four cardinal " ..
    "directions (right, left, up, down).\n" ..
    "This means the minimum amount of units you need for a successful " ..
    "surround, is four.\n" ..
    "The size of your units and of the units you want to surround does not " ..
    "matter for this. Four Peasants can surround a Kodo! (You will need " ..
    "five though, in case one gets eaten!)\n\n" ..
    "One way to do this is send one unit to each the four sides.\n" ..
    "This is simple, but it is very hard to do in the heat of battle.\n\n" ..
    "Another way is to select all of your units while they are already " ..
    "standing arranged around the enemy unit.\n" ..
    "Then you spam {Term: Move} commands on the enemy, which requires using " ..
    "the {Input: hotkey} and clicking, about four or five times in a row.\n" ..
    "This is easier, but you have to hope for the best.\n" ..
    "It might require you make some quick adjustments for one or two of " ..
    "your units, to close off a side.\n\n" ..
    "Lastly, you can purposefully arrange your units in a wide cross " ..
    "shape, meaning they are already arranged in something like the final " ..
    "position, with one in every cardinal direction, and an empty space in " ..
    "the middle.\n" ..
    "Then you give them a {Term: Move} command that makes them run diagonally " ..
    "across the path of the enemy unit, so the enemy unit ends up in the " ..
    "middle of the formation without displacing anyone.\n" ..
    "Then you spam {Term: Move} commands on the enemy, which requires using " ..
    "the {Input: hotkey} and clicking, about four or five times in a row.\n" ..
    "This has a better chance of success, but you might still have to make " ..
    "a quick adjustment or two.\n\n" ..
    "No matter the method, this is a pretty micro intensive skill."

JTG.SurroundHowItWorksQuestText =
    "Surrounding exploits a fundamental aspect of Warcraft III's engine.\n\n" ..
    "Under the hood, every unit blocks movement with a square-shaped area.\n" ..
    "Some are bigger and some are smaller, but they all have four equal " ..
    "sides.\n" ..
    "This square always faces the same direction and does not turn with " ..
    "the unit.\n\n" ..
    "For this reason, the unit can move through smaller spaces when moving " ..
    "straight up and down or side to side, compared to moving diagonally.\n\n" ..
    "Press the {Button: Squares} button to display these squares."

local RACES = {
    {key = "human", label = "Human"},
    {key = "orc", label = "Orc"},
    {key = "undead", label = "Undead"},
    {key = "nightelf", label = "Night Elf"},
    {key = "neutral", label = "Neutral"},
}

local SETUPS = {
    human = {
        {name = "Mountain King 1", units = {{"Hmkg", 1, "AHtb"}, {"hfoo", 4}}},
        {name = "Mountain King 2", units = {{"Hmkg", 1, "AHtc"}, {"hfoo", 4}}},
        {name = "Blood Mage", units = {{"Hblm", 1, "AHbn"}, {"hfoo", 4}}},
        {name = "Sorceresses", units = {{"hsor", 2}, {"hfoo", 4}}},
        {name = "Militia", units = {{"hmil", 8}}},
        {name = "Peasants", units = {{"hpea", 8}}},
        {name = "Footmen", units = {{"hfoo", 6}}},
        {name = "Knights", units = {{"hkni", 4}}},
    },
    orc = {
        {name = "Shadow Hunter", units = {{"Oshd", 1, "AOhx"}, {"ogru", 4}}},
        {name = "Tauren Chieftain", units = {{"Otch", 1, "AOws"}, {"ogru", 4}}},
        {name = "Shamans", units = {{"oshm", 2}, {"ogru", 4}}},
        {name = "Raiders", units = {{"orai", 2}, {"ogru", 4}}},
        {name = "Peons", units = {{"opeo", 8}}},
        {name = "Grunts", units = {{"ogru", 6}}},
        {name = "Taurens", units = {{"otau", 4}}},
    },
    undead = {
        {name = "Dread Lord", units = {{"Udre", 1, "AUsl"}, {"ugho", 4}}},
        {name = "Crypt Lord", units = {{"Ucrl", 1, "AUim"}, {"ugho", 6}}},
        {name = "Lich", units = {{"Ulic", 1, "AUfn"}, {"ugho", 5}}},
        {name = "Necromancers", units = {{"unec", 2, {"Arai", "Auhf", "Acri"}}, {"ugho", 4}}},
        {name = "Frost Wyrm", units = {{"ufro", 1}, {"ugho", 5}}},
        {name = "Ghouls", units = {{"ugho", 6}}},
        {name = "Crypt Fiends", units = {{"ucry", 5}}},
    },
    nightelf = {
        {name = "Keeper of the Grove", units = {{"Ekee", 1, "AEer"}, {"esen", 4}}},
        {name = "Dryads", units = {{"edry", 4}, {"earc", 4}}},
        {name = "Huntresses", units = {{"esen", 6}}},
    },
    neutral = {
        {name = "Naga Sea Witch", units = {{"Nngs", 1, "ANfa"}, {"hfoo", 5}}},
        {name = "Pandaren Brewmaster", units = {{"Npbm", 1, "ANdh"}, {"ogru", 5}}},
        {name = "Forsaken Paladin", units = {{"Npal", 1, "ANrf"}, {"ugho", 5}}},
    },
}

local RUNNERS = {
    {id = FourCC("ogru"), name = "Grunt"},
    {id = FourCC("Edem"), name = "Demon Hunter"},
}

local DISABLING_BUFFS = {
    FourCC("BHtb"), -- Storm Bolt
    FourCC("BOhx"), -- Hex
    FourCC("BOws"), -- War Stomp
    FourCC("BUsl"), -- Sleep
    FourCC("BUim"), -- Impale
    FourCC("BEer"), -- Entangling Roots
}

function JTG.FormatSurroundQuestText(text)
    local formatted = text:gsub("{Button:%s*(.-)}", "|cffffcc00%1|r")
    formatted = formatted:gsub("{Term:%s*(.-)}", "|cffff9933%1|r")
    return formatted:gsub("{Input:%s*(.-)}", "|cff80ff80%1|r")
end

local function AddButton(scope, parent, name, label, width, height, action)
    local button = JTG.ScopeTrackFrame(scope, BlzCreateFrameByType("GLUETEXTBUTTON",
        name, parent, "ScriptDialogButton", 0))
    BlzFrameSetSize(button, width, height)
    BlzFrameSetText(button, label)
    local trigger = JTG.ScopeTrackTrigger(scope, CreateTrigger())
    BlzTriggerRegisterFrameEvent(trigger, button, FRAMEEVENT_CONTROL_CLICK)
    TriggerAddAction(trigger, function()
        if JTG.UI and JTG.UI.PlayButtonSound then
            JTG.UI.PlayButtonSound("normal")
        end
        if JTG.UI and JTG.UI.ReleaseFrameFocus then
            JTG.UI.ReleaseFrameFocus(BlzGetTriggerFrame())
        end
        action()
        if JTG.UI and JTG.UI.ReleaseKeyboardFocusAfterClick then
            JTG.UI.ReleaseKeyboardFocusAfterClick()
        end
    end)
    return button
end

local function TrainAbilities(unit, abilities)
    if abilities == nil then return end
    if type(abilities) == "string" then abilities = {abilities} end
    if IsUnitType(unit, UNIT_TYPE_HERO) then
        for _, rawcode in ipairs(abilities) do
            SelectHeroSkill(unit, FourCC(rawcode))
        end
        SetUnitState(unit, UNIT_STATE_MANA, BlzGetUnitMaxMana(unit))
    else
        for _, rawcode in ipairs(abilities) do
            UnitAddAbility(unit, FourCC(rawcode))
        end
    end
end

function JTG.OpenSurroundsMenu(originCategory, pauseGame, restorePage,
        restoreData)
    local active = JTG.Controller.session
    local returning = active ~= nil and active.id == "skills.surround"
    local selection = {race = "human", setupIndex = 1, runnerIndex = 1}
    for key, value in pairs((active and active.restartData) or {}) do
        selection[key] = value
    end
    for key, value in pairs(restoreData or {}) do selection[key] = value end

    local function releasePause()
        if JTG.UI then JTG.UI.SetGameplayMenuPaused(false) end
    end
    local function resume()
        releasePause()
        JTG.ResumeActivity()
    end
    local function launch(race)
        releasePause()
        selection.race = race
        selection.setupIndex = 1
        selection.runnerIndex = 1
        local data = {
            race = race, setupIndex = 1, runnerIndex = 1,
            skipIntro = returning,
        }
        if JTG.Controller.session ~= nil then
            JTG.StartActivityAfterCleanup("skills.surround",
                originCategory or "skills", data, nil, "briefing-restart")
        else
            JTG.StartActivity("skills.surround", originCategory or "skills", data)
        end
    end
    local showRoot, showRaces
    local function show(spec, page)
        spec.title = "Surrounds"
        spec.activityId = "skills.surround"
        spec.originCategory = originCategory or "skills"
        spec.headingArtwork = "JTGMenu\\SurroundsBriefing.dds"
        spec.headingArtworkWidth = 0.176
        spec.headingArtworkHeight = 0.086
        spec.body = INTRO
        spec.pageId = page
        spec.restoreData = selection
        spec.pauseGame = pauseGame == true
        if pauseGame then
            spec.resumeAction = resume
            spec.exitAction = function()
                JTG.StopActivity("menu-exit")
                pauseGame = false
                returning = false
                showRoot()
            end
        end
        JTG.UI.ShowActivityBriefing(spec)
    end
    showRoot = function()
        show({
            choices = {
                {label = "Start Training", primary = true,
                    action = showRaces},
            },
            centerSingleChoice = true,
            backAction = function()
                if pauseGame then JTG.UI.ShowCategory(originCategory or "skills")
                else JTG.UI.ShowCategory(originCategory or "skills") end
            end,
        }, "root")
    end
    showRaces = function()
        local choices = {}
        for _, race in ipairs(RACES) do
            local key, label = race.key, race.label
            table.insert(choices, {label = label, primary = true,
                action = function() launch(key) end})
        end
        show({
            choices = choices,
            compactChoices = true,
            compactColumns = 2,
            choiceOffsetY = -0.045,
            backAction = showRoot,
        }, "races")
    end
    if restorePage == "races" then
        showRaces()
    else
        showRoot()
    end
end

function JTG.CreateSurroundsActivity(session)
    local data = session.restartData or {}
    local activity = {
        race = data.race or "human",
        setupIndex = data.setupIndex or 1,
        runnerIndex = data.runnerIndex or 1,
        skipIntro = data.skipIntro == true,
        army = {},
        runner = nil,
        running = false,
        finished = false,
        countdownActive = false,
        runnerWaiting = false,
        countdownValue = 3,
        locallyPaused = false,
        setupsOpen = false,
        presentationVisible = true,
        holdTime = 0,
        healElapsed = 0,
        previousRunnerX = nil,
        previousRunnerY = nil,
        squaresVisible = data.squaresVisible == true,
        squareEntries = {},
    }

    function activity:makeTimer(period, repeating, callback)
        return JTG.StartScopedTimer(session, session.scope, period, repeating,
            callback)
    end

    function activity:currentSetup()
        local list = SETUPS[self.race] or SETUPS.human
        self.setupIndex = math.max(1, math.min(#list, self.setupIndex))
        return list[self.setupIndex], list
    end

    function activity:captureResetState()
        return {
            race = self.race, setupIndex = self.setupIndex,
            runnerIndex = self.runnerIndex, skipIntro = true,
            squaresVisible = self.squaresVisible,
        }
    end

    function activity:hasNextRun()
        local _, list = self:currentSetup()
        return self.runnerIndex == 1 or self.setupIndex < #list
    end

    function activity:nextStage()
        if not self:hasNextRun() then return false end
        if self.runnerIndex == 1 then
            self.runnerIndex = 2
        else
            self.setupIndex = self.setupIndex + 1
            self.runnerIndex = 1
        end
        self:setSetupsOpen(false)
        JTG.ResetActivity()
        return true
    end

    function activity:createCourseMarkers()
        self.startLine = JTG.ScopeTrackLightning(session.presentationScope,
            AddLightning("DRAL", false, self.startX, self.arenaMinY,
                self.startX, self.arenaMaxY))
        self.finishLine = JTG.ScopeTrackLightning(session.presentationScope,
            AddLightning("DRAL", false, self.finishX, self.arenaMinY,
                self.finishX, self.arenaMaxY))
        if self.startLine ~= nil then
            SetLightningColor(self.startLine, 0.25, 1.0, 0.25, 0.90)
        end
        if self.finishLine ~= nil then
            SetLightningColor(self.finishLine, 1.0, 0.30, 0.25, 0.90)
        end
        self.startTag = JTG.ScopeTrackTextTag(session.presentationScope, CreateTextTag())
        SetTextTagText(self.startTag, "START", 0.022)
        SetTextTagPos(self.startTag, self.startX - 70, self.laneY + 590, 24)
        SetTextTagColor(self.startTag, 100, 255, 100, 255)
        self.finishTag = JTG.ScopeTrackTextTag(session.presentationScope, CreateTextTag())
        SetTextTagText(self.finishTag, "FINISH", 0.022)
        SetTextTagPos(self.finishTag, self.finishX - 85, self.laneY + 590, 24)
        SetTextTagColor(self.finishTag, 255, 100, 80, 255)
    end

    function activity:createSquareOverlays()
        self.squareEntries = {}
        if self.runner ~= nil then
            self:addSquareOverlay(self.runner,
                JTG.UnitSquareEnemyTexture)
        end
        for _, unit in ipairs(self.army) do
            self:addSquareOverlay(unit,
                JTG.UnitSquarePlayerTexture)
        end
    end

    function activity:updateSquareOverlays()
        for _, entry in ipairs(self.squareEntries) do
            if entry.unit ~= nil and GetUnitTypeId(entry.unit) ~= 0 then
                SetImagePosition(entry.image,
                    GetUnitX(entry.unit) - entry.half,
                    GetUnitY(entry.unit) - entry.half, 2)
                ShowImage(entry.image,
                    self.squaresVisible and self.presentationVisible)
            end
        end
    end

    function activity:addSquareOverlay(unit, texture)
        local collision = BlzGetUnitCollisionSize(unit)
        local half = JTG.UnitObstructionHalfSize(collision)
        local size = half * 2.0
        local image = JTG.ScopeTrackImage(session.presentationScope,
            CreateImage(texture, size, size, 0,
                GetUnitX(unit) - half, GetUnitY(unit) - half, 2,
                0, 0, 0, 2))
        SetImageRenderAlways(image, true)
        SetImageAboveWater(image, true, true)
        ShowImage(image, self.squaresVisible and self.presentationVisible)
        local entry = {unit = unit, image = image, half = half}
        table.insert(self.squareEntries, entry)
    end

    function activity:toggleSquares()
        self.squaresVisible = not self.squaresVisible
        self:updateSquareOverlays()
        if JTG.UI and JTG.UI.SetSquaresActive then
            JTG.UI.SetSquaresActive(self.squaresVisible)
        end
    end

    function activity:createCountdownUI()
        local gameUI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        self.countdownFrame = JTG.ScopeTrackFrame(session.presentationScope,
            BlzCreateFrameByType("TEXT", "JTGSurroundCountdown", gameUI, "", 0))
        BlzFrameSetSize(self.countdownFrame, 0.20, 0.08)
        BlzFrameSetAbsPoint(self.countdownFrame, FRAMEPOINT_CENTER, 0.40, 0.38)
        BlzFrameSetTextAlignment(self.countdownFrame, TEXT_JUSTIFY_MIDDLE,
            TEXT_JUSTIFY_CENTER)
        BlzFrameSetScale(self.countdownFrame, 2.45)
        BlzFrameSetEnable(self.countdownFrame, false)
        BlzFrameSetVisible(self.countdownFrame, false)
    end

    function activity:createStatusUI()
        local gameUI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        self.statusFrame = JTG.ScopeTrackFrame(session.presentationScope,
            BlzCreateFrameByType("TEXT", "JTGSurroundStatus", gameUI, "", 0))
        BlzFrameSetSize(self.statusFrame, 0.58, 0.045)
        BlzFrameSetAbsPoint(self.statusFrame, FRAMEPOINT_TOP, 0.40, 0.505)
        BlzFrameSetTextAlignment(self.statusFrame, TEXT_JUSTIFY_MIDDLE,
            TEXT_JUSTIFY_CENTER)
        BlzFrameSetScale(self.statusFrame, 1.20)
        BlzFrameSetEnable(self.statusFrame, false)
    end

    function activity:updateStatus()
        local setup = self:currentSetup()
        local runner = RUNNERS[self.runnerIndex]
        local hold = math.min(100, math.floor(self.holdTime / 3.0 * 100 + 0.5))
        BlzFrameSetText(self.statusFrame,
            "|cffffcc00" .. setup.name .. "|r  vs " .. runner.name ..
            "   Still " .. tostring(hold) .. "%")
    end

    activity.resultActions = {
        next = function(self)
            if self.resultAction == "finish" then
                JTG.ExitActivity()
                return
            end
            if self.resultAction == "next_round" then
                self.runnerIndex = 2
            elseif self.resultAction == "next_setup" then
                self.setupIndex = self.setupIndex + 1
                self.runnerIndex = 1
            end
            JTG.ResetActivity()
        end,
    }

    function activity:createResultUI()
        self.resultCard = JTG.UI.CreateResultCard(session, {
            name = "JTGSurroundResult", width = 0.36,
            detailsHeight = 0.060, centerY = 0.33,
        })
        self.resultPanel = self.resultCard.panel
    end

    function activity:renderResultPresentation(visible)
        if self.resultCard == nil or self.resultTitleText == nil then return end
        JTG.UI.ShowResultCard(self.resultCard, {
            title = self.resultTitleText,
            tone = self.resultTone,
            details = self.resultDetailsText or "",
            visible = visible ~= false,
            actions = {
                replay = {},
                next = self.resultAction ~= "retry" and
                    {label = self.resultPrimaryLabel or "Next"} or nil,
                menu = {},
            },
        })
    end

    function activity:createSetupsUI()
        local gameUI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        local _, list = self:currentSetup()
        local panelHeight = JTG.TutorialMenuHeight(#list) + 0.015
        self.setupsPanel = JTG.ScopeTrackFrame(session.presentationScope,
            JTG.UI.CreateNativePanel("JTGSurroundSetups", gameUI, 0.20,
                panelHeight))
        BlzFrameSetAbsPoint(self.setupsPanel, FRAMEPOINT_TOPRIGHT, 0.795, 0.485)
        self.setupButtons = {}
        for index, setup in ipairs(list) do
            local setupIndex = index
            local button = AddButton(session.presentationScope,
                self.setupsPanel, "JTGSurroundSetup" .. tostring(index),
                setup.name, 0.155, 0.026, function()
                    self.setupIndex = setupIndex
                    self.runnerIndex = 1
                    self.setupsOpen = false
                    JTG.ResetActivity()
                end)
            BlzFrameSetPoint(button, FRAMEPOINT_TOP, self.setupsPanel,
                FRAMEPOINT_TOP, 0, -0.038 - (index - 1) * 0.029)
            self.setupButtons[index] = button
        end
        local close = AddButton(session.presentationScope, self.setupsPanel,
            "JTGSurroundSetupsClose", "Close", 0.10, 0.026,
            function() self:setSetupsOpen(false) end)
        BlzFrameSetPoint(close, FRAMEPOINT_BOTTOM, self.setupsPanel,
            FRAMEPOINT_BOTTOM, 0, 0.025)
        BlzFrameSetVisible(self.setupsPanel, false)
    end

    function activity:setSetupsOpen(open)
        self.setupsOpen = open == true
        if self.setupsPanel ~= nil then
            BlzFrameSetVisible(self.setupsPanel,
                self.presentationVisible and self.setupsOpen)
        end
        PauseUnit(self.runner, self.locallyPaused or self.setupsOpen or
            self.countdownActive or self.runnerWaiting or self.finished)
        for _, unit in ipairs(self.army) do
            PauseUnit(unit, self.locallyPaused or self.setupsOpen or
                self.countdownActive or self.finished)
        end
    end

    function activity:toggleSetups()
        if self.finished then return end
        self:setSetupsOpen(not self.setupsOpen)
    end

    function activity:setOverlayVisible(visible)
        self.presentationVisible = visible == true
        if self.statusFrame ~= nil then
            BlzFrameSetVisible(self.statusFrame,
                self.presentationVisible and not self.finished)
        end
        if self.countdownFrame ~= nil then
            BlzFrameSetVisible(self.countdownFrame,
                self.presentationVisible and self.countdownActive)
        end
        if self.setupsPanel ~= nil then
            BlzFrameSetVisible(self.setupsPanel,
                self.presentationVisible and self.setupsOpen)
        end
        if self.resultPanel ~= nil then
            BlzFrameSetVisible(self.resultPanel,
                self.presentationVisible and self.finished)
        end
        if self.startTag ~= nil then SetTextTagVisibility(self.startTag, visible) end
        if self.finishTag ~= nil then SetTextTagVisibility(self.finishTag, visible) end
        self:updateSquareOverlays()
    end

    function activity:spawnArmy()
        local setup = self:currentSetup()
        local specs = setup.units
        local total = 0
        for _, spec in ipairs(specs) do total = total + spec[2] end
        local number = 0
        for _, spec in ipairs(specs) do
            local unitId = FourCC(spec[1])
            for _ = 1, spec[2] do
                number = number + 1
                local angle = 2 * math.pi * (number - 1) / total
                local radius = 190
                local x = self.finishX + math.cos(angle) * radius
                local y = self.laneY + math.sin(angle) * radius
                local unit = JTG.ScopeTrackUnit(session.scope,
                    BlzCreateUnitWithSkin(Player(0), unitId,
                        x, y, 180, unitId))
                SetUnitAcquireRange(unit, 0)
                TrainAbilities(unit, spec[3])
                PauseUnit(unit, true)
                table.insert(self.army, unit)
            end
        end
        if GetLocalPlayer() == Player(0) then
            ClearSelection()
            for _, unit in ipairs(self.army) do SelectUnit(unit, true) end
        end
    end

    function activity:spawnRunner()
        local runnerData = RUNNERS[self.runnerIndex]
        self.runner = JTG.ScopeTrackUnit(session.scope,
            BlzCreateUnitWithSkin(Player(1), runnerData.id, self.startX,
                self.laneY, 0, runnerData.id))
        SetUnitAcquireRange(self.runner, 0)
        PauseUnit(self.runner, true)
        self.previousRunnerX = GetUnitX(self.runner)
        self.previousRunnerY = GetUnitY(self.runner)
    end


    function activity:beginRun()
        self.running = true
        self.countdownActive = false
        self.runnerWaiting = true
        PauseUnit(self.runner, true)
        for _, unit in ipairs(self.army) do PauseUnit(unit, false) end
        BlzFrameSetText(self.countdownFrame, "|cff80ff80GO!|r")
        self:makeTimer(0.65, false, function()
            BlzFrameSetVisible(self.countdownFrame, false)
        end)
        self:makeTimer(2.0, false, function()
            if self.finished then return end
            self.runnerWaiting = false
            PauseUnit(self.runner,
                self.locallyPaused or self.setupsOpen or self.finished)
            IssuePointOrder(self.runner, "move", self.finishX + 300, self.laneY)
        end)
    end

    function activity:countdownTick()
        if self.locallyPaused then return end
        if self.countdownValue > 1 then
            self.countdownValue = self.countdownValue - 1
            BlzFrameSetText(self.countdownFrame, "|cffffcc00" ..
                tostring(self.countdownValue) .. "|r")
        else
            PauseTimer(self.countdownTimer)
            self.countdownValue = 0
            self:beginRun()
        end
    end

    function activity:finish(success, reason)
        if self.finished then return end
        self.finished = true
        self.running = false
        PauseUnit(self.runner, true)
        for _, unit in ipairs(self.army) do PauseUnit(unit, true) end
        self:setSetupsOpen(false)
        local _, list = self:currentSetup()
        if success then
            self.resultTitleText = "SURROUND COMPLETE"
            self.resultTone = "success"
            if self.runnerIndex == 1 then
                self.resultAction = "next_round"
                self.resultPrimaryLabel = "Next Round"
                self.resultDetailsText =
                    "The Grunt stayed fully surrounded.\nNext: Demon Hunter."
            elseif self.setupIndex < #list then
                self.resultAction = "next_setup"
                self.resultPrimaryLabel = "Next Setup"
                self.resultDetailsText =
                    "Both runners were surrounded with this setup."
            else
                self.resultAction = "finish"
                self.resultPrimaryLabel = "Finish"
                self.resultDetailsText =
                    "You completed every " .. self.race .. " setup."
            end
        else
            self.resultAction = "retry"
            self.resultPrimaryLabel = "Retry"
            self.resultTitleText = "RUNNER ESCAPED"
            self.resultTone = "failure"
            self.resultDetailsText = reason or
                "The runner reached the finish line."
        end
        self:renderResultPresentation(false)
        if JTG.UI then JTG.UI.HideToolbar() end
        self:makeTimer(1.0, false, function()
            self:renderResultPresentation(self.presentationVisible)
        end)
    end

    function activity:update()
        if self.locallyPaused or self.setupsOpen or not self.running or
                self.finished then return end
        if GetUnitTypeId(self.runner) == 0 or
                IsUnitType(self.runner, UNIT_TYPE_DEAD) then
            self:finish(false, "The runner was killed before it was surrounded.")
            return
        end
        if self.runnerWaiting then
            self:updateSquareOverlays()
            return
        end
        self.healElapsed = self.healElapsed + 0.05
        if self.healElapsed >= 2.0 then
            self.healElapsed = self.healElapsed - 2.0
            SetWidgetLife(self.runner, BlzGetUnitMaxHP(self.runner))
        end
        if GetUnitCurrentOrder(self.runner) == 0 then
            IssuePointOrder(self.runner, "move", self.finishX + 300, self.laneY)
        end
        local x, y = GetUnitX(self.runner), GetUnitY(self.runner)
        if x >= self.finishX then
            SetUnitX(self.runner, self.finishX)
            IssueImmediateOrder(self.runner, "stop")
            self:updateSquareOverlays()
            self:finish(false, "The runner crossed the finish line.")
            return
        end
        local dx, dy = x - self.previousRunnerX, y - self.previousRunnerY
        local movement = math.sqrt(dx * dx + dy * dy)
        self.previousRunnerX, self.previousRunnerY = x, y
        self:updateSquareOverlays()
        local disabled = false
        for _, buffId in ipairs(DISABLING_BUFFS) do
            if GetUnitAbilityLevel(self.runner, buffId) > 0 then
                disabled = true
                break
            end
        end
        local activelyMoving = GetUnitCurrentOrder(self.runner) ==
            OrderId("move")
        if movement <= 2.5 and activelyMoving and not disabled then
            self.holdTime = self.holdTime + 0.05
        else
            self.holdTime = 0
        end
        self:updateStatus()
        if self.holdTime >= 3.0 then
            self:finish(true)
        end
    end

    function activity:createTrainingQuests()
        local definitions = {
            {
                title = "How to Surround",
                icon = "ReplaceableTextures\\CommandButtons\\BTNMassTeleport.blp",
                text = JTG.SurroundHowToQuestText,
                required = true,
            },
            {
                title = "How it works...",
                icon = "ReplaceableTextures\\CommandButtons\\BTNPatrol.blp",
                text = JTG.SurroundHowItWorksQuestText,
                required = false,
            },
        }
        self.quests = {}
        for _, definition in ipairs(definitions) do
            local quest = JTG.ScopeTrackQuest(session.scope, CreateQuest())
            QuestSetTitle(quest, definition.title)
            QuestSetDescription(quest,
                JTG.FormatSurroundQuestText(definition.text))
            QuestSetIconPath(quest, definition.icon)
            QuestSetRequired(quest, definition.required)
            QuestSetDiscovered(quest, true)
            QuestSetEnabled(quest, true)
            table.insert(self.quests, quest)
        end
    end

    function activity:setup(current)
        local p0, p1 = Player(0), Player(1)
        JTG.BorrowCamera(current.scope, p0)
        local oldController = GetPlayerController(p1)
        local oldColor = GetPlayerColor(p1)
        local passive01 = GetPlayerAlliance(p0, p1, ALLIANCE_PASSIVE)
        local passive10 = GetPlayerAlliance(p1, p0, ALLIANCE_PASSIVE)
        JTG.ScopeBorrow(current.scope, function()
            SetPlayerController(p1, oldController)
            SetPlayerColor(p1, oldColor)
            SetPlayerAlliance(p0, p1, ALLIANCE_PASSIVE, passive01)
            SetPlayerAlliance(p1, p0, ALLIANCE_PASSIVE, passive10)
        end)
        SetPlayerController(p1, MAP_CONTROL_COMPUTER)
        SetPlayerColor(p1, ConvertPlayerColor(1))
        SetPlayerAlliance(p0, p1, ALLIANCE_PASSIVE, false)
        SetPlayerAlliance(p1, p0, ALLIANCE_PASSIVE, false)

        JTG.ResetWorldFog(p0)
        JTG.ScopeRevealScene(current.scope, current.scene, p0)

        self.startX = current.scene.centerX - 1200
        self.finishX = current.scene.centerX + 1200
        self.laneY = current.scene.centerY
        self.arenaMinY = current.scene.centerY - 620
        self.arenaMaxY = current.scene.centerY + 620
        self:createCourseMarkers()
        self:createTrainingQuests()
        self:createCountdownUI()
        self:createStatusUI()
        self:createResultUI()
        self:createSetupsUI()
        self:spawnRunner()
        self:spawnArmy()
        self:createSquareOverlays()
        self:updateStatus()
        self.updateTimer = self:makeTimer(0.05, true,
            function() self:update() end)
    end

    function activity:start(current)
        if GetLocalPlayer() == Player(0) then
            SetCameraPosition(current.scene.centerX, current.scene.centerY)
        end
        self.countdownActive = true
        self.countdownValue = 3
        BlzFrameSetText(self.countdownFrame, "|cffffcc003|r")
        BlzFrameSetVisible(self.countdownFrame, true)
        self.countdownTimer = self:makeTimer(1.0, true,
            function() self:countdownTick() end)
        if JTG.UI and JTG.UI.SetNextEnabled then
            JTG.UI.SetNextEnabled(self:hasNextRun())
            JTG.UI.SetSquaresActive(self.squaresVisible)
        end
        if not self.skipIntro and JTG.UI and JTG.UI.HighlightQuestButton then
            JTG.UI.HighlightQuestButton(5.0)
        end
        local setup = self:currentSetup()
        DisplayTimedTextToPlayer(Player(0), 0, 0, 5,
            "|cffffcc00" .. setup.name .. " vs " ..
            RUNNERS[self.runnerIndex].name .. "|r  Close all four sides and hold.")
    end

    function activity:setPaused(paused)
        self.locallyPaused = paused == true
        if self.runner ~= nil then
            PauseUnit(self.runner, self.locallyPaused or self.setupsOpen or
                self.countdownActive or self.runnerWaiting or self.finished)
        end
        for _, unit in ipairs(self.army) do
            PauseUnit(unit, self.locallyPaused or self.setupsOpen or
                self.countdownActive or self.finished)
        end
    end

    function activity:restorePresentation()
        self.presentationVisible = true
        self:setOverlayVisible(true)
        if self.finished then
            self:renderResultPresentation(true)
            if JTG.UI then JTG.UI.HideToolbar() end
        elseif JTG.UI then
            JTG.UI.ShowToolbar(session.descriptor.capabilities)
            JTG.UI.SetNextEnabled(self:hasNextRun())
            JTG.UI.SetSquaresActive(self.squaresVisible)
        end
    end

    function activity:hidePresentationForMenu()
        self:setOverlayVisible(false)
        JTG.UI.HideResultCard(self.resultCard)
    end

    function activity:rebuildPresentation()
        self.countdownFrame = nil
        self.statusFrame = nil
        self.resultCard = nil
        self.resultPanel = nil
        self.setupsPanel = nil
        self.startLine = nil
        self.finishLine = nil
        self.startTag = nil
        self.finishTag = nil
        self.squareEntries = {}
        self:createCourseMarkers()
        self:createCountdownUI()
        self:createStatusUI()
        self:createResultUI()
        self:createSetupsUI()
        self:createSquareOverlays()
        self:updateStatus()
        if self.finished then
            self:renderResultPresentation(true)
        end
        self:setOverlayVisible(true)
    end

    function activity:discardPresentationForLoad()
        self.resultCard = nil
        self.resultPanel = nil
        if self.startLine ~= nil then DestroyLightning(self.startLine) end
        if self.finishLine ~= nil then DestroyLightning(self.finishLine) end
        if self.startTag ~= nil then DestroyTextTag(self.startTag) end
        if self.finishTag ~= nil then DestroyTextTag(self.finishTag) end
        for _, entry in ipairs(self.squareEntries or {}) do
            if entry.image ~= nil then DestroyImage(entry.image) end
        end
        self.startLine = nil
        self.finishLine = nil
        self.startTag = nil
        self.finishTag = nil
        self.squareEntries = {}
    end

    function activity:cleanup()
        self.army = {}
        self.runner = nil
        self.quests = {}
    end

    return activity
end
