-- Development-only observation. Never manufactures launch, impact or dodge events.
JTG.Dev = JTG.Dev or {}
local Timing = {enabled=false, runs={}, nextId=0, samplePeriod=0.01, maxEvents=2000}
JTG.Dev.DodgeTiming = Timing
local PLAYER=Player(0)
local EXPORT_FILE="JTG-Dodge-Timing.pld"

local function Raw(value)
    if not value or value==0 then return "" end
    local bytes={}
    for index=4,1,-1 do bytes[index]=string.char(value%256); value=math.floor(value/256) end
    return table.concat(bytes)
end

function Timing.Record(run, event, role, unit, ability, detail, quality)
    if run.closed or not Timing.enabled then return end
    if #run.events>=Timing.maxEvents then run.truncated=true; return end
    run.events[#run.events+1]={time=TimerGetElapsed(run.clock),event=event,role=role or "",
        unit=unit and Raw(GetUnitTypeId(unit)) or "",ability=ability or "",
        unitHandle=unit and GetHandleId(unit) or "",
        detail=detail or "",quality=quality or "native_event"}
end

function Timing.Attach(session, activity)
    if activity.timingRun then return activity.timingRun end
    Timing.nextId=Timing.nextId+1
    local run={id=Timing.nextId,danger=activity.danger.id,dodger=activity.definition.id or activity.definition.unit,
        stage=activity.stage,events={},states={},samplePeriod=Timing.samplePeriod,
        conditions="training setup; all configured research; enemy attack cooldown set to 2 seconds"}
    activity.timingRun=run
    Timing.runs[#Timing.runs+1]=run
    -- A game-time clock shares Warcraft's pause/save behavior; no wall-clock claims.
    run.clock=JTG.StartScopedTimer(session,session.scope,86400,false,function() end)
    local function role(unit)
        if not unit then return nil end
        if unit==activity.caster then return "enemy" end
        if unit==activity.target then return "target" end
        if unit==activity.pawn then return "player" end
        if unit==activity.helper then return "helper" end
        if activity.timingReplacementHandles and activity.timingReplacementHandles[GetHandleId(unit)] then return "replacement" end
        if activity.baselineUnits and not activity.baselineUnits[unit] and GetOwningPlayer(unit)==PLAYER then
            return "player_created"
        end
    end
    local spellNames={
        [EVENT_PLAYER_UNIT_SPELL_CHANNEL]="cast_start",
        [EVENT_PLAYER_UNIT_SPELL_CAST]="cast_event",
        [EVENT_PLAYER_UNIT_SPELL_EFFECT]="ability_effect",
        [EVENT_PLAYER_UNIT_SPELL_FINISH]="cast_finish",
        [EVENT_PLAYER_UNIT_SPELL_ENDCAST]="cast_end",
    }
    local trigger=JTG.ScopeTrackTrigger(session.scope,CreateTrigger())
    for _,owner in ipairs({PLAYER,Player(1),Player(PLAYER_NEUTRAL_PASSIVE)}) do
        for event in pairs(spellNames) do TriggerRegisterPlayerUnitEvent(trigger,owner,event,nil) end
        for _,event in ipairs({EVENT_PLAYER_UNIT_DAMAGED,EVENT_PLAYER_UNIT_ATTACKED,
            EVENT_PLAYER_UNIT_USE_ITEM,EVENT_PLAYER_UNIT_ISSUED_ORDER,EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER,
            EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER,EVENT_PLAYER_UNIT_SUMMON,EVENT_PLAYER_UNIT_CONSTRUCT_START,
            EVENT_PLAYER_UNIT_CONSTRUCT_FINISH,EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL,EVENT_PLAYER_UNIT_LOADED,
            EVENT_PLAYER_UNIT_DEATH}) do
            TriggerRegisterPlayerUnitEvent(trigger,owner,event,nil)
        end
    end
    TriggerAddAction(trigger,JTG.GuardSession(session,function()
        local event,unit=GetTriggerEventId(),GetTriggerUnit()
        local side=role(unit)
        if event==EVENT_PLAYER_UNIT_SUMMON then unit=GetSummonedUnit(); side=role(GetSummoningUnit()) end
        if event==EVENT_PLAYER_UNIT_LOADED then unit=GetLoadedUnit(); side=role(unit) or role(GetTransportUnit()) end
        if not side then return end
        -- Native handles can compare equal without being the same Lua table key.
        -- Compare event values rather than indexing by the returned handle.
        local spellName
        for registered,name in pairs(spellNames) do
            if event==registered then spellName=name;break end
        end
        if spellName then
            Timing.Record(run,spellName,side,unit,Raw(GetSpellAbilityId()))
        elseif event==EVENT_PLAYER_UNIT_DAMAGED then
            if GetEventDamageSource()==activity.caster then
                Timing.Record(run,"damage",side,unit,"",string.format("%.5f",GetEventDamage()))
            end
        elseif event==EVENT_PLAYER_UNIT_ATTACKED then
            if GetAttacker()==activity.caster then Timing.Record(run,"attack_start","enemy",GetAttacker()) end
        elseif event==EVENT_PLAYER_UNIT_USE_ITEM then
            Timing.Record(run,"item_used",side,unit,Raw(GetItemTypeId(GetManipulatedItem())))
        elseif event==EVENT_PLAYER_UNIT_SUMMON then Timing.Record(run,"summoned",side,unit)
        elseif event==EVENT_PLAYER_UNIT_CONSTRUCT_START then Timing.Record(run,"construction_start",side,unit)
        elseif event==EVENT_PLAYER_UNIT_CONSTRUCT_FINISH then Timing.Record(run,"construction_finish",side,unit)
        elseif event==EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL then Timing.Record(run,"construction_cancel",side,unit)
        elseif event==EVENT_PLAYER_UNIT_LOADED then Timing.Record(run,"loaded",side,unit)
        elseif event==EVENT_PLAYER_UNIT_DEATH then Timing.Record(run,"death",side,unit)
        else Timing.Record(run,"order",side,unit,"",tostring(GetIssuedOrderId())) end
    end))
    local function sampleUnit(unit)
        if not unit then return end
        local side=role(unit)
        if not side then return end
        local current={type=Raw(GetUnitTypeId(unit))}
        if current.type~="" then
            current.hidden=IsUnitHidden(unit)
            current.invisible=IsUnitInvisible(unit,Player(1))
            current.invulnerable=BlzIsUnitInvulnerable(unit)
            if activity.timingRetest then
                current.dead=IsUnitType(unit,UNIT_TYPE_DEAD)
                current.magic_immune=IsUnitType(unit,UNIT_TYPE_MAGIC_IMMUNE)
                current.buff_BHav=GetUnitAbilityLevel(unit,FourCC("BHav"))>0
            end
            current.x,current.y=GetUnitX(unit),GetUnitY(unit)
            current.facing=GetUnitFacing(unit)
            for _,definition in ipairs({activity.danger,activity.definition}) do
                for _,buff in ipairs(definition.buffs or {}) do current["buff_"..buff]=GetUnitAbilityLevel(unit,FourCC(buff))>0 end
            end
        end
        local previous=run.states[unit]
        if not previous then
            Timing.Record(run,"initial_state",side,unit,"",
                string.format("hidden=%s;invisible=%s;invulnerable=%s;x=%.3f;y=%.3f;facing=%.3f",
                    tostring(current.hidden),tostring(current.invisible),tostring(current.invulnerable),
                    current.x or 0,current.y or 0,current.facing or 0),"initial_state")
        else
            for key,value in pairs(current) do
                if key~="x" and key~="y" and key~="facing" and key~="moving" and value~=previous[key] then
                    Timing.Record(run,"state_"..key,side,unit,"",tostring(value),"sampled_transition")
                end
            end
            if current.x and previous.x and not current.dead then
                local dx,dy=current.x-previous.x,current.y-previous.y
                current.moving=dx*dx+dy*dy>0.01
                if current.moving~=(previous.moving or false) then
                    Timing.Record(run,current.moving and "movement_start" or "movement_stop",side,unit,"",
                        string.format("x=%.3f;y=%.3f;facing=%.3f",current.x,current.y,current.facing or 0),"sampled_transition")
                end
                if dx*dx+dy*dy>64*64 then
                    Timing.Record(run,"position_jump",side,unit,"",string.format("%.3f",math.sqrt(dx*dx+dy*dy)),"sampled_transition")
                end
            end
        end
        run.states[unit]=current
    end
    local originalUnits={}
    for _,unit in pairs({activity.caster,activity.target,activity.pawn,activity.helper}) do originalUnits[GetHandleId(unit)]=true end
    local baselineHandles={}
    for unit in pairs(activity.baselineUnits or {}) do baselineHandles[GetHandleId(unit)]=true end
    local nextDiscovery=0
    local function sample()
        if not Timing.enabled or run.closed then return end
        local seen={}
        for _,unit in pairs({activity.caster,activity.target,activity.pawn,activity.helper}) do
            if not seen[unit] then seen[unit]=true; sampleUnit(unit) end
        end
        if activity.timingTrackReplacements and TimerGetElapsed(run.clock)>=nextDiscovery then
            nextDiscovery=TimerGetElapsed(run.clock)+0.05
            activity.timingReplacementUnits=activity.timingReplacementUnits or {}
            activity.timingReplacementHandles=activity.timingReplacementHandles or {}
            local group=CreateGroup()
            GroupEnumUnitsOfPlayer(group,PLAYER,nil)
            ForGroup(group,function()
                local unit=GetEnumUnit()
                local handle=GetHandleId(unit)
                local raw=Raw(GetUnitTypeId(unit))
                if not originalUnits[handle] and not baselineHandles[handle] and
                        not activity.timingReplacementHandles[handle] and
                        (raw=="earc" or raw=="ehip" or raw=="ehpr" or raw=="ubsp") then
                    activity.timingReplacementUnits[unit]=true
                    activity.timingReplacementHandles[handle]=true
                    Timing.Record(run,"replacement_discovered","replacement",unit,"",
                        "discovery interval=0.05;not a native creation event","sampled_transition")
                end
            end)
            DestroyGroup(group)
        end
        for unit in pairs(activity.timingReplacementUnits or {}) do
            if not seen[unit] then sampleUnit(unit) end
        end
    end
    sample()
    JTG.StartScopedTimer(session,session.scope,Timing.samplePeriod,true,sample)
    -- Keep the exercise's inferred launch/outcome separate from native observations.
    local confirm=activity.confirmCast
    activity.confirmCast=function(self,...)
        local already=self.castConfirmed
        local result=confirm(self,...)
        if self.castConfirmed and not already then Timing.Record(run,"training_launch_confirmation","enemy",self.caster,"","", "training_inference") end
        return result
    end
    local start=activity.start
    activity.start=function(self,...)
        Timing.Record(run,"exercise_start")
        return start(self,...)
    end
    local verdict=activity.verdict
    activity.verdict=function(self,text,...)
        Timing.Record(run,"training_verdict","",nil,"",text,"training_inference")
        return verdict(self,text,...)
    end
    local cleanup=activity.cleanup
    activity.cleanup=function(self,...)
        Timing.Record(run,"session_end")
        run.closed=true
        run.states={}
        if cleanup then return cleanup(self,...) end
    end
    Timing.Record(run,"recording_start")
    return run
end

local function Csv(value)
    return '"'..tostring(value or ""):gsub('[\r\n]',' '):gsub('"','""')..'"'
end
function Timing.ExportRows()
    local rows={"run,danger,dodger,stage,time_s,event,role,unit,ability_or_item,detail,quality,sample_period_s,truncated,conditions,unit_handle"}
    for _,run in ipairs(Timing.runs) do
        for _,event in ipairs(run.events) do
            local values={run.id,run.danger,run.dodger,run.stage,string.format("%.5f",event.time),event.event,event.role,
                event.unit,event.ability,event.detail,event.quality,run.samplePeriod,tostring(run.truncated==true),run.conditions,event.unitHandle}
            for index,value in ipairs(values) do values[index]=Csv(value) end
            rows[#rows+1]=table.concat(values,",")
        end
    end
    return rows
end
function Timing.Export()
    if GetLocalPlayer()==PLAYER then
        PreloadGenClear(); PreloadGenStart()
        -- Warcraft truncates long individual Preload arguments. Number short
        -- chunks so the reader can reconstruct and verify each complete row.
        local rows=Timing.ExportRows()
        Preload("\")\n//JTG_ROWS,"..#rows.."\n//")
        for index,row in ipairs(rows) do
            local total=math.ceil(#row/160)
            for part=1,total do
                Preload("\")\n//JTG_PART,"..index..","..part..","..total..","..row:sub((part-1)*160+1,part*160).."\n//")
            end
        end
        PreloadGenEnd(EXPORT_FILE)
    end
    DisplayTimedTextToPlayer(PLAYER,0,0,12,"Timing observations exported to CustomMapData\\"..EXPORT_FILE)
end

local function Initialize()
    local descriptor=JTG.Registry.byId["skills.missile_dodging"]
    local factory=descriptor.factory
    descriptor.factory=function(session)
        local activity=factory(session)
        local setup=activity.setup
        activity.setup=function(self,current)
            setup(self,current)
            if Timing.enabled then Timing.Attach(current,self) end
        end
        return activity
    end
    local trigger=CreateTrigger()
    for _,command in ipairs({"-timing-on","-timing-off","-timing-export","-timing-status"}) do
        TriggerRegisterPlayerChatEvent(trigger,PLAYER,command,true)
    end
    TriggerAddAction(trigger,function()
        local command=GetEventPlayerChatString()
        if command=="-timing-export" then Timing.Export(); return end
        if command=="-timing-on" then
            Timing.enabled=true
            local session=JTG.Controller.session
            if session and session.id=="skills.missile_dodging" then Timing.Attach(session,session.activity) end
        elseif command=="-timing-off" then
            -- Export a complete history before disabling; subsequent activity starts are untouched.
            Timing.Export(); Timing.enabled=false
        end
        DisplayTimedTextToPlayer(PLAYER,0,0,12,"Timing recorder: "..(Timing.enabled and "on" or "off")..". Attempts recorded: "..#Timing.runs..". Use -timing-export before leaving the map.")
    end)
    Timing.commandTrigger=trigger
end
JTG.RegisterBootstrapInitializer(Initialize)
