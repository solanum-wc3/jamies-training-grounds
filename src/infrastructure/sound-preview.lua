-- Development-only selected sound browser. Audio stays in Warcraft's data;
-- only the current page's twelve reusable buttons are created.
JTG.Dev = JTG.Dev or {}
local UI=JTG.UI
local state={page=1,buttons={}}
JTG.Dev.soundPreview=state
local PER_PAGE=12

function JTG.Dev.StopSoundPreview()
    if state.sound then StopSound(state.sound,true,false);state.sound=nil end
end

function JTG.Dev.PlaySoundPreview(entry)
    JTG.Dev.StopSoundPreview()
    local file=entry.files[GetRandomInt(1,#entry.files)]
    local sound
    -- Sound tables use FLAC names while some installations expose WAV aliases.
    -- Prefer the exact recording, particularly for numbered sound variants.
    for _,path in ipairs({file,(file:gsub('%.flac$','.wav'))}) do
        if GetSoundFileDuration(path)>0 then
            sound=CreateSound(path,false,false,false,10,10,'');break
        end
    end
    if not sound and not entry.exactVariant then
        sound=CreateSoundFromLabel(entry.label,false,false,false,10,10)
    end
    if not sound then
        BlzFrameSetText(state.description,'|cffff4040Could not load '..entry.name..'.|r')
        return false
    end
    state.sound=sound
    SetSoundVolume(sound,127)
    SetSoundChannel(sound,8)
    StartSound(sound)
    BlzFrameSetText(state.description,'|cffffcc00'..entry.name..'|r\n'..entry.note)
    return true
end

function JTG.Dev.ShowSoundPreviewPage(page)
    JTG.Dev.StopSoundPreview()
    local total=math.ceil(#JTG.DevSoundPreviews/PER_PAGE)
    state.page=math.max(1,math.min(total,page or state.page))
    for index,button in ipairs(state.buttons) do
        local entry=JTG.DevSoundPreviews[(state.page-1)*PER_PAGE+index]
        BlzFrameSetVisible(button,entry~=nil)
        if entry then
            BlzFrameSetText(button,entry.name)
            UI.clickActions[GetHandleId(button)]=function() JTG.Dev.PlaySoundPreview(entry) end
        else UI.clickActions[GetHandleId(button)]=nil end
    end
    BlzFrameSetText(state.pageText,tostring(state.page)..' / '..total)
    BlzFrameSetEnable(state.previous,state.page>1)
    BlzFrameSetEnable(state.next,state.page<total)
    BlzFrameSetAlpha(state.previous,state.page>1 and 255 or 145)
    BlzFrameSetAlpha(state.next,state.page<total and 255 or 145)
    BlzFrameSetText(state.description,'Select a sound to preview it.\nYour notes appear here.')
end

local function Install()
    local scope=JTG.CreateScope('dev-sound-preview')
    state.scope=scope
    local root=BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0)
    local panel=JTG.ScopeTrackFrame(scope,UI.CreateNativePanel('JTGDevSoundPreviewPanel',root,0.64,0.47))
    state.panel=panel;UI.panels.dev_sounds=panel
    BlzFrameSetAbsPoint(panel,FRAMEPOINT_CENTER,0.40,0.32)
    BlzFrameSetVisible(panel,false)
    local function text(name,parent,width,height,scale)
        local frame=JTG.ScopeTrackFrame(scope,BlzCreateFrameByType('TEXT',name,parent,'',0))
        BlzFrameSetSize(frame,width/scale,height/scale);BlzFrameSetScale(frame,scale)
        BlzFrameSetTextAlignment(frame,TEXT_JUSTIFY_MIDDLE,TEXT_JUSTIFY_CENTER)
        BlzFrameSetEnable(frame,false)
        return frame
    end
    local function button(name,parent,label,width,height,action,sound)
        local frame=JTG.ScopeTrackFrame(scope,BlzCreateFrameByType('GLUETEXTBUTTON',name,parent,'ScriptDialogButton',0))
        BlzFrameSetSize(frame,width,height);BlzFrameSetText(frame,label)
        local id=GetHandleId(frame)
        UI.clickActions[id]=action;UI.clickSounds[id]=sound
        BlzTriggerRegisterFrameEvent(UI.clickTrigger,frame,FRAMEEVENT_CONTROL_CLICK)
        JTG.ScopeAdd(scope,function() UI.clickActions[id]=nil;UI.clickSounds[id]=nil end)
        return frame
    end
    local title=text('JTGDevSoundPreviewTitle',panel,0.52,0.04,1.55)
    BlzFrameSetPoint(title,FRAMEPOINT_TOP,panel,FRAMEPOINT_TOP,0,-0.02)
    BlzFrameSetText(title,'|cffffcc00Sound Previews|r')
    state.description=text('JTGDevSoundPreviewDescription',panel,0.53,0.060,0.95)
    BlzFrameSetPoint(state.description,FRAMEPOINT_TOP,panel,FRAMEPOINT_TOP,0,-0.091)
    local credits=button('JTGDevSoundPreviewCredits',panel,'Credits',0.13,0.028,
        function() UI.ShowInfo('credits') end,'return')
    BlzFrameSetPoint(credits,FRAMEPOINT_TOPLEFT,panel,FRAMEPOINT_TOPLEFT,0.04,-0.060)
    local stop=button('JTGDevSoundPreviewStop',panel,'Stop',0.13,0.028,JTG.Dev.StopSoundPreview,false)
    BlzFrameSetPoint(stop,FRAMEPOINT_TOPRIGHT,panel,FRAMEPOINT_TOPRIGHT,-0.04,-0.060)
    state.buttons={}
    for index=1,PER_PAGE do
        local preview=button('JTGDevSoundPreview'..index,panel,'',0.265,0.035,function() end,false)
        BlzFrameSetPoint(preview,FRAMEPOINT_TOP,panel,FRAMEPOINT_TOP,
            index%2==1 and -0.143 or 0.143,-0.161-math.floor((index-1)/2)*0.041)
        state.buttons[index]=preview
    end
    state.pageText=text('JTGDevSoundPreviewPage',panel,0.16,0.035,1)
    BlzFrameSetPoint(state.pageText,FRAMEPOINT_BOTTOM,panel,FRAMEPOINT_BOTTOM,0,0.023)
    state.previous=button('JTGDevSoundPreviewPrevious',panel,'<',0.06,0.035,
        function() JTG.Dev.ShowSoundPreviewPage(state.page-1) end,'return')
    state.next=button('JTGDevSoundPreviewNext',panel,'>',0.06,0.035,
        function() JTG.Dev.ShowSoundPreviewPage(state.page+1) end,'normal')
    BlzFrameSetPoint(state.previous,FRAMEPOINT_BOTTOM,panel,FRAMEPOINT_BOTTOM,-0.13,0.023)
    BlzFrameSetPoint(state.next,FRAMEPOINT_BOTTOM,panel,FRAMEPOINT_BOTTOM,0.13,0.023)
    local creditsPanel=UI.panels.credits
    local back=BlzGetFrameByName('JTGInfoBack2',0)
    if back then
        BlzFrameClearAllPoints(back)
        BlzFrameSetPoint(back,FRAMEPOINT_BOTTOMLEFT,creditsPanel,FRAMEPOINT_BOTTOMLEFT,0.045,0.035)
    end
    state.openButton=button('JTGDevSoundPreviewOpen',creditsPanel,'Sound Previews',0.17,0.044,function()
        UI.ShowInfo('dev_sounds')
        JTG.Dev.ShowSoundPreviewPage(state.page)
        UI.currentBackAction=function() UI.ShowInfo('credits') end
    end,'normal')
    BlzFrameSetPoint(state.openButton,FRAMEPOINT_BOTTOMRIGHT,creditsPanel,FRAMEPOINT_BOTTOMRIGHT,-0.045,0.035)
    JTG.Dev.ShowSoundPreviewPage(state.page)
end

local initialize=UI.Initialize
UI.Initialize=function(restoring)
    JTG.Dev.StopSoundPreview()
    if state.scope then
        if restoring then JTG.AbandonScope(state.scope) else JTG.DisposeScope(state.scope) end
    end
    initialize(restoring)
    Install()
end
local hide=UI.HideAllPanels
UI.HideAllPanels=function(...)
    JTG.Dev.StopSoundPreview()
    return hide(...)
end
