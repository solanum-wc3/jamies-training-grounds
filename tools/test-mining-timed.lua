JTG={UI={},Controller={}}
function FourCC(raw) return raw end
function Player(id) return id end
RACE_HUMAN,RACE_ORC='human','orc'
PLAYER_STATE_RESOURCE_GOLD,PLAYER_STATE_RESOURCE_LUMBER='gold','lumber'
PLAYER_STATE_GOLD_GATHERED,PLAYER_STATE_LUMBER_GATHERED='gatheredGold','gatheredLumber'
local resources={[0]={gold=0,lumber=0},[1]={gold=0,lumber=0},[2]={gold=0,lumber=0}}
function GetPlayerState(owner,resource) return resources[owner][resource] or 0 end
function PauseUnit(unit,value) unit.paused=value end
function BlzFrameSetVisible() end
function JTG.UI.HideToolbar() end
function JTG.UI.ShowResultCard(_,spec) JTG.result=spec end
local menu,launched
function JTG.UI.ShowActivityBriefing(spec) menu=spec end
function JTG.UI.SetGameplayMenuPaused() end
function JTG.UI.ShowCategory() end
function GetRandomInt(low) return low end
function JTG.StartActivity(_,_,data) launched=data end
dofile('src/infrastructure/tutorial.lua')
dofile('src/activities/mining-micro.lua')
JTG.OpenMiningMicroMenu('skills',false)
assert(menu.body:find('|cffffcc00Quest Log|r',1,true) and not menu.body:find('{Button:',1,true),
    'Gold Mine Micro briefing did not format the Quest Log button cue')
menu.choices[2].action()
assert(menu.pageId=='duration' and not launched,'Race choice skipped duration')
assert(menu.choices[1].label=='One Minute' and menu.choices[2].label=='Unlimited')
assert(menu.choices[3].label=='Build Order')
assert(menu.choices[1].tooltip=='Try mitigating as much of the lost mining potential as possible in one minute.')
assert(menu.choices[2].tooltip=='Train mining micro for as long as you want.')
assert(menu.choices[3].tooltip=='Start with regular starting resources and try to use mining micro while following your regular build order. The exercise ends once you send a fifth worker into the gold mine.')
menu.choices[1].action();assert(launched.race=='orc' and launched.duration==60)
menu.choices[2].action();assert(launched.duration==nil)
menu.choices[3].action();assert(launched.baseBuild and launched.duration==nil)
menu.choices[1].action();assert(not launched.baseBuild and launched.duration==60)
local timed=JTG.CreateMiningMicroActivity({restartData={race='human',duration=60}})
timed.lanes={{owner=1,workers={{}},hall={}},{owner=0,workers={{}},hall={}},{owner=2,workers={{}},hall={}}}
timed.running=true
resources[0]={gold=0,lumber=0,gatheredGold=900,gatheredLumber=120};resources[1].gold=1000;resources[2].gold=800
timed.elapsed=59.9;timed:updateCounters()
assert(timed.finished and timed.expectedLoss==200 and timed.recoveredGold==100)
assert(JTG.result.details:find('50.0%%') and JTG.result.details:find('120'))
assert(timed.lanes[1].workers[1].paused and timed:captureResetState().duration==60)
local previous=timed.playerGoldMined;resources[0].gold=950;timed:updateCounters()
assert(timed.playerGoldMined==previous,'Finished score changed')
local unlimited=JTG.CreateMiningMicroActivity({restartData={race='human'}})
unlimited.lanes={};unlimited.running=true;unlimited.elapsed=120;unlimited:updateCounters()
assert(not unlimited.finished,'Unlimited run ended')
timed.expectedLoss=0;timed:showTimedResult()
assert(JTG.result.details:find('N/A',1,true),'Zero reference loss divided by zero')
print('Passed: Mining duration menu, timed recovery percentage/lumber, frozen result and unlimited mode.')
