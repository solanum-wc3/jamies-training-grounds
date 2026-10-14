JTG={UI={}}
function FourCC(raw) return raw end
dofile('src/infrastructure/core.lua')
dofile('src/generated/dev-sounds.lua')
local frames,created,stopped,started={}, {}, {}, {}
function GetHandleId(value) return value end
function GetRandomInt(low) return low end
function BlzCreateFrameByType(kind,name,parent) local f={kind=kind,name=name,parent=parent};frames[#frames+1]=f;return f end
function BlzDestroyFrame(frame) frame.destroyed=true end
function BlzGetOriginFrame() return {} end
local back={}
function BlzGetFrameByName(name) assert(name=='JTGInfoBack2');return back end
function BlzFrameSetSize(frame,w,h) frame.w,frame.h=w,h end
function BlzFrameSetScale() end
function BlzFrameSetTextAlignment() end
function BlzFrameSetAbsPoint() end
function BlzFrameSetPoint() end
function BlzFrameClearAllPoints() end
function BlzFrameSetText(frame,text) frame.text=text end
function BlzFrameSetVisible(frame,value) frame.visible=value end
function BlzFrameSetEnable(frame,value) frame.enabled=value end
function BlzFrameSetAlpha() end
function BlzTriggerRegisterFrameEvent() end
local missing=false
function GetSoundFileDuration(path) return missing and 0 or 1000 end
function CreateSound(path,looping,threeD) assert(not looping and not threeD);local s={path=path};created[#created+1]=s;return s end
function CreateSoundFromLabel(label) local s={label=label};created[#created+1]=s;return s end
function StopSound(sound,kill,fade) assert(kill and not fade);stopped[#stopped+1]=sound end
function StartSound(sound) started[#started+1]=sound end
function SetSoundVolume(_,volume) assert(volume==127) end
function SetSoundChannel(_,channel) assert(channel==8) end
local UI=JTG.UI
UI.Initialize=function() UI.panels={credits={}};UI.clickActions={};UI.clickSounds={};UI.clickTrigger={} end
UI.CreateNativePanel=function(name,parent) return BlzCreateFrameByType('FRAME',name,parent) end
UI.HideAllPanels=function() for _,panel in pairs(UI.panels) do panel.visible=false end end
UI.ShowInfo=function(id) UI.HideAllPanels();UI.panels[id].visible=true;UI.currentView={kind='info',id=id} end
dofile('src/infrastructure/sound-preview.lua')
UI.Initialize(false)
local state=JTG.Dev.soundPreview
assert(#JTG.DevSoundPreviews==52 and #state.buttons==12)
UI.clickActions[state.openButton]()
assert(UI.currentView.id=='dev_sounds' and state.pageText.text=='1 / 5' and not state.previous.enabled)
local count=#frames
for page=1,5 do
    JTG.Dev.ShowSoundPreviewPage(page)
    for index,button in ipairs(state.buttons) do
        local entry=JTG.DevSoundPreviews[(page-1)*12+index]
        assert(button.visible==(entry~=nil))
        if entry then
            assert(button.text==entry.name and UI.clickSounds[button]==false)
            UI.clickActions[button]()
            assert(state.sound.path==entry.files[1] and state.description.text:find(entry.name,1,true))
        end
    end
end
assert(#frames==count,'Page changes create more buttons')
assert(not state.next.enabled and state.pageText.text=='5 / 5')
assert(#started==52 and #stopped==51,'Previews overlap or fail to play exactly the selected set')
UI.HideAllPanels();assert(not state.sound and #stopped==52)
missing=true
local exact
for _,entry in ipairs(JTG.DevSoundPreviews) do if entry.name=='PeonRepair2' then exact=entry end end
assert(exact.exactVariant and not JTG.Dev.PlaySoundPreview(exact),'Missing numbered clip silently plays a random variant')
assert(state.description.text:find('Could not load PeonRepair2',1,true))
assert(JTG.Dev.PlaySoundPreview(JTG.DevSoundPreviews[1]) and state.sound.label=='SoulPreservation',
    'Native label fallback not used for a single-recording sound')
UI.Initialize(false)
assert(not state.sound,'UI rebuild retains old preview audio')
assert(#state.buttons==12 and UI.clickActions[state.openButton])
print('Passed: 52 selected sounds, five pages, twelve reusable buttons, notes, exact variants, no overlapping audio and menu cleanup.')
