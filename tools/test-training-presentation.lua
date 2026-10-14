-- Exercise the real shared contract independently of broad native mock fallbacks.
JTG={UI={}}
local frameCount,entries=0,0
local session={descriptor={capabilities={menu=true}},resultAttempt=3,resultCueAttempt=3}
function CreateUnit() error('Presentation spawned a gameplay actor') end
function TimerStart() error('Presentation started another gameplay clock') end
function BlzFrameSetVisible(frame,visible) assert(not frame.stale,'Used an old presentation handle');frame.visible=visible end
function JTG.UI.HideResultCard(card) if card then BlzFrameSetVisible(card.panel,false) end end
function JTG.UI.HideToolbar() session.toolbar=false end
function JTG.UI.ShowToolbar() session.toolbar=true end
dofile('src/infrastructure/training.lua')
local function frame() frameCount=frameCount+1;return {visible=true} end
local activity={presentationVisible=true,elapsed=12,score=123,finished=false}
local all={}
function activity:createPresentation()
    self.status=frame();self.panel=frame();self.cover=frame();self.icons={frame(),frame()}
    self.resultCard={panel=frame()}
    self.tooltipUpdate=function() assert(not self.panel.stale) end
    for _,f in ipairs({self.status,self.panel,self.cover,self.resultCard.panel,self.icons[1],self.icons[2]}) do all[#all+1]=f end
end
function activity:refreshStatus() BlzFrameSetVisible(self.status,self.presentationVisible and not self.finished) end
function activity:refreshPrompt() BlzFrameSetVisible(self.panel,self.presentationVisible and not self.finished) end
function activity:showResult() BlzFrameSetVisible(self.resultCard.panel,self.presentationVisible) end
activity:createPresentation()
JTG.Training.InstallPresentation(activity,session,{
    roots={'status','panel','cover'},lists={'icons'},
    references={'status','panel','cover','icons','resultCard','tooltipUpdate'},
    refresh={'refreshPrompt'},result='showResult',resume=function() entries=entries+1 end,
})
for _=1,3 do
    activity:hidePresentationForMenu()
    assert(not activity.panel.visible and not activity.cover.visible and not activity.icons[1].visible and not session.toolbar)
    activity:restorePresentation()
    assert(activity.panel.visible and activity.status.visible and session.toolbar)
    assert(activity.elapsed==12 and activity.score==123 and session.resultAttempt==3 and session.resultCueAttempt==3)
end
activity.finished=true;local resumes=entries
activity:hidePresentationForMenu();activity:restorePresentation()
assert(activity.resultCard.panel.visible and not activity.panel.visible and not activity.status.visible and not session.toolbar)
assert(entries==resumes,'Restoring a completed result resumed native selection/gameplay')
local oldFrames=frameCount
activity:discardPresentationForLoad()
assert(not activity.panel and not activity.icons and not activity.tooltipUpdate and not activity.resultCard)
for _,f in ipairs(all) do f.stale=true end
activity:rebuildPresentation()
assert(frameCount==oldFrames*2 and activity.resultCard.panel.visible and not activity.panel.visible)
assert(activity.elapsed==12 and activity.score==123 and session.resultAttempt==3)
assert(entries==resumes,'Presentation rebuild restarted a completed attempt')
print('Passed: registered frame roots/lists, complete alias disposal, repeatable menu/native-menu hiding, completed-state rebuild and unchanged gameplay/attempt state.')

assert(not pcall(JTG.Training.InstallPresentation,{},session,{roots={'forgotten'},references={}}),
    'A root can be hidden without being cleared on presentation rebuild')
assert(not pcall(JTG.Training.InstallPresentation,activity,session,activity.presentationSpec),
    'Duplicate presentation installation silently replaced the lifecycle')
