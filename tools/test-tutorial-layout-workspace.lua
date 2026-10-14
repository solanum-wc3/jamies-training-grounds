-- Synthetic ownership/export checks; native building placement is tested in game.
local units,rows={},{}
JTG={Dev={},Registry={byId={['learn.economy']={status='planned'}}},MeleeTech={'R001'}}
PLAYER_STATE_RESOURCE_GOLD='gold';PLAYER_STATE_RESOURCE_LUMBER='wood';PLAYER_STATE_RESOURCE_FOOD_CAP='food';PLAYER_STATE_RESOURCE_FOOD_USED='used'
FOG_OF_WAR_VISIBLE='visible'
local resources={gold=123,wood=456,food=7}
function Player(n) return n end
function FourCC(s) local n=0;for i=1,4 do n=n*256+s:byte(i) end;return n end
function CreateUnit(owner,raw,x,y,facing) local u={owner=owner,raw=raw,x=x,y=y,facing=facing};units[#units+1]=u;return u end
function GetUnitTypeId(u) return u.raw end
function GetUnitX(u) return u.x end
function GetUnitY(u) return u.y end
function GetUnitFacing(u) return u.facing end
function GetOwningPlayer(u) return u.owner end
function IsUnitVisible() return true end
function GetPlayerId(p) return p end
function CreateGroup() return {} end
function GroupEnumUnitsInRect(g) for _,u in ipairs(units) do if not u.removed then g[#g+1]=u end end end
function GroupEnumUnitsOfPlayer(g,p) for _,u in ipairs(units) do if not u.removed and u.owner==p then g[#g+1]=u end end end
function FirstOfGroup(g) return g[1] end
function GroupRemoveUnit(g,u) for i,v in ipairs(g) do if v==u then table.remove(g,i);return end end end
function DestroyGroup() end
function RemoveUnit(u) u.removed=true end
function GetWorldBounds() return {} end
function RemoveRect() end
function GetPlayerState(_,key) return resources[key] end
function SetPlayerState(_,key,value) resources[key]=value end
local tech=0
function GetPlayerTechCount() return tech end
function SetPlayerTechResearched(_,_,value) tech=value end
function JTG.ScopeAdd(scope,fn) scope[#scope+1]=fn end
JTG.ScopeBorrow=JTG.ScopeAdd
function JTG.ScopeTrackUnit(scope,u) JTG.ScopeAdd(scope,function() RemoveUnit(u) end);return u end
function JTG.ScopeTrackFogModifier(_,f) return f end
function JTG.ScopeTrackTrigger(_,t) return t end
function JTG.GuardSession(_,fn) return fn end
function JTG.BorrowCamera() end
function JTG.ResetWorldFog() end
function CreateFogModifierRect() return {} end
function FogModifierStart() end
function CreateTrigger() return {} end
function TriggerRegisterPlayerChatEvent(_,_,command) assert(command=='-export-layout' or command=='-economy-orders') end
function TriggerAddAction(t,fn) t.action=fn end
function PreloadGenClear() rows={} end
function PreloadGenStart() end
function Preload(text) assert(#text<200);rows[#rows+1]=text end
function PreloadGenEnd(path) assert(path=='JTG-Economy-Layout.pld') end
function DisplayTimedTextToPlayer() end

PLAYER_NEUTRAL_PASSIVE=15;bj_MAX_PLAYER_SLOTS=24;MAP_CONTROL_USER='user'
ALLIANCE_SHARED_VISION='vision';ALLIANCE_SHARED_CONTROL='control';ALLIANCE_SHARED_ADVANCED_CONTROL='advanced';ALLIANCE_PASSIVE='passive'
local alliances,colors,controllers,techs={},{},{},{}
function GetPlayerAlliance(a,b,k) return alliances[a..':'..b..':'..k] or false end
function SetPlayerAlliance(a,b,k,v) alliances[a..':'..b..':'..k]=v end
function GetPlayerController(p) return controllers[p] or 'computer' end
function SetPlayerController(p,v) controllers[p]=v end
function GetPlayerColor(p) return colors[p] or p end
function SetPlayerColor(p,v) colors[p]=v end
function ConvertPlayerColor(p) return p end
function SetUnitColor(u,v) u.color=v end
function SetUnitOwner(u,p) u.owner=p end
function GetLocalPlayer() return 0 end
function ClearSelection() end
local camera={}
function SetCameraPosition(x,y) camera={x,y} end
function GetPlayerTechCount(p,id) return techs[p..':'..id] or 0 end
function SetPlayerTechResearched(p,id,v) techs[p..':'..id]=v end
local trees={{life=10,max=100},{life=0,max=100}}
local enumTree
function EnumDestructablesInRect(_,_,fn) for _,d in ipairs(trees) do enumTree=d;fn() end end
function GetEnumDestructable() return enumTree end
function GetDestructableLife(d) return d.life end
function GetDestructableMaxLife(d) return d.max end
function SetDestructableLife(d,v) d.life=v end
function DestructableRestoreLife(d,v) d.life=v end
function KillDestructable(d) d.life=0 end
PLAYER_NEUTRAL_AGGRESSIVE=12
function IsUnitHidden(u) return u.hidden or false end
function IsUnitPaused(u) return u.paused or false end
function ShowUnit(u,v) u.hidden=not v end
function PauseUnit(u,v) u.paused=v end
function GetDestructableTypeId() return FourCC('LTlt') end
function GetDestructableX(d) return d.x or -1800 end
function GetDestructableY(d) return d.y or -7600 end
function SetResourceAmount(u,n) u.gold=n end
function IssueTargetOrder(u,order,target) u.order=order;u.target=target;return true end
local humanMine=CreateUnit(15,FourCC('ngol'),-2944,-6912,0)
local orcMine=CreateUnit(15,FourCC('ngol'),4160,-5696,0)
local baseCreep=CreateUnit(12,FourCC('nfoo'),-2400,-6400,0)
local distantCreep=CreateUnit(12,FourCC('nfoo'),7000,5000,0)
local tavern=CreateUnit(15,FourCC('ntav'),100,200,270)
local foundation=CreateUnit(0,FourCC('hfoo'),0,0,0)
techs['2:'..FourCC('R001')]=2
SetPlayerAlliance(3,0,ALLIANCE_SHARED_CONTROL,true)
dofile('src/generated/economy-layout.lua')
UNIT_TYPE_STRUCTURE='structure'
function IsUnitIdType(id)
 for _,raw in ipairs({'hpea','opeo','ewsp','uaco','ugho'}) do
  if id==FourCC(raw) then return false end
 end
 return true
end
function SetUnitPathing(u,v) u.pathing=v end
function SetUnitPosition(u,x,y) u.x=x;u.y=y end
function UnitAddAbility() end
function GetUnitAbilityLevel() return 0 end
function UnitMakeAbilityPermanent() end
function GetWidgetLife(u) return u.removed and 0 or 1000 end
function GetUnitCurrentOrder(u) return u.order or 0 end
dofile('src/infrastructure/tutorial.lua')
dofile('src/infrastructure/economy-layout-export.lua')
dofile('src/infrastructure/economy-layout.lua')
local s={scope={}}
local a=JTG.CreateEconomyLayout(s);a:setup(s);a:startGathering()
assert(not a.nextStage and not a.previousStage and not a.start,
 'Scene provider must not retain preview progression')
assert(#a.units==65 and #JTG.EconomyLayout==73)
assert(baseCreep.hidden and baseCreep.paused and not distantCreep.hidden)
local gold,lumber=0,0
for _,assignment in ipairs(a.placements) do
 local u,p=assignment.unit,assignment.placement
 if p.gathering then
  assert(u.target)
  if p.gathering=='gold' and (p.rawcode=='hpea' or p.rawcode=='opeo') then assert(u.order=='harvest')
  else assert(u.order=='harvest') end
  if p.gathering=='gold' then
   gold=gold+1
   if p.rawcode=='ewsp' then assert(u.target.raw==FourCC('egol')) end
   if p.rawcode=='uaco' then assert(u.target.raw==FourCC('ugol')) end
  else lumber=lumber+1 end
 end
end
assert(gold==20 and lumber==26)

assert(foundation.owner==15 and techs['2:'..FourCC('R001')]==0)
assert(trees[1].life==100 and trees[2].life==100)
local expected={human=2,orc=3,nightelf=4,undead=5}
local present={}
for _,u in ipairs(a.units) do assert(u.owner~=0);present[u.raw]=true end
for _,raw in ipairs({'hkee','hcas','halt','oalt','uaod','eate','eden','owtw'}) do assert(not present[FourCC(raw)]) end
for slot=2,5 do
 assert(not GetPlayerAlliance(slot,0,ALLIANCE_SHARED_VISION))
 assert(not GetPlayerAlliance(slot,0,ALLIANCE_SHARED_CONTROL))
 assert(not GetPlayerAlliance(slot,0,ALLIANCE_SHARED_ADVANCED_CONTROL))
end
a:exportLayout();assert(#rows==66)
trees[1].life=0
for i=#s.scope,1,-1 do s.scope[i]() end
for _,u in ipairs(a.units) do assert(u.removed) end
assert(not baseCreep.hidden and not baseCreep.paused and not baseCreep.removed)
assert(not foundation.removed and foundation.owner==0 and not tavern.removed)
assert(techs['2:'..FourCC('R001')]==2 and trees[1].life==10 and trees[2].life==0)
assert(GetPlayerAlliance(3,0,ALLIANCE_SHARED_CONTROL))
assert(not GetPlayerAlliance(5,0,ALLIANCE_SHARED_VISION))
print('Passed: Economy placements, absent placeholders, scene-only ownership, colors, research, trees, export and scoped cleanup.')
