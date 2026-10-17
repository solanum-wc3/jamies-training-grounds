JTG={}
PLAYER_NEUTRAL_PASSIVE,UNIT_TYPE_STRUCTURE=15,'structure'
function Player(id) return id end
function FourCC(raw) return raw end
local map,live={},{}
local clearBlightOnTerrainWrite=false
local timers={}
function CreateTimer() local timer={};timers[#timers+1]=timer;return timer end
function TimerStart(timer,delay,repeating,fn)
 assert((delay==0 or delay==.5 or delay==.1) and not repeating)
 timer.fn=fn;timer.pending=true
end
function PauseTimer(timer) timer.pending=false end
function DestroyTimer(timer) timer.destroyed=true end
local function tick()
 local ready={}
 for _,timer in ipairs(timers) do if timer.pending then ready[#ready+1]=timer end end
 for _,timer in ipairs(ready) do timer.pending=false;timer.fn() end
end
local function at(x,y)
 local id=x..':'..y
 map[id]=map[id] or {kind='grass',variation=(x+y)%3,blight=x==0 and y==0}
 return map[id]
end
FOG_OF_WAR_MASKED,FOG_OF_WAR_FOGGED,FOG_OF_WAR_VISIBLE='masked','fogged','visible'
bj_mapInitialPlayableArea={world=true}
local fog,modifiers,remembered={}, {},{}
local fogDefault='masked'
local delayedSight=false
local function fogKey(x,y) return (math.floor(x/128)*128)..':'..(math.floor(y/128)*128) end
function IsMaskedToPlayer(x,y) return (fog[fogKey(x,y)] or fogDefault)=='masked' end
function IsFoggedToPlayer(x,y)
 local state=fog[fogKey(x,y)] or fogDefault
 return state=='fogged' or (delayedSight and state=='visible')
end
function FogEnable(value) assert(value==true,'Refresh disabled global fog') end
function FogMaskEnable(value) assert(value==true,'Refresh disabled black mask') end
function SetFogStateRect(_,state,area,shared)
 if area.world then fog={};fogDefault=state;return end
 assert(shared==false and (state=='fogged' or state=='visible'),'Unexpected refresh fog policy')
 for x=area.x1,area.x2,128 do for y=area.y1,area.y2,128 do
  if state=='visible' then
   assert(not IsMaskedToPlayer(x,y),'Immediate refresh revealed unexplored terrain')
   remembered[fogKey(x,y)]=at(x,y).blight
  end
  fog[fogKey(x,y)]=state
 end end
end
function CreateFogModifierRect(_,state,area,shared,afterUnits)
 assert(state=='visible' and not shared and not afterUnits)
 local modifier={area=area};modifiers[#modifiers+1]=modifier;return modifier
end
function FogModifierStart(modifier)
 modifier.active=true
 local area=modifier.area
 for x=area.x1,area.x2,128 do for y=area.y1,area.y2,128 do
  assert(not IsMaskedToPlayer(x,y),'Cleanup revealed unexplored terrain')
  -- Model alpha23's native export: starting a short-lived modifier alone
  -- need not establish visibility before the modifier is stopped.
 end end
end
function FogModifierStop(modifier) modifier.active=false end
function DestroyFogModifier(modifier) modifier.destroyed=true end
function GetWorldBounds() return {} end
function GetRectMinX() return -4096 end
function GetRectMinY() return -4096 end
function GetRectMaxX() return 4096 end
function GetRectMaxY() return 4096 end
function RemoveRect() end
function IsPointBlighted(x,y) return at(x,y).blight end
function GetTerrainType(x,y) return at(x,y).kind end
function GetTerrainVariance(x,y) return at(x,y).variation end
function SetTerrainType(x,y,kind,variation,area,shape)
 assert(area==1 and shape==0)
 local cell=at(x,y);cell.kind=kind;cell.variation=variation
 if clearBlightOnTerrainWrite then cell.blight=false end
end
function SetBlightPoint(_,x,y,value)
 -- Point edits can touch neighbouring saved samples; model a 512-unit patch
 -- instead of pretending the native changes just one 128-unit terrain cell.
 for dx=-128,256,128 do for dy=-128,256,128 do at(x+dx,y+dy).blight=value end end
end
local rectangles=0
function Rect(x1,y1,x2,y2) rectangles=rectangles+1;return {x1=x1,y1=y1,x2=x2,y2=y2} end
function SetBlightRect(_,area,value)
 assert(area.x2-area.x1==127 and area.y2-area.y1==127,'Blight write escapes the saved cell')
 at(area.x1,area.y1).blight=value
end
function IsUnitIdType(raw) return raw=='ugrv' or raw=='htow' end
function GetUnitAbilityLevel(u,raw) return u.raw=='ugrv' and raw=='Abgs' and 1 or 0 end
function GetOwningPlayer(u) return not u.removed and u.owner or nil end
function CreateUnit(owner,raw,x,y)
 local u={owner=owner,raw=raw,x=x,y=y};live[u]=true
 if raw=='ugrv' then at(x,y).blight=true;at(x,y).kind='damaged' end
 return u
end
function RemoveUnit(u)
 live[u]=nil;u.removed=true
 if u.raw=='ugrv' then at(u.x,u.y).blight=true end -- final native terrain update
end
dofile('src/infrastructure/core.lua')
dofile('src/infrastructure/terrain.lua')
local one,two=JTG.CreateScope('one'),JTG.CreateScope('two')
local alreadyRemoved=JTG.CreateScope('manually-removed')
local retired=JTG.CreateScopedUnit(alreadyRemoved,0,'htow',-256,-256,0)
RemoveUnit(retired)
assert(JTG.DisposeScope(alreadyRemoved),'Already-removed actor made terrain ownership cleanup fail')
local a=JTG.CreateScopedUnit(one,0,'ugrv',128,128,0)
local b=JTG.CreateScopedUnit(two,15,'ugrv',256,128,0)
a.owner=6 -- native ownership can change after the snapshot
JTG.DisposeScope(one)
assert(a.removed and not b.removed and at(128,128).blight,
 'One scope erased terrain still leased by another live display')
JTG.DisposeScope(two)
assert(b.removed and not at(128,128).blight and not at(256,128).blight)
assert(at(128,128).kind=='grass' and at(128,128).variation==256%3)
assert(at(0,0).blight,'Original map blight was erased')
tick();tick()
local scene=JTG.CreateScope('scene')
local c=JTG.CreateScopedUnit(scene,0,'ugrv',128,128,0)
local clear=JTG.ScopePreserveTerrain(scene,0,128,128,512)
clear();assert(not at(128,128).blight,'Explicit early clear did not restore baseline')
at(128,128).blight=true -- a live building spreads again before removal
JTG.DisposeScope(scene)
assert(c.removed and not at(128,128).blight,'Cleanup happened before the spreading source was removed')
at(128,128).blight=true -- engine update arriving after RemoveUnit returns
tick();assert(not at(128,128).blight,'Next-tick native blight was not restored')
at(128,128).blight=true
tick();assert(not at(128,128).blight,'Settled native blight was not restored')
local history=table.concat(JTG.TerrainCleanupHistory,'\n')
assert(history:find('settled-before',1,true) and history:find('changed=1',1,true))
local repeatScope=JTG.CreateScope('repeat')
JTG.CreateScopedUnit(repeatScope,0,'ugrv',128,128,0)
JTG.DisposeScope(repeatScope);assert(not at(128,128).blight)
-- A new scene must inherit the clean original baseline even if a late native
-- update lands between scenes; old callbacks cannot erase its live blight.
at(128,128).blight=true
local replacement=JTG.CreateScope('replacement')
JTG.CreateScopedUnit(replacement,0,'ugrv',128,128,0)
tick();tick();assert(at(128,128).blight,'Old cleanup erased a live replacement scene')
JTG.DisposeScope(replacement);assert(not at(128,128).blight,'Replacement captured a contaminated baseline')
tick();tick()
-- Regression from alpha59: a passive replacement retained 459 terrain leases,
-- wrongly suppressing the departed Undead scene's delayed blight cleanup.
local undead=JTG.CreateScope('undead-before-human')
JTG.CreateScopedUnit(undead,0,'ugrv',128,128,0)
JTG.DisposeScope(undead)
local human=JTG.CreateScope('human-replacement')
local hall=JTG.CreateScopedUnit(human,0,'htow',128,128,0)
at(128,128).kind='current-building-ground'
at(128,128).blight=true
tick()
assert(not at(128,128).blight and not hall.removed,'Live Human building blocked departed blight cleanup')
assert(at(128,128).kind=='current-building-ground','Old cleanup overwrote the replacement building ground')
at(128,128).blight=true
tick();assert(not at(128,128).blight,'Human lease suppressed the settled blight pass')
JTG.DisposeScope(human);tick();tick()
assert(at(128,128).kind=='grass','Baseline lost while a passive replacement retained it')
-- An existing ordinary building also must not prevent source cleanup.
local standing,spreading=JTG.CreateScope('standing-human'),JTG.CreateScope('concurrent-undead')
JTG.CreateScopedUnit(standing,0,'htow',128,128,0)
JTG.CreateScopedUnit(spreading,0,'ugrv',128,128,0)
JTG.DisposeScope(spreading)
assert(not at(128,128).blight,'Overlapping non-source blocked source disposal')
tick();tick();JTG.DisposeScope(standing);tick();tick()
-- Explicit terrain/blight writers retain conservative protection.
local old=JTG.CreateScope('old-source')
JTG.CreateScopedUnit(old,0,'ugrv',128,128,0);JTG.DisposeScope(old)
local explicit=JTG.CreateScope('explicit-blight')
JTG.ScopePreserveTerrain(explicit,0,128,128,128)
at(128,128).blight=true;tick();tick()
assert(at(128,128).blight,'Old cleanup erased an explicit replacement blight mutation')
JTG.DisposeScope(explicit);tick();tick();assert(not at(128,128).blight)
-- Masked areas stay hidden until the next explored-map tutorial requests them.
assert(#modifiers==0,'Cleanup exposed masked terrain')
remembered['128:128']=true;remembered['0:0']=true
JTG.UseExploredWorldFog(0)
assert(#modifiers>0 and remembered['128:128']==false,'Explored tutorial retained stale blight memory')
local active=modifiers[#modifiers];assert(active.active)
tick();assert(not active.active and active.destroyed and IsFoggedToPlayer(128,128,0))
assert(remembered['0:0']==true,'Original blight was lost in refreshed memory')
assert(remembered['3008:3008']==nil,'Unchanged terrain was included in the refresh')
-- A delayed native write is also refreshed, but a reset cancels its temporary
-- sight immediately and preserves masked settings against the retired timer.
local late=JTG.CreateScope('fogged-cleanup')
JTG.CreateScopedUnit(late,0,'ugrv',128,128,0)
remembered['128:128']=true;JTG.DisposeScope(late);tick()
active=modifiers[#modifiers];assert(active.active and remembered['128:128']==false)
local stale=timers[#timers].fn
JTG.ResetWorldFog(0);assert(not active.active and active.destroyed and IsMaskedToPlayer(128,128,0))
stale();assert(IsMaskedToPlayer(128,128,0),'Old refresh changed the next activity fog')
tick();tick()
JTG.UseExploredWorldFog(0);active=modifiers[#modifiers];assert(active.active)
stale();assert(active.active,'Retired refresh cancelled a replacement refresh')
tick();assert(active.destroyed)
local departed=JTG.CreateScope('view-before-replacement')
JTG.CreateScopedUnit(departed,0,'ugrv',128,128,0);JTG.DisposeScope(departed)
local nextScene=JTG.CreateScope('view-live-replacement')
JTG.CreateScopedUnit(nextScene,0,'ugrv',128,128,0)
remembered['128:128']=true
JTG.RefreshTerrainView()
assert(remembered['128:128']==true,'Old terrain refresh revealed the replacement blight scene')
JTG.DisposeScope(nextScene);tick();tick();tick()
-- Refresh coverage cannot depend on seeing a dirty live flag AFTER rewriting
-- the tile: the native write may already clear blight while fog memory stays.
local rewrite=JTG.CreateScope('rewrite-clears-live-blight')
JTG.CreateScopedUnit(rewrite,0,'ugrv',2304,2304,0)
at(2304,2304).kind='grass';remembered['2304:2304']=true
clearBlightOnTerrainWrite=true
JTG.DisposeScope(rewrite);tick();tick();tick()
clearBlightOnTerrainWrite=false
assert(not at(2304,2304).blight and remembered['2304:2304']==false,
 'Clean native terrain escaped refresh while fog memory retained its blight')
local cleanRemoval=JTG.CreateScope('removal-already-cleared-blight')
local cleaned=JTG.CreateScopedUnit(cleanRemoval,0,'ugrv',2304,-2304,0)
remembered['2304:-2304']=true
local remove=RemoveUnit
function RemoveUnit(unit)
 remove(unit)
 if unit==cleaned then at(unit.x,unit.y).blight=false;at(unit.x,unit.y).kind='grass' end
end
JTG.DisposeScope(cleanRemoval);tick();tick();tick();RemoveUnit=remove
assert(remembered['2304:-2304']==false,'Already-clean removal escaped fog-memory refresh')
assert(table.concat(JTG.TerrainCleanupHistory,'\n'):find('view-requested=',1,true),
 'Terrain export lacks native refresh coverage evidence')
JTG.ResetWorldFog(0)
local slow=JTG.CreateScope('delayed-native-visibility')
JTG.CreateScopedUnit(slow,0,'ugrv',2304,2304,0);JTG.DisposeScope(slow);tick();tick()
delayedSight=true;JTG.UseExploredWorldFog(0);active=modifiers[#modifiers]
tick();tick();tick();assert(active.active and not active.destroyed,
 'Refresh stopped before native visibility became observable')
delayedSight=false;tick();assert(active.destroyed and IsFoggedToPlayer(2304,2304,0))
-- A modifier that never establishes sight cannot leak or leave a reveal on.
JTG.ResetWorldFog(0)
local stalled=JTG.CreateScope('native-visibility-timeout')
JTG.CreateScopedUnit(stalled,0,'ugrv',2304,2304,0);JTG.DisposeScope(stalled);tick();tick()
delayedSight=true;JTG.UseExploredWorldFog(0);active=modifiers[#modifiers]
for _=1,30 do tick() end
assert(active.destroyed and IsFoggedToPlayer(2304,2304,0),'Timed-out reveal leaked')
assert(table.concat(JTG.TerrainCleanupHistory,'\n'):find('view-timeout',1,true))
delayedSight=false;JTG.UseExploredWorldFog(0);active=modifiers[#modifiers]
assert(active.active,'Timed-out refresh lost its pending cells');tick();assert(active.destroyed)
for _,timer in ipairs(timers) do assert(timer.destroyed,'Terrain cleanup timer leaked') end
assert(rectangles>0,'Terrain restoration still uses overlapping point blight edits')
-- Fixed arenas capture their starting terrain once, before any scene. Later
-- leases and repeated visits must not sample dirty terrain as a new baseline.
JTG.Scenes={
 ['arena.south']={minX=0,minY=0,maxX=256,maxY=256},
 ['arena.north']={minX=0,minY=256,maxX=256,maxY=640},
}
local readTerrain,readVariance,readBlight=GetTerrainType,GetTerrainVariance,IsPointBlighted
local baselineReads=0
function GetTerrainType(x,y) baselineReads=baselineReads+1;return readTerrain(x,y) end
function GetTerrainVariance(x,y) baselineReads=baselineReads+1;return readVariance(x,y) end
function IsPointBlighted(x,y) baselineReads=baselineReads+1;return readBlight(x,y) end
local originalKind,originalVariance=at(128,128).kind,at(128,128).variation
JTG.InitializeTerrainBaseline()
-- Union is x=-1024..1280 (19 cells), y=-1024..1664 (22 cells).
assert(baselineReads==19*22*3,'Overlapping arena baselines were sampled more than once')
baselineReads=0
at(128,128).kind='dirt';at(128,128).variation=9;at(128,128).blight=true
JTG.InitializeTerrainBaseline()
assert(baselineReads==0,'Repeated initialization recaptured modified terrain')
for visit=1,2 do
 local scope=JTG.CreateScope('arena-baseline-'..visit)
 JTG.CreateScopedUnit(scope,0,'ugrv',128,128,0)
 assert(baselineReads==0,'Arena actor setup reread the starting terrain')
 JTG.DisposeScope(scope);tick();tick();tick()
 assert(at(128,128).kind==originalKind and at(128,128).variation==originalVariance and not at(128,128).blight,
  'Repeated arena cleanup lost its immutable starting terrain')
 assert(at(0,0).blight,'Arena baseline lost original map blight')
 baselineReads=0
end
local outside=JTG.CreateScope('outside-arena-baseline')
JTG.CreateScopedUnit(outside,0,'htow',-3072,-3072,0)
assert(baselineReads>0,'Non-arena scenes lost their live terrain snapshots')
JTG.DisposeScope(outside);tick();tick();tick()
print('Passed: pre-spawn terrain snapshots, overlapping scope leases, source removal, ownership changes, original blight, tile variation and repeated scene cleanup.')
