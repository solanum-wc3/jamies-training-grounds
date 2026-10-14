-- Shared contracts for all tutorial factories.
JTG={UI={}}
function Player(n) return n end
function GetLocalPlayer() return 0 end
local pans={}
function PanCameraToTimed(x,y,d) pans[#pans+1]={x,y,d} end
function BlzCreateFrameByType() return {} end
function BlzFrameSetSize(f,w,h) f.width=w;f.height=h end
function BlzFrameSetText(f,s) f.text=s end
function BlzFrameSetEnable(f,v) f.enabled=v end
function BlzFrameSetAlpha() end
function BlzFrameSetTextColor() end
function BlzConvertColor() return 1 end
function GetHandleId(f) return f end
function JTG.UI.SetGameplayMenuPaused(v) JTG.menuPaused=v end
function JTG.UI.ShowActivityMenu(v) JTG.menu=v end
function JTG.UI.SetExercisePaused(v) JTG.UI.exercisePaused=v end
local timers={}
function JTG.StartScopedTimer(_,_,_,_,fn) timers[#timers+1]=fn end
function JTG.StartActivityAfterCleanup(id,category,data) JTG.jump={id,category,data.step} end
dofile('src/infrastructure/tutorial.lua')
local T=JTG.Tutorial
assert(T.ResolveStep({{id='first'},{id='second'}},{step=1,stepId='second'})==2)
assert(T.ResolveStep({{id='first'}},{step=99})==1)
assert(T.FormatNarration('{Term: Gold}')=='|cffff9933Gold|r')
assert(T.FormatNarration('{Gold Font: Kodo}')=='|cffffcc00Kodo|r')
local b=T.CreateButton('test',{},'Continue',.1)
assert(b.height==.024 and b.text=='Continue')
local a={buttonEnabled={},step=1}
function a:setPresentationVisible(v) self.visible=v end
function a:setTopicsVisible(v) self.topicsOpen=v end
function a:refreshControls() self.refreshed=true end
T.SetButtonEnabled(a,b,false);assert(not b.enabled and a.buttonEnabled[b]==false)
T.MoveCamera(0,1,2);assert(pans[1][3]==1.5)
T.OpenMenu(a);assert(a.visible==false and JTG.menuPaused and JTG.menu=='learn')
T.TogglePause(a);assert(JTG.UI.exercisePaused and a.refreshed)
local called=false
T.ScheduleStep({scope={}},a,1,function() called=true end)
a.step=2;timers[1]();assert(not called)
T.RestoreCheckpoint(a,'learn.economy','learn',7);assert(JTG.jump[3]==7 and not a.topicsOpen)
-- Re-entering the same numeric step must not revive its previous visit.
local runner={frames={},buttonEnabled={},actions={},narrationBlocks={},presentationVisible=true}
function runner:showStep(index) self.step=index end
function runner:showOptionalStep(index) self.optionalIndex=index end
function runner:cleanup() self.cleaned=true end
T.InstallRunner(runner,{scope={}},{id='test',player=0,steps={{id='first'},{id='second'}}})
runner:showStep(1)
local expired=0
T.ScheduleStep({scope={}},runner,1,function() expired=expired+1 end)
local old=timers[#timers]
runner:showStep(2);runner:showStep(1);old()
assert(expired==0,'A-B-A revived stale action')
T.ScheduleStep({scope={}},runner,1,function() expired=expired+1 end)
old=timers[#timers];runner:showOptionalStep(1);old()
assert(expired==0,'Optional entry revived stale action')
T.ScheduleStep({scope={}},runner,1,function() expired=expired+1 end)
old=timers[#timers];runner:cleanup();old()
assert(runner.cleaned and expired==0)
local displayed=0
function ClearTextMessages() end
function DisplayTimedTextToPlayer() displayed=displayed+1 end
runner.narrationBlocks={'narration'};runner.topicsOpen=true
runner:renderNarration();assert(displayed==0)
runner.topicsOpen=false;runner:renderNarration();assert(displayed==1)
-- Disabled controls and disposed frames cannot dispatch or play a click sound.
local sounds,clicks=0,0
function JTG.UI.PlayButtonSound() sounds=sounds+1 end
function CreateTrigger() return {} end
function JTG.ScopeTrackTrigger(_,t) return t end
function TriggerAddAction(t,fn) t.action=fn end
function BlzTriggerRegisterFrameEvent() end
local clicked={}
function BlzGetTriggerFrame() return clicked end
local scope={}
T.BindClicks(runner,scope)
runner:registerClick(clicked,function() clicks=clicks+1 end)
runner.buttonEnabled[clicked]=false;runner.clickTrigger.action()
assert(sounds==0 and clicks==0)
runner.buttonEnabled[clicked]=true;runner.clickTrigger.action()
assert(sounds==1 and clicks==1)
scope.disposed=true;runner.clickTrigger.action()
assert(sounds==1 and clicks==1)
for _,name in ipairs({'camera','unit-controls','hotkey-setup','economy'}) do
 local f=assert(io.open('src/activities/'..name..'-tutorial.lua'));local s=f:read('*a');f:close()
 assert(s:find('local FormatNarration = JTG.Tutorial.FormatNarration',1,true))
 assert(s:find('local CreateTutorialButton = JTG.Tutorial.CreateButton',1,true))
 assert(s:find('JTG.Tutorial.OpenMenu',1,true) and s:find('JTG.Tutorial.TogglePause',1,true))
 assert(not s:find('SetCameraPosition',1,true),'Instant camera move in '..name)
end
print('Passed: shared tutorial runner, A-B-A/optional/disposal guards, narration visibility, disabled clicks, formatting, camera and checkpoint contracts.')

-- Heading announcements cover entry and delayed append, while redraws remain silent.
local questSounds=0
function CreateSoundFromLabel(label) assert(label=='QuestNew');return {} end
function StartSound() questSounds=questSounds+1 end
function KillSoundWhenDone() end
local headed={frames={},buttonEnabled={},actions={},narrationBlocks={},presentationVisible=true}
function headed:appendNarration(text) self.narrationBlocks[#self.narrationBlocks+1]=T.FormatNarration(text) end
function headed:showStep(index) self.narrationBlocks={};self:appendNarration('{Heading: SECTION '..index..'}') end
T.InstallRunner(headed,{scope={}},{id='headings',player=0,steps={{id='one'},{id='two'}}})
headed:showStep(1);assert(questSounds==0)
headed:renderNarration();headed:renderNarration();assert(questSounds==0)
headed:appendNarration('Ordinary continuation');assert(questSounds==0)
headed:appendNarration('{Small Heading: DELAYED SECTION}');assert(questSounds==0)
headed:showStep(2);assert(questSounds==0)
headed:showStep(1);assert(questSounds==0)
headed.presentationVisible=false;headed:renderNarration();assert(questSounds==0)
headed.presentationVisible=true;headed:renderNarration();assert(questSounds==0)
-- Direct-block tutorials (Economy/Hotkeys) share the same entry hook.
function headed:directStep() local text=T.FormatNarration('{Heading: DIRECT}');self.narrationBlocks={text} end
T.InstallRunner(headed,{scope={}},{id='direct',player=0,entries={'directStep'}})
headed:directStep();assert(questSounds==0)
assert(#{T.FormatNarration('{Hotkeys}')}==1,'Narration formatter leaks its replacement count')
print('Passed: blue headings never produce quest-activation audio; formatter returns only text.')

-- A Continue-triggered heading uses its transition sound alone, rather than
-- also starting QuestNew from the shared narration announcement.
local continueButton={}
headed.toolbarSoundKinds={[continueButton]='normal'}
T.BindClicks(headed,{})
headed:registerClick(continueButton,function() headed:showStep(2) end)
headed.presentationVisible=true
local beforeQuest=questSounds
local beforeClick=sounds
clicked=continueButton;headed.clickTrigger.action()
assert(questSounds==beforeQuest and sounds==beforeClick+1,'Continue played two transition sounds')
headed:renderNarration();assert(questSounds==beforeQuest,'Redraw replayed a suppressed heading sound')
headed:registerClick(continueButton,function() error('test failure') end)
assert(not pcall(headed.clickTrigger.action) and not headed.suppressHeadingSound,'Failed action left heading sounds muted')
