-- Fixed-target Concoctions. Redo preserves the current stage's approach.
JTG = JTG or {}
local INTRO = "When playing against Orc, using flying units runs risk of being easily countered by the relatively cheap Batriders, using their {Term: Unstable Concoction} ability.\n\nIn this training you can practice quickly and efficiently spacing out your flying units to avoid splash damage."
local GROUPS = {{{2,4},{3,3},{4,2}}, {{4,4},{3,3,2}}, {{4,4,2},{5,5},{3,3,4}}}

function JTG.OpenBatSplittingMenu(originCategory, pauseGame, restorePage, restoreData)
    local selection = restoreData or {}
    local showRoot
    local function release() JTG.UI.SetGameplayMenuPaused(false) end
    local function present(spec, page)
        spec.title, spec.activityId = "Bat Splitting", "skills.bat_splitter"
        spec.originCategory = originCategory or "skills"
        spec.body = JTG.FormatSurroundQuestText(INTRO)
        spec.headingArtwork = "JTGMenu\\BatSplitterBriefing.dds"
        spec.headingArtworkWidth, spec.headingArtworkHeight = 0.100, 0.0693
        spec.pauseGame, spec.pageId, spec.restoreData = pauseGame == true, page, selection
        if pauseGame then
            spec.resumeAction = function() release(); JTG.ResumeActivity() end
            spec.exitAction = function()
                JTG.StopActivity("menu-exit"); pauseGame = false; showRoot()
            end
        end
        JTG.UI.ShowActivityBriefing(spec)
    end
    showRoot = function()
        present({choices={
            {label="Normal Mode",action=function() release(); JTG.StartActivityAfterCleanup("skills.bat_splitter",originCategory or "skills",{hard=false},nil,"new-approach") end},
            {label="Hard Mode",action=function() release(); JTG.StartActivityAfterCleanup("skills.bat_splitter",originCategory or "skills",{hard=true},nil,"new-approach") end}},
            backAction=function() JTG.UI.ShowCategory(originCategory or "skills") end}, "root")
    end
    showRoot()
end
local function Alive(unit)
    return unit~=nil and GetUnitTypeId(unit)~=0 and not IsUnitType(unit,UNIT_TYPE_DEAD)
end
local function NewPlan(stage)
    local choices=GROUPS[stage]
    local plan={groups=choices[GetRandomInt(1,#choices)],angle=GetRandomReal(-0.35,0.35),targets={}}
    for index=1,4+stage*2 do plan.targets[index]=index end
    for index=#plan.targets,2,-1 do
        local other=GetRandomInt(1,index)
        plan.targets[index],plan.targets[other]=plan.targets[other],plan.targets[index]
    end
    return plan
end

function JTG.CreateBatSplittingActivity(session)
    local carry=session.restartData or {}
    local stage=carry.stage or 1
    local activity={hard=carry.hard==true,stage=stage,count=4+stage*2,plan=carry.plan or NewPlan(stage),gryphons={},bats={},targets={},releaseAt={},
        splashDamage=0,splashHits=0,elapsed=0,started=false,finished=false,countdown=3,presentationVisible=true}
    function activity:timer(period,callback)
        return JTG.StartScopedTimer(session,session.scope,period,true,callback)
    end
    function activity:survivors()
        local count=0
        for _,unit in ipairs(self.gryphons) do if Alive(unit) then count=count+1 end end
        return count
    end
    function activity:outcome()
        if self:survivors()<self.count then return "failure","SPLIT FAILED" end
        if self.splashDamage>0 then return "neutral","ALL GRYPHONS SURVIVED" end
        return "success","SPLIT SUCCESSFUL"
    end
    function activity:refreshStatus()
        if not self.status then return end
        BlzFrameSetText(self.status,self.started and
            ("Stage "..self.stage.."/3   Gryphons: "..self:survivors().."/"..self.count..
                "   Splash hits: "..self.splashHits.."   Splash damage: "..math.floor(self.splashDamage+0.5)) or
            ("|cffffcc00"..self.countdown.."|r"))
    end
    function activity:showResult()
        local tone,title=self:outcome()
        JTG.UI.HideToolbar()
        JTG.UI.ShowResultCard(self.resultCard,{title=title,tone=tone,
            details="Gryphons surviving: "..self:survivors().."/"..self.count.."\nSplash hits: "..self.splashHits..
                "\nSplash damage: "..math.floor(self.splashDamage+0.5),visible=self.presentationVisible,
            actions={retry={},next={label=self.stage<3 and "Next Stage" or "New Series"},menu={}}})
    end
    function activity:createPresentation()
        self.status=JTG.ScopeTrackFrame(session.presentationScope,
            BlzCreateFrameByType("TEXT","JTGBatStatus",BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0),"",0))
        BlzFrameSetSize(self.status,0.65,0.045)
        BlzFrameSetAbsPoint(self.status,FRAMEPOINT_TOP,0.40,0.505)
        BlzFrameSetTextAlignment(self.status,TEXT_JUSTIFY_MIDDLE,TEXT_JUSTIFY_CENTER)
        BlzFrameSetEnable(self.status,false)
        self.resultCard=JTG.UI.CreateResultCard(session,{name="JTGBatResult",width=0.40,detailsHeight=0.09})
        self:refreshStatus()
    end
    function activity:finish()
        if self.finished then return end
        self.finished=true
        for _,list in ipairs({self.gryphons,self.bats}) do
            for _,unit in ipairs(list) do if Alive(unit) then PauseUnit(unit,true) end end
        end
        JTG.UI.HideToolbar(); self:showResult()
    end
    function activity:beginBattle()
        self.started=true
        for _,unit in ipairs(self.gryphons) do SetUnitOwner(unit,Player(0),true); UnitShareVision(unit,Player(0),false); PauseUnit(unit,false) end
        if GetLocalPlayer()==Player(0) then
            ClearSelection(); for _,unit in ipairs(self.gryphons) do SelectUnit(unit,true) end
        end
        -- Each approach group begins one second after the preceding group.
    end
    function activity:update()
        if self.finished or not self.started then return end
        self.elapsed=self.elapsed+0.10
        local livingBats=0
        for _,bat in ipairs(self.bats) do
            if Alive(bat) then
                -- A splash death may remove another bat's assigned target.
                -- Continue the attack on a surviving Gryphon so every bat resolves.
                if not Alive(self.targets[bat]) then
                    for _,gryphon in ipairs(self.gryphons) do
                        if Alive(gryphon) then self.targets[bat]=gryphon; break end
                    end
                end
                if not Alive(self.targets[bat]) then KillUnit(bat)
                else
                livingBats=livingBats+1
                if self.elapsed+0.00001 >= self.releaseAt[bat] then
                    PauseUnit(bat,false)
                if GetUnitCurrentOrder(bat)~=OrderId("unstableconcoction") then
                    IssueTargetOrder(bat,"unstableconcoction",self.targets[bat])
                end
                end
                end
            end
        end
        self:refreshStatus()
        -- Wait one simulation step after the final explosion to include all
        -- damage/deaths. No arbitrary round timer remains.
        if livingBats==0 then
            if self.batsResolved then self:finish() else self.batsResolved=true end
        else self.batsResolved=false end
    end
    function activity:setup(current)
        local p0,p1=Player(0),Player(1)
        JTG.BorrowCamera(current.scope,p0)
        local controller=GetPlayerController(p1)
        JTG.ScopeBorrow(current.scope,function() SetPlayerController(p1,controller) end)
        SetPlayerController(p1,MAP_CONTROL_COMPUTER)
        for _,pair in ipairs({{p0,p1},{p1,p0}}) do
            local left,right=pair[1],pair[2]
            local previous=GetPlayerAlliance(left,right,ALLIANCE_PASSIVE)
            JTG.ScopeBorrow(current.scope,function() SetPlayerAlliance(left,right,ALLIANCE_PASSIVE,previous) end)
            SetPlayerAlliance(left,right,ALLIANCE_PASSIVE,false)
        end
        local time,scale=GetFloatGameState(GAME_STATE_TIME_OF_DAY),GetTimeOfDayScale()
        JTG.ScopeBorrow(current.scope,function() SetFloatGameState(GAME_STATE_TIME_OF_DAY,time); SetTimeOfDayScale(scale) end)
        SetFloatGameState(GAME_STATE_TIME_OF_DAY,self.hard and 0 or 12); SetTimeOfDayScale(0)
        self.startX,self.startY=current.scene.centerX,current.scene.maxY
        self.gryphonSet={}
        for index=1,self.count do
            local columns=math.ceil(self.count/2)
            local unit=JTG.ScopeTrackUnit(current.scope,CreateUnit(p0,FourCC("hgry"),
                self.startX+((index-1)%columns-(columns-1)/2)*30,
                self.startY+(math.floor((index-1)/columns)-0.5)*30,270))
            PauseUnit(unit,true)
            self.gryphons[index],self.gryphonSet[unit]=unit,true
            SetUnitOwner(unit,Player(PLAYER_NEUTRAL_PASSIVE),false)
        end
        local index=0
        for groupIndex,groupSize in ipairs(self.plan.groups) do
            for slot=1,groupSize do
                index=index+1
                local target=self.gryphons[self.plan.targets[index]]
                local angle=self.plan.angle+(groupIndex-1)*2*math.pi/#self.plan.groups+(slot-(groupSize+1)/2)*0.025
                -- Installed UnitBalance.slk: hgry sight=1600, nsight=900.
                -- Both modes measure approaches from daytime vision.
                local distance=1600+400
                local bat=JTG.ScopeTrackUnit(current.scope,CreateUnit(p1,FourCC("otbr"),
                    GetUnitX(target)+math.cos(angle)*distance,GetUnitY(target)+math.sin(angle)*distance,
                    (angle*180/math.pi+180)%360))
                UnitAddAbility(bat,FourCC("Auco")); SetUnitAcquireRange(bat,0); PauseUnit(bat,true)
                self.bats[index],self.targets[bat],self.releaseAt[bat]=bat,target,groupIndex
            end
        end
        local damageTrigger=JTG.ScopeTrackTrigger(current.scope,CreateTrigger())
        TriggerRegisterPlayerUnitEvent(damageTrigger,p0,EVENT_PLAYER_UNIT_DAMAGED,nil)
        TriggerAddAction(damageTrigger,JTG.GuardSession(current,function()
            local source,target=GetEventDamageSource(),GetTriggerUnit()
            if self.started and not self.finished and self.gryphonSet[target] and self.targets[source] and
                    target~=self.targets[source] and GetEventDamage()>0 then
                self.splashHits=self.splashHits+1; self.splashDamage=self.splashDamage+GetEventDamage()
            end
        end))
        local enemyVision=JTG.ScopeTrackFogModifier(current.scope,
            CreateFogModifierRadius(p1,FOG_OF_WAR_VISIBLE,self.startX,self.startY,8000,false,false))
        FogModifierStart(enemyVision)
        JTG.ResetWorldFog(p0)
        -- Per-unit shared vision follows native day/night sight and terrain.
        for _,unit in ipairs(self.gryphons) do UnitShareVision(unit,p0,true) end
        self:createPresentation()
    end
    function activity:start()
        if JTG.Training.ShowSetupLabel then
            JTG.Training.ShowSetupLabel(self,session,'Setup',self.stage,3,tostring(self.hard)..':'..self.stage)
        end
        if GetLocalPlayer()==Player(0) then SetCameraPosition(self.startX,self.startY) end
        self:timer(0.10,function() self:update() end)
        JTG.Training.Countdown(self,session,3,function(remaining)
            self.countdown=remaining;self:refreshStatus()
        end,function()
            self.countdown=0;self:beginBattle();self:refreshStatus()
        end)
    end
    function activity:captureResetState()
        if self.newStage then return {stage=self.stage,hard=self.hard} end
        return {stage=self.stage,plan=self.plan,hard=self.hard}
    end
    function activity:nextStage()
        if not self.finished then return false end
        self.stage=self.stage%3+1; self.newStage=true; JTG.ResetActivity(); return true
    end
    activity.resultActions={next=function(self) return self:nextStage() end}
    function activity:hidePresentationForMenu()
        JTG.Training.SetPresentation(self,session,false)
    end
    function activity:restorePresentation()
        JTG.Training.SetPresentation(self,session,true,function()
            if self.finished then self:showResult() end
        end)
    end
    function activity:discardPresentationForLoad() self.status=nil; self.resultCard=nil end
    function activity:rebuildPresentation() self:createPresentation(); self:restorePresentation() end
    function activity:cleanup()
        self.finished = true
        if GetLocalPlayer()==Player(0) then ClearSelection() end
        JTG.UI.HideActivityBriefing()
        self.status, self.resultCard = nil, nil
        self.gryphons, self.bats, self.targets, self.releaseAt, self.gryphonSet = {}, {}, {}, {}, {}
    end
    return activity
end
