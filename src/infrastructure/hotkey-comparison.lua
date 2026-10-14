-- A small dev bench. Observe events independently BEFORE trainer filtering.
-- Legacy reference reproduces action matching and Shockwave's W/Q fallback;
-- it shares the current context, not the legacy map's global helper setup.
local CASES={'common.hfoo.common.stop','orc.Otch.ability.AOws',
    'orc.Otch.ability.AOsh','orc.obar.train.ogru','orc.ofor.research.Rome',
    'orc.ovln.buy.hslv','orc.opeo.build.oalt','orc.Otch.learn.AOre'}
local create=JTG.CreateHotkeyTrainingActivity
function JTG.CreateHotkeyTrainingActivity(session)
    local self=create(session)
    local setup,onKey,cleanup=self.setup,self.onKey,self.cleanup
    local hide,restore=self.hidePresentationForMenu,self.restorePresentation
    function self:comparisonWrite()
        local c=self.comparison
        if not c or GetLocalPlayer()~=Player(0) then return end
        if c.full then return self:fullAuditWrite() end
        PreloadGenClear(); PreloadGenStart()
        Preload('//JTG_COMPARE|format|1')
        Preload('//JTG_COMPARE|binding-hash|'..(JTG.HotkeyComparisonBindingHash or 'none'))
        Preload('//JTG_COMPARE|mode|'..(c.auto and 'forced-ui-key' or 'physical-key')..'|state|'..c.state)
        if c.entry then Preload('//JTG_COMPARE|snapshot|'..c.entry.id..'|native|'..tostring(c.native)..
            '|legacy|'..tostring(c.legacy)..'|trainer|'..tostring(c.trainer)) end
        for _,line in ipairs(c.lines) do Preload('//JTG_COMPARE|'..line) end
        PreloadGenEnd(c.opacityTest and 'JTG-Hotkey-Visibility.pld' or 'JTG-Hotkey-Comparison.pld')
    end
    function self:comparisonStatus()
        local c=self.comparison
        if not c then return end
        if c.full then return self:fullAuditStatus() end
        local legacy=c.entry and (c.entry.kind=='common' or c.entry.kind=='build' or c.entry.kind=='learn')
            and 'not covered' or tostring(c.legacy)
        local appearance=c.opacityTest and ('button alpha '..c.opacity) or (c.hidden and 'hidden card' or 'visible card')
        BlzFrameSetText(self.status,'Comparison '..c.index..'/'..(c.opacityTest and 4 or 8)..' - '..c.state..' - '..appearance..
            '\nKeys: '..#c.keys..'  Native action: '..tostring(c.native)..
            '\nLegacy reference: '..legacy..'  Trainer: '..tostring(c.trainer))
        BlzFrameSetSize(self.status,0.7,0.10)
        BlzFrameSetVisible(self.status,self.presentationVisible)
    end
    function self:comparisonRecord(kind,detail)
        local c=self.comparison
        if not c then return end
        c.lines[#c.lines+1]=kind..'|'..detail..'|time|'..string.format('%.3f',self.elapsed)
        c.dirty=true
    end
    function self:comparisonPrompt(reuseSource)
        local c=self.comparison
        c.entry=c.pool[c.opacityTest and 1 or c.index];c.keys={};c.native=false;c.nativeAt=nil;c.legacy=false;c.trainer=false
        c.button=false
        c.preInputCast=false
        c.sent=0;c.forceAt=nil;c.legacyActionAt=nil;c.dirty=false;c.state='testing'
        c.correctEvents={}
        self.advance=false
        if reuseSource then
            self.pending=nil;self.inputQueue={};self.inputEvents={};self.preparationKeys={}
            self.promptAt=self.elapsed;self.armedAt=self.elapsed+0.2
        else self:nextPrompt(c.entry) end
        if c.full and c.full.targeted then
            -- Independent button-only observer: no target click or execution
            -- event is required, and trainer inputActive() is not consulted.
            local trigger=JTG.ScopeTrackTrigger(self.context,CreateTrigger())
            local entry=c.entry
            TriggerRegisterCommandEvent(trigger,entry.ability and FourCC(entry.activeAbility or entry.ability) or 0,
                entry.order or entry.raw)
            TriggerRegisterCommandEvent(trigger,0,entry.order or entry.raw)
            TriggerAddAction(trigger,JTG.GuardSession(session,function()
                self:comparisonRecord('button-event',entry.id..'|after-input|'..tostring(c.forceAt and self.elapsed>=c.forceAt)..
                    '|selected|'..tostring(IsUnitSelected(self.source,Player(0))))
                if c.forceAt and self.elapsed>=c.forceAt then c.button=true end
            end))
        end
        -- The comparison bench shows its real objects for inspection.
        SetUnitVertexColor(self.source,255,255,255,255)
        if self.buyer then SetUnitVertexColor(self.buyer,255,255,255,255) end
        c.started=self.elapsed;c.traceStart=#(self.eventTrace or {})+1
        c.lines[#c.lines+1]='begin|'..c.entry.id..'|card|'..(c.hidden and 'hidden' or 'visible')
        if c.opacityTest then self:comparisonRecord('opacity-stage',tostring(c.opacity)..'|same-source|'..tostring(reuseSource==true)) end
        self:comparisonRecord('selected',tostring(IsUnitSelected(self.source,Player(0))))
        for _,raw in ipairs(self.promptPrerequisites or {}) do
            self:comparisonRecord('prerequisite',raw..'|actual|'..GetPlayerTechCount(Player(0),FourCC(raw),true))
        end
        for raw,level in pairs(c.entry.requiredResearch or {}) do
            self:comparisonRecord('research',raw..'|required|'..level..'|actual|'..GetPlayerTechCount(Player(0),FourCC(raw),true))
        end
        if c.entry.ability then
            self:comparisonRecord('ability',c.entry.ability..'|level|'..GetUnitAbilityLevel(self.source,FourCC(c.entry.ability)))
        end
        if self.buyer then self:comparisonRecord('patron-order',tostring(self.patronAccepted)) end
        -- Visible caster permits a genuine directional Shockwave cast.
        SetCameraPosition(GetUnitX(self.source),GetUnitY(self.source))
        self:comparisonWrite();self:refreshStatus()
    end
    function self:comparisonNext()
        local c=self.comparison
        if not c or c.state~='testing' then return end
        if c.full then return self:fullAuditNext() end
        self:comparisonRecord('result','native|'..tostring(c.native)..'|legacy|'..tostring(c.legacy)..'|trainer|'..tostring(c.trainer))
        if c.opacityTest then
            local successful=c.native and c.nativeAt and c.forceAt and c.nativeAt>=c.forceAt
            if (c.index==1 or c.index==4) and not successful then
                c.state='visible-control-inconclusive';self:comparisonWrite();self:refreshStatus();return
            end
            c.index=c.index+1
            if c.index>4 then
                c.index=4;c.state='complete';self:comparisonWrite();self:refreshStatus()
                DisplayTimedTextToPlayer(Player(0),0,0,30,'Visibility comparison complete. Saved to CustomMapData\\JTG-Hotkey-Visibility.pld.')
                return
            end
            c.opacity=({255,0,1,255})[c.index]
            self:comparisonPrompt(true);return
        end
        if c.auto and c.index==1 and not (c.native and c.nativeAt and c.forceAt and c.nativeAt>=c.forceAt) then
            c.state='control-inconclusive';self:comparisonWrite();self:refreshStatus()
            DisplayTimedTextToPlayer(Player(0),0,0,30,'Forced-key control did not emit Stop. Automation stopped; this says nothing about other commands.')
            return
        end
        c.index=c.index+1
        if c.index>8 then
            if c.auto and not c.hidden then c.hidden=true;c.index=1
            else
                c.index=8;c.state='complete';self:comparisonWrite();self:refreshStatus()
                DisplayTimedTextToPlayer(Player(0),0,0,30,'Comparison saved to CustomMapData\\JTG-Hotkey-Comparison.pld. You can end the bench now.')
                return
            end
        end
        self:comparisonPrompt()
    end
    function self:onKey(key)
        local c=self.comparison
        if c and c.state=='testing' then
            c.keys[#c.keys+1]={key=key,at=self.elapsed}
            self:comparisonRecord('key',tostring(key)..'|input-active|'..tostring(self:inputActive()))
            -- EXACT legacy targeted Shockwave fallback, labelled as such.
            if c.entry.id=='orc.Otch.ability.AOsh' and (key==81 or key==87) then c.legacy=true end
        end
        return onKey(self,key)
    end
    function self:comparisonTick()
        local c=self.comparison
        BlzFrameSetVisible(self.lowerCover,false)
        if c.opacityTest and self.presentationVisible then
            -- Change only command opacity. Keep the tooltip, same selection,
            -- same unit and the rest of the UI unchanged throughout the test.
            for index=1,12 do BlzFrameSetAlpha(self.nativeCard[index].frame,c.opacity) end
        else self:setNativeCardHidden(self.presentationVisible and c.hidden) end
        if not self.presentationVisible or c.state~='testing' then return end
        if c.full and c.full.prepareAt then
            if self.elapsed>=c.full.prepareAt then
                c.full.prepareAt=nil
                self:fullAuditCreateContext()
            end
            return
        end
        if c.full and c.full.uiStage<2 then
            if not self:sourcePreparationReady() then
                if self.elapsed-c.started>=10 then
                    self:comparisonRecord('setup-error','Ancient did not finish uprooting')
                    self:comparisonNext()
                end
                return
            end
            if c.full.uiStage==0 then
                if self.requiresUprooted then
                    self:comparisonRecord('ancient-ready','building|'..
                        tostring(BlzGetUnitBooleanField(self.source,UNIT_BF_IS_A_BUILDING))..
                        '|last-order|'..tostring(GetUnitCurrentOrder(self.source)))
                end
                if GetLocalPlayer()==Player(0) then ForceUICancel();ClearSelection() end
                self.submenuOpen=false;self.skillMenuOpen=false
                self:comparisonRecord('ui-reset','cancel-and-clear')
                c.full.uiStage=1
            elseif self.elapsed-c.started>=0.5 then
                if GetLocalPlayer()==Player(0) then
                    ClearSelection();SelectUnit(self.source,true)
                    if self.buyer then self.patronAccepted=IssueNeutralTargetOrderById(Player(0),self.source,852566,self.buyer) end
                end
                self:comparisonRecord('ui-reset','select-after-settle|selected|'..tostring(IsUnitSelected(self.source,Player(0))))
                c.full.uiStage=2;c.started=self.elapsed;self.armedAt=self.elapsed+0.2
            end
            return
        end
        if c.legacyActionAt then
            for _,key in ipairs(c.keys) do if math.abs(key.at-c.legacyActionAt)<=0.5 then c.legacy=true end end
        end
        -- Run current grading unchanged, but suppress its prompt advance.
        local before=self.correct
        local restoreSource=self.restoreSource
        if c.opacityTest then self.restoreSource=function() end end
        if not c.full then self:resolveInput() end
        self.restoreSource=restoreSource
        if self.correct>before then c.trainer=true end
        self.advance=false
        for index=c.traceStart,#(self.eventTrace or {}) do
            local event=self.eventTrace[index]
            if c.full and event.kind=='correct' and c.forceAt and event.at>=c.forceAt then
                c.correctEvents[#c.correctEvents+1]=event.at
            end
            self:comparisonRecord('trainer-event',event.kind..'|'..event.origin..'|at|'..event.at)
        end
        c.traceStart=#(self.eventTrace or {})+1
        -- Native action can arrive before its physical-key notification.
        -- Retain both streams throughout the trial instead of consuming the
        -- correct event before the later key has had a chance to correlate.
        for _,at in ipairs(c.correctEvents or {}) do
            for _,key in ipairs(c.keys) do
                if c.forceAt and key.at>=c.forceAt and math.abs(key.at-at)<=0.5 then c.trainer=true end
            end
        end
        if c.dirty then self:comparisonWrite();c.dirty=false end
        if c.auto then
            local bindings=c.full and JTG.HotkeyFullAuditBindings or JTG.HotkeyComparisonBindings
            local keys=(bindings or {})[c.entry.id] or {}
            if #keys==0 then
                self:comparisonRecord('unsupported-binding',c.entry.id);self:comparisonNext();return
            end
            if c.full and #keys>1 and c.sent==1 and not self.submenuOpen then
                -- One prefix dispatch only. Never send the entry key while
                -- Build/Hero Abilities has not emitted its opening event.
                if c.forceAt and self.elapsed-c.forceAt>=1.5 then
                    c.full.submenuMissing=true
                    self:comparisonRecord('submenu-not-open',c.entry.id)
                    self:comparisonNext()
                end
                self:refreshStatus();return
            end
            if c.sent<#keys and self.elapsed-c.started>=1+(c.sent*0.8) then
                if c.full and c.full.selectionAudit then
                    self:comparisonRecord('selection-at-dispatch',tostring(IsUnitSelected(self.source,Player(0))))
                    for slot=0,11 do
                        local frame=self.nativeCard[slot+1].frame
                        self:comparisonRecord('card-state',slot..'|alpha|'..BlzFrameGetAlpha(frame)..
                            '|visible|'..tostring(BlzFrameIsVisible(frame))..'|enabled|'..tostring(BlzFrameGetEnable(frame)))
                    end
                end
                c.sent=c.sent+1;c.forceAt=self.elapsed
                self:comparisonRecord('force-ui-key',keys[c.sent])
                if c.opacityTest then
                    self:comparisonRecord('selected-at-dispatch',tostring(IsUnitSelected(self.source,Player(0))))
                    for slot=0,11 do self:comparisonRecord('actual-alpha',slot..'|'..BlzFrameGetAlpha(self.nativeCard[slot+1].frame)) end
                end
                -- ForceUIKey may only generate key-down, so no held-state reuse.
                self.held={}
                if GetLocalPlayer()==Player(0) then ForceUIKey(keys[c.sent]) end
            elseif c.forceAt and self.elapsed-c.forceAt>=2 then self:comparisonNext() end
        end
        self:refreshStatus()
    end
    function self:comparisonBegin(automated,opacityTest)
        if self.finished or self.paused then return end
        if self.comparison then self:comparisonEnd() end
        self.audit=nil
        local byId={};for _,entry in ipairs(JTG.HotkeyCatalog) do byId[entry.id]=entry end
        local pool={};for _,id in ipairs(CASES) do assert(byId[id],id);pool[#pool+1]=byId[id] end
        local scope=JTG.CreateScope('hotkey-comparison')
        JTG.ScopeAdd(session.scope,function() JTG.DisposeScope(scope) end)
        local oldFog,oldMask=IsFogEnabled(),IsFogMaskEnabled()
        JTG.ScopeBorrow(scope,function() FogEnable(oldFog);FogMaskEnable(oldMask) end)
        FogEnable(false);FogMaskEnable(false)
        self.comparison={pool=pool,index=1,auto=automated,hidden=false,lines={},scope=scope,state='testing',
            opacityTest=opacityTest,opacity=255}
        local c=self.comparison
        -- Independent, persistent observer: does not use inputActive(),
        -- nativeMatched(), or the trainer's command-event registration table.
        local observer=JTG.ScopeTrackTrigger(scope,CreateTrigger())
        for _,event in ipairs({EVENT_PLAYER_UNIT_ISSUED_ORDER,EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER,
            EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER,EVENT_PLAYER_UNIT_SPELL_CHANNEL,
            EVENT_PLAYER_UNIT_TRAIN_START,EVENT_PLAYER_UNIT_RESEARCH_START,
            EVENT_PLAYER_UNIT_UPGRADE_START,EVENT_PLAYER_UNIT_SELL_ITEM,EVENT_PLAYER_UNIT_SELL,EVENT_PLAYER_HERO_SKILL,
            EVENT_PLAYER_UNIT_CONSTRUCT_START}) do
            TriggerRegisterPlayerUnitEvent(observer,Player(0),event,nil)
            TriggerRegisterPlayerUnitEvent(observer,Player(PLAYER_NEUTRAL_PASSIVE),event,nil)
        end
        TriggerAddAction(observer,JTG.GuardSession(session,function()
            if self.comparison~=c or not c.entry then return end
            local event,actor,entry=GetTriggerEventId(),GetTriggerUnit(),c.entry
            local raw,detail,correct,legacy=0,tostring(event),false,false
            if event==EVENT_PLAYER_UNIT_ISSUED_ORDER or event==EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER or event==EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER then
                raw=GetIssuedOrderId();detail='order:'..raw
                correct=actor==self.source and ((entry.order and raw==OrderId(entry.order)) or
                    (not entry.order and raw==FourCC(entry.raw)))
            elseif event==EVENT_PLAYER_UNIT_SPELL_CHANNEL then
                raw=GetSpellAbilityId();detail='spell:'..UnitId2String(raw)
                correct=actor==self.source and entry.kind=='ability' and raw==FourCC(entry.activeAbility or entry.raw);legacy=correct
            elseif event==EVENT_PLAYER_UNIT_TRAIN_START then
                raw=GetTrainedUnitType();detail='train:'..UnitId2String(raw)
                correct=actor==self.source and entry.kind=='train' and raw==FourCC(entry.raw);legacy=correct
            elseif event==EVENT_PLAYER_UNIT_RESEARCH_START then
                raw=GetResearched();detail='research:'..UnitId2String(raw)
                correct=actor==self.source and entry.kind=='research' and raw==FourCC(entry.raw);legacy=correct
            elseif event==EVENT_PLAYER_UNIT_SELL_ITEM then
                actor=GetSellingUnit();raw=GetItemTypeId(GetSoldItem());detail='item:'..UnitId2String(raw)
                correct=actor==self.source and entry.kind=='buy' and raw==FourCC(entry.raw);legacy=correct
            elseif event==EVENT_PLAYER_UNIT_SELL then
                actor=GetSellingUnit();raw=GetUnitTypeId(GetSoldUnit());detail='hire:'..UnitId2String(raw)
                correct=actor==self.source and entry.kind=='hire' and raw==FourCC(entry.raw)
            elseif event==EVENT_PLAYER_HERO_SKILL then
                raw=GetLearnedSkill();detail='learn:'..UnitId2String(raw)
                correct=actor==self.source and entry.kind=='learn' and raw==FourCC(entry.raw)
            elseif event==EVENT_PLAYER_UNIT_CONSTRUCT_START then
                raw=GetUnitTypeId(GetConstructingStructure());detail='construct:'..UnitId2String(raw)
                correct=entry.kind=='build' and raw==FourCC(entry.raw)
            end
            -- Log even mismatches and events during the trainer's arming period.
            self:comparisonRecord('raw-event',detail..'|source|'..tostring(actor==self.source)..'|expected|'..tostring(correct))
            if correct and (not c.auto or c.forceAt and self.elapsed>=c.forceAt) then
                c.native=true;c.nativeAt=self.elapsed
            elseif correct then
                self:comparisonRecord('pre-input-action',detail)
                if event==EVENT_PLAYER_UNIT_SPELL_CHANNEL then c.preInputCast=true end
            end
            if legacy then c.legacyActionAt=self.elapsed end
        end))
        c.frames={}
        local root=BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0)
        for index,item in ipairs({{'Next',function() self:comparisonNext() end},
            {'Retry',function() self:comparisonPrompt() end},
            {'Card',function() if not c.opacityTest then c.hidden=not c.hidden;self:comparisonRecord('card-toggle',tostring(c.hidden)) end end},
            {'Save',function() self:comparisonWrite() end},
            {'End',function() self:comparisonEnd() end}}) do
            local button=JTG.ScopeTrackFrame(scope,BlzCreateFrameByType('GLUETEXTBUTTON','JTGCompare'..index,root,'ScriptDialogButton',0))
            BlzFrameSetSize(button,0.075,0.035);BlzFrameSetAbsPoint(button,FRAMEPOINT_CENTER,0.22+(index-1)*0.09,0.16)
            BlzFrameSetText(button,item[1]);c.frames[#c.frames+1]=button
            local trigger=JTG.ScopeTrackTrigger(scope,CreateTrigger())
            BlzTriggerRegisterFrameEvent(trigger,button,FRAMEEVENT_CONTROL_CLICK)
            local action=item[2]
            TriggerAddAction(trigger,JTG.GuardSession(session,function()
                BlzFrameSetEnable(button,false);BlzFrameSetEnable(button,true);action()
            end))
        end
        self:comparisonPrompt()
        DisplayTimedTextToPlayer(Player(0),0,0,30,opacityTest and 'Stop visibility test: close chat and wait. Same Footman, alpha 255, 0, 1, then 255. No other commands or selection changes.' or automated and 'Automatic comparison: close chat and wait. Visible-card and hidden-card passes run automatically.' or
            'Comparison: use your hotkey, then Next. Shockwave: click open ground after the key. Altar: open Build, choose Altar, then place it on empty ground. Reincarnation: open Hero Abilities, then choose it. Save at any time.')
    end
    function self:comparisonEnd()
        if not self.comparison then return end
        self.comparison.state='ended';self:comparisonWrite();JTG.DisposeScope(self.comparison.scope)
        self.comparison=nil;self.elapsed=0;self.advance=false
        BlzFrameSetVisible(self.lowerCover,false)
        BlzFrameSetSize(self.status,0.44,0.06);self:nextPrompt();self:refreshStatus()
    end
    function self:setup()
        setup(self)
        for _,entry in ipairs({{'-hotkey-compare',false},{'-hotkey-compare-auto',true},{'-hotkey-visibility',true,true}}) do
            local trigger=JTG.ScopeTrackTrigger(session.scope,CreateTrigger())
            TriggerRegisterPlayerChatEvent(trigger,Player(0),entry[1],true)
            local automated=entry[2]
            local opacityTest=entry[3]
            TriggerAddAction(trigger,JTG.GuardSession(session,function() self:comparisonBegin(automated,opacityTest) end))
        end
    end
    function self:cleanup()
        if self.comparison then self:comparisonWrite() end
        return cleanup(self)
    end
    function self:hidePresentationForMenu()
        if self.comparison then for _,frame in ipairs(self.comparison.frames) do BlzFrameSetVisible(frame,false) end end
        return hide(self)
    end
    function self:restorePresentation()
        restore(self)
        if self.comparison then
            BlzFrameSetVisible(self.lowerCover,false)
            for _,frame in ipairs(self.comparison.frames) do BlzFrameSetVisible(frame,not self.comparison.full) end
            self:setNativeCardHidden(self.comparison.hidden)
        end
    end
    return self
end
-- Catalogue registration precedes dev modules. Rebind the actual entry point,
-- not just the exported global factory (the alpha19 integration defect).
assert(JTG.Registry and JTG.Registry.byId['tools.hotkeys'],'Hotkey catalogue not registered')
JTG.Registry.byId['tools.hotkeys'].factory=JTG.CreateHotkeyTrainingActivity
