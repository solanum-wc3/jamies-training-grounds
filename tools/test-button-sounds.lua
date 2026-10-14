-- Test the two native button cues and real paused/deferred UI dispatch.
JTG={UI={}};UI=JTG.UI
local file=assert(io.open('src/infrastructure/ui.lua'));local source=file:read('*a');file:close()
local code=assert(source:match('local BUTTON_SOUND_FILES=(.-)\nUI.PlayButtonSound = PlayButtonSound'))
local played,created={},{}
function GetLocalPlayer() return 0 end
function Player(id) return id end
function CreateSoundFromLabel(label) local sound={label=label};created[#created+1]=sound;return sound end
function StopSound() end
function StartSound(sound) played[#played+1]=sound.label end
assert(load('local BUTTON_SOUND_FILES='..code..'\nUI.PlayButtonSound = PlayButtonSound'))()
UI.PlayButtonSound('normal');assert(played[#played]=='GlueScreenClick')
UI.PlayButtonSound('menu-open');assert(played[#played]=='PauseGame')
UI.PlayButtonSound('return');assert(played[#played]=='GlueScreenClick')
UI.PlayButtonSound('toolbar');assert(played[#played]=='GlueScreenClick')
local count=#played;UI.PlayButtonSound(false);assert(#played==count)
assert(#created==2,'Native sound handles accumulate')
assert(source:find('function UI.PlayFeedbackSound',1,true))
function GetHandleId(frame) return frame end
function CreateTrigger() return {} end
function TriggerAddAction(trigger,fn) trigger.action=fn end
local clicked
function BlzGetTriggerFrame() return clicked end
function CreateTimer() return {} end
function TimerStart(_,_,_,fn) fn() end
function DestroyTimer() end
function ReleaseFrameFocus() end
function ReleaseKeyboardFocusAfterClick() end
UI.epoch=1;UI.clickActions={};UI.clickSounds={}
local start=assert(source:find('    UI.clickTrigger = CreateTrigger()',1,true))
local finish=assert(source:find('    UI.hoverTrigger = CreateTrigger()',start,true))
assert(load(source:sub(start,finish-1):gsub('PlayButtonSound%(','UI.PlayButtonSound(')))()
for _,paused in ipairs({false,true}) do
    UI.gameplayMenuPaused=paused
    clicked={};UI.clickSounds[clicked]='normal';UI.currentView={kind='root'}
    UI.clickActions[clicked]=function() UI.currentView={kind='briefing'};UI.menuVisible=true end
    count=#played;UI.clickTrigger.action()
    assert(#played==count+1 and played[#played]=='PauseGame','Menu open is silent or plays twice')
    UI.clickActions[clicked]=function() UI.currentView={kind='gameplay'};UI.menuVisible=false end
    count=#played;UI.clickTrigger.action()
    assert(#played==count+1 and played[#played]=='GlueScreenClick','Start uses an opening cue')
end
assert(source:find('RegisterClick(menu, JTG.OpenTrainingMenu, "menu-open")',1,true))
assert(source:find('RegisterClick(setups, JTG.ToggleActivitySetups, "menu-open")',1,true))
assert(source:find('RegisterClick(button, function() UI.ShowCategory(category.id) end, "menu-open")',1,true))
print('Passed: two native button cues, cached sound handles, opening versus ordinary action, and exactly one cue in paused/deferred dispatch.')

-- Limit extraction to the next public helper.
local first=assert(source:find('local FEEDBACK_LABELS=',1,true))
local last=assert(source:find('--',first,true))
assert(load(source:sub(first,last-1)))()
for key,label in pairs({startup='MarkOfChaos',result='ItemIllusion',failure='ReceiveLumber',credits='ReviveOrc',incorrect='StampedeHit',correct='PhaseShift'}) do
 UI.PlayFeedbackSound(key);assert(played[#played]==label)
end
JTG.Controller={session={}}
function BlzFrameSetText() end
function BlzFrameSetVisible() end
function BlzFrameSetSize() end
function BlzFrameClearAllPoints() end
function BlzFrameSetAbsPoint() end
first=assert(source:find('function UI.ShowResultCard(',1,true))
last=assert(source:find('local function PositionTop',first,true))
assert(load("local RESULT_TITLE_COLORS={neutral='',failure=''};local RESULT_ACTION_ORDER={}\n"..source:sub(first,last-1)))()
local card={panel={},title={},details={},buttons={},detailsHeight=.1,width=.3,centerY=.3}
count=#played;UI.ShowResultCard(card,{visible=false});assert(#played==count)
UI.ShowResultCard(card,{tone='failure'});assert(#played==count+1 and played[#played]=='ReceiveLumber')
UI.ShowResultCard(card,{tone='failure'});assert(#played==count+1,'Result redraw replayed audio')
UI.HideResultCard(card);UI.ShowResultCard(card,{tone='failure'});assert(#played==count+1,'Menu/Resume replayed completion audio')
-- Rebuilding presentation preserves the completed attempt's identity.
local rebuilt={panel={},title={},details={},buttons={},detailsHeight=.1,width=.3,centerY=.3,session=JTG.Controller.session}
UI.ShowResultCard(rebuilt,{tone='failure'});assert(#played==count+1,'Rebuild replayed completion audio')
dofile('src/infrastructure/training.lua')
JTG.Training.BeginAttempt(JTG.Controller.session)
UI.ShowResultCard(card,{visible=false});assert(#played==count+1)
UI.ShowResultCard(card,{tone='neutral'});assert(#played==count+2 and played[#played]=='ItemIllusion')
assert(source:find('which=="credits"',1,true))
print('Passed: requested event cues and result audio plays once per result, never on hidden pre-render.')
