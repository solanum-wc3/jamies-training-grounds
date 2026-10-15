-- Development-only sound isolation. No button clicks or synthetic hotkeys are
-- used to enter/leave the tutorial. Reports retain actual native state values.
JTG=JTG or {};JTG.Dev=JTG.Dev or {}
local PLAYER=Player(0)
local audit={active=false,rows={}}
local soundTimer,sound
local function say(text) DisplayTimedTextToPlayer(PLAYER,0,0,12,text) end
local function row(label)
    if not audit.active then return end
    local values={label,'xp='..tostring(GetPlayerHandicapXP(PLAYER)),
        'time='..tostring(GetFloatGameState(GAME_STATE_TIME_OF_DAY))}
    for _,id in ipairs({0,6,PLAYER_NEUTRAL_PASSIVE}) do
        local owner=Player(id)
        values[#values+1]='p'..id..'food='..GetPlayerState(owner,PLAYER_STATE_RESOURCE_FOOD_USED)
        values[#values+1]='p'..id..'cap='..GetPlayerState(owner,PLAYER_STATE_RESOURCE_FOOD_CAP)
    end
    audit.rows[#audit.rows+1]=table.concat(values,',')
end
function JTG.Dev.HeroesAudioTrace(_,label) row(label) end
function JTG.Dev.HeroesAudioUnit(_,raw,unit,x,y)
    if not audit.active then return end
    row('unit='..raw..',owner='..GetPlayerId(GetOwningPlayer(unit))..
        ',planned='..x..'/'..y..',actual='..GetUnitX(unit)..'/'..GetUnitY(unit))
end
local function export()
    PreloadGenClear();PreloadGenStart()
    Preload('// JTG Heroes audio isolation; this is diagnostic preload output.')
    for _,text in ipairs(audit.rows) do Preload('// '..text) end
    PreloadGenEnd('JTG-Heroes-Audio.pld')
    say('Saved JTG-Heroes-Audio.pld ('..#audit.rows..' records).')
end
local function stopSounds()
    if soundTimer then PauseTimer(soundTimer);DestroyTimer(soundTimer);soundTimer=nil end
    if sound then StopSound(sound,false,false);KillSoundWhenDone(sound);sound=nil end
end
local function compareSounds()
    stopSounds()
    local labels={'PauseGame','GlueScreenClick','UpkeepLevel'}
    local index=0
    local function play()
        index=index+1
        if not labels[index] then stopSounds();return end
        if sound then StopSound(sound,false,false);KillSoundWhenDone(sound) end
        sound=CreateSoundFromLabel(labels[index],false,false,false,10,10)
        say('Audio comparison '..index..'/3: '..labels[index])
        if sound and GetLocalPlayer()==PLAYER then StartSound(sound) end
    end
    play();soundTimer=CreateTimer();TimerStart(soundTimer,3,true,play)
end
JTG.RegisterBootstrapInitializer(function()
    local trigger=CreateTrigger()
    for _,command in ipairs({'-heroes-audio-start','-heroes-audio-stop','-heroes-audio-sounds','-heroes-audio-status'}) do
        TriggerRegisterPlayerChatEvent(trigger,PLAYER,command,true)
    end
    TriggerAddAction(trigger,function()
        local command=GetEventPlayerChatString()
        if command=='-heroes-audio-sounds' then compareSounds()
        elseif command=='-heroes-audio-start' then
            if JTG.Controller.session then say('Exit the current activity first.');return end
            stopSounds();audit={active=true,rows={}}
            row('before-no-button-start')
            say('Starting Heroes without button audio. Listen for the upkeep chime.')
            JTG.StartActivity('learn.heroes','learn')
            row('after-no-button-start')
        elseif command=='-heroes-audio-stop' then
            stopSounds()
            local session=JTG.Controller.session
            if session and session.id=='learn.heroes' then
                row('before-no-button-stop');JTG.StopActivity('heroes-audio-isolation')
                JTG.UI.ShowCategory('learn');row('after-no-button-stop')
            end
            if #audit.rows>0 then export() else say('No Heroes audio trace has been started.') end
            audit.active=false
        else
            say('Heroes audio trace: '..#audit.rows..' records; active='..tostring(audit.active))
            if audit.rows[#audit.rows] then say(audit.rows[#audit.rows]) end
        end
    end)
end)
