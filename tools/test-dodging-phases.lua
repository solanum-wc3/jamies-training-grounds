-- Run after the standard Dodging lifecycle/revision tests.
local session={restartData={pawnIndex=1},scope={},presentationScope={}}
local a=JTG.CreateMissileDodgingActivity(session)
a.pawn={id='Obla',owner=0,x=0,y=0};a.target=a.pawn;a.caster={id='Hmkg',owner=1,x=400,y=0}
local oldAdd,oldUnit,oldEvent,oldInvisible,oldColor=TriggerAddAction,GetTriggerUnit,GetTriggerEventId,IsUnitInvisible,SetUnitVertexColor
local action,currentUnit,currentEvent,invisible
local oldSpell,oldHidden,oldInvulnerable,oldFrameText=GetSpellAbilityId,IsUnitHidden,BlzIsUnitInvulnerable,BlzFrameSetText
local currentSpell='AOwk'
function GetSpellAbilityId() return currentSpell end
function IsUnitHidden(u) return u.hidden==true end
function BlzIsUnitInvulnerable(u) return u.invulnerable==true end
function BlzFrameSetText(frame,text) frame.text=text end
function TriggerAddAction(t,fn) oldAdd(t,fn);action=fn end
function GetTriggerUnit() return currentUnit end
function GetTriggerEventId() return currentEvent end
function IsUnitInvisible() return invisible==true end
function SetUnitVertexColor(u,r,g,b) u.tint={r,g,b} end
a:setupPhases(session)
local function emit(unit,event,spell) currentUnit,currentEvent=unit,event;currentSpell=spell or currentSpell;action() end
assert(a.enemyPhase=='waiting' and a.caster.tint[1]==255 and a.dodgePhase=='ready')
emit(a.caster,EVENT_PLAYER_UNIT_SPELL_CHANNEL);assert(a.enemyPhase=='windup' and a.caster.tint[2]==75)
emit(a.caster,EVENT_PLAYER_UNIT_SPELL_EFFECT);assert(a.enemyPhase=='fired' and a.caster.tint[2]==255)
emit(a.caster,EVENT_PLAYER_UNIT_SPELL_ENDCAST);assert(a.enemyPhase=='fired')
emit(a.caster,EVENT_PLAYER_UNIT_SPELL_CHANNEL);emit(a.caster,EVENT_PLAYER_UNIT_SPELL_ENDCAST);assert(a.enemyPhase=='waiting')
emit(a.pawn,EVENT_PLAYER_UNIT_SPELL_CHANNEL);assert(a.dodgePhase=='windup')
emit(a.pawn,EVENT_PLAYER_UNIT_SPELL_EFFECT);assert(a.dodgePhase=='activating' and a.pawn.tint[2]==220)
emit(a.pawn,EVENT_PLAYER_UNIT_SPELL_ENDCAST);assert(a.dodgePhase=='activating')
a:updateDodgePhase();assert(a.dodgePhase=='activating')
invisible=true;a:updateDodgePhase();assert(a.dodgePhase=='active' and a.pawn.tint[2]==255)
invisible=false;a:updateDodgePhase();assert(a.dodgePhase=='ready')
local area
for _,d in ipairs(JTG.DodgeDangers) do if d.ability=='AOsh' then area=d end end
assert(JTG.DodgeInvalidTargetReason(area,{unit='hgry'}))
for _,d in ipairs(JTG.DodgeDangers) do if d.ability=='AUcs' then assert(not JTG.DodgeInvalidTargetReason(d,{unit='hgry'})) end end
assert(JTG.DodgeStats(area):find('Area:',1,true))
assert(not JTG.DodgeStats(a.definition,true):find('Projectile Speed:',1,true))
assert(a.definition.castPoint==0 and a.definition.fadeDuration==0.6)
a.status={}
a:refreshStatus();assert(a.status.text:find('|cff5aff6eready|r',1,true))
assert(a.status.text:find('|r  -  ',1,true),'Status separator must be plain ASCII')
emit(a.pawn,EVENT_PLAYER_UNIT_SPELL_CHANNEL,'AOmi')
assert(a.status.text:find('|cffff4b4bwindup|r',1,true) and a.pawn.tint[2]==75)
emit(a.pawn,EVENT_PLAYER_UNIT_SPELL_EFFECT,'AOmi')
assert(a.dodgePhase=='activating','Mirror Image must wait for its hidden/protected state')
a.pawn.hidden=true;a:updateDodgePhase();assert(a.dodgePhase=='active')
a.pawn.hidden=false;a:updateDodgePhase();assert(a.dodgePhase=='ready')
a.pawn.id='uobs'
emit(a.pawn,EVENT_PLAYER_UNIT_SPELL_CHANNEL,'Aave')
a.pawn.id='ubsp';emit(a.pawn,EVENT_PLAYER_UNIT_SPELL_EFFECT,'Aave')
assert(a.dodgePhase=='active','Immediate morph is compared with the type before its effect')
a.pawn.id='Edem'
emit(a.pawn,EVENT_PLAYER_UNIT_SPELL_CHANNEL,'AEme');emit(a.pawn,EVENT_PLAYER_UNIT_SPELL_EFFECT,'AEme')
assert(a.dodgePhase=='activating')
a.pawn.id='Edmm';a:updateDodgePhase();assert(a.dodgePhase=='active')
emit(a.pawn,EVENT_PLAYER_UNIT_SPELL_CHANNEL,'Afa2')
emit(a.pawn,EVENT_PLAYER_UNIT_SPELL_EFFECT,'Afa2')
assert(a.dodgePhase=='active','An unrelated automatic spell must not overwrite the dodge phase')
emit(a.pawn,EVENT_PLAYER_UNIT_SPELL_CHANNEL,'AItp')
a.pawn.invulnerable=true;a:updateDodgePhase()
assert(a.dodgePhase=='active','Town Portal protection starts before the teleport effect')
a.pawn.invulnerable=false;emit(a.pawn,EVENT_PLAYER_UNIT_SPELL_EFFECT,'AItp')
assert(a.dodgePhase=='ready')
emit(a.pawn,EVENT_PLAYER_UNIT_SPELL_CHANNEL,'AEbl');emit(a.pawn,EVENT_PLAYER_UNIT_SPELL_EFFECT,'AEbl')
assert(a.dodgePhase=='activating')
a.pawn.x=500;a:updateDodgePhase();assert(a.dodgePhase=='active')
local function resolutionFixture()
    local test=JTG.CreateMissileDodgingActivity(session)
    test.pawn={id='ewsp',owner=0,x=0,y=0};test.target=test.pawn;test.caster=a.caster
    test.castConfirmed=true;test.castTime=0;test.resolveAfter=0
    test.definition={unit='ewsp',mine=true};test.verdict=function(self,text) self.testVerdict=text end
    return test
end
local loading=resolutionFixture();loading.pawn.hidden=true;loading.phaseKind='loading'
loading:updateTrial();assert(loading.testVerdict=='WELL DONE!','Loaded units must still reach resolution')
local removal=resolutionFixture();removal.pawn.dead=true;removal.phaseKind='removal';removal.phaseDodgeEffect=true
removal:updateDodgePhase();removal:updateTrial()
assert(removal.dodgeReplaced and removal.testVerdict=='WELL DONE!','Intentional removal must not reset before missile resolution')
for _,entry in ipairs(JTG.DodgePawns) do
    if entry.unit=='uobs' then assert(JTG.DodgeStats(entry,true)=='Cast Point: Instant') end
    if entry.item=='pinv' then assert(JTG.DodgeStats(entry,true):find('1.95',1,true)) end
    if entry.unit=='earc' then assert(JTG.DodgeStats(entry,true)=='Cast Point: Instant') end
end
TriggerAddAction,GetTriggerUnit,GetTriggerEventId,IsUnitInvisible,SetUnitVertexColor=oldAdd,oldUnit,oldEvent,oldInvisible,oldColor
GetSpellAbilityId,IsUnitHidden,BlzIsUnitInvulnerable,BlzFrameSetText=oldSpell,oldHidden,oldInvulnerable,oldFrameText
print('Passed: cast-driven enemy colours, cancellation, Wind Walk fade-driven colours, area targeting and contextual timing tooltips.')

-- Spell descriptions and target restrictions reflect the player-facing categories.
for _,d in ipairs(JTG.DodgeDangers) do
    assert(d.ability~='Adsm')
    local stats=JTG.DodgeStats(d)
    assert(not stats:find('native area value',1,true) and not stats:find('None',1,true))
    if d.ability=='AUim' then assert(stats:find('Projectile Speed: Instant',1,true)) end
    if d.ability=='AOsh' then assert(stats:find('Area: 125 units wide',1,true)) end
    if d.ability=='ANcs' then assert(stats:find('Area: 200 units radius on lvl 1',1,true)) end
    if d.ability=='Auco' then
        for _,raw in ipairs({'ehip','ehpr','edot','edtm','ugar'}) do
            assert(not JTG.DodgeInvalidTargetReason(d,{unit=raw}),raw)
        end
        assert(JTG.DodgeInvalidTargetReason(d,{unit='hgry'}))
    end
end
print('Passed: instant Impale, explicit area geometry, Concoction targets and removed Storm Spirit Dispel.')

-- Projectile-only advice, including Burrow, follows presentation visibility.
local savedHintVisible,savedHintText=BlzFrameSetVisible,BlzFrameSetText
function BlzFrameSetVisible(frame,value) frame.visible=value end
function BlzFrameSetText(frame,text) frame.text=text end
local hintActivity=JTG.CreateMissileDodgingActivity({restartData={pawnIndex=1},scope={},presentationScope={}})
hintActivity.methodHint={}
hintActivity.danger={menuGroup='Homing'}
for _,definition in ipairs({{category='Invisibility',unit='ucry'},
    {category='Invisibility',unit='ucs2'},{category='Invisibility',unit='Obla'},
    {unit='Ntin',item='pinv'},{unit='Ntin',item='clsd'}}) do
    hintActivity.definition=definition
    hintActivity:refreshMethodHint()
    assert(hintActivity.methodHint.visible and hintActivity.methodHint.text=='This ability might not be able to dodge the projectile on reflex. However, your unit might be safe after the initial damage.')
end
hintActivity.presentationVisible=false;hintActivity:refreshMethodHint();assert(not hintActivity.methodHint.visible)
hintActivity.presentationVisible=true;hintActivity.finished=true;hintActivity:refreshMethodHint();assert(not hintActivity.methodHint.visible)
hintActivity.finished=false;hintActivity.danger.menuGroup='Area';hintActivity:refreshMethodHint();assert(not hintActivity.methodHint.visible)
hintActivity.danger.menuGroup='Ranged';hintActivity.definition={unit='Hpal',category='Invulnerability'}
hintActivity:refreshMethodHint();assert(not hintActivity.methodHint.visible)
print('Passed: invisibility/Burrow projectile advice and menu/result/non-projectile visibility guards.')

BlzFrameSetVisible,BlzFrameSetText=savedHintVisible,savedHintText
