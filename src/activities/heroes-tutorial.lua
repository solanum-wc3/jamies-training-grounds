-- Authored Heroes lessons use the common tutorial lifecycle and scoped scenes.
JTG=JTG or {}
local T=JTG.Tutorial
local PLAYER=Player(0)
local SCRIPT=JTG.HeroesScript
local STEPS=SCRIPT.steps
local TOPICS={};local seen={}
local LABELS={welcome='Welcome',basics='Basics',levels='Levels',['hero-showcase']='Hero Showcase',
    experience='Experience',['xp-range']='XP Range',['xp-amounts']='XP Amounts',items='Items'}
for _,step in ipairs(STEPS) do
    if not seen[step.checkpoint] and not step.terminal then
        TOPICS[#TOPICS+1]={label=LABELS[step.checkpoint],stepId=step.id};seen[step.checkpoint]=true
    end
end
T.TopicSteps(STEPS,TOPICS)
function JTG.CreateHeroesTutorialActivity(session)
    local activity={frames={},actions={},buttonEnabled={},narrationBlocks={},groups={},actors={},dummies={},
        presentationVisible=true,step=T.ResolveStep(STEPS,session.restartData),
        xpNumberChoice='hero'}
    JTG.InstallHeroesScenes(activity,session)
    function activity:clearArrow() JTG.UI.ClearWelcomeArrow(self) end
    function activity:refreshControls()
        local available=self.xpQuestDiscovered==true
        if self.questAccessApplied~=available then
            JTG.UI.SetQuestAvailable(available);self.questAccessApplied=available
        end
        if not self.frames.continue then return end
        local current=self.optionalSection and self.optionalSection.steps[self.optionalStep] or STEPS[self.step]
        local canContinue=not self.complete
        BlzFrameSetText(self.frames.continue,current and (current.sectionEnd or current.optionalComplete) and 'Next' or 'Continue')
        self:setButtonEnabled(self.frames.continue,canContinue)
        self:setButtonEnabled(self.frames.back,self.optionalSection~=nil or self.step>1)
        BlzFrameSetText(self.frames.pause,JTG.UI.exercisePaused and 'Unpause' or 'Pause')
        BlzFrameSetVisible(self.frames.continueHighlight,self.presentationVisible and canContinue and not self.topicsOpen and not self.optionalOpen)
        BlzFrameSetVisible(self.frames.menuHighlight,self.presentationVisible and self.complete and not self.topicsOpen and not self.optionalOpen)
        local levels=self.presentationVisible and not self.topicsOpen and not self.optionalOpen and
            (self.worldScene=='showcase' or self.worldScene=='dice')
        for _,key in ipairs({'plus','minus'}) do BlzFrameSetVisible(self.frames[key],levels) end
        local selected
        for _,record in ipairs(self.levelActors) do
            if record.unit==self.selectedHero and GetUnitTypeId(record.unit)~=0 then selected=record.unit;break end
        end
        self:setButtonEnabled(self.frames.plus,selected~=nil and GetHeroLevel(selected)<10)
        self:setButtonEnabled(self.frames.minus,selected~=nil and GetHeroLevel(selected)>1)
        local xp=self.presentationVisible and not self.topicsOpen and not self.optionalOpen and self.worldScene=='xp-numbers'
        for _,button in ipairs(self.frames.xpChoices or {}) do BlzFrameSetVisible(button,xp) end
        JTG.UI.RefreshWelcomeArrow(self)
    end
    function activity:unlockXPQuest()
        if self.xpQuestDiscovered then return end
        self.xpQuestDiscovered=true;QuestSetDiscovered(self.xpQuest,true)
        JTG.UI.SetQuestAvailable(true)
        FlashQuestDialogButton()
        JTG.UI.PlayFeedbackSound('quest');self:refreshControls()
    end
    function activity:cameraAction(action)
        if action=='altar-tour' then
            local ids={'human','orc','nightelf','undead'}
            local function focus(id)
                local unit=self.buildings[id]
                if unit then T.MoveCamera(PLAYER,GetUnitX(unit),GetUnitY(unit)) end
            end
            focus(ids[1])
            for index=2,#ids do T.ScheduleStep(session,self,(index-1)*5,function() focus(ids[index]) end) end
        elseif action=='tavern-camera' then
            local unit=self.buildings.neutral;T.MoveCamera(PLAYER,GetUnitX(unit),GetUnitY(unit))
        elseif action=='dice-tour' then
            local targets={self.diceTexts[1],self.diceTexts[2],self.diceTexts[3],
                {x=(self.diceTexts[4].x+self.diceTexts[5].x)/2,y=self.diceTexts[4].y}}
            T.MoveCamera(PLAYER,targets[1].x,targets[1].y)
            for index=2,#targets do
                T.ScheduleStep(session,self,(index-1)*(T.cameraMoveDuration+1),function()
                    T.MoveCamera(PLAYER,targets[index].x,targets[index].y)
                end)
            end
        end
    end
    function activity:showStep(index)
        local step=assert(STEPS[index]);self.step=index;self.complete=step.terminal==true
        self:clearNarration();self:ensureWorld(step.scene)
        if step.dummyHostile~=nil then
            for _,record in ipairs(self.dummies) do
                if record.scriptHostile~=step.dummyHostile then
                    self:setDummyHostile(record.unit,step.dummyHostile)
                    record.scriptHostile=step.dummyHostile
                end
            end
        end
        self.narrationBlocks={T.FormatNarration(table.concat(step.lines,'\n'))}
        self:renderNarration();self:cameraAction(step.action)
        if step.checkpoint=='experience' or step.checkpoint=='xp-range' or step.checkpoint=='xp-amounts' or step.checkpoint=='items' then self:unlockXPQuest() end
        if index==1 then JTG.UI.StartWelcomeArrow(self) end
        self:refreshControls()
    end
    function activity:showOptionalStep(index)
        local step=assert(self.optionalSection.steps[index]);self.optionalStep=index;self.complete=false
        self:clearNarration();self:ensureWorld(step.scene)
        self.narrationBlocks={T.FormatNarration(table.concat(step.lines,'\n'))};self:renderNarration()
        self:cameraAction(step.action)
        if self.optionalKey=='xp' then self:unlockXPQuest() end
        self:refreshControls()
    end
    function activity:continueTutorial()
        if self.optionalSection then
            if self.optionalStep<#self.optionalSection.steps then self:showOptionalStep(self.optionalStep+1)
            else self:restoreCheckpoint(self.returnStep) end
        elseif not self.complete then self:showStep(math.min(#STEPS,self.step+1)) end
    end
    function activity:restoreCheckpoint(index)
        self.optionalSection=nil;self.optionalKey=nil;self.optionalStep=nil
        self.topicsOpen=false;self.optionalOpen=false
        T.RestoreAt(self,index,function(target) self:ensureWorld(STEPS[target].scene,true) end,
            function(target) self:showStep(target) end)
        self:refreshMenuVisibility()
    end
    function activity:goBack()
        if self.optionalSection then
            if self.optionalStep>1 then
                local index=self.optionalStep-1
                T.Transition(self,self.optionalSection.steps[index].id,function()
                    self:ensureWorld(self.optionalSection.steps[index].scene,true);self:showOptionalStep(index)
                end,self.optionalSection.steps[index],'restore')
            else self:restoreCheckpoint(self.returnStep) end
        elseif self.step>1 then self:restoreCheckpoint(self.step-1) end
    end
    function activity:openOptional(key)
        self.returnStep=self.optionalSection and self.returnStep or self.step
        self.optionalKey=key;self.optionalSection={steps=assert(SCRIPT.optional[key])}
        self.optionalOpen=false;self.topicsOpen=false
        self:showOptionalStep(1);self:refreshMenuVisibility()
    end
    function activity:selectXPDisplay(choice)
        if self.worldScene~='xp-numbers' then return end
        self.xpNumberChoice=choice;self:ensureWorld('xp-numbers',true);self:refreshControls()
    end
    function activity:refreshMenuVisibility()
        for _,pair in ipairs({{'topicsMenu','topicsOpen'},{'optionalMenu','optionalOpen'}}) do
            if self.frames[pair[1]] then BlzFrameSetVisible(self.frames[pair[1]],self.presentationVisible and self[pair[2]]==true) end
        end
        self:renderNarration();self:refreshControls()
    end
    function activity:createPresentation()
        local scope=session.presentationScope;local root=BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0)
        local suffix=tostring(session.generation or 0)..'x'..tostring(JTG.UI.epoch or 0)
        self.frames={};self.actions={};self.buttonEnabled={};self.questAccessApplied=nil
        T.CreateToolbar(self,scope,root,'JTGHeroes',suffix,{{'menu','Menu',1},{'back','Back',2},
            {'topics','Topics',3},{'optional','Optional',4},{'continue','Continue',5},{'pause','Pause',7}})
        for _,key in ipairs({'continue','menu','pause'}) do T.CreateHighlight(self,scope,'JTGHeroes',suffix,key) end
        self.frames.welcomeArrow=JTG.UI.CreateWelcomeArrow(scope,root,self.frames.continue,'JTGHeroesWelcome'..suffix)
        T.BindClicks(self,scope)
        self:registerClick(self.frames.menu,function() T.OpenMenu(self,'learn') end,'menu-open')
        self:registerClick(self.frames.back,function() self:goBack() end,'return')
        self:registerClick(self.frames.continue,function() self:continueTutorial() end)
        self:registerClick(self.frames.pause,function() T.TogglePause(self) end)
        self:registerClick(self.frames.topics,function() self.topicsOpen=not self.topicsOpen;self.optionalOpen=false;self:refreshMenuVisibility() end,'menu-open')
        self:registerClick(self.frames.optional,function() self.optionalOpen=not self.optionalOpen;self.topicsOpen=false;self:refreshMenuVisibility() end,'menu-open')
        local function panel(key,choices)
            local frame=JTG.ScopeTrackFrame(scope,BlzCreateFrameByType('FRAME','JTGHeroes'..key..suffix,root,'',0))
            BlzFrameSetSize(frame,.185,JTG.TutorialMenuHeight(#choices-1));BlzFrameSetAbsPoint(frame,FRAMEPOINT_TOPRIGHT,.795,.50)
            local skin=JTG.ScopeTrackFrame(scope,BlzCreateFrame('EscMenuBackdrop',frame,0,2100+#choices))
            BlzFrameSetAllPoints(skin,frame);BlzFrameSetEnable(skin,false)
            for index,choice in ipairs(choices) do
                local close=index==#choices
                local width=close and .10 or .115
                local button=JTG.ScopeTrackFrame(scope,T.CreateButton('JTGHeroes'..key..index..suffix,frame,choice.label,width))
                BlzFrameSetSize(button,width,.026)
                if close then BlzFrameSetPoint(button,FRAMEPOINT_BOTTOM,frame,FRAMEPOINT_BOTTOM,0,.025)
                else BlzFrameSetPoint(button,FRAMEPOINT_TOP,frame,FRAMEPOINT_TOP,0,-.041-(index-1)*.029) end
                self:registerClick(button,choice.action)
            end
            self.frames[key..'Menu']=frame
        end
        local choices={}
        for _,topic in ipairs(TOPICS) do choices[#choices+1]={label=topic.label,action=function() self:restoreCheckpoint(topic.step) end} end
        choices[#choices+1]={label='Close',action=function() self.topicsOpen=false;self:refreshMenuVisibility() end}
        panel('topics',choices)
        panel('optional',{{label='Attack Dice',action=function() self:openOptional('dice') end},
            {label='XP Numbers',action=function() self:openOptional('xp') end},
            {label='Close',action=function() self.optionalOpen=false;self:refreshMenuVisibility() end}})
        for index,key in ipairs({'plus','minus'}) do
            local button=JTG.ScopeTrackFrame(scope,T.CreateButton('JTGHeroes'..key..suffix,root,key=='plus' and '+' or '-',.055))
            BlzFrameSetAbsPoint(button,FRAMEPOINT_TOPRIGHT,.785,.435-(index-1)*.032)
            self.frames[key]=button
            self:registerClick(button,function() self:changeHeroLevel(key=='plus' and 1 or -1) end)
        end
        self.frames.xpChoices={}
        for index,choice in ipairs({{'Hero','hero'},{'Human','human'},{'Orc','orc'},{'Night Elf','nightelf'},{'Undead','undead'},{'Neutral','neutral'}}) do
            local button=JTG.ScopeTrackFrame(scope,T.CreateButton('JTGHeroesXP'..index..suffix,root,choice[1],.10))
            BlzFrameSetAbsPoint(button,FRAMEPOINT_TOPRIGHT,.785,.435-(index-1)*.031)
            self.frames.xpChoices[index]=button
            self:registerClick(button,function() self:selectXPDisplay(choice[2]) end)
        end
        self:refreshMenuVisibility()
    end
    function activity:setPresentationVisible(visible)
        self.presentationVisible=visible==true
        if self.frames.bar then BlzFrameSetVisible(self.frames.bar,self.presentationVisible) end
        self:refreshMenuVisibility()
    end
    function activity:hidePresentationForMenu() self:setPresentationVisible(false) end
    function activity:restorePresentation()
        JTG.UI.HideToolbar();JTG.UI.currentView={kind='gameplay'};self.questAccessApplied=nil;self:setPresentationVisible(true)
    end
    function activity:setPaused(value) self.locallyPaused=value==true;self:refreshControls() end
    function activity:captureResetState() return T.CaptureCheckpoint(self,self.optionalSection and self.returnStep or self.step) end
    function activity:discardPresentationForLoad() self.frames={};self.actions={};self.buttonEnabled={};self.clickTrigger=nil end
    function activity:rebuildPresentation() self:createPresentation();self:restorePresentation() end
    function activity:setup(current)
        JTG.BorrowCamera(current.scope,PLAYER);JTG.ResetWorldFog(PLAYER)
        local oldTime,oldScale=GetFloatGameState(GAME_STATE_TIME_OF_DAY),GetTimeOfDayScale()
        JTG.ScopeBorrow(current.scope,function() SetFloatGameState(GAME_STATE_TIME_OF_DAY,oldTime);SetTimeOfDayScale(oldScale) end)
        SetFloatGameState(GAME_STATE_TIME_OF_DAY,12);SetTimeOfDayScale(0)
        for _,a in ipairs({self.rosterArena,self.practiceArena}) do JTG.ScopeRevealScene(current.scope,a,PLAYER) end
        local area=GetWorldBounds();local group=CreateGroup();GroupEnumUnitsInRect(group,area,nil)
        while true do
            local unit=FirstOfGroup(group);if not unit then break end;GroupRemoveUnit(group,unit)
            if GetOwningPlayer(unit)==PLAYER then
                local paused,hidden=IsUnitPaused(unit),IsUnitHidden(unit)
                JTG.ScopeBorrow(current.scope,function() SetUnitOwner(unit,PLAYER,false);ShowUnit(unit,not hidden);PauseUnit(unit,paused) end)
                SetUnitOwner(unit,Player(PLAYER_NEUTRAL_PASSIVE),false);ShowUnit(unit,false);PauseUnit(unit,true)
            end
        end
        DestroyGroup(group);RemoveRect(area)
        local oldXPHandicap=GetPlayerHandicapXP(PLAYER)
        if oldXPHandicap~=1 then
            JTG.ScopeBorrow(current.scope,function()
                if GetPlayerHandicapXP(PLAYER)~=oldXPHandicap then SetPlayerHandicapXP(PLAYER,oldXPHandicap) end
            end)
            SetPlayerHandicapXP(PLAYER,1)
        end
        for _,state in ipairs({PLAYER_STATE_RESOURCE_GOLD,PLAYER_STATE_RESOURCE_LUMBER}) do
            local old=GetPlayerState(PLAYER,state);JTG.ScopeBorrow(current.scope,function() SetPlayerState(PLAYER,state,old) end)
        end
        for _,other in ipairs({Player(1),Player(PLAYER_NEUTRAL_AGGRESSIVE)}) do
            for _,pair in ipairs({{PLAYER,other},{other,PLAYER}}) do
                local old=GetPlayerAlliance(pair[1],pair[2],ALLIANCE_PASSIVE)
                JTG.ScopeBorrow(current.scope,function() SetPlayerAlliance(pair[1],pair[2],ALLIANCE_PASSIVE,old) end)
                SetPlayerAlliance(pair[1],pair[2],ALLIANCE_PASSIVE,false)
            end
        end
        -- Only dummies use this hostile faction. Shared control keeps their
        -- two mode commands available without granting control over XP enemies.
        local dummyOwner=Player(6)
        for _,pair in ipairs({{PLAYER,dummyOwner,ALLIANCE_PASSIVE,false},
                {dummyOwner,PLAYER,ALLIANCE_PASSIVE,false},
                {dummyOwner,PLAYER,ALLIANCE_SHARED_CONTROL,true}}) do
            local old=GetPlayerAlliance(pair[1],pair[2],pair[3])
            JTG.ScopeBorrow(current.scope,function() SetPlayerAlliance(pair[1],pair[2],pair[3],old) end)
            SetPlayerAlliance(pair[1],pair[2],pair[3],pair[4])
        end
        self.xpQuest=JTG.ScopeTrackQuest(current.scope,CreateQuest())
        QuestSetTitle(self.xpQuest,'XP Numbers');QuestSetDescription(self.xpQuest,T.FormatNarration(SCRIPT.quest))
        QuestSetIconPath(self.xpQuest,BlzGetAbilityIcon(FourCC('Ainf')))
        QuestSetRequired(self.xpQuest,false);QuestSetDiscovered(self.xpQuest,false);QuestSetEnabled(self.xpQuest,true)
        local selected=JTG.ScopeTrackTrigger(current.scope,CreateTrigger())
        TriggerRegisterPlayerUnitEvent(selected,PLAYER,EVENT_PLAYER_UNIT_SELECTED,nil)
        TriggerAddAction(selected,JTG.GuardSession(current,function() self.selectedHero=GetTriggerUnit();self:refreshControls() end))
        local damaged=JTG.ScopeTrackTrigger(current.scope,CreateTrigger())
        TriggerRegisterPlayerUnitEvent(damaged,PLAYER,EVENT_PLAYER_UNIT_DAMAGED,nil)
        TriggerRegisterPlayerUnitEvent(damaged,dummyOwner,EVENT_PLAYER_UNIT_DAMAGED,nil)
        TriggerAddAction(damaged,JTG.GuardSession(current,function() self:showDummyDamage(GetTriggerUnit(),GetEventDamage()) end))
        local dummyModes=JTG.ScopeTrackTrigger(current.scope,CreateTrigger())
        for _,owner in ipairs({PLAYER,dummyOwner}) do
            TriggerRegisterPlayerUnitEvent(dummyModes,owner,EVENT_PLAYER_UNIT_SPELL_EFFECT,nil)
        end
        TriggerAddAction(dummyModes,JTG.GuardSession(current,function()
            local ability=GetSpellAbilityId()
            if ability==FourCC('JHdN') or ability==FourCC('JHdH') then
                self:setDummyHostile(GetTriggerUnit(),ability==FourCC('JHdN'))
            elseif ability==FourCC('JHdP') or ability==FourCC('JHdM') then
                self:adjustDummyArmor(GetTriggerUnit(),ability==FourCC('JHdP') and 1 or -1)
            else
                for _,kind in ipairs(JTG.HeroesData.dummyArmorTypes) do
                    if ability==FourCC(kind.raw) then self:adjustDummyArmor(GetTriggerUnit());break end
                end
            end
        end))
        local summoned=JTG.ScopeTrackTrigger(current.scope,CreateTrigger())
        TriggerRegisterPlayerUnitEvent(summoned,PLAYER,EVENT_PLAYER_UNIT_SUMMON,nil)
        TriggerAddAction(summoned,JTG.GuardSession(current,function()
            local scope=self.ownerScopes[GetSummoningUnit()];local unit=GetSummonedUnit()
            if scope then
                SetUnitUseFood(unit,false)
                if scope.disposed then RemoveUnit(unit) else JTG.ScopeTrackUnit(scope,unit);self.ownerScopes[unit]=scope end
            end
        end))
        self:makeRoster('overview');self.worldScene='overview';self.actors={};self.dummies={}
        self:createPresentation()
        self:makeTimer(.05,true,function()
            if self.locallyPaused or JTG.UI.exercisePaused then return end
            self:tickWorld();JTG.UI.TickWelcomeArrow(self,.05)
            self:refreshControls()
        end)
    end
    function activity:start()
        JTG.UI.HideToolbar()
        if self.step>1 then self:restoreCheckpoint(self.step)
        else T.MoveCamera(PLAYER,self.rosterArena.centerX,self.rosterArena.centerY);self:showStep(1) end
    end
    function activity:cleanup()
        self.presentationVisible=false;self.complete=true;ClearTextMessages()
        JTG.UI.SetQuestAvailable(false)
        if GetLocalPlayer()==PLAYER then ClearSelection() end
    end
    T.InstallRunner(activity,session,{id='learn.heroes',player=PLAYER,steps=STEPS,requireStableIds=true})
    return activity
end
