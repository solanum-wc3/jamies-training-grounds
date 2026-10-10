-- Run after test-training-orders.lua and test-dodging-lifecycle.lua.
-- Checks revised menu eligibility and native-order orchestration, not game physics.
for raw,range in pairs({echm=450,hgyr=100,etrp=700}) do
    local found=false
    for _,danger in ipairs(JTG.DodgeDangers) do
        if danger.unit==raw and danger.menuGroup=='Ranged' then
            assert(danger.weapon==1 and danger.range==range,raw..': wrong ranged weapon/range')
            found=true
        end
    end
    assert(found,raw..': missing ranged entry')
end
local screen,selection,result
JTG.Controller.session=nil
JTG.UI.ShowActivityBriefing=function(spec) screen=spec end
JTG.UI.ShowResultCard=function(_,spec) result=spec end
JTG.StartActivityAfterCleanup=function(_,_,state) selection=state end
local columns=JTG.GetSurroundCustomRaceColumns
JTG.GetSurroundCustomRaceColumns=function(race)
    if race=='human' then return {{{rawcode='hmtn',label='Siege Engine'},{rawcode='hgry',label='Gryphon Rider'}}} end
    if race=='nightelf' then return {{{rawcode='Edem',label='Demon Hunter'}}} end
    if race=='orc' then return {{{rawcode='o001',label='Serpent Ward 1'},{rawcode='o002',label='Serpent Ward 2'},{rawcode='o003',label='Serpent Ward 3'}}} end
    if race=='neutral' then return {{{rawcode='nqb1',label='Quillbeast 1'},{rawcode='nqb2',label='Quillbeast 2'},{rawcode='nqb3',label='Quillbeast 3'},{rawcode='nwe1',label='Hawk 1'},{rawcode='nwe2',label='Hawk 2'},{rawcode='nwe3',label='Hawk 3'},{rawcode='nlv1',label='Lava Spawn 1'},{rawcode='nlv2',label='Lava Spawn 2'},{rawcode='nlv3',label='Lava Spawn 3'}}} end
    return {{{rawcode='hwat',label='Water Elemental 1'},{rawcode='hwt2',label='Water Elemental 2'},{rawcode='hwt3',label='Water Elemental 3'},
        {rawcode='hmtn',label='Siege Engine'},{rawcode='umtw',label='Meat Wagon'},{rawcode='ebal',label='Glaive Thrower'},{rawcode='ubsp',label='Destroyer'}}}
end
for _,raceIndex in ipairs({2,5}) do
    JTG.OpenMissileDodgingMenu('skills',false); screen.choices[1].action(); screen.choices[2].action(); screen.choices[raceIndex].action()
    for _,choice in ipairs(screen.choices) do
        if choice.label=='Hawk 1' then
            assert(not choice.enabled and choice.tooltip==nil)
        else
            assert(choice.enabled,choice.label)
            assert(not choice.tooltip:find(choice.label,1,true),'Names belong only in the headline')
            assert(choice.tooltip:find('Attack range:',1,true) and choice.tooltip:find('Projectile Speed:',1,true))
        end
    end
end
JTG.OpenMissileDodgingMenu('skills',false); screen.choices[1].action(); screen.choices[2].action(); screen.choices[4].action()
local demon=screen.choices[1]
assert(demon.enabled and demon.unitRawcode=='Edmm' and demon.icon:find('BTNMetamorphosis',1,true))
assert(demon.tooltip:find('600',1,true) and demon.tooltip:find('900',1,true) and demon.tooltip:find('0.26',1,true))
demon.action()
JTG.OpenMissileDodgingMenu('skills',false); screen.choices[1].action(); screen.choices[2].action(); screen.choices[1].action()
assert(screen.choices[1].enabled)
screen.choices[1].action()
local count=0
for _,choice in ipairs(screen.choices) do
    local allowed=choice.unitRawcode=='ehip' or choice.unitRawcode=='ehpr' or choice.unitRawcode=='edot'
    assert(choice.enabled==allowed,choice.label)
    if allowed then count=count+1 end
    if choice.unitRawcode=='edot' then choice.action() end
end
assert(count==3)
assert(selection and selection.startDelay)
local orders={}
local oldImmediate,oldTarget=IssueImmediateOrder,IssueTargetOrder
function IssueImmediateOrder(unit,order) orders[#orders+1]={unit,order}; unit.order=order; return true end
function IssueTargetOrder(unit,order,target) orders[#orders+1]={unit,order,target}; unit.order=order; return true end
local function session(state)
    return {restartData=state,scope={},presentationScope={},scene={centerX=0,centerY=0},descriptor={capabilities={}}}
end
local talonSession=session(selection)
local talon=JTG.CreateMissileDodgingActivity(talonSession); talon:setup(talonSession)
local transformed=false
for _,order in ipairs(orders) do if order[1]==talon.pawn and order[2]=='ravenform' then transformed=true end end
assert(transformed and talon.danger.unit=='hrtt')
JTG.OpenMissileDodgingMenu('skills',false); screen.choices[2].action(); screen.choices[2].action(); screen.choices[1].action(); screen.choices[1].action()
for _,choice in ipairs(screen.choices) do assert(not choice.enabled,choice.label..' must be excluded from Devour') end
JTG.GetSurroundCustomRaceColumns=columns

local indices={}
for i,danger in ipairs(JTG.DodgeDangers) do
    if danger.menuGroup=='Artillery' then indices[danger.unit]=i end
    if danger.ability=='Adev' then indices.devour=i end
end
local mortar=JTG.DodgeDangers[indices.hmtm]
assert(mortar.name=='Mortar Team' and mortar.icon:find('BTNMortarTeam',1,true))
local tech={}
function GetPlayerTechCount(owner,raw) return tech[owner..raw] or 2 end
function SetPlayerTechResearched(owner,raw,level) tech[owner..raw]=level end
local oldRange=BlzGetUnitWeaponRealField
function BlzGetUnitWeaponRealField() return 1800 end
local artillerySession=session({dangerIndex=indices.ocat})
local artillery=JTG.CreateMissileDodgingActivity(artillerySession); artillery:setup(artillerySession)
assert(artillery.arenaHalf==1800 and artillery.arenaInner==artillery.danger.minRange)
assert(tech['1Rolf']==0,'Burning Oil must be disabled')
for i=#artillerySession.scope,1,-1 do artillerySession.scope[i]() end
assert(tech['1Rolf']==2,'Burning Oil must be restored on cleanup')
BlzGetUnitWeaponRealField=oldRange

local triggers={}
function CreateTrigger() local trigger={events={}}; triggers[#triggers+1]=trigger; return trigger end
local randomReal=GetRandomReal
function GetRandomReal(low,high) return low end
local devourSession=session({dangerIndex=indices.devour,movementUnit={unit='hfoo',name='Footman',abilities={}}})
local devour=JTG.CreateMissileDodgingActivity(devourSession); devour:setup(devourSession)
devour:tryAttack()
assert(devour.devourRetryAt==2 and devour.devourMoveAt==0.5)
devour:resetAfterHit(); assert(not devour.resetPending and not devour.finished)
function GetTriggerUnit() return devour.caster end
function GetSpellAbilityId() return 'Adev' end
function GetTriggerEventId() return EVENT_PLAYER_UNIT_SPELL_ENDCAST end
local castStopped,castEffect
for _,trigger in ipairs(triggers) do
    for _,event in ipairs(trigger.events) do
        if event[1]==1 and event[2]==EVENT_PLAYER_UNIT_SPELL_ENDCAST then castStopped=trigger.action end
        if event[1]==1 and event[2]==EVENT_PLAYER_UNIT_SPELL_EFFECT then castEffect=trigger.action end
    end
end
devour.trialTime=1; castStopped()
assert(devour.devourRetryAt==2,'Endcast must not alter the command schedule')
local attempts=devour.attempts
devour.trialTime=1.8; devour:tryAttack(); assert(devour.attempts==attempts)
devour.trialTime=2; devour:tryAttack(); assert(devour.attempts==attempts+1 and devour.caster.order=='devour')
devour.feedback={text='WELL DONE!'}
function BlzFrameSetText(frame,text) frame.text=text end
devour:hidePresentationForMenu(); assert(devour.feedback.text=='' and devour.flashUntil==nil)
devour.presentationVisible=true
devour.trialTime=14.96; devour:updateTrial()
assert(devour.finished and result.title=='DODGE SUCCESSFUL' and result.actions.next==nil)
local eaten=JTG.CreateMissileDodgingActivity(devourSession)
local scopedTimer=JTG.StartScopedTimer
local eatenTimer
JTG.StartScopedTimer=function(...)
    eatenTimer=scopedTimer(...); return eatenTimer
end
eaten.caster=devour.caster; eaten:finishDevour(true)
assert(eaten.finished and eaten.devourEaten and not eaten.devourResultReady)
assert(eatenTimer.period==1)
eatenTimer.callback()
assert(eaten.devourResultReady and result.title=='DODGE FAILED')
-- Confirm the real native effect path invokes the same failure result.
devour.finished=false
castEffect(); assert(not devour.finished and devour.devourEffectSeen)
local wasHidden=IsUnitHidden
function IsUnitHidden(unit) return unit==devour.target end
devour:updateTrial(); assert(devour.finished and devour.devourEaten)
IsUnitHidden=wasHidden
JTG.StartScopedTimer=scopedTimer
GetRandomReal=randomReal
IssueImmediateOrder,IssueTargetOrder=oldImmediate,oldTarget
print('Passed: Ranged summon choices, Siege Engine eligibility and pre-GO transformation, Devour exclusions, Mortar tooltip artwork, native artillery range, Burning Oil restoration, command-based retry deadlines, 15-second survival, eating failure and menu feedback clearing.')

local oldCollision=BlzGetUnitCollisionSize
function BlzGetUnitCollisionSize(unit) return unit==devour.caster and 48 or 31 end
devour:updateDevourCircle()
assert(devour.devourRadius==179,'Devour range includes caster and target collision radii')
BlzGetUnitCollisionSize=oldCollision
local fades={['Blademaster']=0.6,['Shadowmeld']=1.5,['Cloak of Shadows']=1.5,['Sorceress: Invisibility']=0}
for _,entry in ipairs(JTG.DodgePawns) do
    if fades[entry.name] then assert(entry.fadeDuration==fades[entry.name]) end
    if entry.name=='Potion of Invisibility' then assert(entry.fadeUnknown and not entry.fadeDuration) end
end
print('Passed: all Lava Spawn levels, ranged attack stats, Devour collision-adjusted radius and verified invisibility fade fields.')

local deathCoil,ensnare
for dangerIndex,danger in ipairs(JTG.DodgeDangers) do
    if danger.ability=='AUdc' then deathCoil=danger end
    if danger.ability=='Aens' then ensnare=danger end
    if danger.orbOrder then
        assert(JTG.DodgeInvalidTargetReason(danger,{unit='efdr'})=='Not targetable.')
        JTG.OpenMissileDodgingMenu('skills',false,'abilities',{dangerIndex=dangerIndex})
        local foundBanshee=false
        for _,choice in ipairs(screen.choices) do
            if choice.unitRawcode=='uban' then foundBanshee=true;assert(not choice.enabled) end
        end
        assert(foundBanshee,'Orb picker must retain the disabled Banshee')
    end
end
assert(JTG.DodgeInvalidTargetReason(deathCoil,{unit='efdr'})=='Not targetable.')
assert(not JTG.DodgeInvalidTargetReason(ensnare,{unit='efdr'}))
local removeAbility=UnitRemoveAbility
local targetOrder=IssueTargetOrder
function IssueTargetOrder(unit,order,target) unit.order=order; return true end
local removed={}
function UnitRemoveAbility(unit,id) removed[id]=true; return removeAbility(unit,id) end
for index,danger in ipairs(JTG.DodgeDangers) do
    if danger.menuGroup=='Ranged' and (danger.unit=='osp1' or danger.unit=='edtm') then
        for stage=1,3 do
            local current=session({dangerIndex=index,stage=stage})
            local activity=JTG.CreateMissileDodgingActivity(current)
            activity:setup(current)
            if danger.unit=='osp1' then
                assert(activity.caster.x-activity.target.x==activity.testRange*(stage==3 and 0.5 or 1))
                assert(not activity.halfApproach,'Stationary attackers cannot approach')
                activity:tryAttack(); assert(activity.caster.order=='attack')
            end
        end
    end
end
assert(removed.Afae and removed.Afa2,'Both Faerie Fire variants must be disabled')
UnitRemoveAbility=removeAbility
IssueTargetOrder=targetOrder
print('Passed: stationary attacker range in all stages, attack-only ward commands, both Faerie Fire variants and native Faerie Dragon target restrictions.')
