-- Windwalk Pop: use Wind Walk's native loss and restoration of collision to
-- displace a surrounded Orc unit. The normal setup teaches the isolated
-- mechanic; Hard Mode and Counterplay stage a small two-army encounter.
JTG = JTG or {}

local WINDWALK_POP_INTRO =
    "Orcs have a unique way to free a unit from being surrounded.\n" ..
    "During Blademaster's {Term: Windwalk}, he has no unit collision.\n" ..
    "This allows him \"pop out\" a surrounded unit, after getting " ..
    "collision again.\n" ..
    "In these trainings, you can practice freeing units from surrounds " ..
    "like this,\nor you can learn the counterplay against a Windwalk Pop.\n\n" ..
    "Check the {Button: Quest Log} for precise instructions!\n" ..
    "You can reset the training using the {Button: Redo} button."

local WINDWALK_POP_QUEST_TEXT =
    "The Blademaster loses unit collision immediately upon using his Wind " ..
    "Walk ability.\n\n" ..
    "He regains it immediately after ending the effect.\n\n" ..
    "This does not immediately push him and other units apart. That only " ..
    "happens once one of them moves.\n\n\n" ..
    "Keeping that in mind, here is the order of operations on how to " ..
    "perform a Windwalk Pop.\n\n" ..
    "1. Use {Term: Wind Walk}.\n" ..
    "2. Run through the surrounded unit by using a {Term: Move} command " ..
    "behind it.\n" ..
    "3. When the Blademaster is exactly on it, use a {Term: Stop} or " ..
    "{Term: Hold Position} command.\n" ..
    "4. Attack one of the surrounding units.\n" ..
    "5. Select the surrounded unit you want to save, and have it move " ..
    "somewhere.\n\n" ..
    "If executed correctly, the surrounded unit will pop out of the " ..
    "surround.\n\n" ..
    "Of course, now the Blademaster is surrounded, so you should not do " ..
    "this when he does not have enough mana for two Wind Walks."

local COUNTERPLAY_QUEST_TEXT =
    "Knowing you are facing a Blademaster, you can try to counterplay the " ..
    "Windwalk pop.\n\n" ..
    "To do this, you need to see it coming.\n\n" ..
    "If you now loosen the surround a bit, so the surrounded unit is still " ..
    "trapped, but so there is enough space for it and the Blademaster, the " ..
    "Windwalk Pop will instead also trap the Blademaster in the surround."

local BLADEMASTER_ID = FourCC("Obla")
local GRUNT_ID = FourCC("ogru")
local TAUREN_CHIEFTAIN_ID = FourCC("Otch")
local ARCHMAGE_ID = FourCC("Hamg")
local MOUNTAIN_KING_ID = FourCC("Hmkg")
local FOOTMAN_ID = FourCC("hfoo")
local RIFLEMAN_ID = FourCC("hrif")
local SPELL_BREAKER_ID = FourCC("hspt")
local CROWN_OF_KINGS_ID = FourCC("ckng")
local WATER_ELEMENTAL_UNIT_IDS = {
    [FourCC("hwat")] = true,
    [FourCC("hwt2")] = true,
    [FourCC("hwt3")] = true,
}

local WINDWALK_ID = FourCC("AOwk")
local CRITICAL_STRIKE_ID = FourCC("AOcr")
local WAR_STOMP_ID = FourCC("AOws")
local ENDURANCE_AURA_ID = FourCC("AOae")
local WATER_ELEMENTAL_ID = FourCC("AHwe")
local BRILLIANCE_AURA_ID = FourCC("AHab")
local STORM_BOLT_ID = FourCC("AHtb")
local STORM_BOLT_BUFF_ID = FourCC("BHtb")
local THUNDER_CLAP_ID = FourCC("AHtc")

local function FormatBriefingText(text)
    local formatted = string.gsub(text, "{Button:%s*(.-)}",
        "|cffffcc00%1|r")
    return string.gsub(formatted, "{Term:%s*(.-)}", "|cffff9933%1|r")
end

local function TrainSkill(hero, abilityId, levels)
    for _ = 1, levels do SelectHeroSkill(hero, abilityId) end
end

local function PrepareHero(hero, skills)
    SetHeroLevel(hero, 3, false)
    for _, skill in ipairs(skills) do TrainSkill(hero, skill[1], skill[2]) end
    SetUnitState(hero, UNIT_STATE_MANA, BlzGetUnitMaxMana(hero))
end

function JTG.OpenWindwalkPopMenu(originCategory, pauseGame, restorePage,
        restoreData)
    local active = JTG.Controller.session
    local returningFromRun = active ~= nil and active.id == "skills.windwalk"
    local selection = {mode = "normal"}
    for key, value in pairs((active and active.restartData) or {}) do
        selection[key] = value
    end
    for key, value in pairs(restoreData or {}) do selection[key] = value end
    local page = restorePage == "modes" and "modes" or "root"

    local function releaseMenuPause()
        if JTG.UI then JTG.UI.SetGameplayMenuPaused(false) end
    end
    local function resumeCurrentRun()
        releaseMenuPause()
        JTG.ResumeActivity()
    end
    local function launch(mode)
        releaseMenuPause()
        selection.mode = mode
        local restartData = {
            mode = mode,
            skipQuestHighlight = returningFromRun,
        }
        if JTG.Controller.session ~= nil then
            JTG.StartActivityAfterCleanup("skills.windwalk",
                originCategory or "skills", restartData, nil,
                "briefing-restart")
        else
            JTG.StartActivity("skills.windwalk", originCategory or "skills",
                restartData)
        end
    end
    local showBriefing
    showBriefing = function(nextPage)
        page = nextPage or page
        local choices
        local backAction
        if page == "modes" then
            choices = {
                {label = "Normal Mode", primary = true,
                    action = function() launch("normal") end},
                {label = "Hard Mode", primary = true,
                    action = function() launch("hard") end},
            }
            backAction = function() showBriefing("root") end
        else
            choices = {
                {label = "Start Training", primary = true,
                    action = function() showBriefing("modes") end},
                {label = "Counterplay", primary = false,
                    action = function() launch("counterplay") end},
            }
            backAction = function() JTG.UI.ShowSkillRace("orc") end
        end
        local spec = {
            title = "Windwalk Pop",
            activityId = "skills.windwalk",
            originCategory = originCategory or "skills",
            headingArtwork = "JTGMenu\\WindwalkPopBriefing.dds",
            headingArtworkWidth = 0.2214,
            headingArtworkHeight = 0.108,
            headingArtworkOffsetX = -0.010,
            headingArtworkOffsetY = -0.027,
            body = FormatBriefingText(WINDWALK_POP_INTRO),
            choices = choices,
            backAction = backAction,
            pauseGame = pauseGame == true,
            pageId = page,
            restoreData = selection,
        }
        if pauseGame then
            spec.resumeAction = resumeCurrentRun
            spec.exitAction = function()
                JTG.StopActivity("menu-exit")
                returningFromRun = false
                pauseGame = false
                showBriefing(page)
            end
        end
        JTG.UI.ShowActivityBriefing(spec)
    end
    showBriefing(page)
end

function JTG.CreateWindwalkPopActivity(session)
    local selection = session.restartData or {}
    local activity = {
        mode = selection.mode or "normal",
        blademaster = nil,
        surroundee = nil,
        humanArmy = {},
        archmage = nil,
        summonedWaterElementals = {},
        quests = {},
        highlightQuestOnStart = selection.skipQuestHighlight ~= true,
    }

    function activity:createTrainingQuests()
        local definitions = {
            {
                title = "Windwalk Pop",
                icon = "ReplaceableTextures\\CommandButtons\\BTNWindWalkOn.blp",
                text = WINDWALK_POP_QUEST_TEXT,
                required = true,
            },
            {
                title = "Counterplay",
                icon = "ReplaceableTextures\\CommandButtons\\BTNMassTeleport.blp",
                text = COUNTERPLAY_QUEST_TEXT,
                required = false,
            },
        }
        self.quests = {}
        for _, definition in ipairs(definitions) do
            local quest = CreateQuest()
            QuestSetTitle(quest, definition.title)
            QuestSetDescription(quest, FormatBriefingText(definition.text))
            QuestSetIconPath(quest, definition.icon)
            QuestSetRequired(quest, definition.required)
            QuestSetDiscovered(quest, true)
            QuestSetEnabled(quest, true)
            table.insert(self.quests, quest)
            JTG.ScopeAdd(session.scope, function()
                if quest ~= nil then DestroyQuest(quest) end
            end)
        end
    end

    function activity:createBlademaster(owner, x, y, facing)
        local hero = JTG.ScopeTrackUnit(session.scope,
            BlzCreateUnitWithSkin(owner, BLADEMASTER_ID, x, y, facing,
                BLADEMASTER_ID))
        PrepareHero(hero, {{WINDWALK_ID, 2}, {CRITICAL_STRIKE_ID, 1}})
        IssueImmediateOrder(hero, "holdposition")
        self.blademaster = hero
        return hero
    end

    function activity:createHumanArmy(owner, centerX, centerY)
        local specifications = {
            {ARCHMAGE_ID, -190.0, -300.0, 90.0},
            {MOUNTAIN_KING_ID, 190.0, -300.0, 90.0},
            {FOOTMAN_ID, -285.0, -245.0, 90.0},
            {FOOTMAN_ID, 285.0, -245.0, 90.0},
            {RIFLEMAN_ID, -95.0, -340.0, 90.0},
            {RIFLEMAN_ID, 95.0, -340.0, 90.0},
            {SPELL_BREAKER_ID, -190.0, -245.0, 90.0},
            {SPELL_BREAKER_ID, 190.0, -245.0, 90.0},
        }
        self.humanArmy = {}
        self.archmage = nil
        self.summonedWaterElementals = {}
        self.mountainKing = nil
        for _, spec in ipairs(specifications) do
            local unit = JTG.ScopeTrackUnit(session.scope,
                BlzCreateUnitWithSkin(owner, spec[1], centerX + spec[2],
                    centerY + spec[3], spec[4], spec[1]))
            if spec[1] == ARCHMAGE_ID then
                PrepareHero(unit,
                    {{WATER_ELEMENTAL_ID, 2}, {BRILLIANCE_AURA_ID, 1}})
                self.archmage = unit
            elseif spec[1] == MOUNTAIN_KING_ID then
                PrepareHero(unit, {{STORM_BOLT_ID, 2}, {THUNDER_CLAP_ID, 1}})
                self.mountainKing = unit
            end
            table.insert(self.humanArmy, unit)
        end

        local summonTrigger = JTG.ScopeTrackTrigger(session.scope,
            CreateTrigger())
        TriggerRegisterPlayerUnitEvent(summonTrigger, owner,
            EVENT_PLAYER_UNIT_SUMMON, nil)
        TriggerAddAction(summonTrigger, JTG.GuardSession(session, function()
            local summoned = GetSummonedUnit()
            if GetSummoningUnit() == self.archmage and summoned ~= nil and
                    WATER_ELEMENTAL_UNIT_IDS[GetUnitTypeId(summoned)] then
                table.insert(self.summonedWaterElementals, summoned)
            end
        end))
        JTG.ScopeAdd(session.scope, function()
            for _, summoned in ipairs(self.summonedWaterElementals) do
                if summoned ~= nil and GetUnitTypeId(summoned) ~= 0 then
                    RemoveUnit(summoned)
                end
            end
            self.summonedWaterElementals = {}
        end)
    end

    function activity:formBasicSurround(centerX, centerY)
        local positions = {
            {centerX, centerY + 200.0, 270.0},
            {centerX + 200.0, centerY, 180.0},
            {centerX, centerY - 200.0, 90.0},
            {centerX - 200.0, centerY, 0.0},
        }
        self.humanArmy = {}
        for _, point in ipairs(positions) do
            local enemy = JTG.ScopeTrackUnit(session.scope,
                BlzCreateUnitWithSkin(Player(1), FOOTMAN_ID, point[1], point[2],
                    point[3], FOOTMAN_ID))
            table.insert(self.humanArmy, enemy)
        end
        local formationStep = 0
        local timer = JTG.ScopeTrackTimer(session.scope, CreateTimer())
        TimerStart(timer, 0.25, true,
            JTG.GuardSession(session, function()
                formationStep = formationStep + 1
                for _, enemy in ipairs(self.humanArmy) do
                    if formationStep <= 5 then
                        IssueTargetOrder(enemy, "move", self.surroundee)
                    else
                        IssuePointOrder(enemy, "attack",
                            GetUnitX(self.surroundee), GetUnitY(self.surroundee))
                    end
                end
                if formationStep > 5 then PauseTimer(timer) end
            end))
    end

    function activity:adjustOpenCardinalSides()
        local tcX = GetUnitX(self.surroundee)
        local tcY = GetUnitY(self.surroundee)
        local sides = {
            {name = "east", x = 1.0, y = 0.0, occupied = false},
            {name = "west", x = -1.0, y = 0.0, occupied = false},
            {name = "north", x = 0.0, y = 1.0, occupied = false},
            {name = "south", x = 0.0, y = -1.0, occupied = false},
        }
        local available = {}
        for _, unit in ipairs(self.humanArmy) do
            local dx = GetUnitX(unit) - tcX
            local dy = GetUnitY(unit) - tcY
            local assigned = false
            if dx >= 45.0 and dx <= 110.0 and math.abs(dy) <= 65.0 then
                sides[1].occupied = true
                assigned = true
            elseif dx <= -45.0 and dx >= -110.0 and
                    math.abs(dy) <= 65.0 then
                sides[2].occupied = true
                assigned = true
            elseif dy >= 45.0 and dy <= 110.0 and
                    math.abs(dx) <= 65.0 then
                sides[3].occupied = true
                assigned = true
            elseif dy <= -45.0 and dy >= -110.0 and
                    math.abs(dx) <= 65.0 then
                sides[4].occupied = true
                assigned = true
            end
            if not assigned then table.insert(available, unit) end
        end

        local moved = false
        local contactOffset = 80.0
        for _, side in ipairs(sides) do
            if not side.occupied and #available > 0 then
                local targetX = tcX + side.x * contactOffset
                local targetY = tcY + side.y * contactOffset
                local bestIndex = 1
                local bestDistance = nil
                for index, unit in ipairs(available) do
                    local dx = GetUnitX(unit) - targetX
                    local dy = GetUnitY(unit) - targetY
                    local distance = dx * dx + dy * dy
                    if bestDistance == nil or distance < bestDistance then
                        bestDistance = distance
                        bestIndex = index
                    end
                end
                local unit = table.remove(available, bestIndex)
                IssuePointOrder(unit, "move", targetX, targetY)
                moved = true
            end
        end
        return moved
    end

    function activity:orderHumanArmyToAttack()
        local army = CreateGroup()
        for _, unit in ipairs(self.humanArmy) do
            GroupAddUnit(army, unit)
        end
        GroupTargetOrder(army, "attack", self.surroundee)
        DestroyGroup(army)
    end

    function activity:waitForHumanArmyStill(callback)
        local previous = {}
        for index, unit in ipairs(self.humanArmy) do
            previous[index] = {x = GetUnitX(unit), y = GetUnitY(unit)}
        end
        local stableTicks = 0
        local stillTimer = JTG.ScopeTrackTimer(session.scope, CreateTimer())
        TimerStart(stillTimer, 0.10, true,
            JTG.GuardSession(session, function()
                local allStill = true
                for index, unit in ipairs(self.humanArmy) do
                    local x = GetUnitX(unit)
                    local y = GetUnitY(unit)
                    local dx = x - previous[index].x
                    local dy = y - previous[index].y
                    if dx * dx + dy * dy > 1.0 then allStill = false end
                    previous[index].x = x
                    previous[index].y = y
                end
                if allStill then stableTicks = stableTicks + 1
                else stableTicks = 0 end
                if stableTicks >= 1 then
                    PauseTimer(stillTimer)
                    callback()
                end
            end))
    end

    function activity:beginHardAttack()
        self:orderHumanArmyToAttack()
        local groundAttackTimer = JTG.ScopeTrackTimer(session.scope,
            CreateTimer())
        TimerStart(groundAttackTimer, 1.00, false,
            JTG.GuardSession(session, function()
                local targetX = GetUnitX(self.surroundee)
                local targetY = GetUnitY(self.surroundee)
                local army = CreateGroup()
                for _, unit in ipairs(self.humanArmy) do
                    GroupAddUnit(army, unit)
                end
                GroupPointOrder(army, "attack", targetX, targetY)
                DestroyGroup(army)
            end))
    end

    function activity:finishHardSurround()
        local moved = self:adjustOpenCardinalSides()
        if moved then
            self:waitForHumanArmyStill(function()
                self:beginHardAttack()
            end)
        else
            self:beginHardAttack()
        end
    end

    function activity:beginHardSurrounding()
        local moveCount = 0
        local function issueMoveOrders()
            moveCount = moveCount + 1
            for _, unit in ipairs(self.humanArmy) do
                IssueTargetOrder(unit, "move", self.surroundee)
            end
            return moveCount >= 5
        end

        issueMoveOrders()
        local moveTimer = JTG.ScopeTrackTimer(session.scope, CreateTimer())
        TimerStart(moveTimer, 0.15, true,
            JTG.GuardSession(session, function()
                if issueMoveOrders() then
                    PauseTimer(moveTimer)
                    self:finishHardSurround()
                end
            end))
    end

    function activity:stageHardSurround(centerX, centerY)
        local function beginPositioning()
            local tcX = GetUnitX(self.surroundee)
            local tcY = GetUnitY(self.surroundee)
            local army = CreateGroup()
            for _, unit in ipairs(self.humanArmy) do
                GroupAddUnit(army, unit)
            end
            GroupPointOrder(army, "move", tcX, tcY + 600.0)
            DestroyGroup(army)

            local approachTimer = JTG.ScopeTrackTimer(session.scope,
                CreateTimer())
            TimerStart(approachTimer, 0.03, true,
                JTG.GuardSession(session, function()
                    local liveTcY = GetUnitY(self.surroundee)
                    for _, unit in ipairs(self.humanArmy) do
                        if GetUnitY(unit) >= liveTcY + 250.0 then
                            PauseTimer(approachTimer)
                            self:beginHardSurrounding()
                            return
                        end
                    end
                end))
        end

        IssueTargetOrder(self.mountainKing, "thunderbolt", self.surroundee)
        local stunPollTicks = 0
        local stunTimer = JTG.ScopeTrackTimer(session.scope, CreateTimer())
        TimerStart(stunTimer, 0.03, true,
            JTG.GuardSession(session, function()
                stunPollTicks = stunPollTicks + 1
                if GetUnitAbilityLevel(self.surroundee,
                        STORM_BOLT_BUFF_ID) > 0 or stunPollTicks >= 100 then
                    PauseTimer(stunTimer)
                    beginPositioning()
                end
            end))
    end

    function activity:stageCounterplay(centerX, centerY)
        local radius = 108.0
        for index, unit in ipairs(self.humanArmy) do
            local angle = (index - 1) * bj_PI * 0.25
            SetUnitPosition(unit, centerX + radius * Cos(angle),
                centerY + radius * Sin(angle))
            IssueTargetOrder(unit, "attack", self.surroundee)
        end
        local beginTimer = JTG.ScopeTrackTimer(session.scope, CreateTimer())
        TimerStart(beginTimer, 3.0, false,
            JTG.GuardSession(session, function()
                IssueImmediateOrder(self.blademaster, "windwalk")
                IssuePointOrder(self.blademaster, "move",
                    GetUnitX(self.surroundee), GetUnitY(self.surroundee))
                local enteredTicks = 0
                local enterTimer = JTG.ScopeTrackTimer(session.scope,
                    CreateTimer())
                TimerStart(enterTimer, 0.10, true,
                    JTG.GuardSession(session, function()
                        enteredTicks = enteredTicks + 1
                        local dx = GetUnitX(self.blademaster) -
                            GetUnitX(self.surroundee)
                        local dy = GetUnitY(self.blademaster) -
                            GetUnitY(self.surroundee)
                        if dx * dx + dy * dy <= 75.0 * 75.0 or
                                enteredTicks >= 50 then
                            PauseTimer(enterTimer)
                            if self.humanArmy[1] ~= nil then
                                IssueTargetOrder(self.blademaster, "attack",
                                    self.humanArmy[1])
                            end
                            local visibilityTicks = 0
                            local visibilityTimer = JTG.ScopeTrackTimer(
                                session.scope, CreateTimer())
                            TimerStart(visibilityTimer, 0.03, true,
                                JTG.GuardSession(session, function()
                                    visibilityTicks = visibilityTicks + 1
                                    if IsUnitInvisible(self.blademaster,
                                            Player(0)) and
                                            visibilityTicks < 200 then
                                        return
                                    end
                                    PauseTimer(visibilityTimer)
                                    IssuePointOrder(self.surroundee, "move",
                                        centerX + 350.0, centerY)
                                    local jointMoveTimer =
                                        JTG.ScopeTrackTimer(session.scope,
                                            CreateTimer())
                                    TimerStart(jointMoveTimer, 0.50, false,
                                        JTG.GuardSession(session, function()
                                            local escapingUnits = CreateGroup()
                                            GroupAddUnit(escapingUnits,
                                                self.surroundee)
                                            GroupAddUnit(escapingUnits,
                                                self.blademaster)
                                            GroupPointOrder(escapingUnits,
                                                "move", centerX + 350.0,
                                                centerY)
                                            DestroyGroup(escapingUnits)
                                        end))
                                end))
                        end
                    end))
            end))
    end

    function activity:createScenario()
        local centerX = session.scene.centerX
        local centerY = session.scene.centerY
        local p0 = Player(0)
        local p1 = Player(1)

        if self.mode == "normal" then
            self.surroundee = JTG.ScopeTrackUnit(session.scope,
                BlzCreateUnitWithSkin(p0, GRUNT_ID, centerX, centerY, 0.0,
                    GRUNT_ID))
            IssueImmediateOrder(self.surroundee, "holdposition")
            self:createBlademaster(p0, centerX - 360.0, centerY - 240.0,
                45.0)
            self:formBasicSurround(centerX, centerY)
        elseif self.mode == "hard" then
            -- The Blademaster is created first so he always occupies F1.
            self:createBlademaster(p0, centerX - 730.0, centerY - 80.0, 0.0)
            self.surroundee = JTG.ScopeTrackUnit(session.scope,
                BlzCreateUnitWithSkin(p0, TAUREN_CHIEFTAIN_ID, centerX,
                    centerY, 270.0, TAUREN_CHIEFTAIN_ID))
            PrepareHero(self.surroundee,
                {{WAR_STOMP_ID, 2}, {ENDURANCE_AURA_ID, 1}})
            UnitAddItemById(self.surroundee, CROWN_OF_KINGS_ID)
            IssueImmediateOrder(self.surroundee, "holdposition")
            self:createHumanArmy(p1, centerX, centerY)
            self:stageHardSurround(centerX, centerY)
        else
            self.surroundee = JTG.ScopeTrackUnit(session.scope,
                BlzCreateUnitWithSkin(p1, TAUREN_CHIEFTAIN_ID, centerX,
                    centerY, 270.0, TAUREN_CHIEFTAIN_ID))
            PrepareHero(self.surroundee,
                {{WAR_STOMP_ID, 2}, {ENDURANCE_AURA_ID, 1}})
            UnitAddItemById(self.surroundee, CROWN_OF_KINGS_ID)
            IssueImmediateOrder(self.surroundee, "holdposition")
            self:createBlademaster(p1, centerX - 430.0, centerY - 80.0, 0.0)
            self:createHumanArmy(p0, centerX, centerY)
            self:stageCounterplay(centerX, centerY)
        end

        if GetLocalPlayer() == p0 then
            ClearSelection()
            if self.mode == "counterplay" then
                for _, unit in ipairs(self.humanArmy) do SelectUnit(unit, true) end
            else
                SelectUnit(self.blademaster, true)
            end
        end
    end

    function activity:setup(current)
        local p0 = Player(0)
        local p1 = Player(1)
        JTG.BorrowCamera(current.scope, p0)

        local passive01 = GetPlayerAlliance(p0, p1, ALLIANCE_PASSIVE)
        local passive10 = GetPlayerAlliance(p1, p0, ALLIANCE_PASSIVE)
        local oldController = GetPlayerController(p1)
        local oldColor = GetPlayerColor(p1)
        JTG.ScopeAdd(current.scope, function()
            SetPlayerAlliance(p0, p1, ALLIANCE_PASSIVE, passive01)
            SetPlayerAlliance(p1, p0, ALLIANCE_PASSIVE, passive10)
            SetPlayerController(p1, oldController)
            SetPlayerColor(p1, oldColor)
        end)
        SetPlayerController(p1, MAP_CONTROL_COMPUTER)
        SetPlayerAlliance(p0, p1, ALLIANCE_PASSIVE, false)
        SetPlayerAlliance(p1, p0, ALLIANCE_PASSIVE, false)
        SetPlayerColor(p1, ConvertPlayerColor(1))

        JTG.ResetWorldFog(p0)
        local visible = Rect(current.scene.minX, current.scene.minY,
            current.scene.maxX, current.scene.maxY)
        SetFogStateRect(p0, FOG_OF_WAR_VISIBLE, visible, true)
        local vision = CreateFogModifierRect(p0, FOG_OF_WAR_VISIBLE,
            visible, false, false)
        FogModifierStart(vision)
        JTG.ScopeAdd(current.scope, function()
            FogModifierStop(vision)
            DestroyFogModifier(vision)
        end)
        RemoveRect(visible)

        self:createScenario()
        self:createTrainingQuests()
    end

    function activity:start(current)
        if GetLocalPlayer() == Player(0) then
            SetCameraPosition(current.scene.centerX, current.scene.centerY)
        end
        if self.highlightQuestOnStart and JTG.UI and
                JTG.UI.HighlightQuestButton then
            JTG.UI.HighlightQuestButton(5.0)
        end
    end

    function activity:captureResetState()
        return {mode = self.mode, skipQuestHighlight = true}
    end

    function activity:restorePresentation()
        if JTG.UI then JTG.UI.ShowToolbar(session.descriptor.capabilities) end
    end

    function activity:cleanup()
        if JTG.UI then JTG.UI.HideActivityBriefing() end
        for _, summoned in ipairs(self.summonedWaterElementals) do
            if summoned ~= nil and GetUnitTypeId(summoned) ~= 0 then
                RemoveUnit(summoned)
            end
        end
        self.blademaster = nil
        self.surroundee = nil
        self.humanArmy = {}
        self.archmage = nil
        self.summonedWaterElementals = {}
        self.mountainKing = nil
        self.quests = {}
    end

    return activity
end
