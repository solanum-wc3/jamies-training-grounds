JTG={Dev={},Controller={},UI={}}
PLAYER_NEUTRAL_PASSIVE=15
PLAYER_STATE_RESOURCE_FOOD_USED,PLAYER_STATE_RESOURCE_FOOD_CAP='food','cap'
GAME_STATE_TIME_OF_DAY='time'
ALLIANCE_SHARED_CONTROL='control'
local control=false
function GetPlayerAlliance() return control end
function SetPlayerAlliance(owner,viewer,kind,value)
 assert(owner==6 and viewer==0 and kind==ALLIANCE_SHARED_CONTROL);control=value
end
function Player(id) return id end
function GetLocalPlayer() return 0 end
function GetPlayerId(id) return id end
function GetPlayerHandicapXP() return .85 end
function GetFloatGameState() return 7 end
function GetPlayerState(owner,key) return key=='food' and owner or 100 end
function GetOwningPlayer(u) return u.owner end
function GetUnitX(u) return u.x end
function GetUnitY(u) return u.y end
local init,callback,command,timer,rows,played,messages=nil,nil,nil,nil,{},{},{}
function JTG.RegisterBootstrapInitializer(fn) init=fn end
function CreateTrigger() return {} end
function TriggerRegisterPlayerChatEvent() end
function TriggerAddAction(_,fn) callback=fn end
function GetEventPlayerChatString() return command end
function DisplayTimedTextToPlayer(_,_,_,_,text) messages[#messages+1]=text end
function PreloadGenClear() rows={} end
function PreloadGenStart() end
function Preload(text) rows[#rows+1]=text end
local exported
function PreloadGenEnd(path) exported=path end
function JTG.StartActivity(id)
 JTG.startedWithoutControl=JTG.Dev.HeroesAudioSkipSharedControl
 JTG.Controller.session={id=id}
 JTG.Dev.HeroesAudioTrace({},'mock-native-start')
end
function JTG.StopActivity() JTG.Dev.HeroesAudioTrace({},'mock-native-stop');JTG.Controller.session=nil end
function JTG.UI.ShowCategory(id) assert(id=='learn') end
function JTG.UI.PlayButtonSound() error('No-button audit played a button cue') end
function CreateSoundFromLabel(label) return {label=label} end
function StartSound(s) played[#played+1]=s.label end
function StopSound() end
function KillSoundWhenDone() end
function CreateTimer() timer={};return timer end
function TimerStart(t,delay,repeating,fn) assert(delay==3);t.fn=fn end
function PauseTimer() end
function DestroyTimer(t) t.destroyed=true end
dofile('src/infrastructure/heroes-diagnostics.lua');init()
local function run(text) command=text;callback() end
run('-heroes-audio-start');assert(JTG.Controller.session.id=='learn.heroes' and #played==0)
JTG.Dev.HeroesAudioUnit({},'unp1',{owner=15,x=101,y=205},100,200)
run('-heroes-audio-stop');assert(not JTG.Controller.session and exported=='JTG-Heroes-Audio.pld')
local text=table.concat(rows,'\n')
assert(text:find('xp=0.85',1,true) and text:find('p15food=15',1,true))
assert(text:find('planned=100/200,actual=101/205',1,true))
assert(text:find('before-no-button-start',1,true) and text:find('after-no-button-stop',1,true))
run('-heroes-audio-sounds');assert(played[1]=='PauseGame')
timer.fn();assert(played[2]=='GlueScreenClick')
timer.fn();assert(played[3]=='UpkeepLevel')
timer.fn();assert(timer.destroyed)
local cueCount=#played
run('-heroes-audio-control');assert(control and #played==cueCount)
timer.fn();assert(not control and timer.destroyed and #played==cueCount)
run('-heroes-audio-no-control');assert(JTG.startedWithoutControl==true)
assert(JTG.Dev.HeroesAudioSkipSharedControl==nil,'Diagnostic flag leaked into ordinary gameplay')
run('-heroes-audio-stop')
local ordinaryStart=JTG.StartActivity
JTG.StartActivity=function() error('simulated setup error') end
run('-heroes-audio-no-control')
assert(JTG.Dev.HeroesAudioSkipSharedControl==nil,'Failed diagnostic start leaked its flag')
JTG.StartActivity=ordinaryStart
JTG.TerrainCleanupHistory={'settled-before,cells=10,changed=2'}
run('-heroes-terrain');assert(exported=='JTG-Heroes-Terrain.pld' and rows[1]:find('changed=2',1,true))
print('Passed: no-button Heroes start/stop, actual native-state report, planned/actual coordinates and separately named sound comparison.')
