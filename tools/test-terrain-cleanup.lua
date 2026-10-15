JTG={}
PLAYER_NEUTRAL_PASSIVE,UNIT_TYPE_STRUCTURE=15,'structure'
function Player(id) return id end
function FourCC(raw) return raw end
local map,live={},{}
local function at(x,y)
 local id=x..':'..y
 map[id]=map[id] or {kind='grass',variation=(x+y)%3,blight=x==0 and y==0}
 return map[id]
end
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
end
function SetBlightPoint(_,x,y,value) at(x,y).blight=value end
function IsUnitIdType(raw) return raw=='ugrv' or raw=='htow' end
function GetOwningPlayer(u) return u.owner end
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
local scene=JTG.CreateScope('scene')
local c=JTG.CreateScopedUnit(scene,0,'ugrv',128,128,0)
local clear=JTG.ScopePreserveTerrain(scene,0,128,128,512)
clear();assert(not at(128,128).blight,'Explicit early clear did not restore baseline')
at(128,128).blight=true -- a live building spreads again before removal
JTG.DisposeScope(scene)
assert(c.removed and not at(128,128).blight,'Cleanup happened before the spreading source was removed')
local repeatScope=JTG.CreateScope('repeat')
JTG.CreateScopedUnit(repeatScope,0,'ugrv',128,128,0)
JTG.DisposeScope(repeatScope);assert(not at(128,128).blight)
print('Passed: pre-spawn terrain snapshots, overlapping scope leases, source removal, ownership changes, original blight, tile variation and repeated scene cleanup.')
