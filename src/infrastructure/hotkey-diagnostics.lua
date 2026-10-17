-- Development-only bridge. Production knows only the optional adapter contract;
-- audit modes, native observations, card snapshots and report export live here.
local create=JTG.CreateHotkeyTrainingActivity
function JTG.CreateHotkeyTrainingActivity(session)
    local self=create(session)
    self.diagnostics={
        active=function(activity) return activity.comparison~=nil or activity.audit~=nil end,
        status=function(activity)
            if activity.comparison then activity:comparisonStatus()
            elseif activity.audit then activity:auditStatus() end
        end,
        tick=function(activity)
            if activity.comparison then activity:comparisonTick()
            elseif activity.audit then activity:auditTick() end
        end,
        trace=function(activity,kind,origin)
            if not activity.prompt then return end
            activity.eventTrace=activity.eventTrace or {}
            activity.eventTrace[#activity.eventTrace+1]={prompt=activity.prompt.id,kind=kind,origin=origin,at=activity.elapsed}
        end,
        observe=function(self,event)
                local detail=tostring(event)
                if event==EVENT_PLAYER_UNIT_ISSUED_ORDER then detail='order:'..GetIssuedOrderId()
                elseif event==EVENT_PLAYER_UNIT_SPELL_CHANNEL or event==EVENT_PLAYER_UNIT_SPELL_CAST or event==EVENT_PLAYER_UNIT_SPELL_EFFECT then detail='spell:'..UnitId2String(GetSpellAbilityId())
                elseif event==EVENT_PLAYER_UNIT_TRAIN_START then detail='train:'..UnitId2String(GetTrainedUnitType())
                elseif event==EVENT_PLAYER_UNIT_RESEARCH_START then detail='research:'..UnitId2String(GetResearched())
                elseif event==EVENT_PLAYER_HERO_SKILL then detail='learn:'..UnitId2String(GetLearnedSkill()) end
                self.diagnostics.trace(self,'observed',detail)
        end,
    }
    -- Compatibility for historical diagnostic modes. Never hide native buttons.
    function self:setNativeCardHidden() end
    local setup=self.setup
    function self:setup(...)
        setup(self,...)
        self.nativeCard={}
        for slot=0,11 do
            local frame=BlzGetOriginFrame(ORIGIN_FRAME_COMMAND_BUTTON,slot)
            self.nativeCard[#self.nativeCard+1]={frame=frame,alpha=BlzFrameGetAlpha(frame)}
        end
        local tooltip=BlzGetOriginFrame(ORIGIN_FRAME_TOOLTIP,0)
        self.nativeCard[#self.nativeCard+1]={frame=tooltip,alpha=BlzFrameGetAlpha(tooltip)}
        local debug=JTG.ScopeTrackTrigger(session.scope,CreateTrigger())
        TriggerRegisterPlayerChatEvent(debug,Player(0),'-hotkey-debug',true)
        TriggerAddAction(debug,JTG.GuardSession(session,function()
            if not self.prompt then return end
            local last=self.logs[#self.logs]
            DisplayTimedTextToPlayer(Player(0),0,0,20,'Prompt: '..(self.prompt and self.prompt.id or 'none')..
                '\nLast input: '..(last and (tostring(last.key)..' / '..last.origin..' / '..tostring(last.correct)) or 'none'))
            if GetLocalPlayer()==Player(0) then
                PreloadGenClear();PreloadGenStart()
                Preload('//JTG_HOTKEY|prompt|'..(self.prompt and self.prompt.id or 'none'))
                Preload('//JTG_HOTKEY|selected|'..tostring(IsUnitSelected(self.source,Player(0))))
                Preload('//JTG_HOTKEY|button-slot|'..tostring(self.prompt.learnSlot or self.prompt.nativeSlot))
                Preload('//JTG_HOTKEY|source-type|'..UnitId2String(GetUnitTypeId(self.source)))
                for slot=0,11 do
                    local button=BlzGetOriginFrame(ORIGIN_FRAME_COMMAND_BUTTON,slot)
                    Preload('//JTG_HOTKEY|button|'..slot..'|enabled|'..tostring(BlzFrameGetEnable(button)))
                end
                if self.prompt.kind=='train' or self.prompt.kind=='research' then
                    Preload('//JTG_HOTKEY|tech-limit|'..GetPlayerTechMaxAllowed(Player(0),FourCC(self.prompt.raw)))
                    Preload('//JTG_HOTKEY|tech-level|'..GetPlayerTechCount(Player(0),FourCC(self.prompt.raw),true))
                end
                if self.buyer then
                    Preload('//JTG_HOTKEY|patron-order|'..tostring(self.patronAccepted)..'|shop|'..
                        GetUnitX(self.source)..'|'..GetUnitY(self.source)..'|buyer|'..GetUnitX(self.buyer)..'|'..GetUnitY(self.buyer))
                end
                if self.prompt.ability then
                    local active=self.prompt.activeAbility or self.prompt.ability
                    local raw=FourCC(active)
                    Preload('//JTG_HOTKEY|ability|'..active..'|level|'..GetUnitAbilityLevel(self.source,raw)..
                        '|x|'..BlzGetAbilityPosX(raw)..'|y|'..BlzGetAbilityPosY(raw))
                end
                for _,raw in ipairs(self.promptPrerequisites or {}) do
                    Preload('//JTG_HOTKEY|prerequisite|'..raw..'|'..GetPlayerTechCount(Player(0),FourCC(raw),true))
                end
                for raw,level in pairs(self.prompt.requiredResearch or {}) do
                    Preload('//JTG_HOTKEY|required-research|'..raw..'|expected|'..level..'|actual|'..GetPlayerTechCount(Player(0),FourCC(raw),true))
                end
                for _,event in ipairs(self.eventTrace or {}) do
                    Preload('//JTG_HOTKEY|confirmation|'..event.prompt..'|'..event.kind..'|'..event.origin..'|'..event.at)
                end
                for _,row in ipairs(self.logs) do
                    Preload('//JTG_HOTKEY|input|'..row.prompt..'|'..row.key..'|'..row.origin..'|'..tostring(row.correct)..'|'..row.response)
                end
                for id,other in pairs(self.skippedConflicts or {}) do
                    Preload('//JTG_HOTKEY|conflict-skipped|'..id..'|with|'..other)
                end
                PreloadGenEnd('JTG-Hotkey-Debug.pld')
                DisplayTimedTextToPlayer(Player(0),0,0,20,'Diagnostic saved to CustomMapData\\JTG-Hotkey-Debug.pld')
            end
        end))
    end
    return self
end
assert(JTG.Registry and JTG.Registry.byId['tools.hotkeys'],'Hotkey catalogue not registered')
JTG.Registry.byId['tools.hotkeys'].factory=JTG.CreateHotkeyTrainingActivity
