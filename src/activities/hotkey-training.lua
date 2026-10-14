-- Native command-card recognition: Warcraft resolves the player's bindings.
-- No guessed key table, standard-key fallback, or replacement command card.
JTG = JTG or {}
JTG.HotkeyHighScores = JTG.HotkeyHighScores or {}
local RACES = {
    {id='human',name='Human',symbol='Human'}, {id='orc',name='Orc',symbol='Orc'},
    {id='nightelf',name='Night Elf',symbol='NightElf'}, {id='undead',name='Undead',symbol='Undead'},
    {id='neutral',name='Neutral'},
}
local TICK, DURATION = 0.02, 60
-- Physical key notifications and native game actions are different event
-- streams. Keep unanswered keys until the game has had time to confirm them;
-- score response time from the physical key, never from confirmation latency.
local CONFIRMATION_WINDOW = 0.50
local NEUTRAL_SHOPS={ntav=true,ngad=true,ngme=true,nmer=true,nmr2=true,nmr3=true}
local PROMPT_LABELS={build='Building',train='Unit',research='Research',upgrade='Upgrade',
    buy='Item',hire='Unit',ability='Ability',learn='Ability Choice',common='Ability'}
-- Keep cancellation, context creation and selection on separate updates.
-- Native audits retain their longer settling times independently.
local PROMPT_TRANSITION = 0.08
local SELECTION_SETTLE = 0.08
local SELECTION_ARM = 0.04

function JTG.HotkeyPromptConflict(prompt,source)
    if prompt.kind~='ability' then return nil end
    local raw=prompt.activeAbility or prompt.ability
    local x,y=BlzGetAbilityPosX(FourCC(raw)),BlzGetAbilityPosY(FourCC(raw))
    for _,other in ipairs((JTG.HotkeyCommandsBySource or {})[prompt.source] or {}) do
        local otherRaw=other.activeAbility or other.ability
        if other.kind=='ability' and otherRaw~=raw and
                (not source or GetUnitAbilityLevel(source,FourCC(otherRaw))>0) and
                BlzGetAbilityPosX(FourCC(otherRaw))==x and BlzGetAbilityPosY(FourCC(otherRaw))==y then
            return other.id
        end
    end
end

function JTG.OpenHotkeyTrainingMenu(category, paused, page, data)
    category = category or 'tools'
    local spec = {title='Hotkey Trainer',activityId='tools.hotkeys',originCategory=category,
        pageId=page or 'root',restoreData=data or {},pauseGame=paused==true,
        body=JTG.Training.BriefingText('tools.hotkeys','root'),
        centerSingleChoice=true,
        headingArtwork='JTGMenu\\HotkeyTrainingBriefing.dds',
        headingArtworkWidth=0.16,headingArtworkHeight=0.08,
        backAction=function() JTG.UI.ShowCategory(category) end}
    if page=='race' then
        spec.body=JTG.Training.BriefingText('tools.hotkeys','race')
        spec.headingArtwork=nil
        spec.choices={}
        for index,race in ipairs(RACES) do
            local id=race.id
            spec.choices[index]={label=race.name,primary=true,
                x=index==5 and 0 or nil,
                icon=race.symbol and ('UI\\Glues\\Loading\\Backgrounds\\Campaigns\\'..race.symbol..'Symbol.dds') or
                    'ReplaceableTextures\\CommandButtons\\BTNTavern.blp',
                iconSize=race.symbol and 0.0396 or 0.02376,iconOffsetX=0.051,
                action=function()
                    JTG.UI.SetGameplayMenuPaused(false)
                    JTG.StartActivityAfterCleanup('tools.hotkeys',category,{race=id},nil,'hotkey-race')
                end}
        end
        spec.backAction=function() JTG.OpenHotkeyTrainingMenu(category,paused) end
    else
        spec.choices={{label='Start Training',primary=true,action=function()
            JTG.OpenHotkeyTrainingMenu(category,paused,'race')
        end}}
    end
    if paused then
        spec.resumeAction=function() JTG.UI.SetGameplayMenuPaused(false); JTG.ResumeActivity() end
        spec.exitAction=function() JTG.StopActivity('menu-exit'); JTG.OpenHotkeyTrainingMenu(category,false) end
    end
    JTG.UI.ShowActivityBriefing(spec)
end

function JTG.HotkeyCommandKey(prompt)
    -- The command is the curriculum item, not the unit carrying its button.
    -- Learning and using a skill are deliberately separate tasks.
    local name=(prompt.name or prompt.raw):lower():gsub('%s+',' ')
    return prompt.kind..':'..name..':'..tostring(prompt.researchLevel or '')
end

function JTG.HotkeyChooseCommand(state,entries)
    local fresh,review,seen={},{},{}
    for _,entry in ipairs(entries) do
        local key=JTG.HotkeyCommandKey(entry)
        if not seen[key] and not state.stageSeen[key] then
            seen[key]=true
            if not state.tested[key] then fresh[#fresh+1]=entry
            elseif state.stage>=2 and state.failed[key] then review[#review+1]=entry end
        end
    end
    local choices=#fresh>0 and fresh or review
    if #choices>0 then return choices[GetRandomInt(1,#choices)] end
end

function JTG.CreateHotkeyTrainingActivity(session)
    local requestedRace=(session.restartData or {}).race or 'human'
    local self={race=JTG.HotkeyPools[requestedRace] and requestedRace or 'human',elapsed=0,score=0,
        correct=0,incorrect=0,totalResponse=0,presentationVisible=true,logs={},held={},frames={},
        stage=1,stageStart=0,tested={},failed={},stageSeen={}}
    function self:diagnosticsActive()
        return self.diagnostics~=nil and self.diagnostics.active(self)==true
    end
    function self:runDiagnostics(hook)
        if not self:diagnosticsActive() then return false end
        local callback=self.diagnostics[hook]
        if callback then callback(self);return true end
        return false
    end
    function self:createUnit(owner,raw,x,y,facing)
        local unit=CreateUnit(owner,raw,x,y,facing)
        self:concealUnit(unit)
        return unit
    end
    function self:concealUnit(unit)
        if unit then BlzSetUnitRealField(unit,UNIT_RF_SIGHT_RADIUS,0) end
    end
    function self:refreshCovers()
        local visible=self.presentationVisible and not self:diagnosticsActive()
        -- The camera looks at masked terrain away from the units. Only the
        -- lower interface needs a visual cover; never cover the prompt area.
        if self.lowerCover then
            BlzFrameSetVisible(self.lowerCover,visible and not self.finished and (self.promptMistakes or 0)<3)
        end
    end
    function self:inputActive()
        return not self.finished and not self.paused and self.presentationVisible and self.prompt and
            not self.advance and not self.transitionAt and self:promptIsReady()
    end
    function self:eventInputActive()
        return self:inputActive() or (self.promptShown and not self.finished and not self.paused and
            self.presentationVisible and self.prompt and not self.advance and not self.transitionAt and
            self.elapsed>=(self.armedAt or math.huge))
    end
    function self:promptIsReady()
        return self.source and self.elapsed>=(self.armedAt or math.huge) and self:sourcePreparationReady() and
            IsUnitSelected(self.source,Player(0)) and (not self.buyer or self.prompt.kind=='common' or self.patronAccepted and
                self.elapsed>=(self.patronAssignedAt or self.promptAt or math.huge)+TICK)
    end
    function self:updatePromptReadiness()
        if self.waitingPrompt or not self.prompt then return end
        if self.selectionAt then
            if self.elapsed<self.selectionAt then return end
            self.selectionAt=nil
            self:restoreSource()
            self.armedAt=self.elapsed+SELECTION_ARM
        end
        if self.buyer and self.prompt.kind~='common' and not self.patronAccepted and
            IsUnitSelected(self.source,Player(0)) then self:assignPatron() end
        local ready=self:promptIsReady()==true
        if ready~=self.promptReady then
            self.promptReady=ready
            if ready and not self.promptShown then
                self.promptShown=true;self.promptAt=self.elapsed
                if not self.forcedPrompt and not self:diagnosticsActive() then
                    local key=JTG.HotkeyCommandKey(self.prompt)
                    self.tested[key]=true;self.stageSeen[key]=true
                end
            end
            self:refreshPrompt()
        end
    end
    function self:sourcePreparationReady()
        if self.garrisonPeon and not IsUnitInTransport(self.garrisonPeon,self.source) then return false end
        if not self.requiresUprooted then return true end
        return self:preparedAncientReady(self.activePreparedAncient)
    end
    function self:prepareGarrison()
        if self.preparedGarrison then return end
        local scope=JTG.CreateScope('hotkey-prepared-burrow')
        JTG.ScopeAdd(session.scope,function() JTG.DisposeScope(scope) end)
        local burrow=JTG.ScopeTrackUnit(scope,self:createUnit(Player(0),FourCC('otrb'),
            session.scene.centerX+800,self.spawnY+1000,0))
        SetUnitPathing(burrow,false);SetUnitInvulnerable(burrow,true);SetUnitAcquireRange(burrow,0)
        local peon=JTG.ScopeTrackUnit(scope,self:createUnit(Player(0),FourCC('opeo'),GetUnitX(burrow),GetUnitY(burrow),0))
        SetUnitPathing(peon,false);SetUnitAcquireRange(peon,0)
        -- Native creation can push a unit out of a building footprint.
        SetUnitX(peon,GetUnitX(burrow));SetUnitY(peon,GetUnitY(burrow))
        self.preparedGarrison={scope=scope,unit=burrow,peon=peon,
            accepted=IssueTargetOrder(peon,'smart',burrow)==true}
    end
    function self:garrisonReady()
        local prepared=self.preparedGarrison
        return prepared and prepared.accepted and IsUnitInTransport(prepared.peon,prepared.unit)
    end
    function self:takePreparedGarrison(context)
        self:prepareGarrison()
        local prepared=self.preparedGarrison
        self.preparedGarrison=nil
        JTG.ScopeAdd(context,function() JTG.DisposeScope(prepared.scope) end)
        SetUnitX(prepared.unit,session.scene.centerX);SetUnitY(prepared.unit,self.spawnY)
        self.garrisonPeon=prepared.peon
        self:prepareGarrison()
        return prepared.unit,prepared.accepted
    end
    function self:clearPreparedGarrison()
        if self.preparedGarrison then JTG.DisposeScope(self.preparedGarrison.scope) end
        self.preparedGarrison=nil
    end
    function self:assignPatron()
        if not self.buyer or self.prompt.kind=='common' then return end
        self.patronAccepted=IssueNeutralTargetOrderById(Player(0),self.source,852566,self.buyer)==true
        self.patronAssignedAt=self.patronAccepted and self.elapsed or nil
    end
    function self:preparedAncientReady(prepared)
        return prepared and prepared.accepted and self.elapsed>=prepared.readyAt and
            not BlzGetUnitBooleanField(prepared.unit,UNIT_BF_IS_A_BUILDING)
    end
    function self:prepareAncient(raw)
        self.preparedAncients=self.preparedAncients or {}
        if self.preparedAncients[raw] then return end
        local scope=JTG.CreateScope('hotkey-prepared-ancient')
        JTG.ScopeAdd(session.scope,function() JTG.DisposeScope(scope) end)
        local unit=JTG.ScopeTrackUnit(scope,self:createUnit(Player(0),FourCC(raw),
            session.scene.centerX+800,self.spawnY+1000,0))
        assert(unit and GetUnitTypeId(unit)~=0,'Missing Ancient: '..raw)
        SetUnitPathing(unit,false);SetUnitInvulnerable(unit,true);SetUnitAcquireRange(unit,0)
        local accepted=IssueImmediateOrder(unit,'unroot')==true
        local ability=BlzGetUnitAbility(unit,FourCC('Aro1')) or BlzGetUnitAbility(unit,FourCC('Aro2'))
        assert(ability,'Ancient has no Root ability: '..raw)
        local duration=BlzGetAbilityRealLevelField(ability,ABILITY_RLF_DURATION_NORMAL,0)
        self.preparedAncients[raw]={unit=unit,scope=scope,accepted=accepted,
            readyAt=self.elapsed+math.max(0,duration)+0.10}
    end
    function self:ancientReady(raw)
        local prepared=self.preparedAncients and self.preparedAncients[raw]
        return self:preparedAncientReady(prepared)
    end
    function self:takePreparedAncient(raw,context)
        self:prepareAncient(raw)
        local prepared=self.preparedAncients[raw]
        self.preparedAncients[raw]=nil
        self.activePreparedAncient=prepared
        JTG.ScopeAdd(context,function() JTG.DisposeScope(prepared.scope) end)
        SetUnitX(prepared.unit,session.scene.centerX);SetUnitY(prepared.unit,self.spawnY)
        -- Start its replacement now, so later prompts do not repeat the animation.
        self:prepareAncient(raw)
        return prepared.unit,prepared.accepted
    end
    function self:clearPreparedAncients()
        for _,prepared in pairs(self.preparedAncients or {}) do JTG.DisposeScope(prepared.scope) end
        self.preparedAncients={}
    end
    function self:refreshStatus()
        if not self.status then return end
        if self:runDiagnostics("status") then return end
        BlzFrameSetText(self.status,string.format('Stage %d     Time: %ds\nCorrect: %d     Incorrect: %d',
            self.stage,math.ceil(math.max(0,DURATION-(self.elapsed-self.stageStart))),self.correct,self.incorrect))
        if self.scoreFrame then
            local color,scale=JTG.Training.ScoreStyle(self.score)
            BlzFrameSetText(self.scoreFrame,color..'Score: '..self.score..'|r')
            BlzFrameSetSize(self.scoreFrame,0.40/scale,0.055/scale)
            BlzFrameSetScale(self.scoreFrame,scale)
            BlzFrameSetVisible(self.scoreFrame,self.presentationVisible and not self.finished)
        end
        BlzFrameSetVisible(self.status,self.presentationVisible and not self.finished)
    end
    function self:refreshPrompt()
        if not self.panel then return end
        local prompt=self.prompt
        BlzFrameSetVisible(self.panel,self.presentationVisible and not self.finished and not self.transitionAt and prompt~=nil and self:promptIsReady()==true)
        if not prompt then return end
        BlzFrameSetText(self.heading,'|cffffcc00'..PROMPT_LABELS[prompt.kind]..': '..prompt.name..'|r')
        BlzFrameSetTexture(self.commandIcon,prompt.icon,0,true)
        BlzFrameSetTexture(self.sourceIcon,prompt.sourceIcon,0,true)
        local submenu=prompt.kind=='build' or prompt.kind=='learn'
        BlzFrameSetVisible(self.buildIcon,submenu)
        BlzFrameSetVisible(self.buildButton,submenu)
        BlzFrameClearAllPoints(self.sourceButton)
        BlzFrameSetPoint(self.sourceButton,FRAMEPOINT_CENTER,self.panel,FRAMEPOINT_CENTER,
            submenu and -0.095 or -0.042,-0.014)
        BlzFrameClearAllPoints(self.buildButton)
        BlzFrameSetPoint(self.buildButton,FRAMEPOINT_CENTER,self.panel,FRAMEPOINT_CENTER,0.015,-0.014)
        if submenu then BlzFrameSetTexture(self.buildIcon,prompt.buildIcon,0,true) end
        BlzFrameSetSize(self.panel,submenu and 0.37 or 0.32,0.17)
        BlzFrameSetSize(self.heading,submenu and 0.33 or 0.28,0.055)
        BlzFrameSetVisible(self.sourceIcon,not prompt.universal)
        BlzFrameSetVisible(self.sourceButton,not prompt.universal)
        BlzFrameClearAllPoints(self.commandButton)
        BlzFrameSetPoint(self.commandButton,FRAMEPOINT_CENTER,self.panel,FRAMEPOINT_CENTER,
            prompt.universal and 0 or (submenu and 0.079 or 0.042),-0.014)
        local description=prompt.description or ''
        if prompt.kind=='ability' then
            description=BlzGetAbilityExtendedTooltip(FourCC(prompt.ability),math.max(0,GetUnitAbilityLevel(self.source,FourCC(prompt.ability))-1))
        end
        if prompt.kind=='learn' then description=BlzGetAbilityResearchExtendedTooltip(FourCC(prompt.ability),0) end
        self.sourceTooltipUpdate('|cffffcc00'..prompt.sourceName..'|r\n'..(prompt.sourceDescription or ''))
        self.commandTooltipUpdate('|cffffcc00'..prompt.name..'|r\n'..description)
        self.buildTooltipUpdate(prompt.kind=='learn' and '|cffffcc00Hero Abilities|r\nOpens this hero\'s skill-selection menu.' or '|cffffcc00Build|r\nOpens this worker\'s construction menu.')
    end
    function self:createPresentation()
        local root=BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0)
        local function frame(kind,name,parent,template)
            return JTG.ScopeTrackFrame(session.presentationScope,
                BlzCreateFrameByType(kind,'JTGHotkeys'..name,parent,template or '',0))
        end
        -- Cover visuals, not the native command buttons. Disabling/hiding the
        -- command-card hierarchy also disables the user's real hotkeys.
        if JTG.UI.toolbar then BlzFrameSetLevel(JTG.UI.toolbar,40) end
        self.lowerCover=frame('BACKDROP','LowerUI',root)
        BlzFrameSetAbsPoint(self.lowerCover,FRAMEPOINT_CENTER,0.4,0.08)
        BlzFrameSetSize(self.lowerCover,1.2,0.16)
        BlzFrameSetTexture(self.lowerCover,'JTGMenu\\OpaqueBlack.dds',0,true)
        BlzFrameSetVertexColor(self.lowerCover,BlzConvertColor(255,0,0,0))
        BlzFrameSetEnable(self.lowerCover,false)
        BlzFrameSetLevel(self.lowerCover,20)
        self.panel=frame('BACKDROP','Prompt',root,'EscMenuBackdrop')
        BlzFrameSetSize(self.panel,0.39,0.25)
        BlzFrameSetAbsPoint(self.panel,FRAMEPOINT_CENTER,0.40,0.32)
        BlzFrameSetEnable(self.panel,false)
        BlzFrameSetLevel(self.panel,30)
        self.heading=frame('TEXT','Name',self.panel)
        BlzFrameSetSize(self.heading,0.35,0.055)
        BlzFrameSetPoint(self.heading,FRAMEPOINT_TOP,self.panel,FRAMEPOINT_TOP,0,-0.015)
        BlzFrameSetTextAlignment(self.heading,TEXT_JUSTIFY_MIDDLE,TEXT_JUSTIFY_CENTER)
        BlzFrameSetScale(self.heading,1.3)
        self.sourceButton=frame('BACKDROP','SourceButton',self.panel)
        self.commandButton=frame('BACKDROP','CommandButton',self.panel)
        self.buildButton=frame('BACKDROP','BuildButton',self.panel)
        for _,button in ipairs({self.sourceButton,self.commandButton,self.buildButton}) do
            BlzFrameSetSize(button,0.064,0.064)
            BlzFrameSetEnable(button,false)
        end
        self.sourceIcon=frame('BACKDROP','Source',self.sourceButton)
        self.commandIcon=frame('BACKDROP','Command',self.commandButton)
        self.buildIcon=frame('BACKDROP','Build',self.buildButton)
        BlzFrameSetAllPoints(self.sourceIcon,self.sourceButton)
        BlzFrameSetAllPoints(self.commandIcon,self.commandButton)
        BlzFrameSetAllPoints(self.buildIcon,self.buildButton)
        BlzFrameSetPoint(self.buildButton,FRAMEPOINT_CENTER,self.panel,FRAMEPOINT_CENTER,0,-0.014)
        for _,icon in ipairs({self.sourceIcon,self.commandIcon,self.buildIcon}) do
            BlzFrameSetSize(icon,0.064,0.064)
            BlzFrameSetEnable(icon,false)
        end
        self.customTooltips={}
        -- During native validation, the icons are display-only and the actual
        -- command grid supplies tooltips. No custom icon input/focus handlers.
        self.sourceTooltipUpdate=function() end
        self.commandTooltipUpdate=function() end
        self.buildTooltipUpdate=function() end
        self.status=frame('TEXT','Stats',root)
        BlzFrameSetSize(self.status,0.44,0.06)
        BlzFrameSetAbsPoint(self.status,FRAMEPOINT_CENTER,0.4,0.48)
        BlzFrameSetTextAlignment(self.status,TEXT_JUSTIFY_MIDDLE,TEXT_JUSTIFY_CENTER)
        BlzFrameSetScale(self.status,1.25)
        BlzFrameSetEnable(self.status,false)
        BlzFrameSetLevel(self.status,30)
        self.scoreFrame=frame('TEXT','Score',root)
        BlzFrameSetSize(self.scoreFrame,0.40,0.055)
        BlzFrameSetAbsPoint(self.scoreFrame,FRAMEPOINT_CENTER,0.4,0.425)
        BlzFrameSetTextAlignment(self.scoreFrame,TEXT_JUSTIFY_MIDDLE,TEXT_JUSTIFY_CENTER)
        BlzFrameSetEnable(self.scoreFrame,false)
        BlzFrameSetLevel(self.scoreFrame,30)
        self.resultCard=JTG.UI.CreateResultCard(session,{name='JTGHotkeysResult',width=0.46,detailsHeight=0.17})
        if self.resultCard.panel then BlzFrameSetLevel(self.resultCard.panel,30) end
        self.resultScore=frame('TEXT','ResultScore',self.resultCard.panel)
        BlzFrameSetSize(self.resultScore,0.36,0.055)
        BlzFrameSetPoint(self.resultScore,FRAMEPOINT_TOP,self.resultCard.panel,FRAMEPOINT_TOP,0,-0.067)
        BlzFrameSetTextAlignment(self.resultScore,TEXT_JUSTIFY_MIDDLE,TEXT_JUSTIFY_CENTER)
        BlzFrameSetEnable(self.resultScore,false)
        if self.resultCard.details then
            BlzFrameSetSize(self.resultCard.details,0.40,0.12)
            BlzFrameClearAllPoints(self.resultCard.details)
            BlzFrameSetPoint(self.resultCard.details,FRAMEPOINT_TOP,self.resultScore,FRAMEPOINT_BOTTOM,0,-0.004)
        end
        self:refreshCovers()
        self:refreshPrompt(); self:refreshStatus()
    end
    function self:restoreSource()
        if not self.source or self.finished then return end
        if GetLocalPlayer()==Player(0) then
            self.skillMenuOpen=false
            self.submenuOpen=false
            ForceUICancel()
            ClearSelection(); SelectUnit(self.source,true)
            if self.buyer and not self.patronAccepted then self:assignPatron() end
        end
    end
    function self:nativeMatched(origin)
        -- Warcraft may change selection while executing an instant spell.
        -- A confirmed event from this context still belongs to the shown
        -- question; selection is a preparation requirement, not an outcome.
        if not self:eventInputActive() then return end
        if GetLocalPlayer()~=Player(0) then return end
        self.matchedAt,self.matchOrigin=self.elapsed,origin
        self:recordInputEvent('correct',origin)
    end
    function self:recordInputEvent(kind,origin)
        if self.diagnostics then self.diagnostics.trace(self,kind,origin) end
        if not self:eventInputActive() then return end
        self.inputEvents=self.inputEvents or {}
        local last=self.inputEvents[#self.inputEvents]
        -- Several native event routes can describe the same button activation.
        if last and last.kind==kind and last.at==self.elapsed then return end
        self.inputEvents[#self.inputEvents+1]={kind=kind,at=self.elapsed,origin=origin}
    end
    function self:nativePrefix()
        if not self:inputActive() then return end
        self.prefixAt=self.elapsed
        self.submenuOpen=true
        self.skillMenuOpen=self.prompt.kind=='learn'
        self:recordInputEvent('prefix','submenu')
    end
    function self:nextPrompt(forcedPrompt)
        self.waitingPrompt=nil
        self.advance=false
        self.forcedPrompt=forcedPrompt~=nil
        self.promptWrong=false;self.promptAnswered=false;self.promptMistakes=0
        self:refreshCovers()
        self.transitionAt=nil
        self.pending,self.matchedAt,self.matchOrigin,self.prefixAt=nil,nil,nil,nil
        self.inputQueue,self.inputEvents,self.preparationKeys={},{},{}
        self.buyer,self.patronAccepted,self.patronAssignedAt,self.garrisonPeon=nil,nil,nil,nil
        self.promptReady=false
        self.promptShown=false
        self.armedAt=math.huge
        self.activePreparedAncient=nil
        if self.context then JTG.DisposeScope(self.context) end
        self.context=JTG.CreateScope('hotkey-prompt')
        local context=self.context
        JTG.ScopeAdd(session.scope,function() JTG.DisposeScope(context) end)
        local options,usable={},{}
        for _,entry in ipairs(self.pool) do
            local conflict=JTG.HotkeyPromptConflict(entry)
            if conflict then
                self.skippedConflicts=self.skippedConflicts or {}
                self.skippedConflicts[entry.id]=conflict
            else
                usable[#usable+1]=entry
                if (not (entry.raw=='root' or entry.uprooted) or self:ancientReady(entry.source)) and
                        (entry.raw~='Astd' or self:garrisonReady()) then
                    options[#options+1]=entry
                end
            end
        end
        if forcedPrompt then self.prompt=forcedPrompt
        else
            self.prompt=JTG.HotkeyChooseCommand(self,options)
            local pending=JTG.HotkeyChooseCommand(self,usable)
            if self.prompt and pending and self.tested[JTG.HotkeyCommandKey(self.prompt)] and
                not self.tested[JTG.HotkeyCommandKey(pending)] then self.prompt=nil end
            if not self.prompt then
                self.waitingPrompt=pending
                self.source=nil
                if self.waitingPrompt then self:refreshPrompt();return end
                self:finish();return
            end
        end
        local prompt=self.prompt
        if prompt.night then
            local previousTime=GetFloatGameState(GAME_STATE_TIME_OF_DAY)
            local previousScale=GetTimeOfDayScale()
            JTG.ScopeAdd(context,function()
                SetFloatGameState(GAME_STATE_TIME_OF_DAY,previousTime)
                SetTimeOfDayScale(previousScale)
            end)
            SetFloatGameState(GAME_STATE_TIME_OF_DAY,0);SetTimeOfDayScale(0)
        end
        if prompt.kind=='buy' or prompt.kind=='hire' or prompt.kind=='train' or
                prompt.kind=='research' or prompt.kind=='upgrade' or prompt.kind=='build' then
            SetPlayerState(Player(0),PLAYER_STATE_RESOURCE_GOLD,1000)
            SetPlayerState(Player(0),PLAYER_STATE_RESOURCE_LUMBER,1000)
        end
        local changedTech={}
        if prompt.heroRecruitment then
            -- The map can cap all heroes separately from each individual type.
            local heroLimit=GetPlayerTechMaxAllowed(Player(0),FourCC('HERO'))
            JTG.ScopeAdd(context,function() SetPlayerTechMaxAllowed(Player(0),FourCC('HERO'),heroLimit) end)
            SetPlayerTechMaxAllowed(Player(0),FourCC('HERO'),-1)
        end
        if prompt.kind=='train' or prompt.kind=='research' or prompt.kind=='build' or prompt.kind=='upgrade' or prompt.kind=='hire' then
            local raw=FourCC(prompt.raw)
            local limit=GetPlayerTechMaxAllowed(Player(0),raw)
            JTG.ScopeAdd(context,function() SetPlayerTechMaxAllowed(Player(0),raw,limit) end)
            SetPlayerTechMaxAllowed(Player(0),raw,prompt.kind=='research' and (prompt.researchLevel or 1) or -1)
        end
        local function research(raw,level)
            local id=FourCC(raw)
            if changedTech[raw]==nil then
                changedTech[raw]=GetPlayerTechCount(Player(0),id,true)
                local oldLimit=GetPlayerTechMaxAllowed(Player(0),id)
                JTG.ScopeAdd(context,function() SetPlayerTechMaxAllowed(Player(0),id,oldLimit) end)
            end
            SetPlayerTechMaxAllowed(Player(0),id,-1)
            local current=GetPlayerTechCount(Player(0),id,true)
            if current>level then BlzDecPlayerTechResearched(Player(0),id,current-level) end
            SetPlayerTechResearched(Player(0),id,level)
        end
        JTG.ScopeAdd(context,function()
            for raw,level in pairs(changedTech) do
                local id=FourCC(raw)
                local current=GetPlayerTechCount(Player(0),id,true)
                if current>level then BlzDecPlayerTechResearched(Player(0),id,current-level) end
                SetPlayerTechResearched(Player(0),id,level)
            end
        end)
        for raw,level in pairs(prompt.requiredResearch or {}) do research(raw,level) end
        if prompt.kind=='train' and prompt.raw=='ohun' then research('Robk',0) end
        if prompt.kind=='research' then research(prompt.raw,(prompt.researchLevel or 1)-1) end
        self.promptPrerequisites={}
        for raw,amount in pairs(prompt.requiredUnits or {}) do
            for index=1,amount do
                local unit=JTG.ScopeTrackUnit(context,self:createUnit(Player(0),FourCC(raw),
                    session.scene.centerX+index*450,self.spawnY+600,0))
                assert(unit,'Missing prerequisite: '..raw)
                SetUnitPathing(unit,false);SetUnitVertexColor(unit,255,255,255,255);SetUnitInvulnerable(unit,true)
                self.promptPrerequisites[#self.promptPrerequisites+1]=raw
            end
        end
        self.sourceOwner=(NEUTRAL_SHOPS[prompt.source] and (prompt.kind=='buy' or prompt.kind=='hire' or prompt.raw=='select'))
            and Player(PLAYER_NEUTRAL_PASSIVE) or Player(0)
        self.requiresUprooted=prompt.raw=='root' or prompt.uprooted==true
        self.preparationChecks={}
        if prompt.raw=='Astd' then
            local accepted
            self.source,accepted=self:takePreparedGarrison(context)
            self.preparationChecks[#self.preparationChecks+1]={kind='garrison-peon',accepted=accepted}
        elseif self.requiresUprooted then
            local accepted
            self.source,accepted=self:takePreparedAncient(prompt.source,context)
            self.preparationChecks[#self.preparationChecks+1]={kind='background-uproot',accepted=accepted}
        else
            self.source=JTG.ScopeTrackUnit(context,self:createUnit(self.sourceOwner,FourCC(prompt.source),
                session.scene.centerX,self.spawnY,0))
        end
        assert(self.source and GetUnitTypeId(self.source)~=0,'Hotkey context missing: '..prompt.source)
        SetUnitPathing(self.source,false)
        SetUnitInvulnerable(self.source,true)
        SetUnitVertexColor(self.source,255,255,255,255)
        SetUnitAcquireRange(self.source,0)
        if self.sourceOwner==Player(PLAYER_NEUTRAL_PASSIVE) then
            -- Native shops must be visible to the player to supply their
            -- command card. Reveal only their off-camera prompt context.
            JTG.ScopeRevealRect(context,Player(0),GetUnitX(self.source)-256,GetUnitY(self.source)-256,
                GetUnitX(self.source)+256,GetUnitY(self.source)+256)
        end
        if IsUnitType(self.source,UNIT_TYPE_HERO) then
            SetHeroLevel(self.source,prompt.kind=='learn' and 6 or 10,false)
            if prompt.kind~='learn' then
                -- Learn through the hero system, not UnitAddAbility: this also
                -- prepares every other command and unlocks the ultimate.
                for raw,levels in pairs(prompt.heroSkills or {}) do
                    for level=1,levels do SelectHeroSkill(self.source,FourCC(raw)) end
                end
            end
        end
        if prompt.ability and prompt.kind=='ability' then
            local active=prompt.activeAbility or prompt.ability
            if GetUnitAbilityLevel(self.source,FourCC(active))==0 then UnitAddAbility(self.source,FourCC(active)) end
            if not IsUnitType(self.source,UNIT_TYPE_HERO) then SetUnitAbilityLevel(self.source,FourCC(active),1) end
            BlzUnitDisableAbility(self.source,FourCC(active),false,false)
            UnitResetCooldown(self.source)
        end
        SetUnitState(self.source,UNIT_STATE_MANA,GetUnitState(self.source,UNIT_STATE_MAX_MANA))
        if prompt.kind=='buy' or prompt.kind=='hire' or prompt.raw=='select' then
            local buyer=JTG.ScopeTrackUnit(context,self:createUnit(Player(0),FourCC('Hpal'),
                session.scene.centerX+100,self.spawnY,0))
            SetUnitPathing(buyer,false); SetUnitInvulnerable(buyer,true)
            -- Native creation can push a nearby hero outside a shop footprint.
            -- Place after disabling pathing, using the shop's actual position.
            SetUnitX(buyer,GetUnitX(self.source)+100); SetUnitY(buyer,GetUnitY(self.source))
            UnitAddAbility(buyer,FourCC('AInv'))
            SetUnitVertexColor(buyer,255,255,255,255)
            self.buyer=buyer
            if prompt.kind=='buy' then
                AddItemToStock(self.source,FourCC(prompt.raw),1,1)
            elseif prompt.kind=='hire' then AddUnitToStock(self.source,FourCC(prompt.raw),1,1) end
            -- Prime the patron before selecting the shop, rather than waiting
            -- for its command card to open and then assigning it twice.
            self:assignPatron()
        end
        if prompt.raw=='uproot' then
            -- Tree starts rooted by default.
        end
        if prompt.autocastOff and prompt.autocastOff~='' then
            local accepted=IssueImmediateOrder(self.source,prompt.autocastOff)==true
            self.preparationChecks[#self.preparationChecks+1]={kind='autocast-off:'..prompt.autocastOff,accepted=accepted}
        end
        local function support(raw,x,y,owner)
            local unit=JTG.ScopeTrackUnit(context,self:createUnit(owner or Player(0),FourCC(raw),
                GetUnitX(self.source)+(x or 100),GetUnitY(self.source)+(y or 0),0))
            SetUnitPathing(unit,false);SetUnitAcquireRange(unit,0)
            return unit
        end
        local function check(kind,accepted)
            self.preparationChecks[#self.preparationChecks+1]={kind=kind,accepted=accepted==true}
        end
        local function corpse()
            local unit=JTG.ScopeTrackUnit(context,CreateCorpse(Player(0),FourCC('hfoo'),GetUnitX(self.source)+100,GetUnitY(self.source),0))
            self:concealUnit(unit);return unit
        end
        if prompt.raw=='Alam' then
            support('usap')
        elseif prompt.raw=='Aco3' then
            support('earc')
        elseif prompt.raw=='Ambt' or prompt.order=='heal' or prompt.order=='creepheal' then
            local ally=support('hfoo');SetUnitState(ally,UNIT_STATE_LIFE,100)
        elseif prompt.raw=='Aabs' then
            local ally=support('hmpr');SetUnitState(ally,UNIT_STATE_MANA,GetUnitState(ally,UNIT_STATE_MAX_MANA))
        elseif prompt.raw=='Adro' then
            local passenger=support('hfoo')
            check('load-passenger',IssueTargetOrder(self.source,'load',passenger))
        elseif prompt.raw=='Amed' then
            local target=corpse()
            local accepted=IssueTargetOrder(self.source,'loadcorpse',target)
            if not accepted then accepted=IssuePointOrder(self.source,'loadcorpse',GetUnitX(target),GetUnitY(target)) end
            check('store-corpse',accepted)
        elseif prompt.raw=='Amel' or prompt.raw=='AUcb' or prompt.raw=='Arai' then
            corpse()
        elseif prompt.raw=='gather' then
            local mine=support('ngol',250,0,Player(PLAYER_NEUTRAL_PASSIVE));SetResourceAmount(mine,10000)
        end
        local command=JTG.ScopeTrackTrigger(context,CreateTrigger())
        if prompt.kind=='research' or prompt.kind=='upgrade' then
            TriggerRegisterUpgradeCommandEvent(command,FourCC(prompt.raw))
            TriggerRegisterCommandEvent(command,FourCC('Aque'),prompt.raw)
            TriggerRegisterCommandEvent(command,0,prompt.raw)
        elseif prompt.kind=='train' then
            TriggerRegisterCommandEvent(command,FourCC('Aque'),UnitId2String(FourCC(prompt.raw)))
            TriggerRegisterCommandEvent(command,0,prompt.raw)
        elseif prompt.kind=='build' then
            TriggerRegisterCommandEvent(command,FourCC(prompt.ability),UnitId2String(FourCC(prompt.raw)))
        elseif prompt.kind=='learn' then
            TriggerRegisterCommandEvent(command,FourCC('AHer'),prompt.raw)
            TriggerRegisterCommandEvent(command,0,prompt.raw)
        elseif prompt.kind=='buy' or prompt.kind=='hire' then
            local ability=prompt.kind=='buy' and 'Asid' or 'Asud'
            TriggerRegisterCommandEvent(command,FourCC(ability),prompt.raw)
            if prompt.kind=='buy' then TriggerRegisterCommandEvent(command,FourCC('Apit'),prompt.raw) end
            TriggerRegisterCommandEvent(command,0,prompt.raw)
        else
            TriggerRegisterCommandEvent(command,prompt.ability and FourCC(prompt.activeAbility or prompt.ability) or 0,prompt.order)
            if prompt.ability then TriggerRegisterCommandEvent(command,0,prompt.order) end
        end
        TriggerAddAction(command,JTG.GuardSession(session,function() self:nativeMatched('command-button') end))
        if prompt.kind=='build' or prompt.kind=='learn' then
            local prefix=JTG.ScopeTrackTrigger(context,CreateTrigger())
            TriggerRegisterGameEvent(prefix,prompt.kind=='build' and EVENT_GAME_BUILD_SUBMENU or EVENT_GAME_SHOW_SKILL)
            TriggerRegisterCommandEvent(prefix,FourCC(prompt.kind=='learn' and 'AHer' or prompt.ability),prompt.buildOrder)
            TriggerRegisterCommandEvent(prefix,0,prompt.buildOrder)
            TriggerAddAction(prefix,JTG.GuardSession(session,function()
                if self:inputActive() then
                    self:nativePrefix()
                end
            end))
        end
        -- Do not register CONTROL_CLICK on native command frames. These
        -- engine-owned simple buttons must retain their original handlers.
        -- Observe command/gameplay events without changing native input.
        -- Native execution confirms non-targeted actions and purchases as well.
        local native=JTG.ScopeTrackTrigger(context,CreateTrigger())
        for _,event in ipairs({EVENT_PLAYER_UNIT_SPELL_CHANNEL,EVENT_PLAYER_UNIT_SPELL_CAST,EVENT_PLAYER_UNIT_SPELL_EFFECT,EVENT_PLAYER_UNIT_TRAIN_START,
            EVENT_PLAYER_UNIT_RESEARCH_START,EVENT_PLAYER_UNIT_UPGRADE_START,
            EVENT_PLAYER_UNIT_SELL_ITEM,EVENT_PLAYER_UNIT_SELL,EVENT_PLAYER_UNIT_ISSUED_ORDER,EVENT_PLAYER_HERO_SKILL}) do
            TriggerRegisterPlayerUnitEvent(native,self.sourceOwner,event,nil)
        end
        TriggerAddAction(native,JTG.GuardSession(session,function()
            local event=GetTriggerEventId()
            local same=GetTriggerUnit()==self.source
            if same and self.diagnostics then self.diagnostics.observe(self,event) end
            local correct=same and (
                (event==EVENT_PLAYER_UNIT_SPELL_CHANNEL or event==EVENT_PLAYER_UNIT_SPELL_CAST or event==EVENT_PLAYER_UNIT_SPELL_EFFECT) and prompt.kind=='ability' and GetSpellAbilityId()==FourCC(prompt.activeAbility or prompt.raw) or
                event==EVENT_PLAYER_HERO_SKILL and prompt.kind=='learn' and GetLearnedSkill()==FourCC(prompt.raw) or
                event==EVENT_PLAYER_UNIT_TRAIN_START and prompt.kind=='train' and GetTrainedUnitType()==FourCC(prompt.raw) or
                event==EVENT_PLAYER_UNIT_RESEARCH_START and prompt.kind=='research' and GetResearched()==FourCC(prompt.raw) or
                event==EVENT_PLAYER_UNIT_UPGRADE_START and prompt.kind=='upgrade' or
                event==EVENT_PLAYER_UNIT_ISSUED_ORDER and prompt.kind=='ability' and GetIssuedOrderId()==OrderId(prompt.order) or
                event==EVENT_PLAYER_UNIT_ISSUED_ORDER and (prompt.kind=='train' or prompt.kind=='research' or prompt.kind=='upgrade') and GetIssuedOrderId()==FourCC(prompt.raw) or
                event==EVENT_PLAYER_UNIT_ISSUED_ORDER and prompt.kind=='common' and GetIssuedOrderId()==OrderId(prompt.order))
            if event==EVENT_PLAYER_UNIT_SELL_ITEM and prompt.kind=='buy' then
                correct=GetSellingUnit()==self.source and GetItemTypeId(GetSoldItem())==FourCC(prompt.raw)
                if GetSellingUnit()==self.source then
                    local item=GetSoldItem()
                    JTG.ScopeAdd(context,function() RemoveItem(item) end)
                end
            elseif event==EVENT_PLAYER_UNIT_SELL and prompt.kind=='hire' then
                correct=GetSellingUnit()==self.source and GetUnitTypeId(GetSoldUnit())==FourCC(prompt.raw)
                if GetSellingUnit()==self.source then
                    local unit=JTG.ScopeTrackUnit(context,GetSoldUnit())
                end
            end
            if correct then self:nativeMatched('native-action') end
        end))
        -- Creating/selecting on one UI update can leave a stale command card
        -- even though IsUnitSelected returns true. Use the audited handoff.
        self.selectionAt=nil
        if not forcedPrompt then self.selectionAt=self.elapsed+SELECTION_SETTLE end
        if forcedPrompt then self:restoreSource()
        elseif GetLocalPlayer()==Player(0) then ForceUICancel();ClearSelection() end
        if GetLocalPlayer()==Player(0) then SetCameraPosition(self.cameraX,self.cameraY) end
        self.promptAt=self.elapsed+TICK
        self.armedAt=forcedPrompt and self.elapsed+TICK or math.huge
        self:refreshPrompt(); self:refreshStatus()
    end
    function self:beginPromptTransition()
        -- Cancel while the old selected source still exists. Disposing it
        -- first left Warcraft's command card and target cursor stale.
        if GetLocalPlayer()==Player(0) then ForceUICancel();ClearSelection() end
        self.transitionAt=self.elapsed+PROMPT_TRANSITION
        self.armedAt=math.huge
        self.advance=false;self.pending=nil
        self.inputQueue,self.inputEvents={},{}
        self:refreshPrompt()
    end
    function self:onKey(key)
        -- ForceUICancel can itself produce Escape notifications. Escape is
        -- menu/cursor control and is never a scored command in this trainer.
        if key==GetHandleId(OSKEY_ESCAPE) then return end
        if not self:inputActive() then return end
        self.inputQueue[#self.inputQueue+1]={key=key,at=self.elapsed,prompt=self.prompt}
        self.pending=self.inputQueue[1]
    end
    function self:resolveInput(force)
        local queue=self.inputQueue or {}
        -- Keep every key, including a fast submenu -> entry sequence. Native
        -- UI events may arrive before or after the keyboard callback.
        -- Give the final command priority: a mouse-opened submenu must not
        -- consume the sole keyboard input as its opening key.
        for _,eventKind in ipairs({'correct','prefix'}) do
            for _,event in ipairs(self.inputEvents or {}) do
                if not event.used and event.kind==eventKind then
                    local candidate
                    for index,input in ipairs(queue) do
                        if not input.kind and math.abs(input.at-event.at)<=CONFIRMATION_WINDOW then
                            candidate=index
                            if event.kind=='prefix' then break end
                        end
                    end
                    if candidate then
                        queue[candidate].kind=event.kind
                        queue[candidate].origin=event.origin
                        event.used=true
                    end
                end
            end
        end
        while queue[1] and (force or queue[1].kind or self.preparationKeys[queue[1].key] or self.elapsed-queue[1].at>=CONFIRMATION_WINDOW) do
            local input=table.remove(queue,1)
            local correct=input.kind=='correct'
            local response=input.at-self.promptAt
            if input.kind=='prefix' then self.preparationKeys[input.key]=true end
            local preparation=input.kind=='prefix' or (not correct and self.preparationKeys[input.key])
            if not preparation then
                self.logs[#self.logs+1]={prompt=self.prompt.id,key=input.key,correct=correct,
                    response=response,origin=input.origin or 'no-command-event'}
                if correct then
                    self.promptAnswered=true
                    self.promptMistakes=0;self:refreshCovers()
                    if not self.forcedPrompt and not self:diagnosticsActive() and not self.promptWrong then
                        self.failed[JTG.HotkeyCommandKey(self.prompt)]=nil
                    end
                    self.correct=self.correct+1; self.totalResponse=self.totalResponse+response
                    self.score=self.score+JTG.Training.ResponseAward(response)
                    if not self:diagnosticsActive() and JTG.UI.PlayFeedbackSound then JTG.UI.PlayFeedbackSound("correct") end
                    self.advance=true
                    break
                else
                    self.promptWrong=true
                    self.promptMistakes=(self.promptMistakes or 0)+1
                    self:refreshCovers()
                    if not self.forcedPrompt and not self:diagnosticsActive() then
                        self.failed[JTG.HotkeyCommandKey(self.prompt)]=self.prompt
                    end
                    self.incorrect=self.incorrect+1; self.score=self.score-10
                    if not self:diagnosticsActive() and JTG.UI.PlayFeedbackSound then JTG.UI.PlayFeedbackSound("incorrect") end
                    -- Re-selecting cancels Build and Hero Abilities. Leave
                    -- those menus untouched, even after an incorrect entry.
                    if self.prompt.kind~='build' and self.prompt.kind~='learn' then self:restoreSource() end
                end
            end
        end
        self.pending=queue[1]
        self.matchedAt=nil
        self:refreshStatus()
    end
    function self:finish()
        if self.finished then return end
        self.finished=true
        if self.promptShown and not self.promptAnswered and not self.forcedPrompt and not self:diagnosticsActive() then
            self.failed[JTG.HotkeyCommandKey(self.prompt)]=self.prompt
        end
        self.transitionAt=nil
        self.pending=nil
        if GetLocalPlayer()==Player(0) then ForceUICancel(); ClearSelection() end
        self:clearPreparedAncients()
        self:clearPreparedGarrison()
        if self.context then JTG.DisposeScope(self.context); self.context=nil end
        local previous=JTG.HotkeyHighScores[self.race]
        self.highScore=math.max(previous or self.score,self.score)
        JTG.HotkeyHighScores[self.race]=self.highScore
        self:refreshPrompt(); self:refreshStatus()
        self:refreshCovers()
        JTG.UI.HideToolbar()
        for _,tooltip in ipairs(self.customTooltips or {}) do BlzFrameSetVisible(tooltip,false) end
        self:showResult()
    end
    function self:showResult()
        local remaining,missed=self:remainingCommands()
        JTG.UI.ShowResultCard(self.resultCard,{title='Stage '..self.stage..' complete',tone='neutral',visible=self.presentationVisible,
            details=string.format('High score: %d\nCorrect: %d   Incorrect: %d\nAverage response: %.2fs\nUntested: %d   To practice: %d',
                self.highScore,self.correct,self.incorrect,self.correct>0 and self.totalResponse/self.correct or 0,remaining,missed),
            actions={next={visible=remaining+missed>0,enabled=true,label='Continue'},
                retry={visible=true,enabled=true,label='Start Over'},menu={visible=true,enabled=true}}})
        if self.resultScore then
            local color,scale=JTG.Training.ScoreStyle(self.score)
            BlzFrameSetText(self.resultScore,color..'Score: '..self.score..'|r')
            BlzFrameSetSize(self.resultScore,0.36/scale,0.055/scale)
            BlzFrameSetScale(self.resultScore,scale)
        end
    end
    function self:remainingCommands()
        local fresh,missed,seen=0,0,{}
        for _,entry in ipairs(self.pool) do
            local key=JTG.HotkeyCommandKey(entry)
            if not seen[key] and not JTG.HotkeyPromptConflict(entry) then
                seen[key]=true
                if not self.tested[key] then fresh=fresh+1 end
                if self.failed[key] then missed=missed+1 end
            end
        end
        return fresh,missed
    end
    function self:nextStage()
        if not self.finished then return false end
        JTG.Training.BeginAttempt(session)
        self.stage=self.stage+1;self.stageStart=self.elapsed
        self.stageSeen={};self.score=0;self.correct=0;self.incorrect=0;self.totalResponse=0
        self.finished=false;self.advance=false
        self:clearPreparedAncients();self:clearPreparedGarrison()
        for _,entry in ipairs(self.pool) do
            if entry.raw=='root' or entry.uprooted then self:prepareAncient(entry.source) end
            if entry.raw=='Astd' then self:prepareGarrison() end
        end
        JTG.UI.HideResultCard(self.resultCard)
        JTG.UI.ShowToolbar(session.descriptor.capabilities)
        self:nextPrompt()
        return true
    end
    self.resultActions={next=function() return self:nextStage() end}
    function self:setup()
        JTG.BorrowCamera(session.scope,Player(0))
        local world=GetWorldBounds()
        self.cameraX=(GetRectMinX(world)+GetRectMaxX(world))/2
        self.cameraY=(GetRectMinY(world)+GetRectMaxY(world))/2
        self.spawnY=GetRectMaxY(world)-1800
        RemoveRect(world)
        if GetLocalPlayer()==Player(0) then SetCameraPosition(self.cameraX,self.cameraY) end
        local fogEnabled,maskEnabled=IsFogEnabled(),IsFogMaskEnabled()
        JTG.ScopeBorrow(session.scope,function() FogEnable(fogEnabled);FogMaskEnable(maskEnabled) end)
        FogEnable(true);FogMaskEnable(true)
        JTG.ResetWorldFog(Player(0))
        assert(JTG.HotkeyPools[self.race],'Missing hotkey practice list: '..self.race)
        self.pool={}
        for _,entry in ipairs(JTG.HotkeyPools[self.race]) do self.pool[#self.pool+1]=entry end
        for _,entry in ipairs(self.pool) do
            if self.race=='nightelf' and (entry.raw=='root' or entry.uprooted) then self:prepareAncient(entry.source) end
            if entry.raw=='Astd' then self:prepareGarrison() end
        end
        for _,state in ipairs({PLAYER_STATE_RESOURCE_GOLD,PLAYER_STATE_RESOURCE_LUMBER,
            PLAYER_STATE_RESOURCE_FOOD_CAP,PLAYER_STATE_FOOD_CAP_CEILING}) do
            local value=GetPlayerState(Player(0),state)
            JTG.ScopeBorrow(session.scope,function() SetPlayerState(Player(0),state,value) end)
            SetPlayerState(Player(0),state,10000)
        end
        local keys=JTG.ScopeTrackTrigger(session.scope,CreateTrigger())
        local codes={OSKEY_ESCAPE}
        for id=0x30,0x5A do if id<=0x39 or id>=0x41 then codes[#codes+1]=ConvertOsKeyType(id) end end
        for id=0x60,0x6F do codes[#codes+1]=ConvertOsKeyType(id) end
        for id=0xBA,0xDE do codes[#codes+1]=ConvertOsKeyType(id) end
        for _,key in ipairs(codes) do
            for modifiers=0,15 do
                BlzTriggerRegisterPlayerKeyEvent(keys,Player(0),key,modifiers,true)
                BlzTriggerRegisterPlayerKeyEvent(keys,Player(0),key,modifiers,false)
            end
        end
        TriggerAddAction(keys,JTG.GuardSession(session,function()
            if GetTriggerPlayer()~=Player(0) then return end
            local key=GetHandleId(BlzGetTriggerPlayerKey())
            if not BlzGetTriggerPlayerIsKeyDown() then self.held[key]=nil;return end
            if self.held[key] then return end
            self.held[key]=true
            self:onKey(key)
        end))
        local summons=JTG.ScopeTrackTrigger(session.scope,CreateTrigger())
        TriggerRegisterPlayerUnitEvent(summons,Player(0),EVENT_PLAYER_UNIT_SUMMONED,nil)
        TriggerAddAction(summons,JTG.GuardSession(session,function()
            if GetSummoningUnit()==self.source and self.context then
                local unit=JTG.ScopeTrackUnit(self.context,GetSummonedUnit())
                self:concealUnit(unit)
                SetUnitVertexColor(unit,255,255,255,255)
            end
        end))
        local trained=JTG.ScopeTrackTrigger(session.scope,CreateTrigger())
        TriggerRegisterPlayerUnitEvent(trained,Player(0),EVENT_PLAYER_UNIT_TRAIN_FINISH,nil)
        TriggerAddAction(trained,JTG.GuardSession(session,function()
            if GetTriggerUnit()==self.source and self.context then
                local unit=JTG.ScopeTrackUnit(self.context,GetTrainedUnit())
                self:concealUnit(unit)
            end
        end))
        self:createPresentation()
    end
    -- The shared controller passes its session as the first argument.
    -- A forced prompt is a separate diagnostic-only argument.
    function self:start(_session,forcedPrompt)
        self:nextPrompt(forcedPrompt)
        JTG.StartScopedTimer(session,session.scope,TICK,true,function()
            if self.paused or self.finished then return end
            self.elapsed=self.elapsed+TICK
            self:refreshCovers()
            if self.presentationVisible and not self:diagnosticsActive() and GetLocalPlayer()==Player(0) then
                SetCameraPosition(self.cameraX,self.cameraY)
            end
            self:updatePromptReadiness()
            if self:runDiagnostics("tick") then return end
            if self.waitingPrompt then
                if self.elapsed-self.stageStart>=DURATION then self:finish();return end
                local prompt=self.waitingPrompt
                if (not (prompt.raw=='root' or prompt.uprooted) or self:ancientReady(prompt.source)) and
                    (prompt.raw~='Astd' or self:garrisonReady()) then self:nextPrompt() end
                self:refreshStatus();return
            end
            if self.transitionAt then
                if self.elapsed-self.stageStart>=DURATION then self:finish();return end
                if self.elapsed>=self.transitionAt then self:nextPrompt() end
                self:refreshStatus();return
            end
            if self.presentationVisible and not self.selectionAt and not self.advance and self.source and not IsUnitSelected(self.source,Player(0)) then
                self:restoreSource()
            end
            if self.elapsed-self.stageStart>=DURATION then self:resolveInput(true); self:finish(); return end
            self:resolveInput()
            if self.advance then self:beginPromptTransition() end
            self:refreshStatus()
        end)
    end
    function self:setPaused(value) self.paused=value end
    function self:captureResetState() return {race=self.race} end
    JTG.Training.InstallPresentation(self,session,{
        roots={'panel','lowerCover','status','scoreFrame','resultScore'},lists={'customTooltips'},
        references={'panel','lowerCover','status','resultCard','scoreFrame','resultScore',
            'heading','sourceButton','commandButton','buildButton','sourceIcon','commandIcon','buildIcon',
            'customTooltips','sourceTooltipUpdate','commandTooltipUpdate','buildTooltipUpdate'},
        refresh={'refreshCovers','refreshPrompt'},result='showResult',
        beforeHide=function(activity)
            activity.pending,activity.matchedAt=nil,nil
            activity.inputQueue,activity.inputEvents={},{}
        end,
        -- Native selection recovery is an explicit Hotkey-specific operation.
        resume=function(activity) activity:restoreSource() end,
    })
    function self:cleanup()
        self.finished=true
        self.transitionAt=nil
        if GetLocalPlayer()==Player(0) then ForceUICancel();ClearSelection() end
        self:clearPreparedAncients()
        self:clearPreparedGarrison()
        for _,tooltip in ipairs(self.customTooltips or {}) do BlzFrameSetVisible(tooltip,false) end
        if self.context then JTG.DisposeScope(self.context);self.context=nil end
    end
    return self
end
