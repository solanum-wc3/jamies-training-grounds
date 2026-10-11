-- Recognition prototype. Neutral ownership
-- keeps selection possible without player commands interrupting the walkers.
JTG = JTG or {}
local WIDTH, HEIGHT = 1800, 1000
local MIN_COPIES, MAX_COPIES, COLUMNS, ROWS = 4, 8, 15, 8
local TICK = 0.25
local TARGETS = {"hfoo", "hfoo", "hmpr", "hkni"}
local CUE_TICK, CUE_HOLD, CUE_MOVE = 0.02, 0.2, 0.3

function JTG.OpenReflexTrainingMenu(originCategory, pauseGame, restorePage, restoreData)
    local category = originCategory or "skills"
    local function release() JTG.UI.SetGameplayMenuPaused(false) end
    local spec = {
        title = "Reflex Training", activityId = "skills.reflex",
        originCategory = category, pageId = "root", restoreData = {},
        pauseGame = pauseGame == true,
        body = "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        choices = {{label = "Start Training", action = function()
            release()
            JTG.StartActivityAfterCleanup("skills.reflex", category, {}, nil, "new-crowd")
        end}},
        backAction = function() JTG.UI.ShowCategory(category) end,
    }
    if pauseGame then
        spec.resumeAction = function() release(); JTG.ResumeActivity() end
        spec.exitAction = function()
            JTG.StopActivity("menu-exit")
            JTG.OpenReflexTrainingMenu(category, false)
        end
    end
    JTG.UI.ShowActivityBriefing(spec)
end

local function Shuffle(list)
    for index = #list, 2, -1 do
        local other = GetRandomInt(1, index)
        list[index], list[other] = list[other], list[index]
    end
end

function JTG.CreateReflexTrainingActivity(session)
    local activity = {units = {}, walkersByUnit = {}, elapsed = 0, finished = false,
        started = false, completed = {}, correct = 0, countdown = 3, presentationVisible = true}
    function activity:refreshStatus()
        if not self.status then return end
        local text = not self.started and tostring(self.countdown) or
            (self.cueElapsed < CUE_HOLD and "GO!" or "")
        BlzFrameSetText(self.status, "|cffffcc00" .. text .. "|r")
        BlzFrameSetVisible(self.status,self.presentationVisible and not self.finished and text~="")
    end
    function activity:refreshIcons()
        if not self.icons then return end
        local t = math.max(0, math.min(1, ((self.cueElapsed or 0) - CUE_HOLD) / CUE_MOVE))
        -- Smoothly translate and shrink the entire row after its central flash.
        t = t * t * (3 - 2 * t)
        for index, icon in ipairs(self.icons) do
            local startX = 0.40 + (index - 2.5) * 0.074
            local endX = 0.714 + (index - 2.5) * 0.038
            BlzFrameClearAllPoints(icon)
            BlzFrameSetAbsPoint(icon,FRAMEPOINT_CENTER,startX+(endX-startX)*t,0.30+(0.484-0.30)*t)
            local size = 0.064 + (0.032 - 0.064) * t
            BlzFrameSetSize(icon,size,size)
            BlzFrameSetAlpha(icon,self.completed[index] and 65 or 255)
            BlzFrameSetVisible(icon,self.presentationVisible and self.started and not self.finished)
        end
    end
    function activity:showResult()
        JTG.UI.HideToolbar()
        self:refreshStatus(); self:refreshIcons()
        JTG.UI.ShowResultCard(self.resultCard,{title="Well done!",tone="success",
            details="You found two Footmen, one Priest and one Knight.",visible=self.presentationVisible,
            actions={retry={},menu={}}})
    end
    function activity:createPresentation()
        local root = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0)
        self.status = JTG.ScopeTrackFrame(session.presentationScope,
            BlzCreateFrameByType("TEXT","JTGReflexCountdown",root,"",0))
        BlzFrameSetSize(self.status,0.3,0.055)
        BlzFrameSetAbsPoint(self.status,FRAMEPOINT_CENTER,0.40,0.38)
        BlzFrameSetTextAlignment(self.status,TEXT_JUSTIFY_MIDDLE,TEXT_JUSTIFY_CENTER)
        BlzFrameSetScale(self.status,2)
        BlzFrameSetEnable(self.status,false)
        self.icons = {}
        for index, rawcode in ipairs(TARGETS) do
            local icon = JTG.ScopeTrackFrame(session.presentationScope,
                BlzCreateFrameByType("BACKDROP","JTGReflexTarget"..index,root,"",0))
            BlzFrameSetTexture(icon,JTG.GetSurroundCustomUnitIcon(rawcode),0,true)
            BlzFrameSetEnable(icon,false)
            self.icons[index] = icon
        end
        self.resultCard=JTG.UI.CreateResultCard(session,{name="JTGReflexResult",width=0.40,detailsHeight=0.07})
        self:refreshStatus(); self:refreshIcons()
    end
    function activity:selectTarget(unit)
        local walker = self.walkersByUnit[unit]
        if not self.started or self.finished or self.paused or not self.presentationVisible or not walker or walker.accepted then return end
        local code = GetUnitTypeId(unit)
        for index, target in ipairs(TARGETS) do
            if not self.completed[index] and code == FourCC(target) then
                self.completed[index], walker.accepted = true, true
                self.correct = self.correct + 1
                -- Persistent Banish-like appearance; do not apply its slow or
                -- alter collision/pathing while the crowd keeps walking.
                SetUnitVertexColor(unit,120,255,180,100)
                JTG.ScopeTrackEffect(session.scope,AddSpecialEffectTarget(
                    "Abilities\\Spells\\Human\\Banish\\BanishTarget.mdl",unit,"origin"))
                self:refreshIcons()
                if self.correct == #TARGETS then
                    self.finished = true
                    for _, entry in ipairs(self.units) do PauseUnit(entry.unit,true) end
                    self:showResult()
                end
                return
            end
        end
    end
    function activity:setPaused(paused) self.paused = paused end
    function activity:chooseDestination(walker)
        walker.targetX = GetRandomReal(self.minX + 64, self.maxX - 64)
        walker.targetY = GetRandomReal(self.minY + 64, self.maxY - 64)
        walker.stalled = 0
        IssuePointOrder(walker.unit, "move", walker.targetX, walker.targetY)
    end
    function activity:update()
        if self.finished or not self.started or self.paused then return end
        self.elapsed = self.elapsed + TICK
        for _, walker in ipairs(self.units) do
            local unit = walker.unit
            if GetUnitTypeId(unit) ~= 0 and not IsUnitType(unit, UNIT_TYPE_DEAD) then
                local x, y = GetUnitX(unit), GetUnitY(unit)
                if x < self.minX or x > self.maxX or y < self.minY or y > self.maxY then
                    -- Recover collision pushes at an edge; destinations alone
                    -- cannot guarantee that a dense native crowd stays inside.
                    SetUnitPosition(unit, math.max(self.minX + 48, math.min(self.maxX - 48, x)),
                        math.max(self.minY + 48, math.min(self.maxY - 48, y)))
                    x, y = GetUnitX(unit), GetUnitY(unit)
                    self:chooseDestination(walker)
                end
                local dx, dy = x - walker.lastX, y - walker.lastY
                walker.stalled = dx * dx + dy * dy < 4 and walker.stalled + TICK or 0
                walker.lastX, walker.lastY = x, y
                if self.elapsed >= walker.nextChoice then
                    local tx, ty = x - (walker.targetX or x), y - (walker.targetY or y)
                    if walker.targetX == nil or tx * tx + ty * ty < 64 * 64 or walker.stalled >= 1.5 then
                        self:chooseDestination(walker)
                        walker.nextChoice = self.elapsed + GetRandomReal(0.5, 1.5)
                    end
                end
            end
        end
    end
    function activity:setup(current)
        local scene, player = current.scene, Player(0)
        self.centerX, self.centerY = scene.centerX, scene.centerY
        self.minX, self.maxX = self.centerX - WIDTH / 2, self.centerX + WIDTH / 2
        self.minY, self.maxY = self.centerY - HEIGHT / 2, self.centerY + HEIGHT / 2
        JTG.BorrowCamera(current.scope, player)
        local time, scale = GetFloatGameState(GAME_STATE_TIME_OF_DAY), GetTimeOfDayScale()
        JTG.ScopeBorrow(current.scope, function()
            SetFloatGameState(GAME_STATE_TIME_OF_DAY, time); SetTimeOfDayScale(scale)
        end)
        SetFloatGameState(GAME_STATE_TIME_OF_DAY, 12); SetTimeOfDayScale(0)
        JTG.ResetWorldFog(player)
        JTG.ScopeRevealRect(current.scope, player, self.minX - 200, self.minY - 200,
            self.maxX + 200, self.maxY + 200)

        local roster, slots = {}, {}
        -- Reuse the shared racial roster, including heroes and summon levels.
        -- Human entries marked unavailable here are the flying units.
        local choices, families = {}, {}
        for _, column in ipairs(JTG.GetSurroundCustomRaceColumns("human")) do
            for _, choice in ipairs(column) do
                if choice.kind == "unit" and choice.enabled then
                    choices[#choices + 1] = choice
                    local family = JTG.GetSurroundCustomSummonFamily(choice.rawcode)
                    if family then families[family] = (families[family] or 0) + 1 end
                end
            end
        end
        local familyIndices, familyBudgets = {}, {}
        for _, choice in ipairs(choices) do
            local count = choice.hero and 1 or GetRandomInt(MIN_COPIES, MAX_COPIES)
            local family = JTG.GetSurroundCustomSummonFamily(choice.rawcode)
            if family and not choice.hero then
                local index = (familyIndices[family] or 0) + 1
                familyIndices[family] = index
                -- Keep one population budget per summon type, split across
                -- its levels; distribute any remainder in roster order.
                familyBudgets[family] = familyBudgets[family] or GetRandomInt(MIN_COPIES, MAX_COPIES)
                local budget = familyBudgets[family]
                count = math.floor(budget / families[family]) +
                    (index <= budget % families[family] and 1 or 0)
            end
            for _ = 1, count do roster[#roster + 1] = JTG.GetSurroundCustomSpawnRawcode(choice.rawcode) end
        end
        for row = 0, ROWS - 1 do
            for column = 0, COLUMNS - 1 do
                slots[#slots + 1] = {
                    x = self.minX + (column + 0.5) * WIDTH / COLUMNS + GetRandomReal(-3, 3),
                    y = self.minY + (row + 0.5) * HEIGHT / ROWS + GetRandomReal(-3, 3),
                }
            end
        end
        assert(#roster <= #slots, "Reflex crowd exceeds separated spawn capacity")
        Shuffle(roster); Shuffle(slots)
        local selected = JTG.ScopeTrackTrigger(current.scope,CreateTrigger())
        TriggerAddAction(selected,JTG.GuardSession(current,function()
            if GetTriggerPlayer() ~= Player(0) then return end
            self:selectTarget(GetTriggerUnit())
            -- Allow a second click on the same model without allowing it to
            -- count twice, and keep selection circles out of the next search.
            if GetLocalPlayer()==Player(0) then ClearSelection() end
        end))
        for index, rawcode in ipairs(roster) do
            local slot = slots[index]
            local unit = JTG.ScopeTrackUnit(current.scope,
                CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), FourCC(rawcode), slot.x, slot.y, GetRandomReal(0, 360)))
            assert(unit ~= nil,"Reflex could not create native unit "..rawcode)
            SetUnitColor(unit, PLAYER_COLOR_BLUE)
            SetUnitInvulnerable(unit, true)
            SetUnitAcquireRange(unit, 0)
            SetUnitCreepGuard(unit, false)
            assert(not IsUnitType(unit, UNIT_TYPE_FLYING), "Flying unit in Reflex ground crowd")
            local walker = {unit = unit, lastX = GetUnitX(unit), lastY = GetUnitY(unit),
                stalled = 0, nextChoice = GetRandomReal(0, 1.5)}
            self.units[#self.units + 1] = walker
            self.walkersByUnit[unit] = walker
            TriggerRegisterUnitEvent(selected,unit,EVENT_UNIT_SELECTED)
        end
        self:createPresentation()
    end
    function activity:start()
        if GetLocalPlayer() == Player(0) then
            SetCameraField(CAMERA_FIELD_ROTATION, 90, 0)
            SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, 304, 0)
            SetCameraPosition(self.centerX, self.centerY)
            ClearSelection()
        end
        JTG.StartScopedTimer(session, session.scope, TICK, true, function() self:update() end)
        self.cueTimer = JTG.StartScopedTimer(session, session.scope, CUE_TICK, true, function()
            if not self.started or self.finished or self.paused or self.cueElapsed >= CUE_HOLD+CUE_MOVE then return end
            self.cueElapsed = math.min(CUE_HOLD+CUE_MOVE,self.cueElapsed+CUE_TICK)
            self:refreshIcons(); self:refreshStatus()
            if self.cueElapsed >= CUE_HOLD+CUE_MOVE then PauseTimer(self.cueTimer) end
        end)
        JTG.Training.Countdown(self,session,3,function(remaining)
            self.countdown = remaining; self:refreshStatus()
        end,function()
            self.countdown,self.started,self.cueElapsed = 0,true,0
            self:refreshStatus(); self:refreshIcons()
        end)
    end
    function activity:captureResetState() return {} end
    function activity:hidePresentationForMenu()
        JTG.Training.SetPresentation(self,session,false,nil,function() self:refreshIcons() end)
    end
    function activity:restorePresentation()
        JTG.Training.SetPresentation(self,session,true,function()
            self:refreshIcons()
            if self.finished then self:showResult() end
        end)
    end
    function activity:discardPresentationForLoad() self.status=nil; self.icons=nil; self.resultCard=nil end
    function activity:rebuildPresentation() self:createPresentation(); self:restorePresentation() end
    function activity:cleanup()
        self.finished = true
        self.presentationVisible = false
        self:refreshStatus(); self:refreshIcons()
        if GetLocalPlayer() == Player(0) then ClearSelection() end
        JTG.UI.HideActivityBriefing()
    end
    function activity:afterCleanup() self.units = {}; self.walkersByUnit = {} end
    return activity
end
