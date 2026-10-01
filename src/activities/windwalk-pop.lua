-- Windwalk Pop: use Wind Walk's native loss and restoration of collision to
-- displace a friendly Grunt from an organically formed enemy surround.
JTG = JTG or {}

local WINDWALK_POP_INTRO =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Practice " ..
    "using Wind Walk to enter a surround and pop the trapped Grunt free."

local BLADEMASTER_ID = FourCC("Obla")
local GRUNT_ID = FourCC("ogru")
local ENEMY_ID = FourCC("hfoo")
local WINDWALK_ID = FourCC("AOwk")

function JTG.OpenWindwalkPopMenu(originCategory, pauseGame, restorePage,
        restoreData)
    local function releaseMenuPause()
        if JTG.UI then JTG.UI.SetGameplayMenuPaused(false) end
    end
    local function resumeCurrentRun()
        releaseMenuPause()
        JTG.ResumeActivity()
    end
    local function launch()
        releaseMenuPause()
        if JTG.Controller.session ~= nil then
            JTG.StartActivityAfterCleanup("skills.windwalk",
                originCategory or "skills", nil, nil, "briefing-restart")
        else
            JTG.StartActivity("skills.windwalk", originCategory or "skills")
        end
    end
    local function showBriefing()
        local spec = {
            title = "Windwalk Pop",
            activityId = "skills.windwalk",
            originCategory = originCategory or "skills",
            headingArtwork = "JTGMenu\\WindwalkPop.dds",
            headingArtworkWidth = 0.123,
            headingArtworkHeight = 0.060,
            body = WINDWALK_POP_INTRO,
            choices = {{label = "Start Training", primary = true,
                action = launch}},
            centerSingleChoice = true,
            backAction = function() JTG.UI.ShowSkillRace("orc") end,
            pauseGame = pauseGame == true,
            pageId = "root",
            restoreData = restoreData,
        }
        if pauseGame then
            spec.resumeAction = resumeCurrentRun
            spec.exitAction = function()
                JTG.StopActivity("menu-exit")
                pauseGame = false
                showBriefing()
            end
        end
        JTG.UI.ShowActivityBriefing(spec)
    end
    showBriefing()
end

function JTG.CreateWindwalkPopActivity(session)
    local activity = {blademaster = nil, grunt = nil, enemies = {}}

    function activity:createScenario()
        local centerX = session.scene.centerX
        local centerY = session.scene.centerY
        local p0 = Player(0)
        local p1 = Player(1)

        self.grunt = JTG.ScopeTrackUnit(session.scope,
            BlzCreateUnitWithSkin(p0, GRUNT_ID, centerX, centerY, 0.0,
                GRUNT_ID))
        IssueImmediateOrder(self.grunt, "holdposition")

        self.blademaster = JTG.ScopeTrackUnit(session.scope,
            BlzCreateUnitWithSkin(p0, BLADEMASTER_ID, centerX - 360.0,
                centerY - 240.0, 45.0, BLADEMASTER_ID))
        SetHeroLevel(self.blademaster, 1, false)
        SelectHeroSkill(self.blademaster, WINDWALK_ID)
        if GetUnitAbilityLevel(self.blademaster, WINDWALK_ID) < 1 then
            UnitAddAbility(self.blademaster, WINDWALK_ID)
            SetUnitAbilityLevel(self.blademaster, WINDWALK_ID, 1)
        end
        local windwalk = BlzGetUnitAbility(self.blademaster, WINDWALK_ID)
        if windwalk ~= nil then
            BlzSetAbilityIntegerLevelField(windwalk,
                ABILITY_ILF_MANA_COST, 0, 0)
            BlzSetAbilityRealLevelField(windwalk,
                ABILITY_RLF_COOLDOWN, 0, 0.0)
        end
        UnitResetCooldown(self.blademaster)

        local positions = {
            {centerX, centerY + 200.0, 270.0},
            {centerX + 200.0, centerY, 180.0},
            {centerX, centerY - 200.0, 90.0},
            {centerX - 200.0, centerY, 0.0},
        }
        for _, point in ipairs(positions) do
            local enemy = JTG.ScopeTrackUnit(session.scope,
                BlzCreateUnitWithSkin(p1, ENEMY_ID, point[1], point[2],
                    point[3], ENEMY_ID))
            table.insert(self.enemies, enemy)
        end

        -- Reissue the approach as distinct orders. Each quarter-second update
        -- makes Warcraft recalculate the route into the occupied center and
        -- lets ordinary collision tighten the four cardinal positions. Only
        -- after five movement passes do the Footmen begin attacking.
        local formationStep = 0
        local formationTimer = JTG.ScopeTrackTimer(session.scope, CreateTimer())
        TimerStart(formationTimer, 0.25, true,
            JTG.GuardSession(session, function()
                formationStep = formationStep + 1
                local targetX = GetUnitX(self.grunt)
                local targetY = GetUnitY(self.grunt)
                for _, enemy in ipairs(self.enemies) do
                    if formationStep <= 5 then
                        IssuePointOrder(enemy, "move", targetX, targetY)
                    else
                        IssuePointOrder(enemy, "attack", targetX, targetY)
                    end
                end
                if formationStep > 5 then PauseTimer(formationTimer) end
            end))

        if GetLocalPlayer() == p0 then
            ClearSelection()
            SelectUnit(self.blademaster, true)
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
    end

    function activity:start(current)
        if GetLocalPlayer() == Player(0) then
            SetCameraPosition(current.scene.centerX, current.scene.centerY)
        end
    end

    function activity:restorePresentation()
        if JTG.UI then JTG.UI.ShowToolbar(session.descriptor.capabilities) end
    end

    function activity:cleanup()
        if JTG.UI then JTG.UI.HideActivityBriefing() end
        self.blademaster = nil
        self.grunt = nil
        self.enemies = {}
    end

    return activity
end
