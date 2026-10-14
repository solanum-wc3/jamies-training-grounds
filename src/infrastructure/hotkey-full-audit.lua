-- Dev-only repeated full catalogue audit. Uses the independent comparison
-- observer; direct issued orders are never substituted for UI-key activation.
local create=JTG.CreateHotkeyTrainingActivity
function JTG.CreateHotkeyTrainingActivity(session)
    local self=create(session)
    local setup=self.setup
    function self:fullAuditWrite(flush)
        local c=self.comparison;local f=c and c.full
        if not f or GetLocalPlayer()~=Player(0) then return end
        PreloadGenClear();PreloadGenStart()
        Preload('//JTG_FULL|format|1|binding-hash|'..JTG.HotkeyComparisonBindingHash)
        Preload('//JTG_FULL|batch|'..f.batch..'|job|'..f.job..'|state|'..c.state)
        for _,line in ipairs(c.lines) do Preload('//JTG_FULL|'..line) end
        local report=f.targeted and 'JTG-Hotkey-Targeted-Audit' or f.selectionAudit and 'JTG-Hotkey-Selection-Audit' or 'JTG-Hotkey-Full-Audit'
        PreloadGenEnd(string.format(report..'-%03d.pld',f.batch))
        PreloadGenClear();PreloadGenStart()
        Preload('//JTG_FULL|manifest|batches|'..f.batch..'|job|'..f.job..'|total|'..#f.plan..'|state|'..c.state)
        for result,count in pairs(f.counts) do Preload('//JTG_FULL|count|'..result..'|'..count) end
        PreloadGenEnd(report..'.pld')
        if flush then f.batch=f.batch+1;c.lines={} end
    end
    function self:fullAuditStatus()
        local c=self.comparison;local f=c.full
        BlzFrameSetText(self.status,(f.targeted and 'Targeted audit ' or f.selectionAudit and 'Selection comparison ' or 'Full audit ')..f.job..'/'..#f.plan..' - '..c.state..
            '\nThree repetitions. Everything visible.'..
            '\nNative: '..tostring(c.native)..'  Trainer: '..tostring(c.trainer))
        BlzFrameSetSize(self.status,0.7,0.10)
        BlzFrameSetVisible(self.status,self.presentationVisible)
    end
    function self:fullAuditPrepare()
        local c=self.comparison;local f=c.full
        local job=f.plan[f.job]
        if job and job.transition~='dispose-before-close' then
            self.armedAt=math.huge
            if GetLocalPlayer()==Player(0) then ForceUICancel();ClearSelection() end
            self.submenuOpen=false;self.skillMenuOpen=false
            self:comparisonRecord('transition','close-before-dispose|old-source-alive|'..tostring(self.source~=nil))
            f.prepareAt=self.elapsed+0.5
            return
        end
        self:fullAuditCreateContext()
    end
    function self:fullAuditCreateContext()
        local c=self.comparison;local f=c.full
        while f.job<=#f.plan do
            local job=f.plan[f.job]
            c.pool={job.entry};c.index=1;c.hidden=false
            f.missing=false;f.submenuMissing=false
            f.uiStage=0
            self:comparisonRecord('trial',f.job..'|repeat|'..job.repeatIndex..'|control|'..tostring(job.control))
            self:comparisonRecord('transition-method',job.transition or 'close-before-dispose')
            local restoreSource=self.restoreSource
            self.restoreSource=function() end
            local ok,err=pcall(function() self:comparisonPrompt() end)
            self.restoreSource=restoreSource
            if ok then
                self.armedAt=math.huge
                self:comparisonRecord('source-owner',tostring(GetPlayerId(GetOwningPlayer(self.source))))
                for _,check in ipairs(self.preparationChecks or {}) do
                    self:comparisonRecord('preparation',check.kind..'|accepted|'..tostring(check.accepted))
                end
                for raw,count in pairs(job.entry.requiredUnits or {}) do
                    local actual=GetPlayerTechCount(Player(0),FourCC(raw),true)
                    self:comparisonRecord('requires-unit',raw..'|expected|'..count..'|actual|'..actual)
                    if actual<count then f.missing=true end
                end
                for raw,level in pairs(job.entry.requiredResearch or {}) do
                    if GetPlayerTechCount(Player(0),FourCC(raw),true)<level then f.missing=true end
                end
                self:comparisonRecord('resources','gold|'..GetPlayerState(Player(0),PLAYER_STATE_RESOURCE_GOLD)..
                    '|lumber|'..GetPlayerState(Player(0),PLAYER_STATE_RESOURCE_LUMBER)..
                    '|food-cap|'..GetPlayerState(Player(0),PLAYER_STATE_RESOURCE_FOOD_CAP))
                if IsUnitType(self.source,UNIT_TYPE_HERO) then
                    self:comparisonRecord('hero','level|'..GetHeroLevel(self.source)..'|skill-points|'..GetHeroSkillPoints(self.source))
                end
                if job.entry.kind=='research' then
                    self:comparisonRecord('research-stage',job.entry.raw..'|requested|'..(job.entry.researchLevel or 1)..
                        '|current|'..GetPlayerTechCount(Player(0),FourCC(job.entry.raw),true))
                end
                if job.entry.kind=='research' or job.entry.kind=='train' or job.entry.kind=='build' or job.entry.kind=='upgrade' then
                    self:comparisonRecord('tech-limit',job.entry.raw..'|'..GetPlayerTechMaxAllowed(Player(0),FourCC(job.entry.raw)))
                end
                self:fullAuditWrite();return
            end
            -- A bad context is data, not a reason to lose the entire audit.
            c.state='testing'
            self:comparisonRecord('setup-error',tostring(err):gsub('[\r\n"]',' '):sub(1,150))
            f.counts['setup-error']=(f.counts['setup-error'] or 0)+1
            if f.job%20==0 then self:fullAuditWrite(true) end
            f.job=f.job+1
        end
        c.state='complete';self:fullAuditWrite();self:refreshStatus()
        DisplayTimedTextToPlayer(Player(0),0,0,60,'Audit complete. Reports saved in CustomMapData: '..(f.targeted and 'JTG-Hotkey-Targeted-Audit*.pld' or f.selectionAudit and 'JTG-Hotkey-Selection-Audit*.pld' or 'JTG-Hotkey-Full-Audit*.pld'))
    end
    function self:fullAuditNext()
        local c=self.comparison;local f=c.full;local job=f.plan[f.job]
        local bindings=(JTG.HotkeyFullAuditBindings or {})[job.entry.id] or {}
        local keySeen=false
        for _,key in ipairs(c.keys) do if c.forceAt and key.at>=c.forceAt then keySeen=true end end
        local result
        if #bindings==0 then result='unsupported-binding'
        elseif f.missing then result='requirements-missing'
        elseif f.submenuMissing then result='submenu-not-open'
        elseif c.preInputCast and job.entry.autocastOff and job.entry.autocastOff~='' then result='autocast-inconclusive'
        elseif c.native and c.trainer then result='native-and-trainer'
        elseif c.button and not c.trainer then result='button-recognition-missed'
        elseif c.native then result='native-recognition-missed'
        elseif c.trainer then result='activation-only'
        elseif not keySeen then result='no-key-notification'
        else result='no-activation-evidence' end
        self:comparisonRecord('outcome',job.entry.id..'|'..result..'|control-healthy|'..tostring(f.healthy))
        if f.targeted then self:comparisonRecord('evidence','button|'..tostring(c.button)..
            '|execution|'..tostring(c.native)..'|trainer|'..tostring(c.trainer)) end
        f.counts[result]=(f.counts[result] or 0)+1
        if job.control then
            local passed=c.native and c.forceAt and c.nativeAt and c.nativeAt>=c.forceAt
            f.healthy=passed==true
            self:comparisonRecord('control-result',tostring(f.healthy))
            if not passed and not f.retryControl then
                f.retryControl=true;self:fullAuditPrepare();return
            end
            f.retryControl=false
            if not passed and f.job==1 then
                c.state='control-inconclusive';self:fullAuditWrite();self:refreshStatus();return
            end
        end
        -- Save bounded batches instead of rewriting an ever-growing file.
        if f.job%20==0 then self:fullAuditWrite(true) end
        f.job=f.job+1
        self:fullAuditPrepare()
    end
    function self:fullAuditBegin(targeted)
        if self.finished or self.paused then return end
        local remaining=0
        for _,entry in ipairs(JTG.HotkeyCatalog) do
            if targeted and (JTG.HotkeyTargetedAuditIds or {})[entry.id] or
                not targeted and not (JTG.HotkeyAuditTested or {})[entry.id] then remaining=remaining+1 end
        end
        if remaining==0 then
            DisplayTimedTextToPlayer(Player(0),0,0,30,'All commands have completed an audit trial. No untested commands remain; prior reports are preserved.')
            return
        end
        self:comparisonBegin(true)
        local c=self.comparison
        if not c then return end
        local stop,pool
        pool={}
        for _,entry in ipairs(JTG.HotkeyCatalog) do
            if entry.id=='common.hfoo.common.stop' then stop=entry end
            if targeted and (JTG.HotkeyTargetedAuditIds or {})[entry.id] or
                not targeted and not (JTG.HotkeyAuditTested or {})[entry.id] then pool[#pool+1]=entry end
        end
        assert(stop,'Missing Stop control')
        for _,entry in ipairs(pool) do
            if entry.raw=='root' or entry.uprooted then self:prepareAncient(entry.source) end
        end
        local plan={}
        for repetition=1,3 do
            local order={};for index,entry in ipairs(pool) do order[index]=entry end
            for index=#order,2,-1 do local other=GetRandomInt(1,index);order[index],order[other]=order[other],order[index] end
            plan[#plan+1]={entry=stop,control=true,repeatIndex=repetition}
            for index,entry in ipairs(order) do
                plan[#plan+1]={entry=entry,repeatIndex=repetition}
                if index%20==0 then plan[#plan+1]={entry=stop,control=true,repeatIndex=repetition} end
            end
            plan[#plan+1]={entry=stop,control=true,repeatIndex=repetition}
        end
        c.lines={};c.full={plan=plan,job=1,batch=1,counts={},healthy=false,targeted=targeted==true};c.hidden=false
        for _,frame in ipairs(c.frames) do BlzFrameSetVisible(frame,false) end
        self:fullAuditPrepare()
        DisplayTimedTextToPlayer(Player(0),0,0,60,(targeted and 'Targeted audit: ' or 'Full audit: ')..#pool..
            ' commands, 3 repetitions plus Stop controls. Close chat and leave it running. Reports save automatically; -hotkey-full-audit-end stops.')
    end
    function self:selectionAuditBegin()
        if self.finished or self.paused then return end
        self:comparisonBegin(true)
        local c=self.comparison
        if not c then return end
        local ids={'common.hfoo.common.stop','orc.Otch.ability.AOws',
            'orc.Otch.ability.AOsh','orc.obar.train.ogru','orc.ofor.research.Rome',
            'orc.ovln.buy.hslv','orc.opeo.build.oalt','orc.Otch.learn.AOre'}
        local byId={};for _,entry in ipairs(JTG.HotkeyCatalog) do byId[entry.id]=entry end
        local plan={}
        for repetition=1,3 do
            for _,method in ipairs({'close-before-dispose'}) do
                for _,id in ipairs(ids) do
                    plan[#plan+1]={entry=assert(byId[id],id),repeatIndex=repetition,transition=method}
                end
            end
        end
        c.lines={};c.full={plan=plan,job=1,batch=1,counts={},healthy=false,selectionAudit=true}
        for _,frame in ipairs(c.frames) do BlzFrameSetVisible(frame,false) end
        self:fullAuditPrepare()
        DisplayTimedTextToPlayer(Player(0),0,0,60,'Selection verification: 24 trials, approximately 2 minutes. Close chat and leave it running. Reports save automatically to JTG-Hotkey-Selection-Audit*.pld.')
    end
    function self:setup()
        setup(self)
        local trigger=JTG.ScopeTrackTrigger(session.scope,CreateTrigger())
        TriggerRegisterPlayerChatEvent(trigger,Player(0),'-hotkey-full-audit',true)
        TriggerAddAction(trigger,JTG.GuardSession(session,function() self:fullAuditBegin() end))
        local targeted=JTG.ScopeTrackTrigger(session.scope,CreateTrigger())
        TriggerRegisterPlayerChatEvent(targeted,Player(0),'-hotkey-targeted-audit',true)
        TriggerAddAction(targeted,JTG.GuardSession(session,function() self:fullAuditBegin(true) end))
        local selection=JTG.ScopeTrackTrigger(session.scope,CreateTrigger())
        TriggerRegisterPlayerChatEvent(selection,Player(0),'-hotkey-selection-audit',true)
        TriggerAddAction(selection,JTG.GuardSession(session,function() self:selectionAuditBegin() end))
        local stop=JTG.ScopeTrackTrigger(session.scope,CreateTrigger())
        TriggerRegisterPlayerChatEvent(stop,Player(0),'-hotkey-full-audit-end',true)
        TriggerAddAction(stop,JTG.GuardSession(session,function() self:comparisonEnd() end))
    end
    return self
end
JTG.Registry.byId['tools.hotkeys'].factory=JTG.CreateHotkeyTrainingActivity
