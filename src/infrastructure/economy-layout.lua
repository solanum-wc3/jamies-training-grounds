-- Scoped Economy layout environment; the tutorial supplies progression and ownership policy.
JTG=JTG or {}
local viewer=Player(0)
local factions={
 {id='human',name='Human',slot=2,color=1,x=-2368,y=-6400},
 {id='orc',name='Orc',slot=3,color=0,x=3648,y=-5120},
 {id='nightelf',name='Night Elf',slot=4,color=2,x=-4928,y=-3904},
 {id='undead',name='Undead',slot=5,color=3,x=-6336,y=1920},
}
function JTG.CreateEconomyLayout(session)
 local activity={spawnedWorkerRaces={},factions=factions,units={},placements={},trees={},mines={},raceIndex=(session.restartData or {}).raceIndex or 1}
 function activity:setup(current)
  local scope=current.scope
  JTG.BorrowCamera(scope,viewer)
  local world=GetWorldBounds();local group=CreateGroup()
  GroupEnumUnitsInRect(group,world,nil)
  while true do
   local u=FirstOfGroup(group);if not u then break end
   GroupRemoveUnit(group,u)
   local raw=GetUnitTypeId(u)
   if raw==FourCC('ngol') then
    local replaced=false
    for _,p in ipairs(JTG.EconomyLayout) do
     if (p.rawcode=='egol' or p.rawcode=='ugol') and (p.x-GetUnitX(u))^2+(p.y-GetUnitY(u))^2<256^2 then replaced=true end
    end
    if replaced then
     local hidden,paused=IsUnitHidden(u),IsUnitPaused(u)
     JTG.ScopeBorrow(scope,function() ShowUnit(u,not hidden);PauseUnit(u,paused);SetUnitPathing(u,true) end)
     ShowUnit(u,false);PauseUnit(u,true);SetUnitPathing(u,false)
    else self.mines[#self.mines+1]=u end
   end
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
    local hidden,paused=IsUnitHidden(u),IsUnitPaused(u)
    JTG.ScopeBorrow(scope,function()
     SetUnitOwner(u,viewer,false);ShowUnit(u,not hidden);PauseUnit(u,paused)
    end)
    SetUnitOwner(u,Player(PLAYER_NEUTRAL_PASSIVE),false)
    ShowUnit(u,false);PauseUnit(u,true)
   end
  end
  DestroyGroup(group)
  for slot=1,bj_MAX_PLAYER_SLOTS-1 do
   local owner=Player(slot);local old=GetPlayerAlliance(owner,viewer,ALLIANCE_SHARED_VISION)
   JTG.ScopeBorrow(scope,function() SetPlayerAlliance(owner,viewer,ALLIANCE_SHARED_VISION,old) end)
   SetPlayerAlliance(owner,viewer,ALLIANCE_SHARED_VISION,false)
  end
  for _,key in ipairs({PLAYER_STATE_RESOURCE_GOLD,PLAYER_STATE_RESOURCE_LUMBER,PLAYER_STATE_RESOURCE_FOOD_CAP,PLAYER_STATE_RESOURCE_FOOD_USED}) do
   local old=GetPlayerState(viewer,key)
   JTG.ScopeBorrow(scope,function() SetPlayerState(viewer,key,old) end)
  end
  for _,raw in ipairs(JTG.MeleeTech or {}) do
   local id=FourCC(raw);local old=GetPlayerTechCount(viewer,id,true)
   JTG.ScopeBorrow(scope,function() SetPlayerTechResearched(viewer,id,old) end)
   SetPlayerTechResearched(viewer,id,0)
  end
  local owners={}
  for _,f in ipairs(factions) do
   local owner=Player(f.slot);owners[f.id]=owner
   for _,key in ipairs({PLAYER_STATE_RESOURCE_FOOD_CAP,PLAYER_STATE_RESOURCE_FOOD_USED}) do
    local old=GetPlayerState(owner,key)
    JTG.ScopeBorrow(scope,function() SetPlayerState(owner,key,old) end)
   end
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
   for _,raw in ipairs(JTG.MeleeTech or {}) do
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
  -- Structures must claim their footprints before workers are created.
  -- Coordinate-only setters on a displaced building can leave its model behind.
  for _,p in ipairs(JTG.EconomyLayout) do
   local raw=FourCC(p.rawcode)
   if p.appearance=='initial' and IsUnitIdType(raw,UNIT_TYPE_STRUCTURE) then
    local owner=assert(owners[p.faction])
    local u=JTG.Tutorial.CreateSceneUnit(scope,owner,raw,p.x,p.y,p.facing)
    SetUnitColor(u,GetPlayerColor(owner));self.units[#self.units+1]=u
    self.placements[#self.placements+1]={unit=u,placement=p}
    if p.rawcode=='egol' or p.rawcode=='ugol' then
     SetResourceAmount(u,100000);self.mines[#self.mines+1]=u
    end
   end
  end
  for index,f in ipairs(factions) do self:spawnRaceWorkers(index,Player(f.slot)) end
  if JTG.InstallEconomyLayoutExport then JTG.InstallEconomyLayoutExport(self,current) end
 end
 function activity:spawnRaceWorkers(index,owner)
  if self.spawnedWorkerRaces[index] then return false end
  self.spawnedWorkerRaces[index]=true
  local f=factions[index]
  for _,p in ipairs(JTG.EconomyLayout) do
   local raw=FourCC(p.rawcode)
   if p.appearance=='initial' and p.faction==f.id and not IsUnitIdType(raw,UNIT_TYPE_STRUCTURE) then
    -- Match Camera: use the authored working positions after structures have
    -- claimed their footprints. A ring around the hall is for checkpoint
    -- recovery, not for the initial resource-gathering layout.
    local u=JTG.Tutorial.CreateMobileUnit(session.scope,owner,raw,p.x,p.y,p.facing)
    SetUnitColor(u,ConvertPlayerColor(f.color))
    self.units[#self.units+1]=u;self.placements[#self.placements+1]={unit=u,placement=p}
    if self.trackEconomyUnit then self:trackEconomyUnit(u,index,true) end
   end
  end
  return true
 end
 function activity:workerIsGathering(unit,placement)
  if not placement.gathering or GetUnitTypeId(unit)~=FourCC(placement.rawcode) or GetWidgetLife(unit)<=0.405 then return false end
  if self.workerTasks and self.workerTasks[unit] then return false end
  local order=GetUnitCurrentOrder(unit)
  for _,name in ipairs({'harvest','resumeharvesting','returnresources','returngold','returnlumber'}) do
   if order==OrderId(name) then return true end
  end
  -- Workers inside a mine can have no visible order while the mine owns the cycle.
  return IsUnitHidden(unit) and self.gatheringObservations and self.gatheringObservations[unit]~=nil
 end
 function activity:startGathering(onlyWorker,race,preserveWorking)
  for _,assignment in ipairs(self.placements) do
   local u,p=assignment.unit,assignment.placement
   local task=self.workerTasks and self.workerTasks[u]
   if task and task.building and task.building~=true and GetUnitTypeId(task.building)==0 then
    self.workerTasks[u]=nil;task=nil
   end
   local current=GetUnitCurrentOrder(u)
   local building=task and task.building or
       (type(current)=='number' and current>=0x20000000 and IsUnitIdType(current,UNIT_TYPE_STRUCTURE))
   if p.gathering and (not race or p.faction==factions[race].id) and not building and
       (not onlyWorker or u==onlyWorker) and GetUnitTypeId(u)~=0 and GetWidgetLife(u)>0.405 and
       not (preserveWorking and self:workerIsGathering(u,p)) then
    local target,distance
    local candidates=p.gathering=='gold' and self.mines or self.trees
    for _,candidate in ipairs(candidates) do
     local valid=p.gathering=='lumber' and GetDestructableLife(candidate)>0 or
      p.gathering=='gold' and GetUnitTypeId(candidate)==FourCC(p.rawcode=='ewsp' and 'egol' or p.rawcode=='uaco' and 'ugol' or 'ngol') and GetWidgetLife(candidate)>0.405
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
    if target then
     -- Use the explicit resource order used by Camera. Smart is contextual
     -- and does not identify the worker as gathering while approaching.
     local command='harvest'
     local accepted
     if self.order then accepted=self:order(u,command,target) else accepted=IssueTargetOrder(u,command,target) end
     local firstAccepted=accepted
     local orderTarget=target
     if not accepted and p.gathering=='gold' and (p.rawcode=='hpea' or p.rawcode=='opeo') then
      -- A rejected mine order may be a worker still carrying gold across an
      -- ownership handoff. Native resumeharvesting targets its drop-off and
      -- delivers the load before continuing the remembered gathering cycle.
      local dropOff,nearest
      for _,building in ipairs(self.units) do
       if GetUnitTypeId(building)~=0 and GetWidgetLife(building)>0.405 and
           GetOwningPlayer(building)==GetOwningPlayer(u) and GetUnitAbilityLevel(building,FourCC('Argl'))>0 then
        local d=(GetUnitX(building)-GetUnitX(u))^2+(GetUnitY(building)-GetUnitY(u))^2
        if not nearest or d<nearest then dropOff,nearest=building,d end
       end
      end
      if dropOff then
       command='resumeharvesting';orderTarget=dropOff
       if self.order then accepted=self:order(u,command,dropOff) else accepted=IssueTargetOrder(u,command,dropOff) end
      end
     end
     self.gatheringObservations=self.gatheringObservations or {}
     self.gatheringObservations[u]={command=command,target=target,accepted=accepted,
         actualOrder=GetUnitCurrentOrder(u),owner=GetOwningPlayer(u),orderTarget=orderTarget,firstAccepted=firstAccepted}
     if self.recordEconomyOrderState then self:recordEconomyOrderState('gather-'..tostring(accepted),u,GetUnitCurrentOrder(u)) end
    end
   end
  end
 end
 function activity:cleanup() end
 return activity
end
