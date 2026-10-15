-- Native key resolution cannot be proven by mocks. This fixture checks event
-- registration, scoring/races, early/paused inputs, and prompt resource cleanup.
JTG={UI={},MeleeTech={'Rhde'}}
local menu,registered,timers,units,stocks={}, {}, {}, {}, {}
function Player(id) return id end
PLAYER_NEUTRAL_PASSIVE=15
function GetPlayerId(player) return player end
function GetOwningPlayer(unit) return unit.owner end
function GetLocalPlayer() return 0 end
function FourCC(value)
    assert(type(value)=='string' and #value==4,'Invalid native FourCC identifier: '..tostring(value))
    return value
end
function UnitId2String(value) return value end
function GetRandomInt(low) return low end
function GetHandleId(value) return value end
function ConvertOsKeyType(value) return value end
OSKEY_ESCAPE=27
local selected,keyDown,currentKey
function ClearSelection() selected=nil end
local reveal
function SelectUnit(unit)
    if unit.owner==PLAYER_NEUTRAL_PASSIVE and unit.sight==0 and not
        (reveal and unit.x>=reveal.x1 and unit.x<=reveal.x2 and unit.y>=reveal.y1 and unit.y<=reveal.y2) then
        selected=nil;return
    end
    selected=unit
end
function JTG.ScopeRevealRect(scope,player,x1,y1,x2,y2)
    assert(player==0)
    reveal={scope=scope,x1=x1,y1=y1,x2=x2,y2=y2}
end
function IsUnitSelected(unit) return unit==selected end
function ForceUICancel() end
function IsFogEnabled() return true end
function IsFogMaskEnabled() return true end
function FogEnable() end
function FogMaskEnable() end
local camera={}
function SetCameraPosition(x,y) camera.x,camera.y=x,y end
function GetWorldBounds() return {} end
function GetRectMinX() return -8192 end
function GetRectMaxX() return 8192 end
function GetRectMinY() return -8192 end
function GetRectMaxY() return 8192 end
function RemoveRect() end
function BlzFrameClick() end
local nativeFrames={}
ORIGIN_FRAME_COMMAND_BUTTON='command'
ORIGIN_FRAME_TOOLTIP='tooltip'
function BlzGetOriginFrame(kind,index)
    local key=kind==ORIGIN_FRAME_TOOLTIP and 'tooltip' or index
    nativeFrames[key]=nativeFrames[key] or {alpha=255}
    return nativeFrames[key]
end
function BlzFrameGetAlpha(frame) return frame.alpha end
function BlzFrameSetAlpha(frame,value) frame.alpha=value end
local customPositions={}
local function abilityPosition(raw)
    if customPositions[raw] then return customPositions[raw][1],customPositions[raw][2] end
    for _,entry in ipairs(JTG.HotkeyCatalog or {}) do
        if entry.kind=='ability' and (entry.activeAbility or entry.ability)==raw and entry.nativeSlot then
            return entry.nativeSlot%4,math.floor(entry.nativeSlot/4)
        end
    end
    return 0,2
end
function BlzGetAbilityPosX(raw) local x=abilityPosition(raw);return x end
function BlzGetAbilityPosY(raw) local _,y=abilityPosition(raw);return y end
local frameTriggers={}
function BlzTriggerRegisterFrameEvent(trigger,frame)
    for index=0,11 do assert(frame~=nativeFrames[index],'Trainer overwrites a native command-button handler') end
    frameTriggers[#frameTriggers+1]=trigger;return {}
end
local clickedFrame
function BlzGetTriggerFrame() return clickedFrame end
function TriggerRegisterGameEvent() return {} end
EVENT_GAME_BUILD_SUBMENU='build-submenu'
EVENT_GAME_SHOW_SKILL='skill-menu'
function BlzCreateFrameByType(kind,name) return {kind=kind,name=name} end
function BlzFrameSetSize(frame,w,h) frame.w,frame.h=w,h end
function BlzFrameSetVisible(frame,value) frame.visible=value end
function BlzFrameSetText(frame,value) frame.text=value end
function BlzFrameSetTexture(frame,value) frame.texture=value end
function BlzFrameSetAbsPoint() end
function BlzFrameSetPoint() end
function BlzFrameSetAllPoints() end
function BlzFrameClearAllPoints() end
function BlzFrameSetEnable() end
function BlzFrameSetVertexColor() end
function BlzFrameSetTextAlignment() end
function BlzFrameSetScale(frame,value) frame.scale=value end
function BlzFrameSetLevel(frame,value) frame.level=value end
function BlzGetAbilityExtendedTooltip() return 'Native ability description' end
function BlzGetAbilityResearchExtendedTooltip() return 'Native skill description' end
function BlzConvertColor() return 0 end
function CreateUnit(owner,raw,x,y)
    local unit={owner=owner,raw=raw,x=x+(raw=='Hpal' and 1000 or 0),y=y}
    units[#units+1]=unit;return unit
end
function GetUnitX(unit) return unit.x end
function GetUnitY(unit) return unit.y end
function SetUnitX(unit,value) unit.x=value end
function SetUnitY(unit,value) unit.y=value end
function IssueNeutralTargetOrderById(player,shop,order,buyer)
    assert(player==0 and order==852566 and buyer.inventory,'Invalid patron order or inventory')
    assert(buyer.x-shop.x==100 and buyer.y==shop.y,'Patron pushed out of range by building placement')
    return true
end
function GetUnitTypeId(unit) return unit.raw end
function SetUnitPathing() end
function SetUnitInvulnerable() end
function SetUnitAcquireRange() end
UNIT_BF_IS_A_BUILDING='building'
ABILITY_RLF_DURATION_NORMAL='duration'
function BlzGetUnitBooleanField(unit,field)
    assert(field==UNIT_BF_IS_A_BUILDING)
    return unit.rooted==true
end
function BlzGetUnitAbility(unit,raw)
    assert(raw=='Aro1' or raw=='Aro2')
    if unit.raw=='etrp' and raw=='Aro1' then return nil end
    return unit
end
function BlzGetAbilityRealLevelField(ability,field,level)
    assert(field==ABILITY_RLF_DURATION_NORMAL and level==0);return 2.5
end
UNIT_RF_SIGHT_RADIUS='sight'
function BlzSetUnitRealField(unit,field,value)
    assert(field==UNIT_RF_SIGHT_RADIUS and value==0)
    unit.sight=value
    return true
end
function SetFogStateRect() end
function SetUnitVertexColor() end
function IsUnitType(unit) return unit.raw:match('^[A-Z]')~=nil end
function SetHeroLevel(unit,level) unit.heroLevel=level end
function SelectHeroSkill(unit,raw) unit.skills=unit.skills or {};unit.skills[raw]=(unit.skills[raw] or 0)+1 end
function UnitAddAbility(unit,raw) if raw=='AInv' then unit.inventory=true end end
function SetUnitAbilityLevel() end
function BlzUnitDisableAbility(unit,raw,disabled) assert(not disabled);unit.enabledAbility=raw end
function UnitResetCooldown(unit) unit.cooldownReset=true end
function GetUnitAbilityLevel(unit,raw) return (unit and unit.skills and unit.skills[raw]) or 1 end
function SetUnitState() end
function GetUnitState() return 100 end
function IssueImmediateOrder(unit,order)
    unit.setupOrder=order;unit.setupOrderCount=(unit.setupOrderCount or 0)+1;return true
end
function IssueTargetOrder(unit,order,target)
    unit.preparedOrder=order;unit.preparedTarget=target
    if order=='smart' and target.raw=='otrb' then unit.transport=target end
    return true
end
function IsUnitInTransport(unit,transport) return unit.transport==transport end
function IssuePointOrder(unit,order,x,y) unit.preparedOrder=order;return true end
function SetResourceAmount(unit,amount) unit.resources=amount end
function CreateCorpse(owner,raw,x,y) local unit=CreateUnit(owner,raw,x,y,0);unit.corpse=true;return unit end
GAME_STATE_TIME_OF_DAY='time'
local gameTime,gameTimeScale=12,1
function GetFloatGameState() return gameTime end
function SetFloatGameState(_,value) gameTime=value end
function GetTimeOfDayScale() return gameTimeScale end
function SetTimeOfDayScale(value) gameTimeScale=value end
function AddItemToStock(source,raw) stocks[#stocks+1]={source=source,raw=raw} end
function AddUnitToStock(source,raw) stocks[#stocks+1]={source=source,raw=raw} end
function RemoveItem(item) item.removed=true end
local tech,states={},{}
local limits={}
function GetPlayerTechMaxAllowed(_,raw) return limits[raw] or 0 end
function SetPlayerTechMaxAllowed(_,raw,value) limits[raw]=value end
function GetPlayerTechCount(_,raw) return tech[raw] or 0 end
function SetPlayerTechResearched(_,raw,value) tech[raw]=value end
function BlzDecPlayerTechResearched(_,raw,value) tech[raw]=(tech[raw] or 0)-value end
function GetPlayerState(_,state) return states[state] or 5 end
function SetPlayerState(_,state,value) states[state]=value end
PLAYER_STATE_RESOURCE_GOLD,PLAYER_STATE_RESOURCE_LUMBER='gold','lumber'
PLAYER_STATE_RESOURCE_FOOD_CAP,PLAYER_STATE_FOOD_CAP_CEILING='food','ceiling'
function CreateTrigger() return {} end
function TriggerAddAction(trigger,action) trigger.action=action end
function TriggerRegisterCommandEvent(trigger,ability,order)
    registered[#registered+1]={trigger=trigger,ability=ability,order=order};return {}
end
function TriggerRegisterUpgradeCommandEvent(trigger,raw)
    registered[#registered+1]={trigger=trigger,upgrade=raw};return {}
end
local nativeRegistrations={}
function TriggerRegisterPlayerUnitEvent(trigger,player,event)
    nativeRegistrations[#nativeRegistrations+1]={trigger=trigger,event=event}
end
local nativeEvent,nativeOrder
function GetTriggerEventId() return nativeEvent end
function GetIssuedOrderId() return nativeOrder end
function OrderId(value) return value end
function GetUnitCurrentOrder(unit) return unit.currentOrder or 0 end
function TriggerRegisterPlayerChatEvent() end
function BlzTriggerRegisterPlayerKeyEvent(trigger) trigger.keys=true end
function GetTriggerPlayer() return 0 end
function GetTriggerUnit() return selected end
function BlzGetTriggerPlayerKey() return currentKey end
function BlzGetTriggerPlayerIsKeyDown() return keyDown end
function DisplayTimedTextToPlayer() end
function CreateFogModifierRect() return {} end
function FogModifierStart() end
function JTG.CreateScope() return {} end
function JTG.ScopeAdd(scope,action) scope[#scope+1]=action end
function JTG.DisposeScope(scope)
    if scope.disposed then return end
    scope.disposed=true
    for index=#scope,1,-1 do scope[index]() end
end
JTG.ScopeBorrow=JTG.ScopeAdd
function JTG.ScopeTrackUnit(scope,unit) JTG.ScopeAdd(scope,function() unit.removed=true end);return unit end
function JTG.CreateScopedUnit(scope,...) return JTG.ScopeTrackUnit(scope,CreateUnit(...)) end
function JTG.ScopeTrackTrigger(scope,trigger) JTG.ScopeAdd(scope,function() trigger.disabled=true end);return trigger end
function JTG.ScopeTrackFrame(_,frame) return frame end
function JTG.ScopeTrackFogModifier(_,fog) return fog end
function JTG.GuardSession(session,action) return function() if session.active then action() end end end
function JTG.StartScopedTimer(_,_,_,_,action) timers[#timers+1]=action end
function JTG.BorrowCamera() end
function JTG.ResetWorldFog() end
function JTG.UI.CreateResultCard() return {} end
function JTG.UI.ShowResultCard(card,spec) card.spec=spec end
function JTG.UI.HideResultCard() end
function JTG.UI.ShowToolbar() end
function JTG.UI.HideToolbar() end
function JTG.UI.ShowActivityBriefing(spec) menu=spec end
function JTG.UI.SetGameplayMenuPaused() end
function JTG.UI.ShowCategory() end
function JTG.UI.AttachActivityTooltip(_,button,description)
    local tooltip={text=description}
    button.tooltip=tooltip
    return tooltip,{},function(value) tooltip.text=value end
end
function JTG.ResumeActivity() end
function JTG.StopActivity() end
local launched
function JTG.StartActivityAfterCleanup(id,category,data) launched={id=id,data=data} end
EVENT_PLAYER_UNIT_SPELL_CHANNEL='spell'
EVENT_PLAYER_UNIT_SPELL_CAST='spell-cast'
EVENT_PLAYER_UNIT_SPELL_EFFECT='spell-effect'
EVENT_PLAYER_UNIT_TRAIN_START='train'
EVENT_PLAYER_UNIT_TRAIN_FINISH='trained'
EVENT_PLAYER_UNIT_RESEARCH_START='research'
EVENT_PLAYER_UNIT_UPGRADE_START='upgrade'
EVENT_PLAYER_UNIT_SELL_ITEM='buy'
EVENT_PLAYER_UNIT_SELL='hire'
EVENT_PLAYER_UNIT_ISSUED_ORDER='order'
EVENT_PLAYER_UNIT_SUMMONED='summon'
dofile('src/infrastructure/training.lua')
dofile('src/infrastructure/tutorial.lua')
dofile('src/generated/exercise-briefings.lua')
dofile('src/generated/hotkey-catalog.lua')
local catalog=JTG.HotkeyCatalog
dofile('src/activities/hotkey-training.lua')
assert(JTG.Training.ResponseAward(1)==15 and JTG.Training.ResponseAward(1.01)==10 and JTG.Training.ResponseAward(5)==10 and JTG.Training.ResponseAward(5.01)==0)
JTG.OpenHotkeyTrainingMenu('tools',false)
assert(menu.choices[1].label=='Start Training' and menu.headingArtwork:find('HotkeyTrainingBriefing'))
assert(menu.centerSingleChoice and not menu.choices[1].x,'Main briefing overrides standard centered action')
menu.choices[1].action();assert(#menu.choices==5 and menu.pageId=='race')
for index,choice in ipairs(menu.choices) do
    assert(not choice.width and not choice.height and not choice.y,'Race selector bypasses shared layout')
    assert(choice.iconOffsetX==0.051 and (index~=5 or choice.x==0),'Race icon/Neutral alignment differs from shared style')
end
menu.choices[5].action();assert(launched.id=='tools.hotkeys' and launched.data.race=='neutral')
local listCount=0
for race,pool in pairs(JTG.HotkeyPools) do
    listCount=listCount+1
    local seen={}
    for _,entry in ipairs(pool) do
        assert(not seen[entry.id] and not JTG.HotkeyUnverified[entry.id],'Duplicate or unresolved practice prompt: '..entry.id)
        seen[entry.id]=true
        assert(entry.race==race or entry.race=='common','Practice list leaks another race: '..entry.id)
        if entry.raw=='root' or entry.raw=='uproot' then assert(race=='nightelf','Ancient command in another race list') end
    end
end
assert(listCount==5,'Expected five independent practice lists')
local session={active=true,scope={},presentationScope={},descriptor={capabilities={menu=true}},scene={centerX=4864,centerY=3456}}
BlzGetOriginFrame(ORIGIN_FRAME_TOOLTIP,0) -- native tooltip exists before the trainer
local activity=JTG.CreateHotkeyTrainingActivity(session)
activity:setup();assert(#units==0,'Startup creates units before choosing a prompt')
assert(not activity.diagnostics and not activity:runDiagnostics('tick'),'Production attached developer behavior')
local holy,shield
for _,entry in ipairs(catalog) do
    if entry.id=='human.Hpal.ability.AHhb' then holy=entry end
    if entry.id=='human.Hpal.ability.AHds' then shield=entry end
end
activity.pool={holy,shield};activity:start(nil,activity.pool[1])
assert(#units==1,'Holy Light prompt needs only one Paladin')
assert(activity.prompt.raw=='AHhb' and registered[#registered].ability==0 and registered[#registered].order=='holybolt')
assert(activity.sourceIcon.w==0.064 and activity.sourceIcon.h==0.064)
assert(activity.panel.w==0.32 and activity.panel.h==0.17)
assert(nativeFrames[0].alpha==255,'Native command grid should remain visible')
nativeFrames[0].alpha=37
assert(not activity.setNativeCardHidden,'Production still exposes command-card hiding')
assert(nativeFrames[0].alpha==37,'Trainer overwrites opacity updated by Warcraft')
nativeFrames[0].alpha=255
for _,entry in ipairs(catalog) do
    assert(entry.raw~='escape' and entry.order~='cancel' and entry.name~='Cancel','Cancel remains in rotation')
end
activity:onKey(81);assert(not activity.pending,'Selection arm delay accepted input')
activity.elapsed=0.5
registered[#registered].trigger.action() -- Native event can arrive before key event.
activity:onKey(81);activity.elapsed=0.61;activity:resolveInput()
assert(activity.correct==1 and activity.score==15 and activity.advance)
local old=activity.source
activity.advance=false;activity:nextPrompt(shield);assert(old.removed,'Previous native unit leaked')
activity.elapsed=1
activity:onKey(84);activity.elapsed=1.12;activity:resolveInput()
assert(activity.incorrect==0 and activity.pending,'Key graded before native confirmation could arrive')
activity.elapsed=1.51;activity:resolveInput()
assert(activity.incorrect==1 and activity.score==5 and activity.prompt.raw=='AHds','Incorrect key advanced prompt')
activity:refreshStatus()
assert(activity.status.text:find('Time: 59s',1,true) and not activity.status.text:find('Time: 59.',1,true),'Countdown contains fractional seconds')
activity:setPaused(true);activity:onKey(81);assert(not activity.pending)
activity:setPaused(false);activity:onKey(81);activity:hidePresentationForMenu();assert(not activity.pending and not activity.cover)
activity:restorePresentation();assert(not activity.cover and activity.lowerCover.visible)
assert(nativeFrames[0].alpha==255)
assert(nativeFrames.tooltip.alpha==255,'Native tooltip should remain visible')
activity:hidePresentationForMenu()
assert(nativeFrames.tooltip.alpha==255,'Native hover tooltip not restored for menu')
for _,tooltip in ipairs(activity.customTooltips) do assert(tooltip.visible==false) end
activity:restorePresentation()
activity.elapsed=6.8
activity:onKey(82);registered[#registered].trigger.action();activity.elapsed=6.92;activity:resolveInput()
assert(activity.correct==2 and activity.score==5,'Slow answer must score zero')
activity.elapsed=59.99;timers[#timers]()
assert(activity.finished and activity.resultCard.spec.details:find('High score: 5',1,true))
assert(activity.source.removed and not selected)
activity:cleanup();JTG.DisposeScope(session.scope)
assert(states.gold==5 and (tech.Rhde or 0)==0,'Borrowed resources/research not restored')
assert(nativeFrames[0].alpha==255,'Native card alpha was not restored')
assert(nativeFrames.tooltip.alpha==255,'Native tooltip alpha was not restored')
for _,unit in ipairs(units) do
    assert(unit.removed,'Context or prerequisite leaked')
    assert(unit.sight==0,'Hotkey actor retains sight during covered practice')
end

local seen,counts={},{}
for _,entry in ipairs(catalog) do
    assert(not seen[entry.id]);seen[entry.id]=true
    assert(entry.icon:find('ReplaceableTextures',1,true) and entry.sourceIcon:find('ReplaceableTextures',1,true))
    if entry.kind=='ability' then assert(entry.order and entry.ability==entry.raw) end
    if entry.kind=='build' then assert(entry.openSlot and entry.ability and entry.buildIcon and entry.buildOrder) end
    counts[entry.race]=(counts[entry.race] or 0)+1
end
for _,race in ipairs({'human','orc','nightelf','undead','neutral','common'}) do assert(counts[race]>0) end
assert(seen['human.hbla.research.Rhme.level2'] and seen['human.hbla.research.Rhme.level3'],
    'Second/third research levels are absent from the rotation')
assert(seen['orc.ofor.research.Rosp.level2'] and not seen['orc.ofor.research.Rosp.level3'],
    'Research rotation does not respect the native maximum level')
assert(seen['neutral.nmr3.hire.nitp'] and seen['neutral.nmr2.hire.ngnw'] and seen['neutral.nmer.hire.nfsp'])
assert(seen['nightelf.eden.buy.moon'] and seen['undead.utom.buy.rnec'],'Native racial shop items missing')
local prerequisites={}
for _,raw in ipairs(JTG.HotkeyPrerequisites) do prerequisites[raw]=true end
assert(prerequisites.hcas and prerequisites.ostr and prerequisites.ofrt and prerequisites.etoe and prerequisites.unp2,
    'Upgraded building prerequisites missing')
local build,devour
for _,entry in ipairs(catalog) do
    if entry.id=='orc.opeo.build.otto' then build=entry end
    if entry.id=='orc.okod.ability.Adev' then devour=entry end
end
local buildSession={active=true,scope={},presentationScope={},restartData={race='orc'},
    descriptor={capabilities={menu=true}},scene={centerX=4864,centerY=3456}}
local buildActivity=JTG.CreateHotkeyTrainingActivity(buildSession)
buildActivity:setup();buildActivity.pool={build,devour};buildActivity:start(nil,buildActivity.pool[1])
assert(buildActivity.buildIcon.visible and buildActivity.buildIcon.texture==build.buildIcon and buildActivity.panel.w==0.37)
assert(#buildActivity.promptPrerequisites==1 and buildActivity.promptPrerequisites[1]=='ostr',
    'Tauren Totem requires only a Stronghold alongside the Peon')
assert(buildActivity.commandButton.tooltip==nil,'Diagnostic icon still has a custom hover handler')
assert(buildActivity.buildButton.kind=='BACKDROP','Build icon intercepts native input')
buildActivity.elapsed=0.4
registered[#registered].trigger.action() -- Open Build submenu.
buildActivity:onKey(66);buildActivity.elapsed=0.52;buildActivity:resolveInput()
assert(buildActivity.incorrect==0 and buildActivity.correct==0 and not buildActivity.pending,
    'Build prefix was penalized or left an input pending')
buildActivity.elapsed=1.3
local target
for _,event in ipairs(registered) do if event.ability=='AObu' and event.order=='otto' then target=event end end
target.trigger.action();buildActivity:onKey(88);buildActivity.elapsed=1.42;buildActivity:resolveInput()
assert(buildActivity.correct==1 and buildActivity.score==10,'Delayed building key was not accepted')
buildActivity.advance=false;buildActivity:nextPrompt(devour);assert(buildActivity.prompt==devour)
buildActivity.elapsed=2
registered[#registered].trigger.action();buildActivity:onKey(81);buildActivity.elapsed=2.12;buildActivity:resolveInput()
assert(buildActivity.correct==2 and buildActivity.logs[#buildActivity.logs].origin=='command-button',
    'Devour native command was not recognized')
buildActivity:cleanup();JTG.DisposeScope(buildSession.scope)
local speed
for _,entry in ipairs(catalog) do
    if entry.kind=='buy' then assert(entry.name~=entry.raw,'Shop prompt displays raw item ID: '..entry.raw) end
    if entry.id=='orc.ovln.buy.shas' then speed=entry end
end
assert(speed and speed.name=='Scroll of Speed','Scroll of Speed name missing')
local shopSession={active=true,scope={},presentationScope={},restartData={race='orc'},
    descriptor={capabilities={menu=true}},scene={centerX=4864,centerY=3456}}
local shopActivity=JTG.CreateHotkeyTrainingActivity(shopSession)
shopActivity:setup();shopActivity.pool={speed,devour};shopActivity:start(nil,shopActivity.pool[1])
assert(shopActivity.patronAccepted and shopActivity.buyer.inventory,'Shop lacks a valid assigned patron')
assert(#shopActivity.promptPrerequisites==0,'Scroll of Speed should not spawn prerequisite buildings')
for _,unit in ipairs(units) do
    if not unit.removed then
        assert(unit.raw~='hcas' and unit.raw~='etoe' and unit.raw~='unp2',
            'Orc session spawned other races\' prerequisite buildings')
    end
end
shopActivity:cleanup();JTG.DisposeScope(shopSession.scope)
assert(shopActivity.buyer.removed,'Shop patron leaked on exit')
local ancientSession={active=true,scope={},presentationScope={},restartData={race='nightelf'},
    descriptor={capabilities={menu=true}},scene={centerX=4864,centerY=3456}}
local ancients=JTG.CreateHotkeyTrainingActivity(ancientSession)
ancients:setup()
local count=0
for _,prepared in pairs(ancients.preparedAncients) do
    count=count+1
    assert(prepared.unit.setupOrder=='unroot' and not prepared.unit.removed)
end
assert(count==8,'Night Elf selection must prepare the eight Ancient types')
local rootPrompt
for _,entry in ipairs(catalog) do if entry.raw=='root' then rootPrompt=entry end end
local prepared=ancients.preparedAncients.etol.unit
prepared.currentOrder='unroot'
assert(not ancients:ancientReady('etol'),'Preparing Ancient entered rotation')
ancients.elapsed=ancients.preparedAncients.etol.readyAt
assert(ancients:ancientReady('etol'),'Completed transition blocked by retained Uproot order')
prepared.rooted=true
assert(not ancients:ancientReady('etol'),'Rooted building accepted despite completed timer')
prepared.rooted=false
ancients:nextPrompt(rootPrompt)
assert(ancients.source==prepared and prepared.setupOrderCount==1,'Take Root restarted uprooting instead of reusing prepared Ancient')
assert(prepared.x==4864 and prepared.y==ancients.spawnY,'Prepared Ancient not moved into prompt position')
assert(ancients.preparedAncients.etol.unit~=prepared,'No replacement is preparing')
local replacement=ancients.preparedAncients.etol.unit
ancients:cleanup()
assert(prepared.removed and replacement.removed,'Prepared Ancients leaked on exit')
JTG.DisposeScope(ancientSession.scope)
-- Audit every prompt context, including passive hero skills and research.
for _,entry in ipairs(catalog) do
    assert(not entry.description:find('<',1,true),'Unresolved command tooltip: '..entry.id)
    assert(entry.kind~='ability' or not entry.icon:find('PASBTN',1,true),'Passive button entered active rotation: '..entry.id)
    assert(not (entry.source=='ubsp' and entry.raw=='Aave'),'Destroyer tested transformation from its already transformed form')
    assert(not entry.sourceDescription:find('<',1,true),'Unresolved source tooltip: '..entry.id)
    if entry.kind=='train' or entry.kind=='research' then
        assert(entry.nativeSlot and entry.nativeSlot>=0 and entry.nativeSlot<12,'Missing native button position: '..entry.id)
    end
    local probeSession={active=true,scope={},presentationScope={},restartData={race=entry.race},
        descriptor={capabilities={menu=true}},scene={centerX=4864,centerY=3456}}
    local probe=JTG.CreateHotkeyTrainingActivity(probeSession)
    local originalResearch=entry.id=='human.hbla.research.Rhme.level2' and 3 or 0
    if entry.kind=='research' then tech[entry.raw]=originalResearch end
    probe:setup();probe.pool={entry};probe:start(probeSession,entry)
    if entry.kind=='buy' or entry.kind=='hire' or entry.kind=='train' or entry.kind=='research' or
        entry.kind=='upgrade' or entry.kind=='build' then
        assert(states.gold==1000 and states.lumber==1000,'Prompt inherited an exhausted budget: '..entry.id)
    end
    if entry.kind=='buy' or entry.kind=='hire' then
        local neutral=entry.source=='ntav' or entry.source=='ngad' or entry.source=='ngme' or
            entry.source=='nmer' or entry.source=='nmr2' or entry.source=='nmr3'
        assert(probe.source.owner==(neutral and PLAYER_NEUTRAL_PASSIVE or 0),'Wrong shop owner: '..entry.id)
    end
    if entry.id=='orc.obar.train.ohun' then assert(tech.Robk==0,'Berserker Upgrade replaced requested Headhunter') end
    if entry.raw=='Amed' then assert(probe.source.preparedOrder=='loadcorpse','Drop Corpse lacks stored-corpse preparation') end
    if entry.raw=='Adro' then assert(probe.source.preparedOrder=='load','Unload has no passenger preparation') end
    if entry.raw=='Aeat' then assert(probe.source.setupOrder=='unroot','Eat Tree source is rooted: '..entry.id) end
    if entry.raw=='root' or entry.uprooted then
        assert(probe.source.setupOrder=='unroot','Uprooted prompt has no preparation: '..entry.id)
        assert(not probe:sourcePreparationReady(),'Prompt accepts input during uprooting')
        probe.elapsed=probe.activePreparedAncient.readyAt
        probe.source.currentOrder='unroot'
        probe.source.rooted=true
        assert(not probe:sourcePreparationReady(),'Rooted building accepted as uprooted')
        probe.source.rooted=false
        assert(probe:sourcePreparationReady(),'Completed uprooting does not unlock prompt')
    end
    if entry.autocastOff and entry.autocastOff~='' then
        assert(probe.source.setupOrder==entry.autocastOff,'Autocast not disabled: '..entry.id)
        if entry.raw=='Anh1' then
            assert(entry.order=='creepheal' and entry.autocastOff=='creephealoff','Neutral Heal uses Priest orders')
        end
        if entry.raw=='AHfa' then
            assert(entry.order=='flamingarrowstarg' and entry.autocastOff=='unflamingarrows','Searing Arrows uses autocast order for manual targeting')
        elseif entry.raw=='Ambt' then
            assert(entry.order=='recharge' and entry.autocastOff=='rechargeoff','Moon Well uses invalid replenish order')
        elseif entry.raw=='ANia' then
            assert(entry.autocastOff=='incineratearrowoff','Incinerate setup enables autocast')
        end
    end
    if entry.raw=='Ashm' then assert(gameTime==0 and gameTimeScale==0,'Hide requires night: '..entry.id) end
    if entry.kind=='research' then
        assert(tech[entry.raw]==(entry.researchLevel or 1)-1,'Incorrect preceding research level: '..entry.id)
        for raw,level in pairs(entry.requiredResearch or {}) do
            assert(tech[raw]==level,'Missing research prerequisite: '..entry.id)
        end
    end
    if entry.heroRecruitment then
        assert(limits.HERO==-1,'Hero group limit blocks altar: '..entry.id)
        if entry.kind=='train' then
            local mains={human={'htow','hkee','hcas'},orc={'ogre','ostr','ofrt'},
                nightelf={'etol','etoa','etoe'},undead={'unpl','unp1','unp2'}}
            local present=false
            for _,raw in ipairs(mains[entry.race] or {}) do
                for _,created in ipairs(probe.promptPrerequisites) do if created==raw then present=true end end
            end
            assert(present,'Altar hero prompt lacks main building: '..entry.id)
            assert(entry.requiredUnits[mains[entry.race][3]]==1,'Altar prompt lacks tier three: '..entry.id)
        end
    end
    if entry.kind=='learn' then
        assert(probe.source.heroLevel==6 and not probe.source.skills,'Learning prompt spent skill points: '..entry.id)
        assert(probe.buildIcon.visible and probe.panel.w==0.37)
        probe.elapsed=0.5;probe:nativePrefix();probe:onKey(79);probe.elapsed=0.61;probe:resolveInput()
        assert(probe.incorrect==0 and probe.skillMenuOpen,'Skill-menu prefix was penalized')
        probe:nativeMatched('command-button');probe:onKey(81);probe.elapsed=0.72;probe:resolveInput()
        assert(probe.correct==1,'Learn button not recognized: '..entry.id)
    elseif entry.kind=='train' or entry.kind=='research' then
        probe.elapsed=0.5;registered[#registered].trigger.action();probe:onKey(81);probe.elapsed=0.61;probe:resolveInput()
        assert(probe.correct==1,'Production/research event route failed: '..entry.id)
    end
    if entry.kind=='ability' and next(entry.heroSkills) then
        assert(probe.source.heroLevel==10,'Casting prompt has wrong hero level')
        for raw,levels in pairs(entry.heroSkills) do assert(probe.source.skills[raw]==levels,'Unlearned hero skill: '..entry.id) end
    end
    if entry.id=='orc.ofor.research.Rosp' then
        assert(entry.description:find('5 damage',1,true) and entry.description:find('20%',1,true))
        assert(not entry.description:find('Further increases',1,true),'Multiple research levels concatenated')
    end
    probe:cleanup();JTG.DisposeScope(probeSession.scope)
    if entry.kind=='research' then
        assert((tech[entry.raw] or 0)==originalResearch,'Original research level not restored: '..entry.id)
        tech[entry.raw]=0
    end
    if limits[entry.raw] then assert(limits[entry.raw]==0,'Technology limit leaked: '..entry.id) end
    assert((limits.HERO or 0)==0,'Hero group limit leaked')
end
-- Form prompts must describe the command actually available in their native
-- starting form. Returning from a form also needs a completed setup cast;
-- an accepted order alone does not prove that the native morph has finished.
local morphCases={
    {'Acpf','ospm','ospw','corporealform','Corporeal Form','BTNEtherealFormOn.blp','BTNSpiritwalker.blp'},
    {'Acpf','ospw','ospm','uncorporealform','Ethereal Form','BTNSpiritwalker.blp','BTNEtherealFormOn.blp'},
    {'Abrf','edoc','edcm','bearform','Bear Form','BTNDruidOfTheClaw.blp','BTNBearForm.blp'},
    {'Abrf','edcm','edoc','unbearform','Night Elf Form','BTNBearForm.blp','BTNDruidOfTheClaw.blp'},
    {'Arav','edot','edtm','ravenform','Storm Crow Form','BTNDruidOfTheTalon.blp','BTNRavenForm.blp'},
    {'Arav','edtm','edot','unravenform','Night Elf Form','BTNRavenForm.blp','BTNDruidOfTheTalon.blp'},
    {'Astn','ugar','ugrm','stoneform','Stone Form','BTNGargoyle.blp','BTNStoneForm.blp'},
    {'Astn','ugrm','ugar','unstoneform','Gargoyle Form','BTNStoneForm.blp','BTNGargoyle.blp'},
    {'Abur','ucry','ucrm','burrow','Burrow','BTNCryptFiend.blp','BTNCryptFiendBurrow.blp'},
    {'Abur','ucrm','ucry','unburrow','Unburrow','BTNCryptFiend.blp','BTNCryptFiendUnBurrow.blp'},
    {'ANrg','Ntin','Nrob','robogoblin','Robo-Goblin','BTNHeroTinker.blp','BTNROBOGOBLIN.blp'},
    {'ANrg','Nrob','Ntin','unrobogoblin','Revert to Tinker Form','BTNROBOGOBLIN.blp','BTNHeroTinker.blp'},
}
local directions={}
for _,case in ipairs(morphCases) do
    local raw,start,target,order,label,sourceIcon,commandIcon=table.unpack(case)
    local entry
    for _,row in ipairs(catalog) do
        if row.kind=='ability' and row.raw==raw and row.source==start then assert(not entry);entry=row end
    end
    assert(entry and entry.transformation and entry.startForm==start and entry.targetForm==target,raw..' has no valid form pair')
    assert(entry.order==order and entry.name==label,'Wrong direction: '..entry.id)
    assert(entry.sourceIcon:sub(-#sourceIcon):lower()==sourceIcon:lower(),'Wrong source portrait: '..entry.id)
    assert(entry.icon:sub(-#commandIcon):lower()==commandIcon:lower(),'Wrong destination icon: '..entry.id)
    if raw=='ANrg' then assert(entry.activeAbility=='ANg3','Tinker prompt ignores learned Engineering Upgrade') end
    directions[raw]=directions[raw] or {}
    local identity=JTG.HotkeyCommandKey(entry)
    assert(not directions[raw][identity],'Forward and return commands collapsed in curriculum')
    directions[raw][identity]=true
    local trialSession={active=true,scope={},presentationScope={},restartData={race=entry.race},
        descriptor={capabilities={menu=true}},scene={centerX=4864,centerY=3456}}
    local trial=JTG.CreateHotkeyTrainingActivity(trialSession)
    trial:setup();trial:start(nil,entry)
    assert(trial.source.raw==entry.spawnSource,'Alternate raw unit was spawned without its native morph state')
    if entry.prepareOrder then
        assert(trial.source.setupOrder==entry.prepareOrder)
        assert(not trial:sourcePreparationReady() and not trial:inputActive(),'Setup cast accepted as ready')
        trial.elapsed=trial.morphPreparation.readyAt
        assert(not trial:sourcePreparationReady(),'Elapsed animation time accepted without native form change')
        trial.source.raw=start
    else
        assert(not trial.morphPreparation,'Forward prompt unnecessarily transforms its source')
        trial.elapsed=1
    end
    trial:updatePromptReadiness()
    assert(trial:inputActive() and trial.promptShown,'Completed native form does not unlock its prompt')
    local tooltip
    trial.commandTooltipUpdate=function(value) tooltip=value end
    trial:refreshPrompt()
    assert(tooltip:find(entry.description,1,true),'Return tooltip replaced by forward tooltip')
    local callback
    for index=#registered,1,-1 do
        local row=registered[index]
        if row.ability==entry.activeAbility and row.order==order then callback=row.trigger.action;break end
    end
    assert(callback,'Directional native command is not registered')
    trial:onKey(81);callback();trial:resolveInput(true)
    assert(trial.correct==1,'Native form command confirmation was lost')
    local actor=trial.source
    trial:cleanup();JTG.DisposeScope(trialSession.scope)
    assert(actor.removed,'Transformed source leaked')
end
for _,raw in ipairs({'Aave','AEme','ANcr'}) do
    local count=0
    for _,entry in ipairs(catalog) do
        if entry.kind=='ability' and entry.raw==raw then
            count=count+1
            assert(entry.transformation and not entry.prepareOrder and entry.source==entry.spawnSource,
                'One-way transformation acquired a return prompt')
        end
    end
    assert(count==1,'One-way transformation has duplicate prompts')
end
print('Passed: directional morph icons/tooltips, native preparation gating, command recognition and cleanup.')

-- Reproduce a delayed game confirmation with NO command-frame callback.
for _,id in ipairs({'orc.otbk.ability.Absk','orc.obea.train.otbr','orc.ofor.research.Rosp'}) do
    local entry
    for _,row in ipairs(catalog) do if row.id==id then entry=row end end
    assert(entry)
    local testSession={active=true,scope={},presentationScope={},restartData={race='orc'},
        descriptor={capabilities={menu=true}},scene={centerX=4864,centerY=3456}}
    local trial=JTG.CreateHotkeyTrainingActivity(testSession)
    trial:setup();trial.pool={entry};trial:start(nil,trial.pool[1]);trial.elapsed=0.5;trial:onKey(81)
    trial.elapsed=0.62;trial:resolveInput()
    assert(trial.pending and trial.incorrect==0,'Premature rejection of a pending native action')
    nativeEvent=EVENT_PLAYER_UNIT_ISSUED_ORDER
    nativeOrder=entry.kind=='ability' and entry.order or entry.raw
    trial.elapsed=0.75
    for index=#nativeRegistrations,1,-1 do
        local registration=nativeRegistrations[index]
        if registration.event==nativeEvent then registration.trigger.action();break end
    end
    trial:resolveInput()
    assert(trial.correct==1 and trial.logs[1].origin=='native-action','Delayed native order was lost: '..id)
    assert(math.abs(trial.totalResponse-(0.5-trial.promptAt))<0.000001,'Confirmation latency changed the response time')
    trial:cleanup();JTG.DisposeScope(testSession.scope)
end

-- Exercise both submenu types with rapid keys, long waits and mouse/key mixes.

-- Instant spells can finish while Warcraft changes the selected unit. Accept
-- the current actor's exact ability on any cast phase, never an unrelated one.
local savedTriggerUnit=GetTriggerUnit
local castActor,castAbility
function GetTriggerUnit() return castActor or savedTriggerUnit() end
function GetSpellAbilityId() return castAbility end
for _,phase in ipairs({EVENT_PLAYER_UNIT_SPELL_CHANNEL,EVENT_PLAYER_UNIT_SPELL_CAST,EVENT_PLAYER_UNIT_SPELL_EFFECT}) do
    local entry
    for _,row in ipairs(catalog) do if row.id=='neutral.Npal.ability.AHcl' then entry=row end end
    assert(entry)
    local testSession={active=true,scope={},presentationScope={},restartData={race='neutral'},
        descriptor={capabilities={menu=true}},scene={centerX=4864,centerY=3456}}
    local trial=JTG.CreateHotkeyTrainingActivity(testSession);trial:setup();trial.pool={entry};trial:start(nil,entry)
    trial.elapsed=0.5;trial.promptShown=true;trial:onKey(81)
    castActor,castAbility=trial.source,'AHcr';nativeEvent=phase
    ClearSelection()
    local callback
    for index=#nativeRegistrations,1,-1 do
        if nativeRegistrations[index].event==phase then callback=nativeRegistrations[index].trigger.action;break end
    end
    assert(callback,'Missing native spell phase registration')
    callback();assert(#trial.inputEvents==0,'Wrong ability accepted')
    castAbility='AHcl';callback();trial.elapsed=0.62;trial:resolveInput()
    assert(trial.correct==1 and trial.incorrect==0,'Cleansing Fire confirmation lost after selection changed')
    castActor=nil;trial:cleanup();JTG.DisposeScope(testSession.scope)
end
GetTriggerUnit=savedTriggerUnit

for _,id in ipairs({'orc.opeo.build.otto','orc.Otch.learn.AOae'}) do
    local entry
    for _,row in ipairs(catalog) do if row.id==id then entry=row end end
    assert(entry)
    for _,mode in ipairs({'rapid','delayed','mouse'}) do
        local testSession={active=true,scope={},presentationScope={},restartData={race='orc'},
            descriptor={capabilities={menu=true}},scene={centerX=4864,centerY=3456}}
        local trial=JTG.CreateHotkeyTrainingActivity(testSession)
        trial:setup();trial.pool={entry};trial:start(nil,trial.pool[1]);trial.elapsed=0.5
        assert(trial.heading.text:find((entry.kind=='build' and 'Building: ' or 'Ability Choice: ')..entry.name,1,true))
        trial:nativePrefix()
        if mode~='mouse' then trial:onKey(66) end
        if mode=='delayed' then
            trial.elapsed=0.62;trial:resolveInput()
            assert(trial.incorrect==0 and trial.submenuOpen)
            trial.elapsed=1;trial:onKey(66);trial.elapsed=1.12;trial:resolveInput()
            assert(trial.incorrect==0,'Previously recognized opening key was penalized')
            trial.elapsed=2;trial:onKey(90);trial.elapsed=2.51;trial:resolveInput()
            assert(trial.incorrect==1 and not trial.submenuOpen and not trial.skillMenuOpen,
                'Wrong entry did not return to the main command grid')
            trial.elapsed=3;trial:nativePrefix();trial:onKey(66)
            trial.elapsed=3.12;trial:resolveInput()
            assert(trial.incorrect==1 and trial.submenuOpen,'Retry opening key was penalized')
            trial.elapsed=10
        else trial.elapsed=0.51 end
        trial:nativeMatched('command-button');trial:onKey(81)
        trial.elapsed=trial.elapsed+0.12;trial:resolveInput()
        assert(trial.correct==1 and trial.incorrect==(mode=='delayed' and 1 or 0),id..' '..mode..' lost/penalized submenu input')
        trial:cleanup();JTG.DisposeScope(testSession.scope)
    end
end
-- Audit gating checks do not prove Warcraft's native keyboard dispatch.
local auditCommands,auditOutput={},{}
function TriggerRegisterPlayerChatEvent(trigger,player,text) auditCommands[text]=trigger end
function PreloadGenClear() auditOutput={} end
function PreloadGenStart() end
function Preload(value) auditOutput[#auditOutput+1]=value end
function PreloadGenEnd(path) assert(path=='JTG-Hotkey-Audit.pld') end
JTG.Registry={byId={['tools.hotkeys']={factory=JTG.CreateHotkeyTrainingActivity}}}
dofile('src/infrastructure/hotkey-diagnostics.lua')
dofile('src/infrastructure/hotkey-audit.lua')
local auditSession={active=true,scope={},presentationScope={},restartData={race='orc'},
    descriptor={capabilities={menu=true}},scene={centerX=4864,centerY=3456}}
local auditTrial=JTG.CreateHotkeyTrainingActivity(auditSession)
auditTrial:setup();auditTrial:start(nil,auditTrial.pool[1])
assert(auditTrial.status.text:find('Time:',1,true),'Dev wrapper changed normal status')
auditCommands['-hotkey-audit'].action()
assert(auditTrial.audit.state=='control' and auditTrial.prompt.raw=='stop')
assert(auditTrial:diagnosticsActive())
local auditTick,dispatches=auditTrial.auditTick,0
auditTrial.auditTick=function() dispatches=dispatches+1 end
assert(auditTrial:runDiagnostics('tick') and dispatches==1,'Audit adapter did not intercept the scored tick')
auditTrial.auditTick=auditTick
assert(auditCommands['-hotkey-debug'],'Development bridge lost its debug command')
auditTrial.elapsed=1;auditTrial:nativeMatched('native-action');auditTrial:auditTick()
assert(auditTrial.audit.state=='control','Mouse-only control incorrectly passed')
auditTrial.elapsed=2;auditTrial:onKey(83);auditTrial:nativeMatched('command-button');auditTrial:auditTick()
assert(auditTrial.audit.state=='control','UI activation alone incorrectly passed execution control')
auditTrial:nativeMatched('native-action');auditTrial:auditTick()
auditTrial.elapsed=2.7;auditTrial:auditTick()
assert(auditTrial.audit.control=='passed' and auditTrial.audit.index==1)
assert(auditTrial.correct==0 and auditTrial.incorrect==0,'Audit affected scores')
auditTrial.elapsed=61;timers[#timers]()
assert(not auditTrial.finished,'Normal one-minute deadline ended audit')
auditTrial:onKey(81);auditTrial:nativeMatched('command-button');auditTrial:auditTick()
auditTrial.elapsed=61.7;auditTrial:auditTick()
assert(auditTrial.audit.index==2 and table.concat(auditOutput,'\n'):find('activated-with-key',1,true),
    'Audit confused command activation with execution')
auditCommands['-hotkey-audit-card'].action()
assert(auditTrial.audit.visible)
auditCommands['-hotkey-audit-skip'].action()
assert(table.concat(auditOutput,'\n'):find('unverified-skipped',1,true))
auditCommands['-hotkey-audit-end'].action()
assert(not auditTrial.audit and auditTrial.elapsed==0)
assert(not auditTrial:diagnosticsActive() and not auditTrial:runDiagnostics('tick'),'Ended audit still intercepts normal training')
auditCommands['-hotkey-audit'].action();auditCommands['-hotkey-audit-skip'].action()
assert(auditTrial.audit.state=='inconclusive' and auditTrial.audit.index==0,'Failed control continued catalogue audit')
auditTrial:cleanup();JTG.DisposeScope(auditSession.scope)
-- Reproduce the real registration order: catalogue captures factory BEFORE
-- development wrappers load. Instantiate through the captured descriptor.
local capturedFactory=JTG.CreateHotkeyTrainingActivity
JTG.Registry={byId={['tools.hotkeys']={factory=capturedFactory}}}
EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER='point-order'
EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER='target-order'
EVENT_PLAYER_UNIT_CONSTRUCT_START='construct'
EVENT_PLAYER_HERO_SKILL='learn'
function IsFogEnabled() return true end
function IsFogMaskEnabled() return true end
function FogEnable() end
function FogMaskEnable() end
function SetCameraPosition() end
local forcedKeys={}
function ForceUIKey(key) forcedKeys[#forcedKeys+1]=key end
function PreloadGenEnd(path) assert(path=='JTG-Hotkey-Audit.pld' or path=='JTG-Hotkey-Comparison.pld' or path=='JTG-Hotkey-Visibility.pld') end
dofile('work/hotkey-comparison-bindings.lua')
dofile('src/infrastructure/hotkey-comparison.lua')
assert(JTG.Registry.byId['tools.hotkeys'].factory==JTG.CreateHotkeyTrainingActivity and
    JTG.Registry.byId['tools.hotkeys'].factory~=capturedFactory,'Dev wrapper never reached registered factory')
local compareSession={active=true,scope={},presentationScope={},restartData={race='orc'},
    descriptor={capabilities={menu=true}},scene={centerX=4864,centerY=3456}}
local compare=JTG.Registry.byId['tools.hotkeys'].factory(compareSession)
compare:setup();compare:start(nil,compare.pool[1])
assert(auditCommands['-hotkey-audit-skip'] and auditCommands['-hotkey-compare'],'Registered activity lacks dev commands')
compare:comparisonBegin(false)
assert(#compare.comparison.pool==8 and compare.prompt.raw=='stop')
-- Independent observer must see orders even when trainer input is disarmed.
nativeEvent=EVENT_PLAYER_UNIT_ISSUED_ORDER;nativeOrder='stop';compare.armedAt=math.huge
local observer
for index=#nativeRegistrations,1,-1 do
    if nativeRegistrations[index].event==EVENT_PLAYER_UNIT_CONSTRUCT_START then observer=nativeRegistrations[index].trigger;break end
end
observer.action()
assert(compare.comparison.native and not compare.comparison.trainer)
compare:comparisonNext()
assert(compare.comparison.index==2,'Next depended on trainer recognition')
compare:comparisonPrompt();compare:comparisonEnd()
assert(not compare.comparison and compare.elapsed==0)
compare:comparisonBegin(true);compare.elapsed=1.1;compare:comparisonTick()
assert(#forcedKeys==1 and forcedKeys[1]==JTG.HotkeyComparisonBindings['common.hfoo.common.stop'][1])
compare.elapsed=3.2;compare:comparisonTick()
assert(compare.comparison.state=='control-inconclusive' and compare.comparison.index==1,
    'Failed forced-key control did not stop automation')
compare:comparisonEnd()
-- Positive automation control then all eight contexts, visible and hidden.
compare:comparisonBegin(true)
local visited=0
while compare.comparison.state=='testing' do
    visited=visited+1
    local c=compare.comparison
    compare.elapsed=c.started+1.1;compare:comparisonTick()
    if c.index==1 then
        nativeEvent=EVENT_PLAYER_UNIT_ISSUED_ORDER;nativeOrder='stop'
        for index=#nativeRegistrations,1,-1 do
            if nativeRegistrations[index].event==EVENT_PLAYER_UNIT_CONSTRUCT_START then
                nativeRegistrations[index].trigger.action();break
            end
        end
    end
    if c.entry.kind=='build' or c.entry.kind=='learn' then
        compare.elapsed=c.started+1.9;compare:comparisonTick()
    end
    compare.elapsed=c.started+4.1;compare:comparisonTick()
    assert(visited<=16,'Automated bench did not terminate')
end
assert(visited==16 and compare.comparison.state=='complete' and compare.comparison.hidden,
    'Automated bench omitted a context or visibility comparison')
compare:comparisonEnd()
compare:comparisonBegin(true,true)
local sameFootman=compare.source
for index,alpha in ipairs({255,0,1,255}) do
    local c=compare.comparison
    assert(c.index==index and c.opacity==alpha and compare.source==sameFootman,'Opacity test changed source or sequence')
    compare.elapsed=c.started+1.1;compare:comparisonTick()
    for slot=0,11 do assert(nativeFrames[slot].alpha==alpha,'Wrong command opacity') end
    if alpha~=0 then
        nativeEvent=EVENT_PLAYER_UNIT_ISSUED_ORDER;nativeOrder='stop'
        for cursor=#nativeRegistrations,1,-1 do
            if nativeRegistrations[cursor].event==EVENT_PLAYER_UNIT_CONSTRUCT_START then
                nativeRegistrations[cursor].trigger.action();break
            end
        end
    end
    compare.elapsed=c.started+3.2;compare:comparisonTick()
end
assert(compare.comparison.state=='complete' and compare.source==sameFootman,
    'Hidden failure prevented visible recovery control or respawned the unit')
compare:comparisonEnd();compare:cleanup();JTG.DisposeScope(compareSession.scope)
function GetHeroLevel(unit) return unit.heroLevel or 1 end
function GetHeroSkillPoints(unit) return (unit.heroLevel or 1)-1 end
function PreloadGenEnd() end
dofile('src/infrastructure/hotkey-full-audit.lua')
local neutralSources={ntav=true,ngad=true,ngme=true,nmer=true,nmr2=true,nmr3=true}
for _,entry in ipairs(JTG.HotkeyCatalog) do
    if entry.kind=='hire' then neutralSources[entry.raw]=true end
end
for _,entry in ipairs(JTG.HotkeyCatalog) do
    assert(entry.race~='neutral' or neutralSources[entry.spawnSource or entry.source],
        'Neutral trainer contains an unpurchasable creep source: '..entry.id)
end
assert(JTG.Registry.byId['tools.hotkeys'].factory==JTG.CreateHotkeyTrainingActivity)
local fullSession={active=true,scope={},presentationScope={},restartData={race='orc'},
    descriptor={capabilities={menu=true}},scene={centerX=4864,centerY=3456}}
local full=JTG.Registry.byId['tools.hotkeys'].factory(fullSession)
full:setup();full:start(nil,full.pool[1]);full:fullAuditBegin()
local function settleAudit(trial)
    local c=trial.comparison
    if c.full.prepareAt then
        trial.elapsed=c.full.prepareAt;trial:comparisonTick()
    end
    local start=c.started
    trial.elapsed=start+0.02;trial:comparisonTick()
    assert(not selected and c.sent==0,'Audit sent keys before cancelling old menu')
    trial.elapsed=start+0.6;trial:comparisonTick()
    assert(selected==trial.source and c.sent==0,'Audit did not settle before selecting source')
end
assert(#full.comparison.full.plan==3*(#JTG.HotkeyCatalog+2+math.floor(#JTG.HotkeyCatalog/20)),
    'Full audit omitted repeated entries or controls')
local coverage={}
for _,job in ipairs(full.comparison.full.plan) do
    if not job.control then coverage[job.entry.id]=(coverage[job.entry.id] or 0)+1 end
end
for _,entry in ipairs(JTG.HotkeyCatalog) do assert(coverage[entry.id]==3,'Missing repetition: '..entry.id) end
-- Shrink execution only; full catalogue plan and coverage were checked above.
local f=full.comparison.full
local stop=f.plan[1].entry
f.plan={{entry=stop,control=true,repeatIndex=1},{entry=JTG.HotkeyCatalog[1],repeatIndex=1},
    {entry=stop,control=true,repeatIndex=1}}
for job=1,3 do
    local c=full.comparison
    settleAudit(full)
    full.elapsed=c.started+1.1;full:comparisonTick()
    if job~=2 then
        nativeEvent=EVENT_PLAYER_UNIT_ISSUED_ORDER;nativeOrder='stop'
        for cursor=#nativeRegistrations,1,-1 do
            if nativeRegistrations[cursor].event==EVENT_PLAYER_UNIT_CONSTRUCT_START then
                nativeRegistrations[cursor].trigger.action();break
            end
        end
    end
    full.elapsed=c.started+1.9;full:comparisonTick()
    full.elapsed=c.started+4.1;full:comparisonTick()
end
assert(full.comparison.state=='complete','Unconfirmed entry halted broad audit')
assert(f.counts['native-recognition-missed']==2,'Independent native evidence not classified separately')
full:comparisonEnd();full:cleanup();JTG.DisposeScope(fullSession.scope)
local gateSession={active=true,scope={},presentationScope={},restartData={race='orc'},
    descriptor={capabilities={menu=true}},scene={centerX=4864,centerY=3456}}
local gated=JTG.Registry.byId['tools.hotkeys'].factory(gateSession)
gated:setup();gated:start(nil,gated.pool[1]);gated:fullAuditBegin()
local burrow
for _,entry in ipairs(JTG.HotkeyCatalog) do if entry.id=='orc.opeo.build.otrb' then burrow=entry end end
local audit=gated.comparison.full
audit.plan={{entry=burrow,repeatIndex=1}};audit.job=1
gated:fullAuditPrepare()
settleAudit(gated)
local beforeKeys=#forcedKeys
gated.elapsed=gated.comparison.started+1.1;gated:comparisonTick()
gated.elapsed=gated.comparison.started+1.9;gated:comparisonTick()
assert(#forcedKeys==beforeKeys+1 and forcedKeys[#forcedKeys]=='Q','Unconfirmed submenu sent entry key')
gated.elapsed=gated.comparison.started+2.7;gated:comparisonTick()
assert(audit.counts['submenu-not-open']==1 and gated.comparison.state=='complete')
gated:comparisonEnd();gated:cleanup();JTG.DisposeScope(gateSession.scope)
local selectionSession={active=true,scope={},presentationScope={},restartData={race='orc'},
    descriptor={capabilities={menu=true}},scene={centerX=4864,centerY=3456}}
local selectionAudit=JTG.Registry.byId['tools.hotkeys'].factory(selectionSession)
selectionAudit:setup();selectionAudit:start(nil,selectionAudit.pool[1]);selectionAudit:selectionAuditBegin()
local selectionPlan=selectionAudit.comparison.full
assert(#selectionPlan.plan==24,'Selection verification must repeat eight cases three times')
selectionAudit.elapsed=selectionPlan.prepareAt;selectionAudit:comparisonTick()
local previousSource=selectionAudit.source
selectionPlan.job=2
selectionAudit:fullAuditPrepare()
assert(selectionAudit.source==previousSource and selectionPlan.prepareAt,
    'Previous source was disposed before its command menu settled')
selectionAudit.elapsed=selectionPlan.prepareAt-0.1;selectionAudit:comparisonTick()
assert(selectionAudit.source==previousSource,'Context replaced during cancellation delay')
selectionAudit.elapsed=selectionPlan.prepareAt;selectionAudit:comparisonTick()
assert(selectionAudit.source~=previousSource and not selectionPlan.prepareAt,
    'Context did not transition after cancellation delay')
selectionAudit:comparisonEnd();selectionAudit:cleanup();JTG.DisposeScope(selectionSession.scope)
local targetSession={active=true,scope={},presentationScope={},restartData={race='orc'},
    descriptor={capabilities={menu=true}},scene={centerX=4864,centerY=3456}}
JTG.HotkeyAuditTested={}
for _,entry in ipairs(JTG.HotkeyCatalog) do JTG.HotkeyAuditTested[entry.id]=true end
JTG.HotkeyTargetedAuditIds={['orc.obar.train.ohun']=true,['neutral.ntav.hire.Npal']=true}
local targeted=JTG.Registry.byId['tools.hotkeys'].factory(targetSession)
targeted:setup();targeted:start(nil,targeted.pool[1]);targeted:fullAuditBegin()
assert(not targeted.comparison,'Completed entries were silently audited again')
targeted:fullAuditBegin(true)
local targetPlan=targeted.comparison.full
assert(targetPlan.targeted and #targetPlan.plan==12,'Targeted pool did not include three repetitions and controls')
local repeated={}
for _,job in ipairs(targetPlan.plan) do
    if not job.control then repeated[job.entry.id]=(repeated[job.entry.id] or 0)+1 end
end
assert(repeated['orc.obar.train.ohun']==3 and repeated['neutral.ntav.hire.Npal']==3)
targeted.elapsed=targetPlan.prepareAt;targeted:comparisonTick()
targetPlan.uiStage=2
local comparison=targeted.comparison
comparison.started=targeted.elapsed;comparison.forceAt=targeted.elapsed
comparison.keys={};comparison.trainer=false
targeted.eventTrace=targeted.eventTrace or {}
comparison.traceStart=#targeted.eventTrace+1
targeted.eventTrace[#targeted.eventTrace+1]={kind='correct',origin='native-action',at=targeted.elapsed}
targeted:comparisonTick()
assert(not comparison.trainer,'Native-only action incorrectly counted as correlated input')
targeted.elapsed=targeted.elapsed+0.12
comparison.keys[#comparison.keys+1]={at=targeted.elapsed,key=81}
targeted:comparisonTick()
assert(comparison.trainer,'Audit lost correct event arriving before the key notification')
comparison.full.plan={{entry={id='test.autocast',autocastOff='creephealoff'},repeatIndex=1}}
comparison.full.job=1
JTG.HotkeyFullAuditBindings['test.autocast']={'Q'}
comparison.preInputCast=true
targeted:fullAuditNext()
assert(comparison.full.counts['autocast-inconclusive']==1,'Automatic pre-input cast was accepted as a hotkey pass')
JTG.HotkeyFullAuditBindings['test.autocast']=nil
targeted:comparisonEnd();targeted:cleanup();JTG.DisposeScope(targetSession.scope)

-- Current-layout grid collisions are skipped without creating a failed input.
local forestHeal,iceHeal
for _,entry in ipairs(catalog) do
    if entry.id=='neutral.nfsp.ability.Anh1' then forestHeal=entry end
    if entry.id=='neutral.nitp.ability.Anh1' then iceHeal=entry end
end
customPositions.Anh1={0,0};customPositions.ACdm={0,0}
assert(JTG.HotkeyPromptConflict(forestHeal)=='neutral.nfsp.ability.ACdm')
assert(not JTG.HotkeyPromptConflict(iceHeal),'Shared key on another unit incorrectly counts as a conflict')
local conflictSession={active=true,scope={},presentationScope={},restartData={race='neutral'},
    descriptor={capabilities={menu=true}},scene={centerX=4864,centerY=3456}}
local conflicts=JTG.CreateHotkeyTrainingActivity(conflictSession)
conflicts:setup();conflicts.pool={forestHeal,iceHeal};conflicts:start()
assert(conflicts.prompt==iceHeal and conflicts.skippedConflicts[forestHeal.id])
assert(conflicts.correct==0 and conflicts.incorrect==0 and conflicts.score==0,'Skipping conflict affects scoring')
conflicts:cleanup();JTG.DisposeScope(conflictSession.scope)
customPositions.Anh1=nil;customPositions.ACdm=nil

-- Normal play uses the verified close-before-dispose transition as well.
local transitionSession={active=true,scope={},presentationScope={},restartData={race='human'},
    descriptor={capabilities={menu=true}},scene={centerX=4864,centerY=3456}}
local transition=JTG.CreateHotkeyTrainingActivity(transitionSession)
transition:setup();transition.pool={holy,shield};transition:start(nil,transition.pool[1])
local tick=timers[#timers]
transition.elapsed=0.5;transition:nativeMatched('command-button');transition:onKey(81)
transition.elapsed=0.61;transition:resolveInput()
local oldSource=transition.source
tick()
assert(transition.transitionAt and not oldSource.removed and not selected,
    'Old source disposed before command-state cancellation settles')
assert(not transition.panel.visible and not transition:inputActive())
local untilReady=transition.transitionAt
assert(untilReady-transition.elapsed<=0.081,'Normal cancellation delay exceeds the fast handoff budget')
transition:setPaused(true);tick()
assert(transition.transitionAt==untilReady and transition.source==oldSource,'Pause advances prompt transition')
transition:setPaused(false)
transition.elapsed=untilReady-0.03;tick()
assert(transition.source==oldSource and not oldSource.removed)
transition.elapsed=untilReady;tick()
assert(oldSource.removed and transition.source~=oldSource and not transition.transitionAt)
assert(transition.correct==1 and transition.incorrect==0 and transition.score==15)
transition:cleanup();JTG.DisposeScope(transitionSession.scope)
-- Match the shared controller's start(activity, session) calling convention.
-- Previously the session was mistaken for a forced prompt, reaching FourCC(nil).
for _,race in ipairs({'human','orc','nightelf','undead','neutral'}) do
    local liveSession={active=true,scope={},presentationScope={},restartData={race=race},
        descriptor={capabilities={menu=true}},scene={centerX=4864,centerY=3456}}
    local live=JTG.Registry.byId['tools.hotkeys'].factory(liveSession)
    live:setup()
    local ok,err=pcall(live.start,live,liveSession)
    assert(ok,'Controller-style startup failed for '..race..': '..tostring(err))
    assert(live.prompt and live.prompt.id and live.prompt~=liveSession and live.source.raw,
        'Controller session was used as a hotkey prompt')
    assert(live.selectionAt and not selected and not live:inputActive(),
        'Normal prompt selects during native context creation')
    local tick=timers[#timers]
    live.elapsed=live.selectionAt-0.04;tick()
    assert(not selected and not live.panel.visible,'Prompt displayed before selection settles')
    live.elapsed=live.selectionAt;tick()
    assert(selected==live.source and not live:inputActive(),'Selection and key arming happen on the same update')
    assert(live.armedAt-live.elapsed<=0.041,'Selection arming delay exceeds the fast handoff budget')
    live.elapsed=live.armedAt;tick()
    assert(live:inputActive() and live.panel.visible and live.promptAt==live.elapsed,
        'Ready prompt does not start its response clock on display')
    local wrong=live.incorrect
    live:onKey(OSKEY_ESCAPE);live:resolveInput(true)
    assert(live.incorrect==wrong,'Cancellation Escape is scored as a wrong answer')
    live:cleanup();JTG.DisposeScope(liveSession.scope)
end
local stand
for _,row in ipairs(catalog) do if row.raw=='Astd' then stand=row;break end end
assert(stand)
local burrowSession={active=true,scope={},presentationScope={},restartData={race='orc'},
    descriptor={capabilities={menu=true}},scene={centerX=4864,centerY=3456}}
local burrow=JTG.CreateHotkeyTrainingActivity(burrowSession)
burrow:setup()
local prepared=burrow.preparedGarrison
assert(prepared.peon.x==prepared.unit.x and prepared.peon.y==prepared.unit.y and burrow:garrisonReady(),
    'Stand Down preparation requires a Peon to walk to its Burrow')
burrow:start(burrowSession,stand)
assert(burrow.source==prepared.unit and burrow.garrisonPeon==prepared.peon)
prepared.peon.transport=nil;burrow.elapsed=1
assert(not burrow:inputActive(),'Unloaded Burrow is accepted as ready for Stand Down')
prepared.peon.transport=prepared.unit
assert(burrow:inputActive())
burrow:cleanup();JTG.DisposeScope(burrowSession.scope)
assert(prepared.unit.removed and prepared.peon.removed,'Prepared Burrow actors leaked')
print('Passed: hotkey trainer registrations, scoring, context cleanup, catalogue identities and audit control gating.')

-- Stage curriculum uses command identities, not carrier-unit identities.
local eat={kind='ability',name='Eat Tree',raw='Aeat',source='etrp'}
local eatOther={kind='ability',name='Eat Tree',raw='Aeat',source='etol'}
assert(JTG.HotkeyCommandKey(eat)==JTG.HotkeyCommandKey(eatOther))
assert(JTG.HotkeyCommandKey({kind='ability',name='Take Root',raw='root',source='etrp'})==
    JTG.HotkeyCommandKey({kind='ability',name='Take Root',raw='root',source='etol'}))
assert(JTG.HotkeyCommandKey(holy)~=JTG.HotkeyCommandKey({kind='learn',name=holy.name,raw=holy.raw}))
local state={stage=1,tested={},failed={},stageSeen={}}
local chosen=JTG.HotkeyChooseCommand(state,{eat,eatOther,shield})
state.tested[JTG.HotkeyCommandKey(chosen)]=true;state.stageSeen[JTG.HotkeyCommandKey(chosen)]=true
state.failed[JTG.HotkeyCommandKey(chosen)]=chosen
assert(JTG.HotkeyChooseCommand(state,{eat,eatOther,shield})==shield)
state.tested[JTG.HotkeyCommandKey(shield)]=true
assert(not JTG.HotkeyChooseCommand(state,{eat,eatOther,shield}),'Stage 1 repeats an already tested command')
state.stage=2;state.stageSeen={}
assert(JTG.HotkeyChooseCommand(state,{shield,eatOther})==eatOther,'Later stage does not review a failed command')
state.stageSeen[JTG.HotkeyCommandKey(eatOther)]=true
assert(not JTG.HotkeyChooseCommand(state,{eat,eatOther,shield}),'Review repeats within one stage')
local lessonSession={active=true,scope={},presentationScope={},restartData={race='human'},
    descriptor={capabilities={menu=true}},scene={centerX=4864,centerY=3456}}
local lesson=JTG.CreateHotkeyTrainingActivity(lessonSession)
lesson:setup();lesson.pool={holy,shield};lesson:start(lessonSession)
local function armLesson()
    lesson.elapsed=lesson.selectionAt;lesson:updatePromptReadiness()
    lesson.elapsed=lesson.armedAt;lesson:updatePromptReadiness()
    assert(lesson:inputActive())
end
local function answerLesson(correct)
    if correct then lesson:nativeMatched('command-button') end
    lesson:onKey(81);lesson:resolveInput(true)
end
armLesson();assert(lesson.prompt==holy)
assert(not lesson.cover and lesson.lowerCover.visible)
assert(lesson.lowerCover.texture=='JTGMenu\\OpaqueBlack.dds' and lesson.lowerCover.h==0.16)
assert(camera.x==0 and camera.y==0 and lesson.source.y==6392,
    'Hotkey camera follows the northern spawn zone')
answerLesson(false);answerLesson(false)
assert(lesson.lowerCover.visible,'Lower UI revealed before three wrong attempts')
answerLesson(false)
assert(not lesson.lowerCover.visible and not lesson.cover,'Third mistake does not reveal only the lower UI')
answerLesson(true)
assert(lesson.lowerCover.visible,'Correct answer does not cover lower UI again')
assert(lesson.failed[JTG.HotkeyCommandKey(holy)],'Correction on second attempt erases practice history')
lesson:finish()
assert(lesson.resultCard.spec.actions.next.visible and lesson.resultCard.spec.actions.next.label=='Continue')
local elapsed=lesson.elapsed
lesson:nextStage()
assert(lesson.stage==2 and lesson.stageStart==elapsed and lesson.score==0 and lesson.correct==0)
armLesson();assert(lesson.prompt==shield,'Review starts before untested commands')
answerLesson(true);lesson:nextPrompt();armLesson()
assert(lesson.prompt==holy,'Missed command not presented after fresh commands')
answerLesson(true)
assert(not lesson.failed[JTG.HotkeyCommandKey(holy)],'Clean first try fails to retire review command')
lesson:nextPrompt()
assert(lesson.finished and not lesson.resultCard.spec.actions.next.visible,'Completed curriculum offers an empty next stage')
for _,sample in ipairs({{249,'|cffff4040',1.25},{250,'|cffffff00',1.45},
    {350,'|cff40dd60',1.65},{450,'|cffffcc00',1.85}}) do
    lesson.score=sample[1];lesson:refreshStatus();lesson:showResult()
    assert(lesson.scoreFrame.text:find(sample[2],1,true) and lesson.scoreFrame.scale==sample[3])
    assert(lesson.resultScore.text:find(sample[2],1,true) and lesson.resultScore.scale==sample[3])
end
lesson:cleanup();JTG.DisposeScope(lessonSession.scope)
local timedSession={active=true,scope={},presentationScope={},restartData={race='human'},
    descriptor={capabilities={menu=true}},scene={centerX=4864,centerY=3456}}
local timed=JTG.CreateHotkeyTrainingActivity(timedSession)
timed:setup();timed.pool={holy,shield};timed:start(timedSession)
timed.elapsed=timed.selectionAt;timed:updatePromptReadiness()
timed.elapsed=timed.armedAt;timed:updatePromptReadiness()
local tick=timers[#timers]
timed.elapsed=59.99;tick()
assert(timed.finished and timed.failed[JTG.HotkeyCommandKey(holy)],'Unanswered timed-out command is not carried into review')
timed:nextStage()
local started=timed.stageStart
timed.elapsed=started+10;tick()
assert(not timed.finished and timed.status.text:find('Time: 50s',1,true),
    'Second stage reuses the first stage deadline')
timed:hidePresentationForMenu()
assert(not timed.scoreFrame.visible,'Score remains over the exercise menu')
timed:restorePresentation()
assert(timed.scoreFrame.visible)
timed:cleanup();JTG.DisposeScope(timedSession.scope)
print('Passed: unique-command stages, fresh-before-review priority, first-try remediation, stage continuation and score thresholds.')


for _,case in ipairs({{249,'|cffff4040',1.25},{250,'|cffffff00',1.45},{350,'|cff40dd60',1.65},{450,'|cffffcc00',1.85}}) do
 local color,scale=JTG.Training.ScoreStyle(case[1]);assert(color==case[2] and scale==case[3])
end
