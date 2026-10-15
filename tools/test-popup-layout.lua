JTG={}
function FourCC(raw) return raw end
FRAMEPOINT_TOPRIGHT,FRAMEPOINT_TOP,FRAMEPOINT_BOTTOM='tr','top','bottom'
function BlzFrameClearAllPoints(frame) frame.anchor=nil end
function BlzFrameSetSize(frame,w,h) frame.width=w;frame.height=h end
function BlzFrameSetAbsPoint(frame,point,x,y) frame.absolute={point,x,y} end
function BlzFrameSetPoint(frame,point,target,targetPoint,x,y) frame.anchor={point,target,targetPoint,x,y} end
dofile('src/infrastructure/core.lua')
for _,count in ipairs({2,5,8,10}) do
 local panel,buttons,close={},{},{}
 for index=1,count do buttons[index]={width=.3,height=.01,anchor={'old'}} end
 JTG.LayoutChoicePopup(panel,buttons,close)
 assert(panel.width==.185 and panel.height==JTG.TutorialMenuHeight(count))
 assert(panel.absolute[2]==.795 and panel.absolute[3]==.5)
 for index,button in ipairs(buttons) do
  assert(button.width==.115 and button.height==.026)
  assert(math.abs(button.anchor[5]-(-.041-(index-1)*.029))<.000001)
 end
 assert(close.width==.10 and close.height==.026 and close.anchor[1]=='bottom' and close.anchor[5]==.025)
 local lastBottom=panel.height+buttons[count].anchor[5]-.026
 assert(lastBottom>=.025+.026,'Last choice overlaps the Close footer')
end
for _,name in ipairs({'camera-tutorial','unit-controls-tutorial','hotkey-setup-tutorial',
 'economy-tutorial','heroes-tutorial','surrounds'}) do
 local file=assert(io.open('src/activities/'..name..'.lua'));local source=file:read('*a');file:close()
 assert(source:find('JTG.LayoutChoicePopup(',1,true),'Popup bypasses shared layout: '..name)
end
print('Passed: shared Topics/Optional/Setups popup geometry, stable anchors, separate Close footer and all migrated activities.')
