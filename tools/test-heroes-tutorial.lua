-- Real scopes and authored Hero scenes; native mocks observe lifetimes/orders.
JTG={UI={epoch=1,exercisePaused=false}};PLAYER_NEUTRAL_PASSIVE=15;PLAYER_NEUTRAL_AGGRESSIVE=12
PLAYER_COLOR_BLUE,PLAYER_COLOR_RED,PLAYER_COLOR_CYAN,PLAYER_COLOR_PURPLE,PLAYER_COLOR_LIGHT_GRAY=1,0,2,3,8
local units,items,timers,images,tags,sounds,pans,triggers={}, {}, {}, {}, {}, {}, {}, {}
local eventUnit,eventAbility
local createdFrames,questFlashes={},0
function GetTriggerUnit() return eventUnit end
function GetSpellAbilityId() return eventAbility end
local selected
function Player(id) return id end
function FourCC(raw) return raw end
function GetLocalPlayer() return 0 end
function GetHandleId(h) return h end
function CreateUnit(owner,raw,x,y,facing)
 if raw:match('^[A-Z]') then
  for _,old in ipairs(units) do
   assert(old.removed or old.hidden or old.raw~=raw or old.x~=x or old.y~=y,'Replacement created before removing its collision occupant')
  end
 end
 local u={owner=owner,raw=raw,x=x,y=y,facing=facing,life=1000,hp=1000,abilities={},inventory={}}
 if raw:match('^[A-Z]') then u.level=1;u.points=1 end
 units[#units+1]=u;return u
end
function GetUnitTypeId(u) return u and not u.removed and u.raw or 0 end
function GetUnitX(u) return u.x end
function GetUnitY(u) return u.y end
function GetWidgetLife(u) return u.life end
function SetWidgetLife(u,v) u.life=v end
function BlzGetUnitMaxHP(u) return u.hp end
function BlzSetUnitMaxHP(u,v) u.hp=v end
function GetOwningPlayer(u) return u.owner end
function SetUnitOwner(u,v) u.owner=v end
function SetUnitUseFood(u,value) u.useFood=value end
function SetUnitColor(u,v) u.color=v end
function SetUnitAcquireRange(u,v) u.acquire=v end
function SetUnitCreepGuard() end
function RemoveUnit(u) u.removed=true end
function ShowUnit(u,v) u.hidden=not v end
function IsUnitHidden(u) return u.hidden==true end
function PauseUnit(u,v) u.paused=v end
function IsUnitPaused(u) return u.paused==true end
function SetUnitInvulnerable(u,v) u.invulnerable=v end
function SuspendHeroXP(u,v) u.suspended=v end
function SetUnitPathing(u,v) u.pathing=v end
function SetUnitPosition(u,x,y) u.x=x;u.y=y end
function SetHeroLevel(u,v)
 assert(v>u.level,'Do not call SetHeroLevel for a fresh level-1 hero or a decrease')
 assert(not u.suspended,'Level-up attempted while hero XP is suspended')
 u.points=(u.points or 1)+v-(u.level or 1);u.level=v
end
function GetHeroLevel(u) return u.level end
function SetHeroXP(u,v) u.xp=v end
function SetUnitState(u,_,v) u.mana=v end
function GetUnitState() return 1000 end
local xpHandicap,xpHandicapWrites=1,0
function GetPlayerHandicapXP() return xpHandicap end
function SetPlayerHandicapXP(_,value) xpHandicap=value;xpHandicapWrites=xpHandicapWrites+1 end
function SelectHeroSkill(u,raw) if u.points>0 then u.abilities[raw]=(u.abilities[raw] or 0)+1;u.points=u.points-1 end end
function GetUnitAbilityLevel(u,raw) return u.abilities[raw] or 0 end
function UnitAddAbility(u,raw) u.abilities[raw]=1 end
UNIT_IF_DEFENSE_TYPE='defenseType'
function BlzSetUnitIntegerField(u,field,value) assert(field==UNIT_IF_DEFENSE_TYPE);u.defenseType=value;return true end
function BlzSetUnitArmor(u,value) u.armor=value end
ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED='extendedTooltip'
function BlzGetUnitAbility(u,raw)
 if raw~='JHdP' and raw~='JHdM' then return nil end
 u.tooltipAbilities=u.tooltipAbilities or {}
 u.tooltipAbilities[raw]=u.tooltipAbilities[raw] or {}
 return u.tooltipAbilities[raw]
end
function BlzSetAbilityStringLevelField(ability,field,level,text)
 assert(field==ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED and level==0);ability.text=text;return true
end
function BlzUnitHideAbility(u,raw,hidden) assert(raw=='ACsk' and hidden);u.hiddenResistance=true end
function UnitMakeAbilityPermanent() end
function UnitRemoveAbility(u,raw) u.abilities[raw]=nil end
function BlzSetUnitBooleanField(u,field,v) u[field]=v end
UNIT_BF_HERO_HIDE_HERO_INTERFACE_ICON='hiddenHeroIcon'
UNIT_TYPE_STRUCTURE='structure'
local buildings={halt=true,oalt=true,uaod=true,eate=true,ntav=true,hcas=true,ofrt=true,etoe=true,unp2=true,
 hvlt=true,ovln=true,eden=true,utom=true,ngme=true,nmrk=true}
function IsUnitType(u,kind) return kind==UNIT_TYPE_STRUCTURE and buildings[u.raw]==true end
function BlzSetUnitSkin(u,skin) u.skin=skin end
function BlzSetUnitStringField(u,field,value) u[field]=value end
UNIT_SF_NAME='name'
function IssueImmediateOrder(u,order) u.order=order;return true end
function IssueTargetOrder(u,order,target) u.order=order;u.target=target;return true end
function CreateItem(raw,x,y) local i={raw=raw,x=x,y=y};items[#items+1]=i;return i end
function RemoveItem(i) i.removed=true end
function UnitItemInSlot(u,slot) return u.inventory[slot] end
function UnitRemoveItem(u,item) for slot,i in pairs(u.inventory) do if i==item then u.inventory[slot]=nil end end end
function UnitAddItem(u,item) for slot=0,5 do if not u.inventory[slot] then u.inventory[slot]=item;return true end end end
function RemoveItemFromStock() end
function AddItemToStock(shop,raw) shop.stock=shop.stock or {};shop.stock[raw]=true end
function CreateImage(texture,w,h,_,x,y) local i={texture=texture,w=w,h=h,x=x,y=y};images[#images+1]=i;return i end
function SetImageRenderAlways() end
function SetImageAboveWater() end
function ShowImage(i,visible) i.visible=visible end
function DestroyImage(i) i.removed=true end
function CreateTextTag() local t={};tags[#tags+1]=t;return t end
function SetTextTagText(t,text) t.text=text end
function SetTextTagPos(tag,x,y) tag.x=x;tag.y=y end
function SetTextTagColor() end
function SetTextTagPermanent() end
function SetTextTagVisibility(t,v) t.visible=v end
function DestroyTextTag(t) t.removed=true end
function CreateTrigger() local t={events={}};triggers[#triggers+1]=t;return t end
function DestroyTrigger(t) t.disposed=true end
function DisableTrigger() end
function TriggerAddAction(t,fn) t.fn=fn end
function TriggerRegisterPlayerUnitEvent(t,owner,event) t.events[#t.events+1]={owner=owner,event=event} end
function BlzTriggerRegisterFrameEvent() end
function CreateTimer() local t={};timers[#timers+1]=t;return t end
function TimerStart(t,delay,repeating,fn) t.delay=delay;t.fn=fn;t.repeating=repeating end
function PauseTimer(t) t.paused=true end
function DestroyTimer(t) t.disposed=true end
function CreateQuest() return {} end
function DestroyQuest(q) q.removed=true end
function QuestSetTitle(q,v) q.title=v end
function QuestSetDescription(q,v) q.description=v end
function QuestSetIconPath(q,v) q.icon=v end
function QuestSetRequired() end
function QuestSetDiscovered(q,v) q.discovered=v end
function QuestSetEnabled() end
function BlzGetAbilityIcon(raw) return raw end
function BlzCreateFrameByType(_,name)
 local frame={name=name};createdFrames[#createdFrames+1]=frame;return frame
end
function BlzCreateFrame() return {} end
function BlzDestroyFrame(f) f.removed=true end
function BlzFrameSetSize(f,w,h) f.width=w;f.height=h end
function BlzFrameSetAbsPoint(frame,point,x,y) frame.absolute={point,x,y} end
function BlzFrameSetPoint(frame,point,target,targetPoint,x,y) frame.anchor={point,target,targetPoint,x,y} end
function BlzFrameSetAllPoints() end
function BlzFrameSetText(f,v) f.text=v end
function BlzFrameSetVisible(f,v) f.visible=v end
function BlzFrameSetEnable(f,v) f.enabled=v end
function BlzFrameSetAlpha() end
function BlzFrameSetTextColor() end
function BlzFrameSetModel() end
function BlzFrameSetSpriteAnimate() end
function BlzFrameSetLevel() end
function BlzConvertColor() return 0 end
function BlzGetFrameByName() return {} end
function BlzGetOriginFrame() return {} end
function BlzGetTriggerFrame() end
function BlzFrameClearAllPoints() end
function BlzFrameGetChild() end
function ClearSelection() selected=nil end
function SelectUnit(u) selected=u end
function PanCameraToTimed(x,y,duration) pans[#pans+1]={x=x,y=y,duration=duration} end
function ClearTextMessages() end
function DisplayTimedTextToPlayer() end
function GetWorldBounds() return {} end
function CreateGroup() return {} end
function GroupEnumUnitsInRect(g) for _,u in ipairs(units) do if not u.removed then g[#g+1]=u end end end
function FirstOfGroup(g) return g[1] end
function GroupRemoveUnit(g,u) for i,x in ipairs(g) do if x==u then table.remove(g,i);return end end end
function DestroyGroup() end
function RemoveRect() end
local resources={foodcap=100,foodmax=100}
function GetPlayerState(_,state) return resources[state] or 0 end
function SetPlayerState(_,state,value)
 assert(state~='foodcap' and state~='foodmax','Heroes must leave food limits untouched')
 resources[state]=value
end
function GetPlayerAlliance() return true end
local allianceWrites={}
function SetPlayerAlliance(owner,other,kind,value)
 allianceWrites[#allianceWrites+1]={kind=kind,value=value}
end
local time,scale=0,1
GAME_STATE_TIME_OF_DAY="time"
function GetFloatGameState() return time end
function SetFloatGameState(_,v) time=v end
function GetTimeOfDayScale() return scale end
function SetTimeOfDayScale(v) scale=v end
function FlashQuestDialogButton() questFlashes=questFlashes+1 end
function JTG.UI.SetQuestAvailable(v) JTG.UI.questAvailable=v end
function JTG.UI.HideToolbar() end
function JTG.UI.PlayFeedbackSound(cue) sounds[#sounds+1]=cue end
function JTG.UI.RegisterPauseHighlight() return function() end end
function JTG.UI.CreateWelcomeArrow() return {} end
function JTG.UI.ClearWelcomeArrow(a) a.welcomeArrowState=nil end
function JTG.UI.RefreshWelcomeArrow() end
function JTG.UI.StartWelcomeArrow(a) a.welcomeArrowState={active=true} end
function JTG.UI.TickWelcomeArrow() end
function JTG.BorrowCamera() end
function JTG.ResetWorldFog() end
-- Constants passed to mocks are intentionally opaque but distinct.
FRAMEPOINT_CENTER,FRAMEPOINT_TOP,FRAMEPOINT_TOPRIGHT='center','top','topright'
FRAMEPOINT_TOPLEFT,FRAMEPOINT_BOTTOMRIGHT='topleft','bottomright'
PLAYER_STATE_RESOURCE_GOLD,PLAYER_STATE_RESOURCE_LUMBER='gold','lumber'
PLAYER_STATE_RESOURCE_FOOD_CAP,PLAYER_STATE_RESOURCE_FOOD_CAP_CEILING='foodcap','foodmax'
UNIT_STATE_MANA,UNIT_STATE_MAX_MANA='mana','maxmana'
ALLIANCE_PASSIVE,EVENT_PLAYER_UNIT_SELECTED,EVENT_PLAYER_UNIT_SUMMON='passive','selected','summon'
ALLIANCE_SHARED_CONTROL='sharedControl'
EVENT_PLAYER_UNIT_SPELL_EFFECT,EVENT_PLAYER_UNIT_DAMAGED='spellEffect','damaged'
ORIGIN_FRAME_GAME_UI,FRAMEEVENT_CONTROL_CLICK='ui','click'
dofile('src/infrastructure/core.lua')
function JTG.ScopeRevealScene() end
function JTG.ResetWorldFog() end
function JTG.BorrowCamera() end
JTG.Scenes={['arena.south']={centerX=4864,centerY=3456,minX=2048,minY=2048,maxX=7808,maxY=4864},
 ['arena.north']={centerX=4864,centerY=6016,minX=2048,minY=4864,maxX=7808,maxY=7552}}
dofile('src/infrastructure/tutorial.lua')
dofile('src/generated/hotkey-catalog.lua')
dofile('src/generated/heroes-tutorial.lua')
dofile('src/infrastructure/heroes-scenes.lua')
dofile('src/activities/heroes-tutorial.lua')
local session={active=true,scope=JTG.CreateScope('heroes-test'),presentationScope=JTG.CreateScope('heroes-presentation'),generation=1}
local activity=JTG.CreateHeroesTutorialActivity(session);session.activity=activity
JTG.Controller.session=session
JTG.Controller.generation=session.generation
local function step(id) for i,row in ipairs(JTG.HeroesScript.steps) do if row.id==string.format('heroes.%03d',id) then return i end end;error('Missing test stop '..id) end
activity:setup(session);activity:start()
assert(time==12 and scale==0 and not JTG.UI.questAvailable)
assert(xpHandicapWrites==0 and resources.foodcap==100 and resources.foodmax==100)
assert(activity.frames.topicsMenu.width==.185 and activity.frames.topicsMenu.height==JTG.TutorialMenuHeight(8))
assert(activity.frames.optionalMenu.width==.185 and activity.frames.optionalMenu.height==JTG.TutorialMenuHeight(2))
for _,frame in ipairs(createdFrames) do
 assert(not frame.name:find('QuestHint',1,true),'Heroes created a second Quest highlight')
 assert(not frame.name:find('Title',1,true),'Heroes popup has a nonstandard title')
 if frame.name:find('JTGHeroestopics9',1,true) or frame.name:find('JTGHeroesoptional3',1,true) then
  assert(frame.width==.10 and frame.height==.026 and frame.anchor[5]==.025,'Close is not in the standard footer')
 end
end
assert(#activity.groups==5 and #units==30)
assert(pans[#pans].x==4864 and pans[#pans].y==3456,'Showcase did not move to Arena1')
for index,u in ipairs(units) do assert(u.owner==15 and (index<=5)==(buildings[u.raw]==true));if index>5 then assert(u.level==10) end end
for _,u in ipairs(units) do assert(u.useFood==false,'Instructional unit contributes to upkeep') end
local human,orc,undead,elf,tavern=table.unpack(activity.groups)
assert(orc.x-human.x==900 and undead.x-orc.x==900 and orc.y-elf.y==600)
assert(elf.color==2 and undead.color==3 and human.color==1 and orc.color==0 and tavern.color==8)
for _,group in ipairs(activity.groups) do
 local roster=JTG.GetTutorialAltarHeroes(group.altarRaw)
 for index,hero in ipairs(group.heroes) do
  local firstRow=group.id=='neutral' and 5 or 4
  assert(hero.raw==roster[index].raw and hero.color==group.color)
  assert(hero.y==group.y-200-(index<=firstRow and 0 or 350))
 end
end
activity:showStep(step(2));local tour=timers[#timers];local panCount=#pans
activity:showStep(step(3));tour.fn();assert(#pans==panCount+1,'Old altar tour moved the next lesson camera')
activity:restoreCheckpoint(step(7));assert(activity.worldScene=='archmages' and #activity.actors==2)
assert(activity.actors[1].level==1 and activity.actors[2].level==10 and activity.actors[2].points==0)
assert(not activity.frames.plus.visible and pans[#pans].y==6016)
activity.actors[1].x=9000;activity:tickWorld();assert(activity.actors[1].x<=7744)
activity:showStep(step(8));assert(#activity.dummies==1 and #activity.actors==3)
local dummy=activity.dummies[1].unit
assert(dummy.owner==6 and dummy.name=='Target Dummie' and not dummy.paused)
assert(not dummy.level and dummy.raw=='jHdm' and dummy.defenseType==2 and dummy.armor==0,
 'Dummy is classified as a hero or has the wrong initial defense')
assert(activity:adjustDummyArmor(dummy,1) and dummy.armor==1)
assert(activity:adjustDummyArmor(dummy,-1) and activity:adjustDummyArmor(dummy,-1) and dummy.armor==-1)
assert(dummy.tooltipAbilities.JHdP.text=='Current: -1' and dummy.tooltipAbilities.JHdM.text=='Current: -1')
for _,defense in ipairs({3,5,7,0,1,2}) do
 assert(activity:adjustDummyArmor(dummy) and dummy.defenseType==defense and dummy.armor==-1)
 assert((dummy.abilities.ACsk~=nil)==(defense==5),'Hero-duration resistance leaked across armor types')
 if defense==5 then assert(dummy.hiddenResistance,'Passive resistance obscures Raise Armor') end
end
assert(activity:setDummyHostile(dummy,false) and dummy.owner==0)
assert(dummy.abilities.JHdN and not dummy.abilities.JHdH,'Neutral dummy shows two mode buttons')
assert(activity.actors[1].order=='stop' and activity.actors[2].order=='stop')
assert(activity:setDummyHostile(dummy,true) and dummy.owner==6)
assert(dummy.abilities.JHdH and not dummy.abilities.JHdN,'Hostile dummy shows two mode buttons')
assert(activity.actors[1].order=='attack' and activity.actors[1].target==dummy)
assert(not activity:setDummyHostile(activity.actors[1],true), 'Non-dummy changed faction')
activity:showStep(step(9));activity:continueTutorial()
assert(not activity.dummies[1].hostile and activity.actors[1].order=='stop',
 'Archmage dummy stayed hostile after the attack-speed narration')
activity:restoreCheckpoint(step(9))
assert(activity.dummies[1].hostile,'Back did not restore the attack-speed demonstration')
dummy=activity.dummies[1].unit
activity:adjustDummyArmor(dummy,-1)
for _,t in ipairs(triggers) do
 if t.events[1] and t.events[1].event=='spellEffect' then
  eventUnit,eventAbility=dummy,'JHdH';t.fn();assert(dummy.owner==0)
  eventAbility='JHdN';t.fn();assert(dummy.owner==6)
  eventAbility='JHdP';t.fn();assert(dummy.armor==0)
  eventAbility='JHdM';t.fn();assert(dummy.armor==-1)
  eventAbility='JHa3';t.fn();assert(dummy.defenseType==3)
 end
end
assert(activity.actors[1].target==activity.dummies[1].unit and not activity.actors[1].invulnerable)
activity:showDummyDamage(activity.dummies[1].unit,12.5)
local popup=activity.damagePopups[1];assert(popup.tag.visible and popup.tag.text=='12.5')
for i=1,25 do activity:tickWorld() end;assert(not popup.tag.visible)
local attackers=activity.actors
activity:restoreCheckpoint(step(24))
for _,u in ipairs(attackers) do assert(u.removed) end
assert(activity.worldScene=='showcase' and #activity.levelActors==25 and #activity.dummies==5)
for _,record in ipairs(activity.dummies) do assert(not record.hostile and record.unit.owner==0) end
local record=activity.levelActors[1];activity.selectedHero=record.unit;activity:refreshControls()
assert(not record.unit.invulnerable and record.unit.level==1 and record.unit.hiddenHeroIcon and activity.frames.plus.visible and not activity.frames.minus.enabled)
activity:changeHeroLevel(1);assert(record.unit.level==2)
record.unit.abilities.AHbz=1;local old=record.unit
local carried=CreateItem('ratf',0,0);old.inventory[0]=carried
activity:changeHeroLevel(-1)
assert(old.removed and record.unit.x==old.x and record.unit.y==old.y and record.unit.level==1 and not record.unit.abilities.AHbz and record.unit.inventory[0]==carried)
assert(record.unit.order=='stop' and record.unit.acquire==0 and not record.unit.invulnerable)
activity:restoreCheckpoint(step(25));assert(activity.xpQuest.discovered and JTG.UI.questAvailable and #sounds==1 and sounds[1]=='quest')
assert(questFlashes==1,'Quest unlock must use exactly one native flash')
assert(images[#images].w==2400 and images[#images].h==2400 and images[#images].visible)
for _,group in ipairs(activity.groups) do for _,hero in ipairs(group.heroes) do assert(hero.owner==15 and hero.suspended and hero.hidden) end end
activity:restoreCheckpoint(step(28));assert(#activity.actors==8 and activity.gnoll.raw=='ngno')
for _,u in ipairs(activity.actors) do if u.level then assert(u.level==1 and u.xp==199) end end
local army=activity.actors;assert(activity.narrationBlocks[1]:find('Afterwards',1,true))
activity:showStep(step(29));for _,u in ipairs(army) do assert(u.removed) end
activity:restoreCheckpoint(step(37));assert(activity.mountainKing.level==4 and activity.paladin.level==2 and activity.paladin.xp==465)
activity:showStep(step(39));assert(activity.mountainKing.level==5 and math.abs(activity.mountainKing.x-4864)>1200)
assert(activity.narrationBlocks[1]:find('using your entire army',1,true))
activity:showStep(step(40));assert(math.abs(activity.mountainKing.x-4864)>1200 and activity.paladin.xp==465)
activity:openOptional('xp');assert(activity.worldScene=='xp-numbers' and #activity.actors==10 and #sounds==1)
assert(activity.actors[1].raw=='Hpal' and activity.actors[1].skin=='Hart' and activity.actors[10].skin=='Harf')
for i,u in ipairs(activity.actors) do
 assert(u.level==i and u.owner==15)
 assert(u.x==activity.practiceArena.centerX+((i-1)%5-2)*300)
 assert(u.y==activity.practiceArena.centerY+350-math.floor((i-1)/5)*700)
end
local optionalActors=activity.actors;activity:selectXPDisplay('orc')
for _,group in ipairs(activity.xpColumns) do
 for _,summon in ipairs(group.summons) do assert(summon.level==group.level and group.food==group.level) end
 assert(group.x>=activity.practiceArena.minX+750)
end
local shown={};for _,u in ipairs(activity.actors) do shown[u.raw]=true end
assert(shown.owtw and shown.otrb,'Defensive buildings missing from XP display')
for _,u in ipairs(optionalActors) do assert(u.removed) end
for _,u in ipairs(activity.actors) do assert(not u.level,'Racial XP display contains a hero') end
assert(#activity.frames.xpChoices==6,'Neutral XP selector is missing')
local orcActors=activity.actors
activity.actions[GetHandleId(activity.frames.xpChoices[6])].action()
assert(activity.xpNumberChoice=='neutral' and #activity.actors==25)
for _,u in ipairs(orcActors) do assert(u.removed,'Previous racial display leaked into Neutral') end
for _,u in ipairs(activity.actors) do assert(u.color==8 and u.paused and not u.level,'Neutral display is not grey, paused summons only') end
for _,race in ipairs({'human','orc','nightelf','undead','neutral'}) do
 activity:selectXPDisplay(race)
 local structureIds={};local structures={}
 for _,entry in ipairs(JTG.HeroesData.racialUnits[race]) do if entry.building then structureIds[entry.raw]=true end end
 for _,u in ipairs(activity.actors) do
  if structureIds[u.raw] then
   assert(u.x%64==0 and u.y%64==0,'Building display is not aligned to the placement grid')
   for _,other in ipairs(structures) do assert((u.x-other.x)^2+(u.y-other.y)^2>=512^2,'Building display cells overlap') end
   structures[#structures+1]=u
  end
 end
 for _,u in ipairs(activity.actors) do assert(u.raw~='even','Invulnerable Spirit remained in XP display') end
 for _,group in ipairs(activity.xpColumns) do
  if #group.summons>0 then
   local caption
   for _,tag in ipairs(tags) do
    if not tag.removed and tag.text:find('Summon\nUnit Level:',1,true) and tag.x==group.x-80 then caption=tag end
   end
   assert(caption and caption.y==activity.practiceArena.centerY-1000,'Summon caption did not receive the extra 200-unit gap')
   for _,u in ipairs(activity.actors) do
    for _,row in ipairs(group.summons) do if u.raw==row.raw then assert(caption.y>u.y,'Summon caption is below its units') end end
   end
  end
 end
end
activity:continueTutorial();activity:continueTutorial();assert(activity.step==step(40) and not activity.optionalSection)
activity:openOptional('dice');assert(#activity.levelActors==25 and #activity.diceTexts==5)
local before=#timers
activity:continueTutorial();local diceTour=timers[#timers]
assert(pans[#pans].x==activity.diceTexts[1].x)
for index=1,3 do
 local timer=timers[before+index]
 assert(timer.delay==index*2.5,'Dice tour omitted the one-second stationary pause')
 timer.fn()
 local expected=index<3 and activity.diceTexts[index+1].x or
  (activity.diceTexts[4].x+activity.diceTexts[5].x)/2
 assert(pans[#pans].x==expected and pans[#pans].y==activity.diceTexts[1].y)
end
activity:restoreCheckpoint(step(43));diceTour.fn()
assert(activity.worldScene=='items' and #items==50 and resources.gold==10000 and resources.lumber==10000)
local itemIds={}
for _,item in ipairs(items) do if item~=carried then assert(not itemIds[item.raw]);itemIds[item.raw]=true end end
local count,actorCount,savedStep=#units,#activity.actors,activity.step
activity:hidePresentationForMenu();assert(not activity.frames.bar.visible and not activity.frames.xpChoices[1].visible)
activity:restorePresentation();activity:discardPresentationForLoad();activity:rebuildPresentation()
assert(#units==count and #activity.actors==actorCount and activity.step==savedStep and #sounds==1)
activity:restoreCheckpoint(step(50));assert(activity.complete and activity.frames.menuHighlight.visible and not activity.frames.continue.enabled)
activity:goBack();assert(activity.step==step(49) and not activity.complete)
for _,pan in ipairs(pans) do assert(pan.duration==1.5,'Camera move did not use the fixed duration') end
activity:cleanup();JTG.DisposeScope(session.presentationScope);JTG.DisposeScope(session.scope)
for _,u in ipairs(units) do assert(u.removed,'Hero scene unit leaked') end
for _,t in ipairs(timers) do assert(t.disposed,'Hero scene timer leaked') end
for _,i in ipairs(images) do assert(i.removed,'XP circle leaked') end
for _,tag in ipairs(tags) do assert(tag.removed,'Showcase label leaked') end
for _,item in ipairs(items) do if item~=carried then assert(item.removed,'Ground item leaked') end end
assert(time==0 and scale==1,'Daytime lock leaked after exit')
assert(xpHandicapWrites==0,'Unchanged XP rate was rewritten during setup/cleanup')
-- Non-default XP rates still receive the correct demonstration rate and are
-- restored on exit; normal entries must not call the native setter at all.
xpHandicap=.8
local alternate={active=true,scope=JTG.CreateScope('heroes-handicap'),
 presentationScope=JTG.CreateScope('heroes-handicap-ui'),generation=2}
local alternateActivity=JTG.CreateHeroesTutorialActivity(alternate)
alternate.activity=alternateActivity;JTG.Controller.session=alternate
alternateActivity:setup(alternate);assert(xpHandicap==1 and xpHandicapWrites==1)
alternateActivity:cleanup();JTG.DisposeScope(alternate.presentationScope);JTG.DisposeScope(alternate.scope)
assert(xpHandicap==.8 and xpHandicapWrites==2)
JTG.Dev={HeroesAudioSkipSharedControl=true};allianceWrites={}
local isolation={active=true,scope=JTG.CreateScope('heroes-control-isolation'),
 presentationScope=JTG.CreateScope('heroes-control-isolation-ui'),generation=3}
local isolatedActivity=JTG.CreateHeroesTutorialActivity(isolation)
isolation.activity=isolatedActivity;JTG.Controller.session=isolation
isolatedActivity:setup(isolation)
isolatedActivity:cleanup();JTG.DisposeScope(isolation.presentationScope);JTG.DisposeScope(isolation.scope)
for _,write in ipairs(allianceWrites) do
 assert(write.kind~=ALLIANCE_SHARED_CONTROL,'Shared-control A/B test still changed native shared control')
end
print('Passed: 47 authored Hero stops, two optional topics, native rosters/skills, 1200-radius XP scenes, level controls, shops/items, fixed camera tours, ownership isolation, checkpoint replay and complete cleanup.')
