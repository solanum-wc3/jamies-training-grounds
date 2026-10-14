-- Development-only, interactive audit. Never simulate a native frame click.
-- UI activation and execution are separate observations, not interchangeable.
local create=JTG.CreateHotkeyTrainingActivity
function JTG.CreateHotkeyTrainingActivity(session)
    local self=create(session)
    local setup,onKey=self.setup,self.onKey
    function self:auditWrite()
        if GetLocalPlayer()~=Player(0) then return end
        PreloadGenClear(); PreloadGenStart()
        Preload('//JTG_AUDIT|format|2|interactive-physical-input')
        Preload('//JTG_AUDIT|race|'..self.race..'|control|'..self.audit.control..'|state|'..self.audit.state)
        for _,line in ipairs(self.audit.lines) do Preload('//JTG_AUDIT|'..line) end
        if self.audit.state=='control' or self.audit.state=='catalogue' then
            Preload('//JTG_AUDIT|pending|'..self.prompt.id)
            for _,key in ipairs(self.audit.keys or {}) do Preload('//JTG_AUDIT|pending-key|'..key.key..'|'..key.at) end
            for index=self.audit.traceStart or 1,#(self.eventTrace or {}) do
                local event=self.eventTrace[index]
                Preload('//JTG_AUDIT|pending-event|'..event.kind..'|'..event.origin..'|'..event.at)
            end
        end
        PreloadGenEnd('JTG-Hotkey-Audit.pld')
    end
    function self:auditStatus()
        if not self.audit then return end
        local a=self.audit
        BlzFrameSetText(self.status,'Audit '..a.index..'/'..#a.pool..' - '..a.state..
            '\nUse your hotkey. No timer or scoring. Card: '..(a.visible and 'visible' or 'hidden'))
        BlzFrameSetVisible(self.status,self.presentationVisible and not self.finished)
    end
    function self:auditPrompt(entry)
        self.advance=false
        self:nextPrompt(entry)
        local a=self.audit
        a.traceStart=#(self.eventTrace or {})+1
        a.keys={}; a.started=self.elapsed; a.accepted=nil
        a.lines[#a.lines+1]='begin|'..entry.id..'|card|'..tostring(a.visible)
        a.lines[#a.lines+1]='selected|'..tostring(IsUnitSelected(self.source,Player(0)))..
            '|source|'..UnitId2String(GetUnitTypeId(self.source))
        for raw,count in pairs(entry.requiredUnits or {}) do
            a.lines[#a.lines+1]='requires-unit|'..raw..'|expected|'..count..'|actual|'..GetPlayerTechCount(Player(0),FourCC(raw),true)
        end
        for _,raw in ipairs(self.promptPrerequisites or {}) do
            a.lines[#a.lines+1]='context-unit|'..raw..'|actual|'..GetPlayerTechCount(Player(0),FourCC(raw),true)
        end
        for raw,count in pairs(entry.requiredResearch or {}) do
            a.lines[#a.lines+1]='requires-research|'..raw..'|expected|'..count..'|actual|'..GetPlayerTechCount(Player(0),FourCC(raw),true)
        end
        if entry.kind=='research' then
            a.lines[#a.lines+1]='research-level|'..entry.researchLevel..'|current|'..GetPlayerTechCount(Player(0),FourCC(entry.raw),true)
        end
        if entry.ability then
            a.lines[#a.lines+1]='ability|'..entry.ability..'|level|'..GetUnitAbilityLevel(self.source,FourCC(entry.ability))
        end
        if self.buyer then a.lines[#a.lines+1]='patron-order-accepted|'..tostring(self.patronAccepted) end
        self:auditWrite(); self:refreshStatus()
    end
    function self:auditRecord(result)
        local a=self.audit
        for _,key in ipairs(a.keys) do a.lines[#a.lines+1]='key|'..key.key..'|time|'..key.at end
        for index=a.traceStart,#(self.eventTrace or {}) do
            local event=self.eventTrace[index]
            a.lines[#a.lines+1]='event|'..event.kind..'|'..event.origin..'|time|'..event.at
        end
        a.lines[#a.lines+1]='result|'..self.prompt.id..'|'..result
        self:auditWrite()
    end
    function self:auditNext(result)
        local a=self.audit
        self:auditRecord(result)
        if a.state=='control' then
            if result~='executed-with-key' then
                a.control='inconclusive'; a.state='inconclusive'
                self:auditWrite(); self:refreshStatus()
                DisplayTimedTextToPlayer(Player(0),0,0,30,'Control did not pass. Audit stopped; no catalogue failures inferred. Use -hotkey-audit to restart.')
                return
            end
            a.control='passed'; a.state='catalogue'; a.visible=false
        end
        a.index=a.index+1
        if a.index>#a.pool then
            a.state='complete'; self:auditWrite(); self:refreshStatus()
            DisplayTimedTextToPlayer(Player(0),0,0,30,'Audit complete. Saved to CustomMapData\\JTG-Hotkey-Audit.pld. Use -hotkey-audit-end to resume training.')
            return
        end
        self:auditPrompt(a.pool[a.index])
    end
    function self:auditTick()
        local a=self.audit
        self:setNativeCardHidden(self.presentationVisible and not a.visible)
        if a.state=='complete' or a.state=='inconclusive' or not self.presentationVisible then return end
        -- Wait for all event streams. Mouse activation alone cannot pass.
        local matched,executed
        for index=a.traceStart,#(self.eventTrace or {}) do
            local event=self.eventTrace[index]
            if event.kind=='correct' then
                for _,key in ipairs(a.keys) do
                    if math.abs(key.at-event.at)<=0.5 then
                        matched=true
                        if event.origin=='native-action' then executed=true end
                    end
                end
            end
        end
        local qualified=matched and (a.state~='control' or executed)
        if qualified then
            a.accepted=a.accepted or self.elapsed
            if self.elapsed-a.accepted>=0.6 then self:auditNext(executed and 'executed-with-key' or 'activated-with-key'); return end
        end
        self:refreshStatus()
    end
    function self:onKey(key)
        if not self.audit then return onKey(self,key) end
        if self:inputActive() and self.audit.state~='complete' and self.audit.state~='inconclusive' then
            self.audit.keys[#self.audit.keys+1]={key=key,at=self.elapsed}
        end
    end
    function self:setup()
        setup(self)
        local function command(text,callback)
            local trigger=JTG.ScopeTrackTrigger(session.scope,CreateTrigger())
            TriggerRegisterPlayerChatEvent(trigger,Player(0),text,true)
            TriggerAddAction(trigger,JTG.GuardSession(session,callback))
        end
        command('-hotkey-audit',function()
            if self.finished or self.paused then return end
            local pool,control={},nil
            for _,entry in ipairs(self.pool) do
                if entry.id=='common.hfoo.common.stop' then control=entry else pool[#pool+1]=entry end
            end
            assert(control,'Audit requires Stop control')
            table.sort(pool,function(a,b) return a.id<b.id end)
            self.audit={pool=pool,index=0,control='pending',state='control',visible=true,lines={}}
            self:auditPrompt(control)
            DisplayTimedTextToPlayer(Player(0),0,0,30,'Audit control: press your Stop hotkey. Then test each prompt. Commands: -hotkey-audit-skip, -hotkey-audit-retry, -hotkey-audit-card, -hotkey-audit-end.')
        end)
        command('-hotkey-audit-skip',function()
            if self.audit and (self.audit.state=='control' or self.audit.state=='catalogue') then self:auditNext('unverified-skipped') end
        end)
        command('-hotkey-audit-retry',function()
            if self.audit and (self.audit.state=='control' or self.audit.state=='catalogue') then
                self:auditRecord('unverified-retry'); self:auditPrompt(self.prompt)
            end
        end)
        command('-hotkey-audit-card',function()
            if self.audit then
                self.audit.visible=not self.audit.visible
                self.audit.lines[#self.audit.lines+1]='card-toggle|'..tostring(self.audit.visible)..'|time|'..self.elapsed
                self:auditWrite()
            end
        end)
        command('-hotkey-audit-save',function()
            if self.audit then
                self:auditWrite()
                DisplayTimedTextToPlayer(Player(0),0,0,20,'Audit snapshot saved to CustomMapData\\JTG-Hotkey-Audit.pld')
            end
        end)
        command('-hotkey-audit-end',function()
            if self.audit then
                self:auditRecord('audit-ended'); self.audit.state='ended'; self:auditWrite()
                self.audit=nil; self.elapsed=0; self:auditStatus(); self:nextPrompt(); self:refreshStatus()
            end
        end)
    end
    return self
end
