-- Exercise the real shared ownership code with a modelled native world.
JTG={}
function FourCC(raw) return raw end
function Player(id) return id end
bj_MAX_PLAYER_SLOTS=2
EVENT_PLAYER_UNIT_SUMMON='summon'
EVENT_PLAYER_UNIT_SPELL_EFFECT='effect'
local world,timers,triggers={}, {}, {}
local event,caster,summoned,ability
local scans=0
local function unit(owner,x,y)
    local value={owner=owner,x=x or 0,y=y or 0}
    world[value]=true;return value
end
function RemoveUnit(value) value.removed=true;world[value]=nil end
function GetUnitX(value) return value.x end
function GetUnitY(value) return value.y end
function GetOwningPlayer(value) return value.owner end
function CreateGroup() return {} end
function GetWorldBounds() return {} end
function GroupEnumUnitsInRect(group)
    scans=scans+1
    for value in pairs(world) do group[#group+1]=value end
end
function BlzGroupGetSize(group) return #group end
function BlzGroupUnitAt(group,index) return group[index+1] end
function DestroyGroup() end
function RemoveRect() end
function CreateTrigger() local value={};triggers[#triggers+1]=value;return value end
function TriggerRegisterPlayerUnitEvent() end
function TriggerAddAction(trigger,action) trigger.action=action end
function DisableTrigger(trigger) trigger.disabled=true end
function DestroyTrigger() end
function GetTriggerEventId() return event end
function GetSummoningUnit() return caster end
function GetSummonedUnit() return summoned end
function GetTriggerUnit() return caster end
function GetSpellAbilityId() return ability end
function CreateTimer() local value={};timers[#timers+1]=value;return value end
function TimerStart(timer,delay,periodic,action) timer.action=action end
function PauseTimer(timer) timer.stopped=true end
function DestroyTimer() end
dofile('src/infrastructure/core.lua')
local original=unit(0)
local session={scope=JTG.CreateScope('session'),active=true,generation=1}
JTG.Controller.session=session;JTG.Controller.generation=1
JTG.TrackSessionGeneratedUnits(session)
local actors=JTG.CreateScope('attempt')
JTG.ScopeAdd(session.scope,function() JTG.DisposeScope(actors) end)
caster=JTG.ScopeTrackUnit(actors,unit(0))
summoned=unit(0,200,0);event='summon';triggers[1].action()
local wolf=summoned
event='effect';ability='AHhb'
local before=scans;triggers[1].action()
assert(scans==before and #timers==0,'Ordinary spells perform replacement scans')
ability='Adec';triggers[1].action()
local split=unit(0,10,10)
timers[1].action()
assert(not split.removed and not original.removed)
JTG.DisposeScope(actors)
assert(wolf.removed and split.removed and caster.removed,'Native products escaped attempt cleanup')
local lateSplit=unit(0,20,20)
timers[2].action()
assert(lateSplit.removed,'Product created after attempt disposal escaped cleanup')
assert(not original.removed,'Original map actor removed')
-- The exit sweep covers unreported products anywhere on the map. Borrowed
-- map state is restored after this sweep, so replacement originals survive.
local orphan=unit(1,10000,10000)
JTG.CleanupSessionGeneratedUnits(session)
assert(orphan.removed and not original.removed)
local restored
JTG.ScopeBorrow(session.scope,function() restored=unit(0,900,900) end)
JTG.DisposeScope(session.scope)
assert(restored and not restored.removed and not original.removed)
session.active=false
local unrelated=unit(0)
triggers[1].action()
assert(not unrelated.removed,'Stale session action remains active')
print('Passed: summon inheritance, split products, late products, original preservation and exit orphan sweep.')

-- Engine-created purchases must follow scene ownership even after dropping.
EVENT_PLAYER_UNIT_PICKUP_ITEM='pickup';EVENT_PLAYER_UNIT_SELL_ITEM='sell'
local items,enumItem,manipulated,sold,buyer,seller={}
local function item(raw) local value={raw=raw};items[#items+1]=value;return value end
function EnumItemsInRect(_,_,callback)
 for _,value in ipairs(items) do if not value.removed and not value.held then enumItem=value;callback() end end
end
function GetEnumItem() return enumItem end
function UnitItemInSlot(u,slot) return u.inventory and u.inventory[slot] end
function GetItemTypeId(value) return value.removed and 0 or value.raw end
function RemoveItem(value) assert(not value.removed,'Item removed twice');value.removed=true end
function GetManipulatedItem() return manipulated end
function GetSoldItem() return sold end
function GetBuyingUnit() return buyer end
function GetSellingUnit() return seller end
local originalItem=item('original')
local originalHeld=item('held-original');original.inventory={[0]=originalHeld};originalHeld.held=original
local itemSession={active=true,scope=JTG.CreateScope('items'),generation=2}
JTG.Controller.session=itemSession;JTG.Controller.generation=2
JTG.TrackSessionGeneratedUnits(itemSession)
local events=triggers[#triggers]
local scene=JTG.CreateScope('shop-scene')
caster=JTG.ScopeTrackUnit(scene,unit(0));buyer=caster;seller=caster
manipulated=item('picked-dropped');manipulated.held=caster
event='pickup';events.action();manipulated.held=nil
local dropped=manipulated
sold=item('purchase');event='sell';events.action()
manipulated=sold;event='pickup';events.action() -- same item: no duplicate disposer
manipulated=originalItem;events.action()
manipulated=originalHeld;events.action()
JTG.DisposeScope(scene)
assert(dropped.removed and sold.removed and not originalItem.removed and not originalHeld.removed)
local orphanItem=item('unreported-drop')
JTG.CleanupSessionGeneratedUnits(itemSession)
assert(orphanItem.removed and not originalItem.removed and not originalHeld.removed)
JTG.DisposeScope(itemSession.scope)
print('Passed: purchased/picked-up/dropped item scene ownership, duplicate-event protection, original ground/inventory preservation and orphan-item exit sweep.')

local removeNative=RemoveUnit
local removals=0
function GetUnitTypeId(value) return value.removed and 0 or 'test' end
RemoveUnit=function(value)
 assert(not value.removed,'Unit removed twice')
 removals=removals+1;removeNative(value)
end
local primary,secondary=JTG.CreateScope('primary-owner'),JTG.CreateScope('duplicate-observer')
local repeated=unit(0)
JTG.ScopeTrackUnit(primary,repeated);JTG.ScopeTrackUnit(primary,repeated);JTG.ScopeTrackUnit(secondary,repeated)
assert(#primary.disposers==1 and #secondary.disposers==0,'Repeated observer added another unit disposer')
JTG.DisposeScope(secondary);assert(not repeated.removed,'Later observer stole ownership')
JTG.DisposeScope(primary);assert(repeated.removed and removals==1)
local replacedScope=JTG.CreateScope('already-replaced');local replaced=JTG.ScopeTrackUnit(replacedScope,unit(0))
RemoveUnit(replaced);JTG.DisposeScope(replacedScope);assert(removals==2,'Replacement was removed again during cleanup')
print('Passed: repeated same/cross-scope unit observations retain one owner/remover and already-removed replacements are skipped.')
