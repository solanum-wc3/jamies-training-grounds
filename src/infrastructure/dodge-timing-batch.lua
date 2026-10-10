-- Development-only automation. Uses the real activity setup and scoped cleanup.
-- Orders, effects and damage remain observations; order acceptance is not success.
JTG.Dev = JTG.Dev or {}
local Batch={active=false,results={}}
JTG.Dev.DodgeTimingBatch=Batch
local PLAYER=Player(0)

local function findDanger(predicate)
    for index,danger in ipairs(JTG.DodgeDangers) do if predicate(danger) then return index end end
end
local function findPawn(id)
    for index,pawn in ipairs(JTG.DodgePawns) do if pawn.id==id then return index end end
end
function Batch.Plan(smoke)
    local plan={}
    local baseline=findPawn("dodge.40")
    local bolt=findDanger(function(d) return d.ability=="AHtb" end)
    local representatives={bolt,
        findDanger(function(d) return d.ability=="Aens" end),
        findDanger(function(d) return d.menuGroup=="Ranged" and d.unit=="ohun" end),
        findDanger(function(d) return d.ability=="AOsh" end)}
    for index,danger in ipairs(JTG.DodgeDangers) do
        if danger.menuGroup=="Homing" or danger.menuGroup=="Area" or danger.menuGroup=="Ranged" then
            plan[#plan+1]={dangerIndex=index,pawnIndex=baseline,mode="baseline"}
        end
    end
    for _,method in ipairs(JTG.DodgeTimingMethods) do
        plan[#plan+1]={dangerIndex=bolt,pawnIndex=method.pawnIndex,method=method,mode="isolated"}
        for _,dangerIndex in ipairs(representatives) do
            for _,mode in ipairs({"before_order","cast_start_plus_0.10","effect_plus_0.10"}) do
                plan[#plan+1]={dangerIndex=dangerIndex,pawnIndex=method.pawnIndex,method=method,mode=mode}
            end
        end
    end
    if smoke then
        -- Focused native verification before another large measurement pass.
        local selected={}
        for _,wanted in ipairs({"AHtb","Aens","ohun","AOsh","echm","hgyr","etrp"}) do
            for _,case in ipairs(plan) do
                local danger=JTG.DodgeDangers[case.dangerIndex]
                if case.mode=="baseline" and (danger.ability==wanted or danger.unit==wanted) then
                    selected[#selected+1]=case;break
                end
            end
        end
        for _,wanted in ipairs({"dodge.01.1","dodge.04.1","dodge.26.1","dodge.34.1","dodge.37.1"}) do
            for _,case in ipairs(plan) do
                if case.method and case.method.id==wanted and case.mode=="isolated" then selected[#selected+1]=case;break end
            end
        end
        for _,mode in ipairs({"cast_start_plus_0.10","effect_plus_0.10"}) do
            for _,case in ipairs(plan) do
                if case.dangerIndex==bolt and case.method and case.method.id=="dodge.01.1" and case.mode==mode then
                    selected[#selected+1]=case;break
                end
            end
        end
        return selected
    end
    return plan
end

local function approachMethod(method)
    return method.method=="Build" or method.method=="Burrow loading" or method.method=="Enter entangled gold mine" or
        method.choice=="dodge.23" or method.choice=="dodge.24" or method.choice=="dodge.34"
end
function Batch.ActivationPlan()
    local plan={}
    local bolt=findDanger(function(d) return d.ability=="AHtb" end)
    for _,method in ipairs(JTG.DodgeTimingMethods) do
        for _,position in ipairs(approachMethod(method) and {"near","far"} or {"stationary"}) do
            for repetition=1,3 do
                plan[#plan+1]={dangerIndex=bolt,pawnIndex=method.pawnIndex,method=method,mode="isolated",
                    activationPass=true,approach=position,repetition=repetition}
            end
        end
    end
    for _,raw in ipairs({"ohun","echm","etrp"}) do
        local dangerIndex=findDanger(function(d) return d.menuGroup=="Ranged" and d.unit==raw end)
        for _,fraction in ipairs({0.45,0.85}) do
            for repetition=1,3 do
                plan[#plan+1]={dangerIndex=dangerIndex,pawnIndex=findPawn("dodge.40"),mode="baseline",
                    activationPass=true,rangeFraction=fraction,repetition=repetition}
            end
        end
    end
    return plan
end

function Batch.RetestPlan()
    local plan={}
    local bolt=findDanger(function(d) return d.ability=="AHtb" end)
    local wanted={['dodge.26.1']=true,['dodge.26.3']=true,['dodge.14.1']=true,
        ['dodge.17.1']=true,['dodge.23.1']=true,['dodge.24.1']=true,
        ['dodge.25.1']=true,['dodge.07.1']=true}
    for _,method in ipairs(JTG.DodgeTimingMethods) do
        if wanted[method.id] then
            local positions=approachMethod(method) and {"near","far"} or {"stationary"}
            local routes=method.id=="dodge.26.3" and {"immediate","point","immediate_near_enemy"} or {"native"}
            for _,position in ipairs(positions) do
                for _,route in ipairs(routes) do
                    for repetition=1,3 do
                        plan[#plan+1]={dangerIndex=bolt,pawnIndex=method.pawnIndex,method=method,mode="isolated",
                            activationPass=true,retest=true,approach=position,route=route,repetition=repetition}
                    end
                end
            end
        end
    end
    return plan
end

-- Focused projectile pass: a real launch is required before a no-hit result
-- can be interpreted. Ranged launch remains explicitly estimated from attack point.
function Batch.MetamorphPlan()
    local plan={}
    local method
    for _,candidate in ipairs(JTG.DodgeTimingMethods) do
        if candidate.ability=="AEme" then method=candidate;break end
    end
    assert(method,"Metamorphosis timing method missing")
    for _,dangerIndex in ipairs({
        findDanger(function(d) return d.ability=="Aens" end),
        findDanger(function(d) return d.ability=="AHtb" end),
        findDanger(function(d) return d.menuGroup=="Ranged" and d.unit=="ohun" end)}) do
        for repetition=1,2 do
            plan[#plan+1]={dangerIndex=dangerIndex,pawnIndex=method.pawnIndex,mode="meta_baseline",
                metamorphPass=true,repetition=repetition,rangeFraction=0.85}
            for _,lead in ipairs({0.25,0.75,1.25}) do
                plan[#plan+1]={dangerIndex=dangerIndex,pawnIndex=method.pawnIndex,method=method,
                    mode="meta_before_order",metamorphPass=true,enemyDelay=lead,repetition=repetition,rangeFraction=0.85}
            end
            for _,fraction in ipairs({0,0.25,0.5,0.75,0.9}) do
                plan[#plan+1]={dangerIndex=dangerIndex,pawnIndex=method.pawnIndex,method=method,
                    mode="meta_after_launch",metamorphPass=true,flightFraction=fraction,repetition=repetition,rangeFraction=0.85}
            end
        end
    end
    return plan
end

function Batch.Snapshot(activity,role,unit)
    if not unit or GetUnitTypeId(unit)==0 then return end
    local detail=string.format("x=%.3f;y=%.3f;facing=%.3f;collision=%.3f",GetUnitX(unit),GetUnitY(unit),
        GetUnitFacing(unit),BlzGetUnitCollisionSize(unit))
    if activity.timingRetest then
        detail=detail..string.format(";order=%d;mana=%.3f;paused=%s;gold=%d;lumber=%d;food_used=%d;food_cap=%d;food_ceiling=%d",
            GetUnitCurrentOrder(unit),GetUnitState(unit,UNIT_STATE_MANA),tostring(IsUnitPaused(unit)),
            GetPlayerState(PLAYER,PLAYER_STATE_RESOURCE_GOLD),GetPlayerState(PLAYER,PLAYER_STATE_RESOURCE_LUMBER),
            GetPlayerState(PLAYER,PLAYER_STATE_RESOURCE_FOOD_USED),GetPlayerState(PLAYER,PLAYER_STATE_RESOURCE_FOOD_CAP),
            GetPlayerState(PLAYER,PLAYER_STATE_RESOURCE_FOOD_CAP_CEILING))
        for _,raw in ipairs({"Aave","Aco2","Aco3","Acoa","Acoh","Adtn","Ashm","AHav","Adec"}) do
            detail=detail..";"..raw.."="..GetUnitAbilityLevel(unit,FourCC(raw))
        end
    end
    if unit==activity.caster and (activity.danger.kind=="attack" or activity.danger.orbOrder) then
        local weapon=activity.danger.weapon or 0
        detail=detail..string.format(";weapon=%d;range=%.3f;attack_damage_point=%.5f;attack_cooldown=%.5f",weapon,
            BlzGetUnitWeaponRealField(unit,UNIT_WEAPON_RF_ATTACK_RANGE,weapon),
            BlzGetUnitWeaponRealField(unit,UNIT_WEAPON_RF_ATTACK_DAMAGE_POINT,weapon),BlzGetUnitAttackCooldown(unit,weapon))
    end
    JTG.Dev.DodgeTiming.Record(activity.timingRun,"setup_snapshot",role,unit,"",
        detail,"native_snapshot")
end

local function alive(unit) return unit and GetUnitTypeId(unit)~=0 and not IsUnitType(unit,UNIT_TYPE_DEAD) end

-- Check terrain, destructibles and units without altering the foundation.
-- A conservative square around the native Moon Well footprint also leaves
-- room for the worker's approach. Recheck immediately before the build order.
function Batch.BuildSiteClear(activity,x,y)
    local margin=96
    for dx=-margin,margin,32 do
        for dy=-margin,margin,32 do
            if IsTerrainPathable(x+dx,y+dy,PATHING_TYPE_BUILDABILITY) then return false,"terrain" end
        end
    end
    local blocked=false
    local group=CreateGroup()
    GroupEnumUnitsInRange(group,x,y,512,nil)
    ForGroup(group,function()
        local unit=GetEnumUnit()
        if unit~=activity.pawn and alive(unit) and not IsUnitType(unit,UNIT_TYPE_FLYING) then
            local radius=BlzGetUnitCollisionSize(unit)+margin
            if math.abs(GetUnitX(unit)-x)<radius and math.abs(GetUnitY(unit)-y)<radius then blocked=true end
        end
    end)
    DestroyGroup(group)
    if blocked then return false,"unit footprint" end
    local rect=Rect(x-margin,y-margin,x+margin,y+margin)
    EnumDestructablesInRect(rect,nil,function() if GetDestructableLife(GetEnumDestructable())>0 then blocked=true end end)
    RemoveRect(rect)
    return not blocked,blocked and "destructible" or "clear"
end

function Batch.PrepareRetest(activity,case)
    activity.timingRetest=true;activity.timingTrackReplacements=true
    activity.batchRoute=case.route
    local method=case.method
    if method.choice=="dodge.26" and method.method~="Enter entangled gold mine" then
        -- These supports are useful in interactive training, but not in a
        -- standalone build/Detonate measurement. Their scope still owns them.
        for _,unit in ipairs(activity.supports) do
            if alive(unit) and (GetUnitTypeId(unit)==FourCC("egol") or GetUnitTypeId(unit)==FourCC("etol")) then RemoveUnit(unit) end
        end
        if case.route=="immediate_near_enemy" then
            SetUnitX(activity.caster,GetUnitX(activity.pawn)+128)
            SetUnitY(activity.caster,GetUnitY(activity.pawn))
        end
    end
    if method.method=="Build" then
        local offset=case.approach=="near" and 192 or 448
        local originX,originY=GetUnitX(activity.pawn),GetUnitY(activity.pawn)-offset
        for radius=0,768,128 do
            for dx=-radius,radius,128 do
                for dy=-radius,radius,128 do
                    if radius==0 or math.abs(dx)==radius or math.abs(dy)==radius then
                        local x,y=math.floor((originX+dx)/32+.5)*32,math.floor((originY+dy)/32+.5)*32
                        if Batch.BuildSiteClear(activity,x,y) then
                            activity.batchBuildSite={x=x,y=y}
                            SetUnitX(activity.pawn,x);SetUnitY(activity.pawn,y+offset)
                            return true
                        end
                    end
                end
            end
        end
        activity.batchSetupFailure="no clear build footprint"
        return false
    elseif method.ability=="Ashm" then
        -- Moving suppresses passive Shadowmeld until the scheduled ambush.
        IssuePointOrder(activity.pawn,"move",GetUnitX(activity.pawn),GetUnitY(activity.pawn)+2000)
    end
    return true
end
function Batch.SetInitialFacing(activity,method)
    local pawn,helper,target=activity.pawn,activity.helper,activity.target
    local function toward(unit,destination)
        if alive(unit) and alive(destination) and unit~=destination then
            local angle=math.atan(GetUnitY(destination)-GetUnitY(unit),GetUnitX(destination)-GetUnitX(unit))*180/math.pi
            BlzSetUnitFacingEx(unit,angle%360)
        end
    end
    if alive(pawn) then BlzSetUnitFacingEx(pawn,180) end
    if alive(target) then BlzSetUnitFacingEx(target,180) end
    toward(activity.caster,target)
    if pawn~=target then toward(pawn,target) end
    if helper~=target then toward(helper,target) end
    if method and alive(pawn) then
        if method.method=="Build" then BlzSetUnitFacingEx(pawn,270)
        elseif method.method=="Burrow loading" or method.choice=="dodge.23" or method.choice=="dodge.24" then toward(pawn,helper)
        elseif method.method=="Enter entangled gold mine" then
            for _,unit in ipairs(activity.supports) do if GetUnitTypeId(unit)==FourCC("egol") then toward(pawn,unit);break end end
        elseif method.ability=="AEbl" or method.choice=="dodge.40" or method.item=="clsd" then BlzSetUnitFacingEx(pawn,90)
        elseif method.ability=="ANcp" then toward(pawn,activity.caster) end
    end
end
function Batch.Action(activity,method)
    local pawn,helper=activity.pawn,activity.helper
    if not alive(pawn) then return false,"pawn unavailable" end
    local x,y=GetUnitX(pawn),GetUnitY(pawn)
    if method.item then
        local carrier=activity.definition.supportItem and helper or pawn
        if not alive(carrier) then return false,"item carrier unavailable" end
        local item
        for slot=0,5 do
            local candidate=UnitItemInSlot(carrier,slot)
            if candidate and GetItemTypeId(candidate)==FourCC(method.item) then item=candidate;break end
        end
        if not item then return false,"item unavailable" end
        if method.item=="clsd" then return IssueImmediateOrder(carrier,"stop"),"stop walking for passive cloak fade" end
        if activity.definition.supportItem then return UnitUseItemTarget(carrier,item,activity.target),"ally-targeted item" end
        if method.item=="stwp" then return UnitUseItemTarget(carrier,item,activity.home),"town portal" end
        return UnitUseItem(carrier,item),"self item"
    end
    if method.method=="Build" then
        -- The existing helper Burrow is north-east of the worker. A Great
        -- Hall north of him overlaps it; use a small native building south.
        local offset=activity.batchBuildOffset or (activity.definition.unit=="ewsp" and 384 or 192)
        local building=FourCC(activity.definition.unit=="opeo" and "otrb" or "emow")
        local site=activity.batchBuildSite
        local buildX,buildY=site and site.x or x,site and site.y or y-offset
        if activity.timingRetest then
            local clear,reason=Batch.BuildSiteClear(activity,buildX,buildY)
            JTG.Dev.DodgeTiming.Record(activity.timingRun,"build_site_check","player",pawn,"",
                "clear="..tostring(clear)..";reason="..reason..";x="..buildX..";y="..buildY,"native_snapshot")
            if not clear then return false,"build site blocked: "..reason end
        end
        local accepted=IssueBuildOrderById(pawn,building,buildX,buildY)
        if activity.timingRun then JTG.Dev.DodgeTiming.Record(activity.timingRun,"build_order_route","player",pawn,"",
            "IssueBuildOrderById="..tostring(accepted)..";x="..buildX..";y="..buildY,"automation") end
        if not accepted and activity.definition.unit=="ewsp" then
            accepted=IssuePointOrderById(pawn,building,buildX,buildY)
            if activity.timingRun then JTG.Dev.DodgeTiming.Record(activity.timingRun,"build_order_route","player",pawn,"",
                "IssuePointOrderById="..tostring(accepted),"automation") end
        end
        return accepted,"construction south "..offset
    elseif method.method=="Burrow loading" then
        return IssueTargetOrder(pawn,"smart",helper),"enter burrow"
    elseif method.method=="Enter entangled gold mine" then
        for _,unit in ipairs(activity.supports) do
            if GetUnitTypeId(unit)==FourCC("egol") then return IssueTargetOrder(pawn,"harvest",unit),"enter mine" end
        end
        return false,"entangled mine unavailable"
    elseif method.choice=="dodge.23" or method.choice=="dodge.24" then
        -- Current native Aco2/Aco3 are based on Acoi (coupletarget), not
        -- the older Acoa/Acoh mounting orders. Keep the legacy route otherwise.
        local current=GetUnitAbilityLevel(pawn,FourCC(method.choice=="dodge.23" and "Aco2" or "Aco3"))>0
        local order=current and "coupletarget" or (method.choice=="dodge.23" and "mounthippogryph" or "loadarcher")
        return IssueTargetOrder(pawn,order,helper),order
    elseif method.choice=="dodge.34" then return IssueTargetOrder(helper,"load",pawn),"zeppelin load"
    elseif method.choice=="dodge.40" then return IssuePointOrder(pawn,"move",x,y+600),"movement baseline" end
    local controller=activity.definition.supportAbilities and helper or pawn
    if not alive(controller) then return false,"ability controller unavailable" end
    if not method.order then return false,"no native order found" end
    if method.ability then BlzEndUnitAbilityCooldown(controller,FourCC(method.ability)) end
    if method.ability=="Aave" then
        return IssueImmediateOrder(controller,"avengerform"),"avengerform (native Aave order)"
    end
    if method.ability=="Adtn" and (not activity.timingRetest or activity.batchRoute=="point") then
        return IssuePointOrder(controller,"detonate",x,y),"detonate point at own position"
    end
    if method.ability=="AEbl" then return IssuePointOrder(controller,method.order,x,y+500),method.order end
    if method.ability=="ANcp" then return IssueTargetOrder(controller,method.order,activity.caster),method.order end
    if method.ability=="Aivs" or method.ability=="Aams" then
        return IssueTargetOrder(controller,method.order,activity.target),method.order
    end
    return IssueImmediateOrder(controller,method.order),method.order
end

function Batch.Stop(reason,showMenu)
    if not Batch.active then return end
    Batch.active=false
    if Batch.session and JTG.Controller.session==Batch.session then JTG.StopActivity("timing-batch-"..reason) end
    Batch.session=nil
    JTG.DisposeScope(Batch.scope);Batch.scope=nil
    JTG.Dev.DodgeTiming.Export()
    JTG.Dev.DodgeTiming.enabled=Batch.wasEnabled
    DisplayTimedTextToPlayer(PLAYER,0,0,20,"Timing batch "..reason..": "..#Batch.results.." / "..#Batch.plan.." trials. Observations exported.")
    if showMenu then JTG.UI.ShowCategory("skills") end
end

local function completeCase(status)
    local run=Batch.session and Batch.session.activity.timingRun
    if run then JTG.Dev.DodgeTiming.Record(run,"batch_case_end","",nil,"",status,"automation") end
    Batch.results[#Batch.results+1]={index=Batch.index,status=status}
    JTG.StopActivity("timing-batch-next");Batch.session=nil
    if #Batch.results%25==0 then JTG.Dev.DodgeTiming.Export() end
    Batch.gap=true
end

local function beginCase()
    Batch.index=Batch.index+1
    if Batch.index>#Batch.plan then Batch.Stop("complete",true);return end
    local case=Batch.plan[Batch.index]
    local danger=JTG.DodgeDangers[case.dangerIndex]
    local selection={dangerIndex=case.dangerIndex,pawnIndex=case.pawnIndex,stage=1,timingBatch=true}
    if case.mode=="baseline" then
        local weapon=(danger.targetTypes or ""):match("^(.-) / ") or danger.targetTypes or ""
        if danger.weapon==1 then weapon=(danger.targetTypes or ""):match(" / (.*)$") or weapon end
        local airOnly=weapon:find("air",1,true) and not weapon:find("ground",1,true)
        selection.movementUnit={unit=airOnly and "hgry" or "hfoo",name="Diagnostic baseline",abilities={}}
    end
    local ok,message=JTG.StartActivity("skills.missile_dodging","skills",selection)
    if not ok then
        Batch.results[#Batch.results+1]={index=Batch.index,status="setup_failed: "..tostring(message)}
        Batch.gap=true;return
    end
    Batch.session=JTG.Controller.session
    local activity=Batch.session.activity
    Batch.time=0;Batch.actionDone=false;Batch.actionAccepted=nil;Batch.enemyOrdered=false;Batch.anchor=nil;Batch.firstDamage=nil;Batch.constructionStarted=false;Batch.enemyStopped=false;Batch.launchAt=nil;Batch.flightTime=nil
    local run=activity.timingRun
    run.conditions=run.conditions..";batch="..Batch.index..";mode="..case.mode..";method="..(case.method and case.method.id or "none")
    if case.activationPass then
        run.conditions=run.conditions..";pass=activation;repetition="..case.repetition..";approach="..(case.approach or "ranged")
    end
    if case.metamorphPass then
        run.conditions=run.conditions..";pass=metamorph;repetition="..case.repetition..
            ";enemy_delay="..(case.enemyDelay or 0)..";flight_fraction="..(case.flightFraction or 0)
    end
    if case.retest then run.conditions=run.conditions..";retest=1;route="..case.route end
    JTG.Dev.DodgeTiming.Record(run,"batch_case_start","",nil,"",case.mode,"automation")
    -- A tower cannot walk the training's extra 200 units into attack range.
    -- Baselines use a stationary target already inside the native range.
    if (case.mode=="baseline" or case.metamorphPass) and not activity.arena and alive(activity.target) then
        local range=activity.testRange or activity.danger.range or 450
        SetUnitX(activity.caster,GetUnitX(activity.target)+math.max(64,range*(case.rangeFraction or 0.85)))
        SetUnitY(activity.caster,GetUnitY(activity.target))
        run.conditions=run.conditions..";baseline_distance="..(case.rangeFraction or 0.85).."*native_range;native_range="..range
    elseif case.mode=="isolated" and alive(activity.target) then
        SetUnitX(activity.caster,GetUnitX(activity.target)+400)
        SetUnitY(activity.caster,GetUnitY(activity.target))
    end
    if case.activationPass and case.method and approachMethod(case.method) then
        local near=case.approach=="near"
        if case.method.method=="Build" then activity.batchBuildOffset=near and 192 or 448
        elseif case.method.method=="Enter entangled gold mine" then
            for _,mine in ipairs(activity.supports) do
                if GetUnitTypeId(mine)==FourCC("egol") then
                    SetUnitX(activity.pawn,GetUnitX(mine)+BlzGetUnitCollisionSize(mine)+BlzGetUnitCollisionSize(activity.pawn)+(near and 32 or 320))
                    SetUnitY(activity.pawn,GetUnitY(mine));break
                end
            end
        elseif alive(activity.helper) then
            local gap=BlzGetUnitCollisionSize(activity.pawn)+BlzGetUnitCollisionSize(activity.helper)+(near and 32 or 320)
            if case.method.method=="Burrow loading" then
                SetUnitX(activity.pawn,GetUnitX(activity.helper));SetUnitY(activity.pawn,GetUnitY(activity.helper)-gap)
            else
                SetUnitX(activity.helper,GetUnitX(activity.pawn));SetUnitY(activity.helper,GetUnitY(activity.pawn)+gap)
            end
        end
    end
    local food=GetPlayerState(PLAYER,PLAYER_STATE_RESOURCE_FOOD_CAP)
    JTG.ScopeBorrow(Batch.session.scope,function() SetPlayerState(PLAYER,PLAYER_STATE_RESOURCE_FOOD_CAP,food) end)
    SetPlayerState(PLAYER,PLAYER_STATE_RESOURCE_FOOD_CAP,200)
    if case.retest then
        local ceiling=GetPlayerState(PLAYER,PLAYER_STATE_RESOURCE_FOOD_CAP_CEILING)
        JTG.ScopeBorrow(Batch.session.scope,function() SetPlayerState(PLAYER,PLAYER_STATE_RESOURCE_FOOD_CAP_CEILING,ceiling) end)
        SetPlayerState(PLAYER,PLAYER_STATE_RESOURCE_FOOD_CAP_CEILING,300)
        SetPlayerState(PLAYER,PLAYER_STATE_RESOURCE_FOOD_CAP,200)
        if not Batch.PrepareRetest(activity,case) then
            completeCase("setup_failed: "..activity.batchSetupFailure);return
        end
    end
    run.conditions=run.conditions..";diagnostic_food_cap=200"
    if Batch.index==1 or Batch.index%10==0 then
        DisplayTimedTextToPlayer(PLAYER,0,0,8,"Automatic timing batch: "..Batch.index.." / "..#Batch.plan)
    end
    -- Creep-style automatic combat must not decide when the diagnostic dodge fires.
    for _,unit in pairs({activity.pawn,activity.helper}) do
        if alive(unit) then UnitRemoveAbility(unit,FourCC("Aatk")) end
    end
    if case.metamorphPass then
        SetUnitMoveSpeed(activity.pawn,0)
        UnitRemoveAbility(activity.pawn,FourCC("AEev"))
        IssueImmediateOrder(activity.pawn,"holdposition")
    end
    PauseUnit(activity.caster,true)
    Batch.SetInitialFacing(activity,case.method)
    run.conditions=run.conditions..";initial_facing=instant_prealigned"
    for _,pair in ipairs({{"enemy",activity.caster},{"target",activity.target},{"player",activity.pawn},{"helper",activity.helper}}) do
        Batch.Snapshot(activity,pair[1],pair[2])
    end
    if case.retest then for _,unit in ipairs(activity.supports) do Batch.Snapshot(activity,"support",unit) end end
    if case.method and case.method.item=="clsd" and alive(activity.pawn) then
        -- The cloak is passive: keep moving until the scheduled Stop, rather
        -- than measuring an already-completed fade as if it were an item cast.
        IssuePointOrder(activity.pawn,"move",GetUnitX(activity.pawn),GetUnitY(activity.pawn)+2000)
    end
end

function Batch.Tick()
    if not Batch.active then return end
    if not JTG.Dev.DodgeTiming.enabled then Batch.Stop("recorder_disabled",true);return end
    if Batch.gap then Batch.gap=false;beginCase();return end
    if JTG.Controller.session~=Batch.session then Batch.Stop("interrupted",false);return end
    local activity=Batch.session.activity
    local case=Batch.plan[Batch.index]
    local run=activity.timingRun
    Batch.time=Batch.time+0.01;activity.trialTime=Batch.time
    if Batch.time<2 then return end -- let native initial morphs/summons settle
    for _,event in ipairs(run.events) do
        if event.event=="construction_start" then Batch.constructionStarted=true end
        if event.role=="enemy" and event.quality=="native_event" then
            local attack=activity.danger.kind=="attack" or activity.danger.orbOrder
            local wanted=case.mode=="cast_start_plus_0.10" and "cast_start" or "ability_effect"
            if attack then wanted="attack_start" end
            if event.event==wanted and not Batch.anchor then Batch.anchor=event.time end
        end
        if event.event=="damage" and not Batch.firstDamage then Batch.firstDamage=event.time end
    end
    if case.metamorphPass then
        local ranged=activity.danger.kind=="attack"
        for _,event in ipairs(run.events) do
            if event.role=="enemy" and event.quality=="native_event" and not Batch.launchAt and
                    event.event==(ranged and "attack_start" or "ability_effect") then
                local point=ranged and BlzGetUnitWeaponRealField(activity.caster,UNIT_WEAPON_RF_ATTACK_DAMAGE_POINT,activity.danger.weapon or 0) or 0
                Batch.launchAt=event.time+point
                local dx,dy=GetUnitX(activity.caster)-GetUnitX(activity.target),GetUnitY(activity.caster)-GetUnitY(activity.target)
                Batch.flightTime=math.sqrt(dx*dx+dy*dy)/math.max(1,activity.danger.missileSpeed or 0)
                JTG.Dev.DodgeTiming.Record(run,"projectile_schedule","enemy",activity.caster,"",
                    string.format("launch=%.5f;flight_estimate=%.5f;anchor=%s",Batch.launchAt,Batch.flightTime,
                        ranged and "estimated_attack_launch" or "native_spell_effect"),"automation")
            end
        end
    end
    local due=case.mode=="isolated" or case.mode=="before_order" or
        (Batch.anchor and TimerGetElapsed(run.clock)>=Batch.anchor+0.10)
    if case.metamorphPass then
        due=case.mode=="meta_before_order" or (case.mode=="meta_after_launch" and Batch.launchAt and
            TimerGetElapsed(run.clock)>=Batch.launchAt+(Batch.flightTime or 0)*(case.flightFraction or 0))
    end
    if case.method and due and not Batch.actionDone then
        Batch.actionDone=true
        if case.retest and case.method.ability=="Ashm" and IsUnitInvisible(activity.pawn,Player(1)) then
            completeCase("setup_failed: Shadowmeld already invisible at request");return
        end
        JTG.Dev.DodgeTiming.Record(run,"batch_dodge_request","",nil,case.method.ability or case.method.item,
            case.method.id,"automation")
        Batch.Snapshot(activity,"player",activity.pawn);Batch.Snapshot(activity,"target",activity.target)
        Batch.Snapshot(activity,"helper",activity.helper)
        local accepted,detail=Batch.Action(activity,case.method)
        Batch.actionAccepted=accepted
        JTG.Dev.DodgeTiming.Record(run,"batch_dodge_order","",nil,case.method.ability or case.method.item,
            tostring(accepted)..":"..tostring(detail),"automation")
    end
    local enemyDue=(case.mode~="before_order" or Batch.time>=2.15)
    if case.mode=="meta_before_order" then enemyDue=Batch.time>=2+(case.enemyDelay or 0) end
    if case.mode~="isolated" and not Batch.enemyOrdered and enemyDue then
        Batch.Snapshot(activity,"enemy",activity.caster);Batch.Snapshot(activity,"target",activity.target)
        JTG.Dev.DodgeTiming.Record(run,"batch_enemy_request","enemy",activity.caster,"","","automation")
        PauseUnit(activity.caster,false)
        activity:tryAttack()
        Batch.enemyOrdered=activity.attempts>0
        if Batch.enemyOrdered then JTG.Dev.DodgeTiming.Record(run,"batch_enemy_order","enemy",activity.caster,"",tostring(activity.accepted),"automation") end
    end
    if case.metamorphPass and Batch.launchAt and not Batch.enemyStopped and
            TimerGetElapsed(run.clock)>=Batch.launchAt+0.03 then
        Batch.enemyStopped=true
        IssueImmediateOrder(activity.caster,"stop")
        JTG.Dev.DodgeTiming.Record(run,"single_shot_stop","enemy",activity.caster,"","","automation")
    end
    if case.metamorphPass then
        if Batch.time>=8 then
            local status=not Batch.launchAt and "no_launch_observed" or
                (case.method and not Batch.actionDone) and "dodge_not_requested" or
                (case.method and not Batch.actionAccepted) and "action_rejected" or
                Batch.firstDamage and "damage_event_observed" or "launched_without_damage_event"
            completeCase(status)
        end
        return
    end
    if case.mode=="isolated" and Batch.time>=(case.activationPass and 10 or 9) then
        if not Batch.actionAccepted then completeCase("action_rejected")
        elseif case.method.method=="Build" then completeCase(Batch.constructionStarted and "construction_started" or "construction_not_started")
        else completeCase("isolated_observations") end
    elseif case.mode=="baseline" and activity.danger.menuGroup~="Area" and Batch.firstDamage and TimerGetElapsed(run.clock)>=Batch.firstDamage+0.5 then
        completeCase("damage_observed")
    elseif Batch.time>=math.max(14,math.min(30,activity.danger.resolveWindow or 0)) then
        completeCase(Batch.anchor and "observations_complete" or "no_matching_enemy_event")
    end
end

function Batch.Start(smoke,activation,retest,metamorph)
    if Batch.active then return end
    Batch.wasEnabled=JTG.Dev.DodgeTiming.enabled
    JTG.Dev.DodgeTiming.enabled=true
    Batch.plan=metamorph and Batch.MetamorphPlan() or retest and Batch.RetestPlan() or (activation and Batch.ActivationPlan() or Batch.Plan(smoke))
    Batch.results={};Batch.index=0;Batch.active=true;Batch.gap=true
    Batch.scope=JTG.CreateScope("dev:dodge-timing-batch")
    -- This driver deliberately survives individual activity sessions, but has
    -- its own scope and stops if another activity replaces the current trial.
    local timer=JTG.ScopeTrackTimer(Batch.scope,CreateTimer())
    TimerStart(timer,0.01,true,function()
        local ok,message=pcall(Batch.Tick)
        if not ok then print("Timing batch error: "..tostring(message));Batch.Stop("error",true) end
    end)
    -- A command issued from a paused configuration menu must release that pause.
    JTG.UI.SetGameplayMenuPaused(false);JTG.UI.SetExercisePaused(false)
    DisplayTimedTextToPlayer(PLAYER,0,0,15,"Automatic timing batch starting: "..#Batch.plan.." trials. Use -timing-stop to stop and export.")
end

JTG.RegisterBootstrapInitializer(function()
    local descriptor=JTG.Registry.byId["skills.missile_dodging"]
    local factory=descriptor.factory
    descriptor.factory=function(session)
        local activity=factory(session)
        if session.restartData and session.restartData.timingBatch then
            -- Normal training scoring is not used as a measurement or allowed
            -- to restart a diagnostic trial before its observation window ends.
            activity.verdict=function() end
            activity.resetAfterHit=function() end
            activity.start=function() end
        end
        return activity
    end
    local trigger=CreateTrigger()
    for _,command in ipairs({"-timing-batch","-timing-smoke","-timing-activation","-timing-retest","-timing-metamorph","-timing-stop"}) do TriggerRegisterPlayerChatEvent(trigger,PLAYER,command,true) end
    TriggerAddAction(trigger,function()
        local command=GetEventPlayerChatString()
        if command=="-timing-stop" then Batch.Stop("stopped",true)
        else Batch.Start(command=="-timing-smoke",command=="-timing-activation",command=="-timing-retest",command=="-timing-metamorph") end
    end)
end)
