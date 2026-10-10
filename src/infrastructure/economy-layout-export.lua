-- Development-only layout export; scripted tutorial is shared with release.
function JTG.InstallEconomyLayoutExport(activity,current)
 activity.economyOrderTrace={}
 function activity:recordEconomyOrderState(phase,worker,issued)
  local placement
  for _,a in ipairs(self.placements) do if a.unit==worker then placement=a.placement;break end end
  if not placement or not placement.gathering or GetUnitTypeId(worker)==0 then return end
  local trace=self.economyOrderTrace
  local observation=self.gatheringObservations and self.gatheringObservations[worker]
  local target=placement.gathering=='gold' and observation and observation.target
  local owner=GetOwningPlayer(worker)
  self.economyTraceSequence=(self.economyTraceSequence or 0)+1
  local row=table.concat({self.economyTraceSequence,phase,self.step or 0,self.raceIndex,placement.id,
   GetPlayerId(owner),issued or 0,GetUnitCurrentOrder(worker),self.scripted and 1 or 0,
   IsUnitPaused(worker) and 1 or 0,IsUnitHidden(worker) and 1 or 0,
   target and IsUnitVisible(target,owner) and 1 or 0,
   math.floor(GetUnitX(worker)),math.floor(GetUnitY(worker))},',')
  trace[#trace+1]='//JTG_ECONOMY_TRACE,'..row
  if #trace>1024 then table.remove(trace,1) end
 end
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
 local trigger=JTG.ScopeTrackTrigger(current.scope,CreateTrigger())
 TriggerRegisterPlayerChatEvent(trigger,Player(0),"-export-layout",true)
 TriggerAddAction(trigger,JTG.GuardSession(current,function() activity:exportLayout() end))
 -- Report commands and observed engine orders separately. An accepted order
 -- alone is not evidence that a worker reached its mine/tree or gathered.
 function activity:reportWorkerOrders()
  PreloadGenClear();PreloadGenStart()
  Preload('//JTG_ECONOMY_META,step='..tostring(self.step)..',race='..tostring(self.raceIndex))
  Preload('//JTG_ECONOMY,id,race,unit,task,owner,requested,accepted,issued_order,current_order,hidden,hp,harvest_ability,building,x,y,target,tx,ty,target_owner,target_hidden,target_paused,mine_gold')
  for _,assignment in ipairs(self.placements) do
   local worker,p=assignment.unit,assignment.placement
   if p.gathering and GetUnitTypeId(worker)~=0 then
    local observation=self.gatheringObservations and self.gatheringObservations[worker]
    local accepted=observation and tostring(observation.accepted) or 'not issued'
    local task=self.workerTasks and self.workerTasks[worker]
    local target=observation and observation.target
    local gold=p.gathering=='gold' and target and GetUnitTypeId(target)~=0
    local values={p.id,p.faction,p.rawcode,p.gathering,GetPlayerId(GetOwningPlayer(worker)),
     observation and observation.command or '-',accepted,
     observation and observation.actualOrder or 0,GetUnitCurrentOrder(worker),IsUnitHidden(worker) and 1 or 0,
     math.floor(GetWidgetLife(worker)),GetUnitAbilityLevel(worker,FourCC('Ahar')),task and 1 or 0,
     math.floor(GetUnitX(worker)),math.floor(GetUnitY(worker)),gold and GetUnitTypeId(target) or 0,
     gold and math.floor(GetUnitX(target)) or 0,gold and math.floor(GetUnitY(target)) or 0,
     gold and GetPlayerId(GetOwningPlayer(target)) or -1,gold and IsUnitHidden(target) and 1 or 0,
     gold and IsUnitPaused(target) and 1 or 0,gold and GetResourceAmount(target) or 0}
    for i,value in ipairs(values) do values[i]=tostring(value) end
    local row='//JTG_ECONOMY,'..table.concat(values,',')
    assert(#row<=240,'Economy diagnostic row exceeds native preload limit')
    Preload(row)
    if p.gathering=='gold' and observation and observation.orderTarget then
     local actual=observation.orderTarget
     Preload(table.concat({'//JTG_ECONOMY_ORDER_TARGET',p.id,tostring(observation.firstAccepted),
      GetHandleId(target),GetHandleId(actual),GetUnitTypeId(actual),
      math.floor(GetUnitX(actual)),math.floor(GetUnitY(actual)),GetUnitAbilityLevel(actual,FourCC('Argl'))},','))
    end
    local text=string.format('%s %s %s: owner=%d, requested=%s, accepted=%s, current=%s, building=%s',
      p.faction,p.rawcode,p.gathering,GetPlayerId(GetOwningPlayer(worker)),
      observation and observation.command or '-',accepted,tostring(GetUnitCurrentOrder(worker)),
      tostring(task~=nil))
    if p.gathering=='gold' and p.faction==self.factions[self.raceIndex].id then
     DisplayTimedTextToPlayer(Player(0),0,0,30,text)
    end
   end
  end
  Preload('//JTG_ECONOMY_TRACE,sequence,phase,step,race,id,owner,issued,current,scripted,paused,hidden,mine_visible,x,y')
  for _,row in ipairs(self.economyOrderTrace) do Preload(row) end
  for _,assignment in ipairs(self.placements) do
   if assignment.placement.gathering and GetUnitTypeId(assignment.unit)~=0 then
    self:recordEconomyOrderState('export',assignment.unit,0)
    Preload(self.economyOrderTrace[#self.economyOrderTrace])
   end
  end
  PreloadGenEnd('JTG-Economy-Orders.pld')
  DisplayTimedTextToPlayer(Player(0),0,0,30,'Economy diagnostics saved to CustomMapData\\JTG-Economy-Orders.pld')
 end
 local orders=JTG.ScopeTrackTrigger(current.scope,CreateTrigger())
 TriggerRegisterPlayerChatEvent(orders,Player(0),'-economy-orders',true)
 TriggerAddAction(orders,JTG.GuardSession(current,function() activity:reportWorkerOrders() end))
end
