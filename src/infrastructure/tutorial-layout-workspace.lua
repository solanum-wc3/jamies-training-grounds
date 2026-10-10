-- Development-only Economy preview; factions retain ownership and never grant control.
JTG.Dev=JTG.Dev or {}
local viewer=Player(0)
local factions={
 {id='human',name='Human',slot=2,color=1,x=-2368,y=-6400},
 {id='orc',name='Orc',slot=3,color=0,x=3648,y=-5120},
 {id='nightelf',name='Night Elf',slot=4,color=2,x=-4928,y=-3904},
 {id='undead',name='Undead',slot=5,color=3,x=-6336,y=1920},
}
local descriptor=assert(JTG.Registry.byId['learn.economy'])
descriptor.status='available'
descriptor.sceneId='tutorial.camera'
descriptor.capabilities={restart=true,menu=true,pause=true,next=true,lastRunner=true,previous=true}
descriptor.factory=function(session)
 local activity={units={},placements={},trees={},mines={},raceIndex=(session.restartData or {}).raceIndex or 1}
 function activity:showRace(index)
  self.raceIndex=(index-1)%4+1
  for i,f in ipairs(factions) do SetPlayerAlliance(Player(f.slot),viewer,ALLIANCE_SHARED_VISION,i==self.raceIndex) end
  JTG.ResetWorldFog(viewer)
  local f=factions[self.raceIndex]
  if GetLocalPlayer()==viewer then ClearSelection();SetCameraPosition(f.x,f.y) end
  DisplayTimedTextToPlayer(viewer,0,0,5,f.name..' — view only. Next and Back switch races.')
  return true
 end
 function activity:nextStage() return self:showRace(self.raceIndex+1) end
 function activity:previousStage() return self:showRace(self.raceIndex-1) end
 function activity:captureRestartState() return {raceIndex=self.raceIndex} end
 function activity:exportLayout()
  local rows={}
  for _,u in ipairs(self.units) do
   local raw=GetUnitTypeId(u)
   if raw~=0 then
    local name=string.char(math.floor(raw/16777216)%256,math.floor(raw/65536)%256,math.floor(raw/256)%256,raw%256)
    rows[#rows+1]=string.format('%s,%.3f,%.3f,%.3f,%d',name,GetUnitX(u),GetUnitY(u),GetUnitFacing(u),GetPlayerId(GetOwningPlayer(u)))
   end
  end
  table.sort(rows);PreloadGenClear();PreloadGenStart();Preload('//JTG_LAYOUT,rawcode,x,y,facing,player')
  for _,row in ipairs(rows) do Preload('//JTG_LAYOUT,'..row) end
  PreloadGenEnd('JTG-Economy-Layout.pld')
 end
 function activity:setup(current)
  local scope=current.scope
  JTG.BorrowCamera(scope)
  local world=GetWorldBounds();local group=CreateGroup()
  GroupEnumUnitsInRect(group,world,nil)
  while true do
   local u=FirstOfGroup(group);if not u then break end
   GroupRemoveUnit(group,u)
   local raw=GetUnitTypeId(u)
   if raw==FourCC('ngol') then self.mines[#self.mines+1]=u end
   if GetOwningPlayer(u)==Player(PLAYER_NEUTRAL_AGGRESSIVE) then
    local x,y=GetUnitX(u),GetUnitY(u)
    local atBase=false
    for _,p in ipairs(JTG.EconomyLayout) do
     if (p.x-x)^2+(p.y-y)^2<=1100^2 then atBase=true;break end
    end
    if atBase then
     local hidden,paused=IsUnitHidden(u),IsUnitPaused(u)
     JTG.ScopeBorrow(scope,function() ShowUnit(u,not hidden);PauseUnit(u,paused) end)
     PauseUnit(u,true);ShowUnit(u,false)
    end
   end
   if GetOwningPlayer(u)==viewer then
    JTG.ScopeBorrow(scope,function() SetUnitOwner(u,viewer,false) end)
    SetUnitOwner(u,Player(PLAYER_NEUTRAL_PASSIVE),false)
   end
  end
  DestroyGroup(group)
  for slot=1,bj_MAX_PLAYER_SLOTS-1 do
   local owner=Player(slot);local old=GetPlayerAlliance(owner,viewer,ALLIANCE_SHARED_VISION)
   JTG.ScopeBorrow(scope,function() SetPlayerAlliance(owner,viewer,ALLIANCE_SHARED_VISION,old) end)
   SetPlayerAlliance(owner,viewer,ALLIANCE_SHARED_VISION,false)
  end
  local owners={}
  for _,f in ipairs(factions) do
   local owner=Player(f.slot);owners[f.id]=owner
   local controller=GetPlayerController(owner);local color=GetPlayerColor(owner)
   JTG.ScopeBorrow(scope,function() SetPlayerController(owner,controller);SetPlayerColor(owner,color) end)
   SetPlayerController(owner,MAP_CONTROL_USER);SetPlayerColor(owner,ConvertPlayerColor(f.color))
   for _,kind in ipairs({ALLIANCE_SHARED_CONTROL,ALLIANCE_SHARED_ADVANCED_CONTROL}) do
    local old=GetPlayerAlliance(owner,viewer,kind)
    JTG.ScopeBorrow(scope,function() SetPlayerAlliance(owner,viewer,kind,old) end)
    SetPlayerAlliance(owner,viewer,kind,false)
   end
   for _,other in ipairs({viewer,Player(2),Player(3),Player(4),Player(5)}) do
    if owner~=other then
     for _,pair in ipairs({{owner,other},{other,owner}}) do
      local left,right=pair[1],pair[2];local old=GetPlayerAlliance(left,right,ALLIANCE_PASSIVE)
      JTG.ScopeBorrow(scope,function() SetPlayerAlliance(left,right,ALLIANCE_PASSIVE,old) end)
      SetPlayerAlliance(left,right,ALLIANCE_PASSIVE,true)
     end
    end
   end
   for _,raw in ipairs(JTG.DodgeTech or {}) do
    local id=FourCC(raw);local old=GetPlayerTechCount(owner,id,true)
    JTG.ScopeBorrow(scope,function() SetPlayerTechResearched(owner,id,old) end)
    SetPlayerTechResearched(owner,id,0)
   end
  end
  EnumDestructablesInRect(world,nil,function()
   local d=GetEnumDestructable();local old=GetDestructableLife(d);local maximum=GetDestructableMaxLife(d)
   if GetDestructableTypeId(d)==FourCC('LTlt') then self.trees[#self.trees+1]=d end
   -- Gathering can damage healthy trees too; restore their entry state on exit.
   JTG.ScopeBorrow(scope,function()
    if old<=0 then KillDestructable(d)
    elseif GetDestructableLife(d)<=0 then DestructableRestoreLife(d,old,false)
    else SetDestructableLife(d,old) end
   end)
   if old<maximum then
    if old<=0 then DestructableRestoreLife(d,maximum,false) else SetDestructableLife(d,maximum) end
   end
  end)
  RemoveRect(world)
  for _,p in ipairs(JTG.EconomyLayout) do
   if p.appearance=='initial' then
    local owner=assert(owners[p.faction]);local u=JTG.ScopeTrackUnit(scope,CreateUnit(owner,FourCC(p.rawcode),p.x,p.y,p.facing))
    SetUnitColor(u,GetPlayerColor(owner));self.units[#self.units+1]=u
    self.placements[#self.placements+1]={unit=u,placement=p}
    if p.rawcode=='egol' or p.rawcode=='ugol' then
     SetResourceAmount(u,100000);self.mines[#self.mines+1]=u
    end
   end
  end
  local trigger=JTG.ScopeTrackTrigger(scope,CreateTrigger())
  TriggerRegisterPlayerChatEvent(trigger,viewer,'-export-layout',true)
  TriggerAddAction(trigger,JTG.GuardSession(current,function() self:exportLayout() end))
 end
 function activity:startGathering()
  for _,assignment in ipairs(self.placements) do
   local u,p=assignment.unit,assignment.placement
   if p.gathering then
    local target,distance
    local candidates=p.gathering=='gold' and self.mines or self.trees
    for _,candidate in ipairs(candidates) do
     local valid=p.gathering=='lumber' and GetDestructableLife(candidate)>0 or
      p.gathering=='gold' and (GetUnitTypeId(candidate)==FourCC('ngol') or GetOwningPlayer(candidate)==GetOwningPlayer(u))
     if valid then
      local x=p.gathering=='gold' and GetUnitX(candidate) or GetDestructableX(candidate)
      local y=p.gathering=='gold' and GetUnitY(candidate) or GetDestructableY(candidate)
      local d=(x-p.x)^2+(y-p.y)^2
      -- Wisps and Acolytes use their prepared racial mine, not its foundation mine.
      local racial=p.rawcode=='ewsp' or p.rawcode=='uaco'
      if not racial or p.gathering=='lumber' or GetUnitTypeId(candidate)~=FourCC('ngol') then
       if not distance or d<distance then target,distance=candidate,d end
      end
     end
    end
    if target then IssueTargetOrder(u,'harvest',target) end
   end
  end
 end
 function activity:start() self:showRace(self.raceIndex);self:startGathering() end
 function activity:rebuildPresentation() self:showRace(self.raceIndex) end
 function activity:cleanup() end
 return activity
end
