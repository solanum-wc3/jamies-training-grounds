-- Build Order's reference repeats economic decisions, not the player's mining
-- clicks. Each actor has a counterpart; native orders still pay native costs
-- and obey prerequisites. Nothing supplies missing gold or completes a build.
JTG = JTG or {}

function JTG.InstallMiningBuildOrder(self,session,race)
    local playerLane,reference=self.lanes[2],self.lanes[1]
    local mirror={pairs={},jobs={},roles={},produced={},actors={},commands={},rallies={}}
    self.buildMirror=mirror
    local dx,dy=reference.mineX-playerLane.mineX,reference.mineY-playerLane.mineY
    local function tracked(unit)
        if unit and not mirror.actors[unit] then
            mirror.actors[unit]=true;JTG.ScopeTrackUnit(session.scope,unit)
        end
    end
    local function pair(playerUnit,referenceUnit)
        mirror.pairs[playerUnit]=referenceUnit;tracked(referenceUnit)
    end
    pair(playerLane.hall,reference.hall)
    for index,worker in ipairs(playerLane.workers) do
        pair(worker,reference.workers[index])
        mirror.roles[worker]={kind=index==1 and 'lumber' or 'gold'}
    end
    for _,entry in ipairs(JTG.HotkeyCatalog) do
        if entry.race==self.race and (entry.kind=='build' or entry.kind=='train' or
                entry.kind=='research' or entry.kind=='upgrade') then
            local source=FourCC(entry.source)
            mirror.commands[source]=mirror.commands[source] or {}
            mirror.commands[source][FourCC(entry.raw)]={kind=entry.kind,raw=FourCC(entry.raw)}
        end
    end
    local function enqueue(actor,kind,values)
        local job=values or {};job.actor=actor;job.kind=kind
        mirror.jobs[#mirror.jobs+1]=job
        return job
    end
    local function role(actor,kind)
        local old=mirror.roles[actor]
        if old and old.kind==kind then return end
        mirror.roles[actor]={kind=kind}
        enqueue(actor,kind)
    end
    local function resource(target,tree)
        if target==playerLane.mine then return 'gold' end
        if tree then return 'lumber' end
    end
    local function register(events,callback)
        local trigger=JTG.ScopeTrackTrigger(session.scope,CreateTrigger())
        for _,owner in ipairs({Player(0),reference.owner}) do
            for _,event in ipairs(events) do TriggerRegisterPlayerUnitEvent(trigger,owner,event,nil) end
        end
        TriggerAddAction(trigger,JTG.GuardSession(session,function()
            if not self.finished then callback() end
        end))
    end
    register({EVENT_PLAYER_UNIT_ISSUED_ORDER,EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER,EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER},function()
        local actor=GetTriggerUnit()
        if GetOwningPlayer(actor)~=Player(0) then return end
        local event,order=GetTriggerEventId(),GetIssuedOrderId()
        local command=(mirror.commands[GetUnitTypeId(actor)] or {})[order]
        if command then
            local values={raw=command.raw}
            if command.kind=='build' then
                if event~=EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER then return end
                values.x,values.y=GetOrderPointX(),GetOrderPointY()
                values.previousRole=mirror.roles[actor]
                mirror.roles[actor]={kind='building'}
            end
            local job=enqueue(actor,command.kind,values)
            if command.kind=='build' then mirror.roles[actor].job=job end
        elseif event==EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER then
            local target,tree=GetOrderTargetUnit(),GetOrderTargetDestructable()
            local kind=resource(target,tree)
            if (order==OrderId('smart') or order==OrderId('harvest')) and GetUnitTypeId(actor)==race.worker and kind then
                role(actor,kind)
            elseif order==OrderId('setrally') then
                mirror.rallies[actor]=kind
                if kind then enqueue(actor,'rally',{resource=kind}) end
            elseif (order==OrderId('repair') or order==OrderId('smart')) and target and
                    GetOwningPlayer(target)==Player(0) and IsUnitType(target,UNIT_TYPE_STRUCTURE) and target~=playerLane.hall then
                local old=mirror.roles[actor]
                if not old or old.kind~='building' or old.target~=target then
                    mirror.roles[actor]={kind='building',target=target}
                    enqueue(actor,'assist',{target=target})
                end
            end
        elseif order==OrderId('setrally') and event==EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER then
            mirror.rallies[actor]=nil
            enqueue(actor,'rally-point',{x=GetOrderPointX(),y=GetOrderPointY()})
        elseif order==OrderId('cancel') or order==OrderId('cancelbuild') or
                order==OrderId('canceltrain') or order==OrderId('cancelresearch') then
            -- Pending economic actions have not spent resources yet. A live
            -- counterpart receives the same native cancellation command.
            for _,job in ipairs(mirror.jobs) do
                if job.actor==actor and not job.done and not job.issued then job.done=true end
            end
            local copy=mirror.pairs[actor]
            if copy then IssueImmediateOrderById(copy,order) end
        end
    end)
    register({EVENT_PLAYER_UNIT_CONSTRUCT_START,EVENT_PLAYER_UNIT_CONSTRUCT_FINISH,EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL},function()
        local event=GetTriggerEventId()
        local building=event==EVENT_PLAYER_UNIT_CONSTRUCT_START and GetConstructingStructure() or
            (event==EVENT_PLAYER_UNIT_CONSTRUCT_FINISH and GetConstructedStructure() or GetCancelledStructure())
        local isPlayer=GetOwningPlayer(building)==Player(0)
        if not isPlayer then tracked(building) end
        for _,job in ipairs(mirror.jobs) do
            if job.kind=='build' and job.raw==GetUnitTypeId(building) then
                local x,y=job.x+(isPlayer and 0 or dx),job.y+(isPlayer and 0 or dy)
                if (GetUnitX(building)-x)^2+(GetUnitY(building)-y)^2<128^2 then
                    if isPlayer then job.playerBuilding=building else job.referenceBuilding=building end
                    if job.playerBuilding and job.referenceBuilding then pair(job.playerBuilding,job.referenceBuilding) end
                    if event==EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL then
                        if isPlayer then
                            job.done=true
                            if job.referenceBuilding then IssueImmediateOrder(job.referenceBuilding,'cancel') end
                            local builder=mirror.pairs[job.actor]
                            if builder and not job.referenceBuilding then IssueImmediateOrder(builder,'stop') end
                        else job.done=true end
                    elseif not isPlayer and event==EVENT_PLAYER_UNIT_CONSTRUCT_FINISH then
                        job.done=true
                        local current=mirror.roles[job.actor]
                        if current and current.job==job and job.previousRole then
                            mirror.roles[job.actor]=job.previousRole
                            enqueue(job.actor,job.previousRole.kind)
                        end
                    end
                    break
                end
            end
        end
    end)
    register({EVENT_PLAYER_UNIT_TRAIN_FINISH},function()
        local producer,unit=GetTriggerUnit(),GetTrainedUnit()
        local isPlayer=GetOwningPlayer(unit)==Player(0)
        if not isPlayer then tracked(unit) end
        -- Pair by producer/type and completion order, not by simultaneous
        -- finish times: the non-micro base may be behind on income.
        for _,job in ipairs(mirror.jobs) do
            if job.kind=='train' and job.raw==GetUnitTypeId(unit) and
                    (isPlayer and producer==job.actor and not job.playerUnit or
                    not isPlayer and producer==mirror.pairs[job.actor] and not job.referenceUnit) then
                if isPlayer then job.playerUnit=unit else job.referenceUnit=unit end
                if job.playerUnit and job.referenceUnit then pair(job.playerUnit,job.referenceUnit) end
                if isPlayer and GetUnitTypeId(unit)==race.worker and mirror.rallies[producer] then
                    role(unit,mirror.rallies[producer])
                end
                break
            end
        end
    end)
    function self:updateBuildMirror()
        if self.finished or self.locallyPaused then return end
        local blocked,busy=false,{}
        for _,job in ipairs(mirror.jobs) do
            if not job.done then
                local copy=mirror.pairs[job.actor]
                local economic=job.kind=='build' or job.kind=='train' or job.kind=='research' or job.kind=='upgrade'
                if job.issued then
                    busy[job.actor]=true
                    -- A walk-to-build order can end without starting a site
                    -- when funds disappeared en route. Retry only when idle.
                    if not job.referenceBuilding and copy and GetUnitCurrentOrder(copy)==0 and not IsUnitHidden(copy) then
                        job.issued=false;blocked=true
                    end
                elseif not busy[job.actor] and (not economic or not blocked) then
                    local accepted=false
                    if copy and GetUnitTypeId(copy)~=0 then
                        if job.kind=='build' then
                            accepted=IssueBuildOrderById(copy,job.raw,job.x+dx,job.y+dy)
                        elseif job.kind=='train' or job.kind=='research' or job.kind=='upgrade' then
                            accepted=IssueImmediateOrderById(copy,job.raw)
                        elseif job.kind=='gold' or job.kind=='lumber' then
                            accepted=IssueTargetOrder(copy,'harvest',job.kind=='gold' and reference.mine or reference.tree)
                        elseif job.kind=='assist' then
                            local target=mirror.pairs[job.target]
                            if target then accepted=IssueTargetOrder(copy,'repair',target) end
                        elseif job.kind=='rally' then
                            accepted=IssueTargetOrder(copy,'setrally',job.resource=='gold' and reference.mine or reference.tree)
                        elseif job.kind=='rally-point' then
                            accepted=IssuePointOrder(copy,'setrally',job.x+dx,job.y+dy)
                        end
                    end
                    if accepted then
                        if job.kind=='build' then job.issued=true;busy[job.actor]=true
                        else job.done=true end
                    elseif economic then blocked=true end
                    if not accepted then busy[job.actor]=true end
                end
            end
        end
    end
end
