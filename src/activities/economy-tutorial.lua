-- Economy & Workers tutorial, using the established tutorial presentation.
JTG=JTG or {}
local ECONOMY_PLAYER=Player(0)
local TICK_INTERVAL=0.05
local NARRATION_DURATION=3600
local STEPS=JTG.EconomySteps
local TOPICS={}
local topicLabels={welcome='Welcome',workers='Workers',peasants='Peasants',peons='Peons',wisps='Wisps',acolytes='Acolytes',food='Food',upkeep='Upkeep',outro='Outro'}
local seenTopics={}
for index,spec in ipairs(STEPS) do
    if not spec.terminal and not seenTopics[spec.checkpoint] then
        TOPICS[#TOPICS+1]={label=topicLabels[spec.checkpoint],step=index}
        seenTopics[spec.checkpoint]=true
    end
end
local FormatNarration = JTG.Tutorial.FormatNarration

local CreateTutorialButton = JTG.Tutorial.CreateButton

function JTG.CreateEconomyTutorialActivity(session)
    local activity=JTG.CreateEconomyLayout(session)
    local layoutSetup,layoutCleanup=activity.setup,activity.cleanup
    activity.step=JTG.Tutorial.ResolveStep(STEPS,session.restartData)
    activity.checkpoint='welcome';activity.waitingForContinue=true
    activity.complete=false;activity.locallyPaused=false;activity.topicsOpen=false
    activity.presentationVisible=true;activity.narrationBlocks={};activity.frames={}
    activity.actions={};activity.buttonEnabled={};activity.orders={};activity.attackers={}
    activity.unitFaction={};activity.scripted=false
    activity.workerTasks={}
    activity.arrowActive=false;activity.arrowBlinking=false;activity.arrowElapsed=0
    activity.arrowBlinkElapsed=0;activity.arrowVisible=false

    function activity:refreshControls()
        JTG.UI.RefreshWelcomeArrow(self)
        if self.frames.continue == nil then return end
        local current = STEPS[self.step]
        local canContinue = self.waitingForContinue and not self.complete
        BlzFrameSetText(self.frames.continue,
            current ~= nil and current.sectionEnd and "Next" or "Continue")
        self:setButtonEnabled(self.frames.continue, canContinue)
        self:setButtonEnabled(self.frames.back, self.step > 1 or self.complete)
        local paused = JTG.UI and JTG.UI.exercisePaused == true
        BlzFrameSetText(self.frames.pause, paused and
            "|cffffffffUnpause|r" or "|cffffcc00Pause|r")
        if self.frames.continueHighlight ~= nil then
            BlzFrameSetVisible(self.frames.continueHighlight,
                canContinue and self.presentationVisible and not self.topicsOpen)
        end
    end

    function activity:clearArrow()
        self.arrowActive = false
        self.arrowBlinking = false
        self.arrowElapsed = 0
        self.arrowBlinkElapsed = 0
        self.arrowVisible = false
        if self.frames.arrow ~= nil then
            BlzFrameSetVisible(self.frames.arrow, false)
        end
    end


    function activity:runStepTrigger(spec) self:runEconomyStep(spec.action) end

    function activity:showStep(index)
        local spec = STEPS[index]
        if spec == nil then return end
        self.step = index
        self.checkpoint = spec.checkpoint or self.checkpoint
        self.complete = spec.terminal == true
        self.waitingForContinue = spec.wait == true and not self.complete
        self:clearNarration()
        local text = FormatNarration(table.concat(spec.lines or {}, "\n"))
        table.insert(self.narrationBlocks, text)
        if self.presentationVisible and not self.topicsOpen then
            DisplayTimedTextToPlayer(ECONOMY_PLAYER, 0, 0,
                NARRATION_DURATION, text)
        end
        self:runStepTrigger(spec)
        if index==1 then JTG.UI.StartWelcomeArrow(self) end
        self:refreshControls()
    end

    function activity:continueTutorial()
        if not self.waitingForContinue or self.complete then return end
        self:showStep(math.min(#STEPS, self.step + 1))
    end

    function activity:captureResetState()
        local index=self.jumpStep or self.step
        return JTG.Tutorial.CaptureCheckpoint(self,index)
    end
    function activity:jumpToStep(index)
        JTG.Tutorial.RestoreAt(self,index,function(target)
            self:setTopicsVisible(false)
            self:clearAttackers()
            self.wolves={};self.wolfTargets={}
            self:prepareCheckpoint(target,true)
        end,function(target) self:showStep(target) end)
    end
    function activity:restoreCheckpoint(index) return self:jumpToStep(index) end
    function activity:goBack() if self.step>1 then self:jumpToStep(self.step-1) end end
    function activity:restoreTopic(index) self:jumpToStep(index) end

    function activity:openMenu()
        JTG.Tutorial.OpenMenu(self,"learn")
    end

    function activity:togglePause()
        JTG.Tutorial.TogglePause(self)
    end


    function activity:setTopicsVisible(visible)
        self.topicsOpen = visible == true
        if self.frames.topicsMenu ~= nil then
            BlzFrameSetVisible(self.frames.topicsMenu,
                self.presentationVisible and self.topicsOpen)
        end
        if self.frames.arrow ~= nil then
            BlzFrameSetVisible(self.frames.arrow,
                self.presentationVisible and self.arrowActive and
                self.arrowVisible and not self.topicsOpen)
        end
        self:renderNarration()
        self:refreshControls()
    end

    function activity:createPresentation()
        local root = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        local scope = session.presentationScope
        local suffix = tostring(session.generation) .. "x" ..
            tostring((JTG.UI and JTG.UI.epoch) or 0)
        self.frames = {}
        self.actions = {}
        self.buttonEnabled = {}

        local labels = {
            {"menu", "Menu", 1}, {"back", "Back", 2},
            {"topics", "Topics", 3}, {"continue", "Continue", 5},
            {"pause", "Pause", 7},
        }
        local bar = JTG.Tutorial.CreateToolbar(self, scope, root, "JTGEconomyTutorial", suffix, labels)
        JTG.Tutorial.CreateHighlight(self, scope, "JTGEconomy", suffix, "continue")
        JTG.Tutorial.CreateHighlight(self, scope, "JTGEconomy", suffix, "menu")
        JTG.Tutorial.CreateHighlight(self, scope, "JTGEconomy", suffix, "pause")

        local arrow = JTG.ScopeTrackFrame(scope, BlzCreateFrameByType("BACKDROP",
            "JTGEconomyCommandArrow" .. suffix, root, "", 0))
        BlzFrameSetSize(arrow, 0.078, 0.078)
        BlzFrameSetTexture(arrow, "JTGMenu\\TutorialArrowUp.dds", 0, true)
        BlzFrameSetEnable(arrow, false)
        BlzFrameSetLevel(arrow, 30)
        BlzFrameSetVisible(arrow, false)
        self.frames.arrow = arrow
        self.frames.welcomeArrow=JTG.UI.CreateWelcomeArrow(scope,root,self.frames.continue,
            "JTGEconomyWelcomeArrow"..suffix)

        local topics = JTG.ScopeTrackFrame(scope, BlzCreateFrameByType("FRAME",
            "JTGEconomyTopics" .. suffix, root, "", 0))
        BlzFrameSetSize(topics, 0.185, JTG.TutorialMenuHeight(#TOPICS))
        BlzFrameSetAbsPoint(topics, FRAMEPOINT_TOPRIGHT, 0.795, 0.500)
        local skin = JTG.ScopeTrackFrame(scope, BlzCreateFrame("EscMenuBackdrop",
            topics, 0, 980 + session.generation))
        BlzFrameSetPoint(skin, FRAMEPOINT_TOPLEFT, topics,
            FRAMEPOINT_TOPLEFT, 0, 0)
        BlzFrameSetPoint(skin, FRAMEPOINT_BOTTOMRIGHT, topics,
            FRAMEPOINT_BOTTOMRIGHT, 0, 0)
        BlzFrameSetEnable(skin, false)
        self.frames.topicsMenu = topics

        local topicButtons = {}
        local previous = nil
        for index, topic in ipairs(TOPICS) do
            local button = JTG.ScopeTrackFrame(scope, CreateTutorialButton(
                "JTGEconomyTopic" .. index .. suffix, topics,
                topic.label, 0.125))
            BlzFrameSetSize(button, 0.125, 0.026)
            if previous == nil then
                BlzFrameSetPoint(button, FRAMEPOINT_TOP, topics,
                    FRAMEPOINT_TOP, 0, -0.041)
            else
                BlzFrameSetPoint(button, FRAMEPOINT_TOP, previous,
                    FRAMEPOINT_BOTTOM, 0, -0.003)
            end
            topicButtons[index] = button
            previous = button
        end
        local close = JTG.ScopeTrackFrame(scope, CreateTutorialButton(
            "JTGEconomyTopicsClose" .. suffix, topics, "Close", 0.10))
        BlzFrameSetSize(close, 0.10, 0.026)
        BlzFrameSetPoint(close, FRAMEPOINT_BOTTOM, topics,
            FRAMEPOINT_BOTTOM, 0, 0.025)

        JTG.Tutorial.BindClicks(self, scope)
        self:registerClick(self.frames.continue,
            function() self:continueTutorial() end)
        self:registerClick(self.frames.back, function() self:goBack() end, "return")
        self:registerClick(self.frames.menu, function() self:openMenu() end)
        self:registerClick(self.frames.pause, function() self:togglePause() end,
            function() return JTG.UI.exercisePaused and "return" or "normal" end)
        self:registerClick(self.frames.topics,
            function() self:setTopicsVisible(not self.topicsOpen) end)
        for index, topic in ipairs(TOPICS) do
            self:registerClick(topicButtons[index],
                function() self:restoreTopic(topic.step) end)
        end
        self:registerClick(close,
            function() self:setTopicsVisible(false) end, "return")

        self:setTopicsVisible(self.topicsOpen)
        self:refreshControls()
    end

    function activity:setPresentationVisible(visible)
        self.presentationVisible = visible == true
        if self.frames.bar ~= nil then
            BlzFrameSetVisible(self.frames.bar, self.presentationVisible)
        end
        if self.frames.topicsMenu ~= nil then
            BlzFrameSetVisible(self.frames.topicsMenu,
                self.presentationVisible and self.topicsOpen)
        end
        if self.frames.arrow ~= nil then
            BlzFrameSetVisible(self.frames.arrow,
                self.presentationVisible and self.arrowActive and
                self.arrowVisible and not self.topicsOpen)
        end
        self:renderNarration()
        self:refreshControls()
        self:restoreResourceArrow()
    end

    function activity:tick()
        for unit,target in pairs(self.attackerTargets or {}) do
            if GetUnitTypeId(unit)~=0 and GetWidgetLife(unit)>0.405 then
                if not target or GetUnitTypeId(target)==0 or GetWidgetLife(target)<=0.405 or IsUnitHidden(target) then
                    target=self:goldAttackTarget(self.attackerRaces[unit])
                end
                if target and (target~=self.attackerTargets[unit] or GetUnitCurrentOrder(unit)~=OrderId('attack')) then
                    self.attackerTargets[unit]=target;self:order(unit,'attack',target)
                end
            end
        end
        if STEPS[self.step].action=='nightelf-defense' and not self.locallyPaused and not (JTG.UI and JTG.UI.exercisePaused) then
            for _,wolf in ipairs(self.wolves or {}) do
                if GetUnitTypeId(wolf)~=0 and GetWidgetLife(wolf)>0.405 then
                    local target=self:visibleLumberWisp()
                    if target and (not self.wolfTargets or self.wolfTargets[wolf]~=target or GetUnitCurrentOrder(wolf)~=OrderId('attack')) then
                        self.wolfTargets[wolf]=target;IssueTargetOrder(wolf,'attack',target)
                    end
                end
            end
        end
        if self.locallyPaused or self.topicsOpen then return end
        JTG.UI.TickWelcomeArrow(self,TICK_INTERVAL)
        if self.arrowActive and self.arrowBlinking and self.frames.arrow ~= nil then
            self.arrowElapsed = self.arrowElapsed + TICK_INTERVAL
            self.arrowBlinkElapsed = self.arrowBlinkElapsed + TICK_INTERVAL
            if self.arrowBlinkElapsed+0.000001 >= 0.35 then
                self.arrowBlinkElapsed=0
                self.arrowToggles=(self.arrowToggles or 0)+1
                if self.arrowToggles>=20 then
                    self.arrowBlinking=false;self.arrowVisible=true
                else self.arrowVisible=not self.arrowVisible end
                BlzFrameSetVisible(self.frames.arrow,self.presentationVisible and self.arrowVisible)
            end
        end
    end

    function activity:scriptCall(callback)
        local previous=self.scripted;self.scripted=true
        local result=callback();self.scripted=previous
        return result
    end
    function activity:order(unit,name,target,x,y)
        if not unit or GetUnitTypeId(unit)==0 then return false end
        self.orders[unit]={name=name,target=target,x=x,y=y}
        return self:scriptCall(function()
            if target then return IssueTargetOrder(unit,name,target)
            elseif x then return IssuePointOrder(unit,name,x,y)
            else return IssueImmediateOrder(unit,name) end
        end)
    end
    function activity:trackEconomyUnit(unit,race,tracked)
        if self.unitFaction[unit] then return unit end
        self.unitFaction[unit]=race
        if not tracked then JTG.ScopeTrackUnit(session.scope,unit);self.units[#self.units+1]=unit end
        local color=self.factions[race].color
        SetUnitColor(unit,ConvertPlayerColor(color))
        return unit
    end
    function activity:createEconomyUnit(raw,x,y,race,facing)
        local owner=race==self.raceIndex and ECONOMY_PLAYER or Player(self.factions[race].slot)
        local unit=JTG.Tutorial.CreateSceneUnit(session.scope,owner,FourCC(raw),x,y,facing)
        self.units[#self.units+1]=unit
        return self:trackEconomyUnit(unit,race,true)
    end
    function activity:findUnit(raw,race,gathering)
        for _,assignment in ipairs(self.placements) do
            local u,p=assignment.unit,assignment.placement
            if p.rawcode==raw and (not race or self.unitFaction[u]==race) and
                (not gathering or p.gathering==gathering) and GetUnitTypeId(u)~=0 and GetWidgetLife(u)>0.405 then return u end
        end
        for _,u in ipairs(self.units) do
            if GetUnitTypeId(u)==FourCC(raw) and (not race or self.unitFaction[u]==race) and GetWidgetLife(u)>0.405 then return u end
        end
    end
    function activity:visibleLumberWisp()
        for _,assignment in ipairs(self.placements) do
            local u,p=assignment.unit,assignment.placement
            if p.rawcode=='ewsp' and p.gathering=='lumber' and
                GetUnitTypeId(u)~=0 and GetWidgetLife(u)>0.405 and not IsUnitHidden(u) then return u end
        end
    end
    function activity:goldMineBurrow()
        local nearest,distance
        for _,assignment in ipairs(self.placements) do
            local u,p=assignment.unit,assignment.placement
            if p.rawcode=='otrb' and GetUnitTypeId(u)~=0 and GetWidgetLife(u)>0.405 then
                local d=(GetUnitX(u)-4160)^2+(GetUnitY(u)+5696)^2
                if not distance or d<distance then nearest,distance=u,d end
            end
        end
        return nearest
    end
    function activity:focus(unit)
        if unit and GetLocalPlayer()==ECONOMY_PLAYER then
            JTG.Tutorial.MoveCamera(ECONOMY_PLAYER,GetUnitX(unit),GetUnitY(unit));ClearSelection();SelectUnit(unit,true)
        end
    end
    function activity:mainBuilding()
        return self:findUnit(({'htow','ogre','etol','unpl'})[self.raceIndex],self.raceIndex)
    end
    function activity:updateOwnership()
        local controlled=self.raceIndex
        if controlled==self.ownedRace then return end
        if self.ownedRace then
            local owner=Player(self.factions[self.ownedRace].slot)
            for _,state in ipairs({PLAYER_STATE_RESOURCE_GOLD,PLAYER_STATE_RESOURCE_LUMBER}) do
                SetPlayerState(owner,state,GetPlayerState(ECONOMY_PLAYER,state))
            end
        end
        for _,state in ipairs({PLAYER_STATE_RESOURCE_GOLD,PLAYER_STATE_RESOURCE_LUMBER}) do
            SetPlayerState(ECONOMY_PLAYER,state,GetPlayerState(Player(self.factions[controlled].slot),state))
        end
        self.ownedRace=controlled
        for _,u in ipairs(self.units) do
            local race=self.unitFaction[u]
            if race and GetUnitTypeId(u)~=0 then
                local owner=race==controlled and ECONOMY_PLAYER or Player(self.factions[race].slot)
                if GetOwningPlayer(u)~=owner then SetUnitOwner(u,owner,false) end
                SetUnitColor(u,ConvertPlayerColor(self.factions[race].color))
            end
        end
        for i,f in ipairs(self.factions) do
            SetPlayerAlliance(Player(f.slot),ECONOMY_PLAYER,ALLIANCE_SHARED_VISION,i==self.raceIndex)
        end
    end
    function activity:setRace(index)
        local ownershipChanged=self.ownedRace~=index
        self.raceIndex=index
        self:updateOwnership()
        -- Active faction is player-owned with unrestricted control. Only it shares sight.
        for i,f in ipairs(self.factions) do
            SetPlayerAlliance(Player(f.slot),ECONOMY_PLAYER,ALLIANCE_SHARED_VISION,i==index)
        end
        SetPlayerColor(ECONOMY_PLAYER,ConvertPlayerColor(self.factions[index].color))
        JTG.ResetWorldFog(ECONOMY_PLAYER)
        -- Ownership, resources and fog are settled before the shared handoff.
        local workers={}
        for _,assignment in ipairs(self.placements) do
            local u,p=assignment.unit,assignment.placement
            if p.gathering and p.faction==self.factions[index].id then workers[#workers+1]=u end
        end
        JTG.Tutorial.RestoreWorkerOrders(session,self,workers,function(unit,preserve)
            self:startGathering(unit,index,preserve)
        end,{force=ownershipChanged,isCurrent=function() return self.raceIndex==index end,
            observe=function(unit,initial)
                if not initial and self.recordEconomyOrderState then self:recordEconomyOrderState('handoff-retry',unit,0) end
            end})
        self:focus(self:mainBuilding())
    end
    function activity:later(seconds,callback)
        return JTG.Tutorial.ScheduleStep(session,self,seconds,callback)
    end
    function activity:restoreResourceArrow()
        if not self.resourceArrow or not self.frames.arrow then return end
        local target=BlzGetFrameByName(({gold='ResourceBarGoldText',lumber='ResourceBarLumberText',food='ResourceBarSupplyText',upkeep='ResourceBarUpkeepText'})[self.resourceArrow],0)
        local x=({gold=0.57,lumber=0.66,food=0.735,upkeep=0.785})[self.resourceArrow]
        BlzFrameClearAllPoints(self.frames.arrow)
        if target then BlzFrameSetPoint(self.frames.arrow,FRAMEPOINT_TOP,target,FRAMEPOINT_BOTTOM,0,-0.004)
        else BlzFrameSetAbsPoint(self.frames.arrow,FRAMEPOINT_TOP,x,0.568) end
        BlzFrameSetVisible(self.frames.arrow,self.arrowActive and self.arrowVisible and self.presentationVisible and not self.topicsOpen)
    end
    function activity:resourceHint(key)
        self.resourceArrow=key;self.arrowActive=true;self.arrowBlinking=true
        self.arrowVisible=true;self.arrowElapsed=0;self.arrowBlinkElapsed=0;self.arrowToggles=0
        self:restoreResourceArrow()
    end
    function activity:clearAttackers()
        for _,unit in ipairs(self.attackers) do if GetUnitTypeId(unit)~=0 then RemoveUnit(unit) end end
        self.attackers={}
        self.attackerTargets={};self.attackerRaces={}
    end
    function activity:killAttackers()
        for _,unit in ipairs(self.attackers) do
            if GetUnitTypeId(unit)~=0 and GetWidgetLife(unit)>0 then KillUnit(unit) end
        end
    end
    function activity:spawnAttack(raw,count,race)
        self:clearAttackers()
        local f=self.factions[race]
        -- These attacks are the purple Undead faction, not the separate Far Seer faction.
        SetPlayerAlliance(Player(5),ECONOMY_PLAYER,ALLIANCE_PASSIVE,false)
        SetPlayerAlliance(ECONOMY_PLAYER,Player(5),ALLIANCE_PASSIVE,false)
        for i=1,count do
            local unit=JTG.ScopeTrackUnit(session.scope,CreateUnit(Player(5),FourCC(raw),f.x+(i-1)*96,f.y+500,270))
            self.attackers[#self.attackers+1]=unit
            SetUnitAcquireRange(unit,0);SetUnitCreepGuard(unit,false);RemoveGuardPosition(unit)
            self.attackerTargets=self.attackerTargets or {}
            self.attackerRaces=self.attackerRaces or {}
            self.attackerRaces[unit]=race
            local target=self:goldAttackTarget(race)
            self.attackerTargets[unit]=target or false
            if target then self:order(unit,'attack',target) end
        end
    end
    function activity:goldAttackTarget(race)
        for _,assignment in ipairs(self.placements) do
            local unit,p=assignment.unit,assignment.placement
            if p.gathering=='gold' and self.unitFaction[unit]==race and
                    GetUnitTypeId(unit)~=0 and GetWidgetLife(unit)>0.405 and not IsUnitHidden(unit) then return unit end
        end
    end
    function activity:placement(raw)
        for _,p in ipairs(JTG.EconomyLayout) do if p.rawcode==raw then return p end end
    end
    function activity:ensureBuilding(raw,race)
        local unit=self:findUnit(raw,race)
        if unit then UnitSetConstructionProgress(unit,100);return unit end
        local p=assert(self:placement(raw),'Missing Economy placement: '..raw)
        return self:createEconomyUnit(raw,p.x,p.y,race,p.facing)
    end
    function activity:setupEconomyScript(current)
        for _,a in ipairs(self.placements) do
            for index,f in ipairs(self.factions) do
                if f.id==a.placement.faction then self:trackEconomyUnit(a.unit,index,true) end
            end
        end
        local oldColor=GetPlayerColor(ECONOMY_PLAYER)
        JTG.ScopeBorrow(current.scope,function()
            SetPlayerColor(ECONOMY_PLAYER,oldColor)
        end)
        for _,f in ipairs(self.factions) do
            local owner=Player(f.slot)
            for _,key in ipairs({PLAYER_STATE_RESOURCE_GOLD,PLAYER_STATE_RESOURCE_LUMBER}) do
                local old=GetPlayerState(owner,key)
                JTG.ScopeBorrow(current.scope,function() SetPlayerState(owner,key,old) end)
                SetPlayerState(owner,key,10000)
            end
        end
        local enemy=Player(1);local controller=GetPlayerController(enemy)
        JTG.ScopeBorrow(current.scope,function() SetPlayerController(enemy,controller) end)
        SetPlayerController(enemy,MAP_CONTROL_USER)
        for _,owner in ipairs({ECONOMY_PLAYER,Player(2),Player(3),Player(4),Player(5)}) do
            for _,pair in ipairs({{owner,enemy},{enemy,owner}}) do
                local a,b=pair[1],pair[2];local old=GetPlayerAlliance(a,b,ALLIANCE_PASSIVE)
                JTG.ScopeBorrow(current.scope,function() SetPlayerAlliance(a,b,ALLIANCE_PASSIVE,old) end)
                SetPlayerAlliance(a,b,ALLIANCE_PASSIVE,false)
            end
        end
        local build=JTG.ScopeTrackTrigger(current.scope,CreateTrigger())
        self.constructionTrigger=build
        for _,owner in ipairs({ECONOMY_PLAYER,Player(2),Player(3),Player(4),Player(5)}) do
            TriggerRegisterPlayerUnitEvent(build,owner,EVENT_PLAYER_UNIT_CONSTRUCT_START,nil)
            TriggerRegisterPlayerUnitEvent(build,owner,EVENT_PLAYER_UNIT_CONSTRUCT_FINISH,nil)
            TriggerRegisterPlayerUnitEvent(build,owner,EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL,nil)
            TriggerRegisterPlayerUnitEvent(build,owner,EVENT_PLAYER_UNIT_TRAIN_FINISH,nil)
        end
        TriggerAddAction(build,JTG.GuardSession(current,function()
            local unit
            local event=GetTriggerEventId()
            if event==EVENT_PLAYER_UNIT_CONSTRUCT_START then unit=GetConstructingStructure()
            elseif event==EVENT_PLAYER_UNIT_CONSTRUCT_FINISH then unit=GetConstructedStructure()
            elseif event==EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL then unit=GetCancelledStructure()
            else unit=GetTrainedUnit() end
            if unit then
                local owner=GetOwningPlayer(unit);local race=self.raceIndex
                for i,f in ipairs(self.factions) do if owner==Player(f.slot) then race=i end end
                self:trackEconomyUnit(unit,race)
                local builder,bestDistance
                for worker,task in pairs(self.workerTasks) do
                    if event==EVENT_PLAYER_UNIT_CONSTRUCT_START and task.raw==GetUnitTypeId(unit) and
                            GetOwningPlayer(worker)==owner and
                            (task.x-GetUnitX(unit))^2+(task.y-GetUnitY(unit))^2<256^2 then
                        local distance=(GetUnitX(worker)-GetUnitX(unit))^2+(GetUnitY(worker)-GetUnitY(unit))^2
                        if not bestDistance or distance<bestDistance then builder,bestDistance=worker,distance end
                    elseif task.building==unit and event~=EVENT_PLAYER_UNIT_CONSTRUCT_START then
                        self.workerTasks[worker]=nil
                    end
                end
                if builder then self.workerTasks[builder].building=unit end
                -- Player-created Shades remain under player control.
            end
        end))
        -- Player ownership always grants full control. No native order is intercepted.
        local workerOrders=JTG.ScopeTrackTrigger(current.scope,CreateTrigger())
        for _,owner in ipairs({ECONOMY_PLAYER,Player(2),Player(3),Player(4),Player(5)}) do
            TriggerRegisterPlayerUnitEvent(workerOrders,owner,EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER,nil)
            TriggerRegisterPlayerUnitEvent(workerOrders,owner,EVENT_PLAYER_UNIT_ISSUED_ORDER,nil)
            TriggerRegisterPlayerUnitEvent(workerOrders,owner,EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER,nil)
        end
        self.workerOrdersTrigger=workerOrders
        TriggerAddAction(workerOrders,JTG.GuardSession(current,function()
            local worker=GetTriggerUnit();local raw=GetIssuedOrderId()
            if self.recordEconomyOrderState then self:recordEconomyOrderState('order-event',worker,raw) end
            if self.unitFaction[worker] and type(raw)=='number' and raw>=0x20000000 and IsUnitIdType(raw,UNIT_TYPE_STRUCTURE) then
                self.workerTasks[worker]={raw=raw,x=GetOrderPointX(),y=GetOrderPointY(),building=true}
            elseif self.workerTasks[worker] and self.workerTasks[worker].building==true then
                -- A cancelled/rejected build must not reserve this worker forever.
                -- Bound construction is released by its finish/cancel event.
                self.workerTasks[worker]=nil
            end
        end))
        local ghoulOrders=JTG.ScopeTrackTrigger(current.scope,CreateTrigger())
        TriggerRegisterPlayerUnitEvent(ghoulOrders,Player(5),EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER,nil)
        TriggerAddAction(ghoulOrders,JTG.GuardSession(current,function()
            if self.scripted then return end
            local unit=GetTriggerUnit();local target=self.attackerTargets and self.attackerTargets[unit]
            if target and GetUnitTypeId(target)~=0 and GetWidgetLife(target)>0.405 and
                    GetOrderTargetUnit()~=target then self:order(unit,'attack',target) end
        end))
        local summons=JTG.ScopeTrackTrigger(current.scope,CreateTrigger())
        TriggerRegisterPlayerUnitEvent(summons,enemy,EVENT_PLAYER_UNIT_SUMMON,nil)
        TriggerAddAction(summons,JTG.GuardSession(current,function()
            if STEPS[self.step].action~='nightelf-defense' then return end
            local wolf=JTG.ScopeTrackUnit(current.scope,GetSummonedUnit());self.attackers[#self.attackers+1]=wolf
            self.wolves=self.wolves or {};self.wolves[#self.wolves+1]=wolf
            SetWidgetLife(wolf,BlzGetUnitMaxHP(wolf)*0.5)
            self.wolfTargets=self.wolfTargets or {}
            SetUnitAcquireRange(wolf,0);SetUnitCreepGuard(wolf,false);RemoveGuardPosition(wolf)
            self.wolfTargets[wolf]=self:visibleLumberWisp()
            if self.wolfTargets[wolf] then
                self:scriptCall(function() IssueTargetOrder(wolf,'attack',self.wolfTargets[wolf]) end)
            end
        end))
        local wolfOrders=JTG.ScopeTrackTrigger(current.scope,CreateTrigger())
        TriggerRegisterPlayerUnitEvent(wolfOrders,enemy,EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER,nil)
        TriggerAddAction(wolfOrders,JTG.GuardSession(current,function()
            local unit=GetTriggerUnit()
            if self.wolfTargets and self.wolfTargets[unit] then
                self.wolfTargets[unit]=GetOrderTargetUnit()
            end
        end))
        JTG.ClearBlightAfterActivity(current,ECONOMY_PLAYER,-6336,1920,1536)
        JTG.ClearBlightAfterActivity(current,Player(5),-6336,1920,1536)
        self:setRace(1)
    end
    function activity:prepareCheckpoint(step,preserveWorkers)
        -- Reconstruct completed practice scenes on Back/Topics only. Entry never
        -- performs the action the player is currently being asked to practice.
        local scene=assert(STEPS[step].restore,'Missing checkpoint scene')
        do
            local wanted={}
            for _,raw in ipairs(scene.buildings or {}) do wanted[raw]=true end
            for _,p in ipairs(JTG.EconomyLayout) do
                if p.appearance~='initial' and not wanted[p.rawcode] then
                    local unit=self:findUnit(p.rawcode)
                    if unit then RemoveUnit(unit) end
                end
            end
        end
        if preserveWorkers then
            local workerCounts={}
            -- Keep actual gathering workers in place, including hidden miners.
            -- Restore idle/missing workers only, before ownership/work-order refresh.
            for index,assignment in ipairs(self.placements) do
                local unit,p=assignment.unit,assignment.placement
                workerCounts[p.faction]=(workerCounts[p.faction] or 0)+(p.gathering and 1 or 0)
                if p.gathering and not self:workerIsGathering(unit,p) then
                    local race
                    for i,f in ipairs(self.factions) do if f.id==p.faction then race=i end end
                    local f=self.factions[race];local ordinal=workerCounts[p.faction]-1
                    local angle=ordinal*math.pi/4;local radius=288+math.floor(ordinal/8)*128
                    local x,y=f.x+math.cos(angle)*radius,f.y+math.sin(angle)*radius
                    if GetUnitTypeId(unit)~=FourCC(p.rawcode) or GetWidgetLife(unit)<=0.405 then
                        assignment.unit=self:createEconomyUnit(p.rawcode,x,y,race,p.facing)
                    else
                        self.workerTasks[unit]=nil
                        SetUnitPosition(unit,x,y);SetUnitFacing(unit,p.facing)
                    end
                end
            end
        end
        for _,raw in ipairs(scene.buildings or {}) do
            local placement=self:placement(raw)
            local race
            for index,faction in ipairs(self.factions) do
                if faction.id==placement.faction then race=index end
            end
            self:ensureBuilding(raw,race)
        end
        for _,raw in ipairs(scene.removed or {}) do
            local unit
            if raw=='ewsp' then unit=self:findUnit(raw,3,'lumber')
            elseif raw=='uaco' then unit=self:findUnit(raw,4,'gold')
            else unit=self:findUnit(raw) end
            local placement
            for _,assignment in ipairs(self.placements) do if assignment.unit==unit then placement=assignment.placement end end
            if unit and not (preserveWorkers and placement and self:workerIsGathering(unit,placement)) then RemoveUnit(unit) end
        end
        local shade=self:findUnit('ushd',4)
        if scene.shade and not shade then self:createEconomyUnit('ushd',-5728,1920,4)
        elseif not scene.shade and shade then RemoveUnit(shade) end
        self:setRace(scene.race)
        if scene.hallHealth then
            local hall=self:findUnit('htow',1)
            SetWidgetLife(hall,BlzGetUnitMaxHP(hall)*scene.hallHealth)
        end
        if scene.foodUsed then self:setFoodUsed(scene.foodUsed) end
    end
    function activity:setFoodUsed(value)
        SetPlayerState(ECONOMY_PLAYER,PLAYER_STATE_RESOURCE_FOOD_USED,value)
    end
    function activity:runEconomyStep(n)
        self.resourceArrow=nil
        self:updateOwnership()
        if n=='welcome' then self:setRace(1);self:focus(self:mainBuilding())
        elseif n=='human-gold' then self:focus(self:findUnit('hpea',1,'gold'));self:resourceHint('gold')
        elseif n=='human-lumber' then self:focus(self:findUnit('hpea',1,'lumber'));self:resourceHint('lumber')
        elseif n=='human-defense' then self:spawnAttack('ugho',2,1)
        elseif n=='human-return-to-work' then self:killAttackers();self:startGathering();self:later(0.25,function() self:startGathering() end)
        elseif n=='human-damage-hall' then
            local hall=self:findUnit('htow',1);SetWidgetLife(hall,BlzGetUnitMaxHP(hall)*0.8)
        elseif n=='human-repair' then self:focus(self:findUnit('htow',1))
        elseif n=='human-build' then self:focus(self:findUnit('hpea',1,'lumber'))
        elseif n=='orc-workers' then self:setRace(2);self:focus(self:findUnit('opeo',2,'lumber'))
        elseif n=='orc-build' then self:focus(self:findUnit('opeo',2,'lumber'))
        elseif n=='orc-select-burrow' or n=='orc-burrow' then self:focus(self:goldMineBurrow())
        elseif n=='orc-defense' then self:spawnAttack('ugho',3,2)
        elseif n=='orc-end-defense' then self:killAttackers()
        elseif n=='nightelf-workers' then self:clearAttackers();self:setRace(3);self:focus(self:findUnit('ewsp',3,'lumber'))
        elseif n=='nightelf-mine-tour' then self:focus(self:findUnit('etol',3));self:later(5,function() self:focus(self:findUnit('egol',3)) end)
        elseif n=='nightelf-lumber' then self:focus(self:findUnit('ewsp',3,'lumber'))
        elseif n=='nightelf-build' then self:focus(self:findUnit('ewsp',3,'lumber'))
        elseif n=='nightelf-defense' then
            local farseer=JTG.ScopeTrackUnit(session.scope,CreateUnit(Player(1),FourCC('Ofar'),-3400,-2400,225))
            self.attackers[#self.attackers+1]=farseer;SelectHeroSkill(farseer,FourCC('AOsf'))
            self:scriptCall(function() IssueImmediateOrder(farseer,'spiritwolf') end)
            self:later(1,function() self:scriptCall(function() IssuePointOrder(farseer,'move',0,0) end) end)
        elseif n=='undead-workers' then self:clearAttackers();self:setRace(4);self:focus(self:findUnit('uaco',4,'gold'))
        elseif n=='undead-mine' then self:focus(self:findUnit('ugol',4))
        elseif n=='undead-lumber' then self:focus(self:findUnit('ugho',4,'lumber'))
        elseif n=='undead-build' then
            self:focus(self:findUnit('uaco',4,'gold'))
            local p=self:placement('uaod');SetBlight(ECONOMY_PLAYER,p.x,p.y,256,true)
        elseif n=='undead-unsummon' then self:focus(self:findUnit('usep',4))
        elseif n=='undead-sacrifice' then self:focus(self:findUnit('usap',4))
        elseif n=='food-display' then self:focus(self:mainBuilding());self:resourceHint('food')
        elseif n=='racial-food-tour' then self:setRace(3);self:later(5,function() self:setRace(4) end)
        elseif n=='orc-food' then self:setRace(2)
        elseif n=='human-hall-tour' then
            self:setRace(1);self:ensureBuilding('hkee',1);self:ensureBuilding('hcas',1)
            self:later(5,function() self:focus(self:findUnit('hkee',1)) end)
            self:later(10,function() self:focus(self:findUnit('hcas',1)) end)
        elseif n=='food-building-tour' then
            for _,raw in ipairs({'hkee','hcas'}) do local u=self:findUnit(raw,1);if u then RemoveUnit(u) end end
            self:setRace(1);self:focus(self:findUnit('hhou',1))
            local well=self:findUnit('emow',3)
            self:later(5,function() self:setRace(2);self:focus(self:goldMineBurrow()) end)
            self:later(10,function() self:setRace(3);self:focus(well) end)
            self:later(15,function() self:setRace(4);self:focus(self:findUnit('uzig',4)) end)
        elseif n=='food-limit-demonstration' then
            self:setRace(4);local hall=self:mainBuilding();self:focus(hall)
            SetPlayerState(ECONOMY_PLAYER,PLAYER_STATE_RESOURCE_FOOD_USED,GetPlayerState(ECONOMY_PLAYER,PLAYER_STATE_RESOURCE_FOOD_CAP))
            self:scriptCall(function() IssueImmediateOrderById(hall,FourCC('uaco')) end)
        elseif n=='upkeep-display' then self:focus(self:mainBuilding());self:resourceHint('upkeep')
        elseif n=='low-upkeep' then self:setFoodUsed(51)
        elseif n=='low-upkeep-focus' then self:focus(self:mainBuilding())
        elseif n=='no-upkeep' then self:setFoodUsed(50)
        elseif n=='high-upkeep' then self:setFoodUsed(81);self:focus(self:mainBuilding())
        elseif n=='outro' then BlzFrameSetVisible(self.frames.menuHighlight,self.presentationVisible) end
    end

    function activity:setup(current)
        layoutSetup(self,current)
        self:setupEconomyScript(current)
        SetBlight(Player(5),-6336,1920,850,true)
        self:prepareCheckpoint(self.step)
        self:makeTimer(TICK_INTERVAL,true,function() self:tick() end)
    end
    function activity:start()
        JTG.UI.HideToolbar()
        self:createPresentation()
        self:startGathering(nil,nil,true)
        -- Sample the initial approach, including races not yet shown. Native
        -- order acceptance alone cannot establish that a worker moved.
        if self.recordEconomyOrderState then
            for _,delay in ipairs({0.25,1,3,5}) do
                JTG.StartScopedTimer(session,session.scope,delay,false,function()
                    for _,assignment in ipairs(self.placements) do
                        if assignment.placement.gathering then
                            self:recordEconomyOrderState('startup-'..delay,assignment.unit,0)
                        end
                    end
                end)
            end
        end
        self:showStep(self.step)
    end

    function activity:setPaused(paused)
        self.locallyPaused = paused == true
        self:refreshControls()
    end

    function activity:setOverlayVisible(visible)
        self:setPresentationVisible(visible)
    end

    function activity:hidePresentationForMenu()
        self:setPresentationVisible(false)
    end

    function activity:restorePresentation()
        if JTG.UI then
            JTG.UI.HideToolbar()
            JTG.UI.currentView = {kind = "gameplay"}
        end
        self:setPresentationVisible(true)
    end

    function activity:rebuildPresentation()
        self.frames = {}
        self.actions = {}
        self.clickTrigger = nil
        self:createPresentation()
        self:renderNarration()
        self:restoreResourceArrow()
    end

    function activity:discardPresentationForLoad()
        self.frames = {}
        self.actions = {}
        self.clickTrigger = nil
    end

    function activity:cleanup()
        JTG.UI.ClearWelcomeArrow(self)
        ClearTextMessages()
        self:clearArrow()
        if GetLocalPlayer() == ECONOMY_PLAYER then ClearSelection() end
        layoutCleanup(self)
        self.frames = {}
        self.actions = {}
    end

    JTG.Tutorial.InstallRunner(activity, session, {id="learn.economy", player=ECONOMY_PLAYER, steps=STEPS, requireStableIds=true,
        sceneExit=function(self,previous,nextStep)
            local action=previous.action
            if (action=='human-defense' or action=='orc-defense' or action=='nightelf-defense') and
                (not nextStep or nextStep.action~=action) then self:killAttackers() end
        end})
    return activity
end
