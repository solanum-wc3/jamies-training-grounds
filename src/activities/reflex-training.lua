-- Recognition and reaction training. Neutral ownership
-- keeps selection possible without player commands interrupting the walkers.
JTG = JTG or {}
local WIDTH, HEIGHT = 1800, 1000
local MIN_COPIES, MAX_COPIES, COLUMNS, ROWS = 2, 4, 15, 8
local TICK = 0.25
local TARGETS = {"hfoo", "hfoo", "hmpr", "hkni"}
local CUE_TICK, CUE_HOLD, CUE_MOVE = 0.02, 0.4, 0.3

function JTG.OpenReflexTrainingMenu(originCategory, pauseGame, restorePage, restoreData)
    local category = originCategory or "skills"
    local function release() JTG.UI.SetGameplayMenuPaused(false) end
    local spec = {
        title = "Reflex Training", activityId = "skills.reflex",
        originCategory = category, pageId = "root", restoreData = {},
        pauseGame = pauseGame == true,
        body = "Choose a training mode. Identify the requested unit types in any order, or click each Rejuvenation-marked unit as quickly as possible through ten trials.",
        choices = {},
        backAction = function() JTG.UI.ShowCategory(category) end,
    }
    for _, mode in ipairs({{id="identify",label="Identify Units"},{id="reflex",label="Reflex Test"}}) do
        local id=mode.id
        spec.choices[#spec.choices+1]={label=mode.label,action=function()
            release()
            JTG.StartActivityAfterCleanup("skills.reflex",category,{mode=id},nil,"new-crowd")
        end}
    end
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
    local carry=session.restartData or {}
    local activity = {mode=carry.mode or "identify", layout=GetRandomInt(1,3), vertical=GetRandomInt(0,1)==1, reactions={}, reactionElapsed=0, units = {}, walkersByUnit = {}, elapsed = 0, finished = false,
        started = false, completed = {}, correct = 0, countdown = 3, presentationVisible = true}
    function activity:refreshStatus()
        if not self.status then return end
        local text = not self.started and (self.countdown>0 and tostring(self.countdown) or "") or
            (self.elapsed < 0.5 and "GO!" or "")
        if self.started and self.mode=="reflex" and text=="" then
            text="Click the marked unit: "..self.correct.."/10"
        end
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
            BlzFrameSetVisible(icon,self.mode=="identify" and self.presentationVisible and self.cueVisible and not self.finished)
        end
    end
    function activity:showResult()
        JTG.UI.HideToolbar()
        self:refreshStatus(); self:refreshIcons()
        local details="You found two Footmen, one Priest and one Knight."
        if self.mode=="reflex" then
            local sum,best=0,math.huge
            for _,time in ipairs(self.reactions) do sum=sum+time;best=math.min(best,time) end
            details=string.format("10 targets clicked. Average: %.2fs. Fastest: %.2fs.",sum/#self.reactions,best)
        end
        JTG.UI.ShowResultCard(self.resultCard,{title="Well done!",tone="success",
            details=details,visible=self.presentationVisible,
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
    function activity:markNextTarget()
        local previous=self.marked
        local candidates={}
        for _,walker in ipairs(self.units) do
            if walker.unit~=previous then candidates[#candidates+1]=walker.unit end
        end
        self.marked=candidates[GetRandomInt(1,#candidates)]
        self.reactionElapsed=0
        self.marker=JTG.ScopeTrackEffect(session.scope,AddSpecialEffectTarget(
            "Abilities\\Spells\\NightElf\\Rejuvenation\\RejuvenationTarget.mdl",self.marked,"origin"))
    end
    function activity:selectTarget(unit)
        local walker = self.walkersByUnit[unit]
        if not self.started or self.finished or self.paused or not self.presentationVisible or not walker or self.mode=="identify" and walker.accepted then return end
        if self.mode=="reflex" then
            if unit~=self.marked then return end
            self.reactions[#self.reactions+1]=self.reactionElapsed
            self.correct=self.correct+1
            BlzSetSpecialEffectAlpha(self.marker,0)
            self.marked=nil
            if self.correct==10 then
                self.finished=true
                for _,entry in ipairs(self.units) do PauseUnit(entry.unit,true) end
                self:showResult()
            else
                self.marked=unit
                self:markNextTarget()
                self:refreshStatus()
            end
            return
        end
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
        self:refreshStatus()
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
        -- Split the crowd density across two races in the same arena.
        local choices, families = {}, {}
        for _,race in ipairs({{id="human",color=PLAYER_COLOR_BLUE},{id="orc",color=PLAYER_COLOR_RED}}) do
            for _, column in ipairs(JTG.GetSurroundCustomRaceColumns(race.id)) do
                for _, choice in ipairs(column) do
                    if choice.kind == "unit" and choice.enabled then
                        choices[#choices + 1] = {definition=choice,color=race.color}
                        local family = JTG.GetSurroundCustomSummonFamily(choice.rawcode)
                        if family then families[family] = (families[family] or 0) + 1 end
                    end
                end
            end
        end
        local familyIndices, familyBudgets = {}, {}
        for _, entry in ipairs(choices) do
            local choice=entry.definition
            local count = choice.hero and 1 or GetRandomInt(MIN_COPIES, MAX_COPIES)
            if choice.rawcode=="hfoo" then count=GetRandomInt(4,6) end
            local family = JTG.GetSurroundCustomSummonFamily(choice.rawcode)
            if family and not choice.hero then
                local index = (familyIndices[family] or 0) + 1
                familyIndices[family] = index
                -- Keep one population budget per summon type, split across
                -- its levels; distribute any remainder in roster order.
                familyBudgets[family] = familyBudgets[family] or GetRandomInt(3,6)
                local budget = familyBudgets[family]
                count = math.floor(budget / families[family]) +
                    (index <= budget % families[family] and 1 or 0)
            end
            for _ = 1, count do roster[#roster + 1] = {
                rawcode=JTG.GetSurroundCustomSpawnRawcode(choice.rawcode),color=entry.color} end
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
        local raceSlots,raceIndices={},{}
        if self.layout~=1 then
            raceSlots={[PLAYER_COLOR_BLUE]={},[PLAYER_COLOR_RED]={}}
            for _,slot in ipairs(slots) do
                local firstHalf=self.vertical and slot.x<self.centerX or not self.vertical and slot.y<self.centerY
                local color=firstHalf and PLAYER_COLOR_BLUE or PLAYER_COLOR_RED
                local group=raceSlots[color];group[#group+1]=slot
            end
            for _,color in ipairs({PLAYER_COLOR_BLUE,PLAYER_COLOR_RED}) do Shuffle(raceSlots[color]) end
        end
        local selected = JTG.ScopeTrackTrigger(current.scope,CreateTrigger())
        -- Register the selecting PLAYER, not an event on neutral-owned units.
        -- Unit-event context does not reliably supply GetTriggerPlayer().
        TriggerRegisterPlayerUnitEvent(selected,Player(0),EVENT_PLAYER_UNIT_SELECTED,nil)
        TriggerAddAction(selected,JTG.GuardSession(current,function()
            if GetTriggerPlayer() ~= Player(0) then return end
            self:selectTarget(GetTriggerUnit())
            -- Allow a second click on the same model without allowing it to
            -- count twice, and keep selection circles out of the next search.
            if GetLocalPlayer()==Player(0) then ClearSelection() end
        end))
        for index, entry in ipairs(roster) do
            local rawcode=entry.rawcode
            local slot = slots[index]
            if self.layout~=1 then
                raceIndices[entry.color]=(raceIndices[entry.color] or 0)+1
                slot=raceSlots[entry.color][raceIndices[entry.color]]
                assert(slot,"Reflex race exceeds its half-arena capacity")
            end
            local unit = JTG.ScopeTrackUnit(current.scope,
                CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), FourCC(rawcode), slot.x, slot.y, GetRandomReal(0, 360)))
            assert(unit ~= nil,"Reflex could not create native unit "..rawcode)
            SetUnitColor(unit, entry.color)
            SetUnitInvulnerable(unit, true)
            SetUnitAcquireRange(unit, 0)
            SetUnitCreepGuard(unit, false)
            assert(not IsUnitType(unit, UNIT_TYPE_FLYING), "Flying unit in Reflex ground crowd")
            local walker = {unit = unit, color=entry.color, lastX = GetUnitX(unit), lastY = GetUnitY(unit),
                stalled = 0, nextChoice = GetRandomReal(0, 1.5)}
            self.units[#self.units + 1] = walker
            self.walkersByUnit[unit] = walker
        end
        self:createPresentation()
    end
    function activity:crossCrowd()
        for _,walker in ipairs(self.units) do
            walker.targetX=self.vertical and (2*self.centerX-GetUnitX(walker.unit)) or GetUnitX(walker.unit)
            walker.targetY=self.vertical and GetUnitY(walker.unit) or (2*self.centerY-GetUnitY(walker.unit))
            walker.stalled=0
            IssuePointOrder(walker.unit,"attack",walker.targetX,walker.targetY)
        end
    end
    function activity:start()
        if GetLocalPlayer() == Player(0) then
            SetCameraField(CAMERA_FIELD_ROTATION, 90, 0)
            SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, 304, 0)
            SetCameraPosition(self.centerX, self.centerY)
            ClearSelection()
        end
        if self.layout==2 then self:crossCrowd() end
        self.cueTimer = JTG.StartScopedTimer(session, session.scope, CUE_TICK, true, function()
            if not self.cueVisible or self.finished or self.paused or self.cueElapsed >= CUE_HOLD+CUE_MOVE then return end
            self.cueElapsed = math.min(CUE_HOLD+CUE_MOVE,self.cueElapsed+CUE_TICK)
            if not self.started and self.cueElapsed>=CUE_HOLD then
                self.started=true
                self.elapsed=0
                if self.layout==3 then
                    for _,walker in ipairs(self.units) do self:chooseDestination(walker) end
                end
                if self.mode=="reflex" then
                    self:markNextTarget()
                    JTG.StartScopedTimer(session,session.scope,0.01,true,function()
                        if not self.finished and not self.paused and self.marked then
                            self.reactionElapsed=self.reactionElapsed+0.01
                        end
                    end)
                end
                if GetLocalPlayer()==Player(0) then ClearSelection() end
                JTG.StartScopedTimer(session,session.scope,TICK,true,function() self:update() end)
            end
            self:refreshIcons(); self:refreshStatus()
            if self.cueElapsed >= CUE_HOLD+CUE_MOVE then PauseTimer(self.cueTimer) end
        end)
        JTG.Training.Countdown(self,session,3,function(remaining)
            self.countdown = remaining; self:refreshStatus()
        end,function()
            self.countdown,self.cueVisible,self.cueElapsed = 0,true,0
            self:refreshStatus(); self:refreshIcons()
        end)
    end
    function activity:captureResetState() return {mode=self.mode} end
    function activity:hidePresentationForMenu()
        if self.marker then BlzSetSpecialEffectAlpha(self.marker,0) end
        JTG.Training.SetPresentation(self,session,false,nil,function() self:refreshIcons() end)
    end
    function activity:restorePresentation()
        if self.marker and self.marked and not self.finished then BlzSetSpecialEffectAlpha(self.marker,255) end
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
