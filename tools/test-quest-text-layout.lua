-- Exercise the real shared native layout without requiring a running timer.
local file=assert(io.open('src/infrastructure/ui.lua'));local source=file:read('*a');file:close()
local first=assert(source:find('local function ApplyFullQuestTextLayout()',1,true))
local last=assert(source:find('local HookNativeLoadButtons',first,true))
local frames={QuestDisplay={},QuestDetailsTitle={},QuestDisplayBackdrop={},QuestItemListContainer={height=.057,visible=true}}
local function lookup(name) return frames[name] end
local environment={BlzGetFrameByName=lookup,FRAMEPOINT_TOPLEFT='TL',FRAMEPOINT_BOTTOMLEFT='BL',FRAMEPOINT_BOTTOMRIGHT='BR',
 BlzFrameClearAllPoints=function(frame) frame.points={} end,
 BlzFrameSetPoint=function(frame,point,target,relative,x,y) frame.points[point]={target=target,relative=relative,x=x,y=y} end,
 BlzFrameSetSize=function(frame,w,h) frame.width=w;frame.height=h end,
 BlzFrameSetVisible=function(frame,value) frame.visible=value end}
local apply=assert(load(source:sub(first,last-1)..'\nreturn ApplyFullQuestTextLayout','quest-layout','t',environment))()
apply()
local items,display,title=frames.QuestItemListContainer,frames.QuestDisplay,frames.QuestDetailsTitle
assert(not items.visible and items.height<.001 and items.points.TL.target==title and items.points.TL.y==0)
assert(display.points.TL.target==title and display.points.TL.y==-.003)
assert(display.points.BR.target==frames.QuestDisplayBackdrop)
-- Re-selecting a quest may re-anchor the description to the native item list.
-- Its collapsed extent must no longer recreate the old 0.057 objective gap.
display.points.TL={target=items}
assert(items.height<.001)
apply();assert(display.points.TL.target==title)
frames.QuestDisplay=nil;apply() -- native dialog not created yet
frames.QuestDisplay={};frames.QuestItemListContainer=nil;apply()
assert(frames.QuestDisplay.points.TL.target==title)
local init=assert(source:find('function UI.Initialize(restoring)',1,true))
assert(source:find('    ApplyFullQuestTextLayout()',init,true),'Layout only depends on a timer after opening')
print('Passed: empty native objective container collapses, description fills the reference area, selection re-anchors retain no gap, and initialization prepares layout.')
