-- Native attack/spell laboratory: do not manufacture projectile dodge results.
JTG = JTG or {}

local RACES = {{"human", "Human"}, {"orc", "Orc"}, {"undead", "Undead"},
    {"nightelf", "Night Elf"}, {"neutral", "Neutral"}}

local BRIEFING = {
    root = "It is possible to dodge and evade many attacks and abilities.\n\nWhen it takes the form of a missile that flies at your unit, it is possible to {Term: Disjoin} that missile, meaning to make it miss its target, effectively dodging it.\nWhen the ability merely has a range or an area of effect, it is possible to {Term: Avoid} the ability.\n\nBoth of these techniques have two advantages: You are making your enemy waste resources (Time, Cooldowns or Mana), and you are preventing your own units from being damaged or disabled.\n\nChoose which kind of dodging you want to train!",
    disjoining = "Do disjoin a projectile, you need to make your unit stop being a valid target after the attacker has thrown it, but before it has hit your unit.\nIf you do this before the attacker has thrown it, you have avoided the effects, but it has cost your enemy nothing.\n\nChoose which kinds of projectiles you want to disjoin!",
    homing = "Choose which ability you want to try to disjoin!\n\nAll but the Raider's Ensnare ability are spells.\nOrb effects are technically just modified ranged attacks.",
    ranged = "Choose which attack projectile you want to try to disjoin!",
    avoiding = "In this training there are two categories of things to avoid.\nThe first being abilities with an {Term: Area} effect, meaning they do not target a unit.\nThey either target the ground, or a direction, or automatically affect an area around the unit that uses them.\n\nThe other category is a specialized training to avoid the {Term: Devour} ability of the Orc's {Gold Font: Kodo Beast}.\n\nChoose what you want to train against!",
    areaIntro = "To avoid an area ability, you have to move outside of the affected area, either through {Term: Movement}, or through the use of your own {Term: Ability}.\n\nIn this training, the enemy will repeatedly try to hit your unit with its ability. You will succeed if you avoid it for 15 seconds.\nDepending on the ability, this can be very hard, or even impossible, so pay attention to telegraphing behavior through targeting and wind-up animations!",
    area = "Choose which {Term: Area} ability you want to practice avoiding!",
    how = "Choose whether you want to train avoiding the ability by movement or with the help of an ability of your own!",
    devour = "The Kodo will continuously try to devour your unit in a small area. Try to avoid being devoured for 15 seconds!\n\nChoose whether you want to train avoiding the Kodo through Movement or whether you want to use your own ability!\n\nChoosing abilities turns this exercise into a timing training instead.",
    devourAbility = "Choose which ability you want to use to try to avoid the Kodo's Devour ability!",
    devourMovement = "Choose which unit you want to use to try to avoid the Kodo's Devour ability!\nSlower units can make this exercise significantly harder, or even impossible.",
}

local function Stats(entry, dodgeInfo)
    if dodgeInfo and entry.activationNote then
        return ("\n"..entry.activationNote.."\n"):gsub("\nInstant\n","\nCast Point: Instant\n"):sub(2,-2)
    end
    if dodgeInfo and entry.unit=="opeo" then return "Cast Point: Instant" end
    if entry.statsKnown == false then return "Cast Point: Instant" end
    if entry.unit=="nwe1" and entry.kind=="attack" then return "No native ranged attack." end
    local point=entry.measuredCastPoint or entry.castPoint or entry.castTime or 0
    local activation=entry.measuredActivation
    if dodgeInfo and point==0 and activation and activation.seconds==0 and
            entry.measuredFadeDuration==nil and entry.fadeDuration==nil and not entry.extraTimingNote then
        return "Cast Point: Instant"
    end
    local text = (entry.kind=="attack" or entry.orbOrder and not dodgeInfo) and "Base attack wind-up: " or "Cast Point: "
    text = text .. (point==0 and "Instant" or string.format("%.3g",point).."s") ..
        (not dodgeInfo and ("\nProjectile Speed: " .. (not entry.instantProjectile and (entry.missileSpeed or 0)>0 and tostring(entry.missileSpeed).." units/s" or "Instant")) or "")
    if dodgeInfo and entry.measuredFadeDuration~=nil then
        text=text.."\nFade duration: "..string.format("%.3g",entry.measuredFadeDuration).."s"
    elseif dodgeInfo and entry.fadeDuration~=nil then text=text.."\nFade duration: "..string.format("%.3g",entry.fadeDuration).."s"
    elseif dodgeInfo and entry.fadeUnknown then text=text.."\nFade duration: Not exposed in game data" end
    if dodgeInfo and entry.measuredActivation and entry.measuredFadeDuration==nil then
        local measured=entry.measuredActivation
        text=text.."\n"..measured.label..": "..(measured.seconds==0 and "Instant" or
            (string.format("%.3g",measured.seconds).."s after command"))
    elseif dodgeInfo and entry.category=="Transformation" then text=text.."\nTransformation delay: Unknown" end
    if dodgeInfo and entry.extraTimingNote then text=text.."\n"..entry.extraTimingNote end
    if not dodgeInfo and entry.menuGroup=="Area" then
        text=text.."\nArea: "..(entry.areaText or (string.format("%.3g",entry.area or 0).." units radius"))
        if entry.waveInterval then text=text.."\nWave interval: "..entry.waveInterval.."s" end
    end
    return text
end

local function InvisibilityMethod(entry)
    local item=entry.item or entry.supportItem
    if item then return item=="pinv" or item=="clsd" end
    return entry.category=="Invisibility"
end

local function InvalidTargetReason(danger,entry)
    local raw=entry.targetSupport and entry.support or entry.unit
    local devourItem=entry.item or entry.supportItem
    if danger.menuGroup=="Devour" then
        if devourItem=="pnvu" then return nil end
        if devourItem=="clsd" or devourItem=="pams" or devourItem=="pinv" then
            return "This ability does not protect against Devour."
        end
    end
    local incompatible= danger.menuGroup=="Devour" and "This ability does not protect against Devour." or
        "This method does not disjoin the selected projectile."
    if danger.menuGroup=="Devour" and entry.unit=="uban" and entry.category=="Magic protection" then
        return incompatible
    end
    if danger.menuGroup=="Devour" and (entry.summon or raw=="osw1" or raw=="osw2" or raw=="osw3") then
        return "Wolves can be re-summoned if they get devoured."
    end
    if raw=="efdr" and danger.menuGroup=="Homing" and danger.ability~="Aens" then
        return "Not targetable."
    end
    if danger.menuGroup=="Area" and entry.category=="Movement" and raw=="edry" then
        return "Not targetable."
    end
    local traits=(JTG.DodgeUnitTraits or {})[raw] or {}
    if danger.menuGroup=="Area" and entry.category=="Movement" and danger.kind~="point" then
        local casterTraits=(JTG.DodgeUnitTraits or {})[danger.unit] or {}
        if traits.movementSpeed and casterTraits.movementSpeed and traits.movementSpeed<casterTraits.movementSpeed then
            return "This unit is too slow to avoid the ability user."
        end
    end
    local item=entry.item or entry.supportItem
    if not item and (raw=="Edem" or raw=="edoc") and danger.ability~="Aens" then
        return incompatible
    end
    if not item and raw=="ugar" and danger.orbOrder then
        return incompatible
    end
    if danger.ability=="Auco" and raw~="ehip" and raw~="ehpr" and raw~="edot" and raw~="edtm" and raw~="ugar" then
        return "Choose a Hippogryph, Hippogryph Rider, Crow Form Druid of the Talon, or Gargoyle."
    end
    if danger.ability=="AUdc" and traits.undead then return "Death Coil cannot damage Undead units." end
    if danger.menuGroup=="Area" and danger.spellTargets and danger.spellTargets~="" then
        local targets=","..danger.spellTargets..","
        local flying=traits.flying or (danger.ability=="Auco" and raw=="edot")
        if flying and not targets:find(",air,",1,true) then return "This ability cannot hit flying units." end
        if not flying and not targets:find(",ground,",1,true) then return "This ability only hits flying units." end
        if traits.mechanical and targets:find(",organic,",1,true) then return "This ability only affects organic units." end
    end
    if danger.menuGroup=="Devour" and (traits.hero or traits.flying or traits.mechanical or raw=="otau" or
        raw=="hwat" or raw=="hwt2" or raw=="hwt3" or (traits.level or 0)>5) then
        return "This unit cannot be devoured."
    end
end
JTG.DodgeInvalidTargetReason=InvalidTargetReason
JTG.DodgeStats=Stats

function JTG.OpenMissileDodgingMenu(originCategory, pauseGame, restorePage, restoreData)
    local active = JTG.Controller.session
    local state = {dangerIndex = 1, pawnIndex = 1, stage = 1}
    if active and active.id == "skills.missile_dodging" then
        state.dangerIndex, state.pawnIndex = active.activity.dangerIndex, active.activity.pawnIndex
        state.movementUnit = active.activity.movementUnit
    end
    for key,value in pairs(restoreData or {}) do state[key]=value end
    local showRoot, showGroups, showRaces, showArtillery, showHow, showAbilities, showMovement, showConfirm, showRangedRaces, showRangedUnits, showHoming, showAreaIntro, backToDanger
    local function eligible(entry)
        local danger=JTG.DodgeDangers[state.dangerIndex]
        if InvalidTargetReason(danger,entry) then return false end
        local raw=entry.unit
        local traits=(JTG.DodgeUnitTraits or {})[raw] or {}
        if danger.menuGroup=="Devour" then
            if entry.item=="pnvu" then return true end
            return not traits.hero and not traits.flying and not traits.mechanical and
                raw~="otau" and raw~="hwat" and raw~="hwt2" and raw~="hwt3" and (traits.level or 0)<=5
        end
        if danger.menuGroup=="Ranged" and danger.unit=="hrtt" then
            return raw=="ehpr" or raw=="ehip" or raw=="edot" or raw=="edtm"
        end
        if danger.menuGroup=="Homing" then
            local item=entry.item or entry.supportItem
            if not item and (raw=="edot" or raw=="edtm") and danger.ability~="Aens" then return false end
            if danger.orbOrder then
                if raw=="uban" then return false end
                if InvisibilityMethod(entry) and raw~="Obla" then return false end
            end
            if danger.ability=="Aens" then
                if InvisibilityMethod(entry) and raw~="Obla" then return false end
                if (not item and (raw=="Hpal" or raw=="uban" or raw=="Hmkg")) or item=="pams" or item=="pnvu" then return false end
            elseif not item and (raw=="uobs" or raw=="Ntin") then return false end
        end
        if danger.ability=="AUdc" then return not traits.undead end
        return true
    end
    local function tooltip(entry)
        local danger=JTG.DodgeDangers[state.dangerIndex]
        local reason=InvalidTargetReason(danger,entry)
        if not eligible(entry) then
            if reason then return reason end
            local item=entry.item or entry.supportItem
            if danger.ability=="Aens" then
                if InvisibilityMethod(entry) then return "Ensnare reveals invisible units." end
                if entry.unit=="Hpal" and not item then return "The net still hits if it was thrown before Divine Shield." end
                if item=="pnvu" then return "The net still hits if it was thrown before invulnerability." end
                return "Only blocks magical abilities."
            end
            if danger.menuGroup=="Ranged" and danger.unit=="hrtt" then return "This attack only targets flying units." end
            return danger.menuGroup=="Devour" and "This ability does not protect against Devour." or
                "This method does not disjoin the selected projectile."
        end
        local text=Stats(entry,true)
        local function addNote(note)
            if entry.unit=="Obla" then
                local marker="\n\nMirror Image"
                local split=text:find(marker,1,true)
                if split then
                    text=text:sub(1,split-1).."\n"..note..text:sub(split)
                    return
                end
            end
            text=text.."\n"..note
        end
        if InvisibilityMethod(entry) and entry.unit=="Obla" and danger.ability~="Aens" then
            addNote("Wind Walk must finish fading before the projectile hits.")
        end
        if JTG.DodgeDangers[state.dangerIndex].ability=="Aens" then
            local note
            if InvisibilityMethod(entry) then note="Ensnare reveals invisible units"
            elseif entry.unit=="Hpal" and not entry.item then note="The net still hits if it was thrown before Divine Shield"
            elseif entry.unit=="uban" or entry.unit=="Hmkg" or entry.item=="pams" then note="Only blocks magical abilities" end
            if note then addNote(note) end
        end
        if JTG.DodgeDangers[state.dangerIndex].orbOrder and entry.unit=="edot" then
            text=text.."\nAfter transforming, Druids of the Talon benefit from higher armor, but they do not dodge attacks."
        end
        if danger.menuGroup=="Homing" and not eligible(entry) and not reason and danger.ability~="Aens" then
            text=text.."\nThis method does not disjoin the selected projectile."
        end
        return text
    end
    local function release() JTG.UI.SetGameplayMenuPaused(false) end
    local function startSelection()
        state.startDelay=true
        release()
        JTG.StartActivityAfterCleanup("skills.missile_dodging",originCategory or "skills",state,nil,"dodge-case")
    end
    local function present(spec, page)
        spec.body=JTG.FormatSurroundQuestText(spec.body or "")
        spec.title, spec.activityId = "Dodging", "skills.missile_dodging"
        spec.titleSuffix=nil
        spec.pauseGame = pauseGame == true
        spec.originCategory, spec.pageId, spec.restoreData = originCategory or "skills", page, state
        if pauseGame then
            spec.resumeAction = function() release(); JTG.ResumeActivity() end
            spec.exitAction = function()
                release(); JTG.StopActivity("menu-exit"); pauseGame = false; showRoot()
            end
        end
        JTG.UI.ShowActivityBriefing(spec)
    end
    showRoot = function()
        present({body=BRIEFING.root,headingArtwork="JTGMenu\\MissileDodging.dds",
            choices={{label="Disjoining",action=function() state.branch="disjoining";showGroups() end},
                {label="Avoiding",action=function() state.branch="avoiding";showGroups() end}},
            backAction=function() JTG.UI.ShowCategory(originCategory or "skills") end},"root")
    end
    showGroups = function()
        local choices = {}
        for _, group in ipairs(state.branch=="avoiding" and {"Area","Devour"} or {"Homing","Ranged"}) do
            local selected = group
            choices[#choices + 1] = {label = selected == "Devour" and "Devour (Kodo)" or selected=="Homing" and "Abilities" or selected=="Ranged" and "Attacks" or selected, action = function()
                if selected == "Ranged" then showRangedRaces()
                elseif selected == "Homing" then showHoming(selected)
                elseif selected == "Area" then showAreaIntro()
                elseif selected == "Devour" then
                    for index,entry in ipairs(JTG.DodgeDangers) do if entry.menuGroup == "Devour" then state.dangerIndex=index; break end end
                    showHow()
                else showArtillery() end
            end}
        end
        present({body = state.branch=="avoiding" and BRIEFING.avoiding or BRIEFING.disjoining,
            titleSuffix=state.branch=="avoiding" and "- Avoiding" or "- Disjoining",choices=choices,backAction=showRoot},"groups")
    end
    showConfirm = function(entry, back)
        state.confirmMethod = back==showAbilities and "ability" or "movement"
        local danger = JTG.DodgeDangers[state.dangerIndex]
        local arena = danger.menuGroup == "Artillery" or danger.menuGroup == "Area" or danger.menuGroup == "Devour"
        local singleStage=danger.orbOrder and entry.unit=="Obla"
        present({body = "Opponent: " .. danger.name .. "\nDodge: " .. entry.name .. "\n\n" ..
            (danger.menuGroup=="Devour" and (state.movementUnit and "Avoid being devoured for 15 seconds." or "Your pawn cannot move. Dodge the approaching Kodo's Devour three times in a row. There is one stage.") or
            danger.menuGroup=="Area" and "Avoid being hit for 15 seconds." or arena and "Practice in an enclosed arena. This is an unscored test." or entry.summon and "Two stages with stationary Spirit Wolves: the enemy fires from maximum range, then from half range. The enemy starts at the tested range plus 400." or singleStage and "One stage: the enemy fires from maximum range while your unit can move." or
                "Three stages: both units start at the tested range plus 200. First you can move; then you cannot move. In the final stage, the enemy approaches to half range before firing."),
            centerSingleChoice = true, choices = {{label = "Begin", action = function()
                release(); JTG.StartActivityAfterCleanup("skills.missile_dodging", originCategory or "skills", state, nil, "dodge-case")
            end}}, backAction = back}, "confirm")
    end
    showAbilities = function()
        local groups = {{"human", "Human", 0, 2}, {"orc", "Orc", 2, 2}, {"undead", "Undead", 4, 2},
            {"nightelf", "Night Elf", 7, 2}, {"neutral", "Neutral", 10, 1}, {"item", "Item", 12, 2}}
        local choices, headings = {}, {}
        local step=0.034
        local neutralMain={Ntin=true,Npbm=true,Npal=true}
        for _, group in ipairs(groups) do
            local left, span = group[3], group[4]
            local lastColumn = left
            local count, mainCount = 0, 0
            for index, entry in ipairs(JTG.DodgePawns) do
                local key = (entry.item or entry.supportItem) and "item" or entry.race
                if key == group[1] and entry.name ~= "Move on the ground" then
                    local column,row
                    if key=="human" or key=="orc" then
                        column,row=left,count+1; count=count+1
                    elseif key=="neutral" and (neutralMain[entry.unit] or entry.support=="nzep") then
                        column,row=left,mainCount+1; mainCount=mainCount+1
                    else
                        local offset=key=="neutral" and 1 or 0
                        column,row=left+offset+count%2,math.floor(count/2)+1; count=count+1
                    end
                    local selected = index
                    lastColumn = math.max(lastColumn, column)
                    choices[#choices + 1] = {label = entry.name, icon = entry.icon, tooltip = tooltip(entry), tooltipColor="|cffbbbbbb", tooltipWhenDisabled=true,
                        enabled=eligible(entry), unitRawcode=entry.unit, column=column, row=row, action = function()
                            state.pawnIndex, state.movementUnit = selected, nil
                            local danger=JTG.DodgeDangers[state.dangerIndex]
                            if danger.menuGroup=="Artillery" then showConfirm(entry,showAbilities)
                            else startSelection() end
                        end}
                end
            end
            headings[#headings + 1] = {label = group[2], x = (left-6.5)*step-step*0.5,
                y = -0.155, width=(lastColumn-left+1)*step, scale=1}
        end
        local danger=JTG.DodgeDangers[state.dangerIndex]
        local body
        if danger.menuGroup=="Devour" then body=BRIEFING.devourAbility
        elseif danger.menuGroup=="Homing" then
            body="Choose which ability you want to use to try to disjoin "..danger.name.."!\nYou will advance through three stages after three successful disjoins.\nBe careful! Not every ability works quickly enough to be able to disjoin every projectile."
        elseif danger.menuGroup=="Ranged" then body="Choose which ability you want to use to try to disjoin "..danger.name.."!"
        else body="Choose which ability you want to use to try to avoid "..danger.name.."!" end
        present({body = body,
            choices = choices, commandGridChoices = true, commandGridColumns = 14, commandGridRows = 7,
            commandGridButtonSize = 0.027, commandGridStep = 0.032, commandGridColumnStep = step, commandGridTop = -0.155,
            commandGridHeadings = headings, backAction = function()
                local group = JTG.DodgeDangers[state.dangerIndex].menuGroup
                if group == "Homing" or group == "Ranged" then backToDanger() else showHow() end
            end}, "abilities")
    end
    showHoming = function(filter)
        filter=filter or "Homing"
        state.dangerGroup=filter
        if filter=="Homing" then
            local choices={}
            local layouts={{"AHtb","Storm Bolt",0,1},{"AUdc","Death Coil",0,2},
                {"AUim","Impale",0,3},{"AEsh","Shadow Strike",0,4},{"ANdh","Drunken Haze",0,5},
                {"Aens","Ensnare",1,1},{"AHfa","Searing Arrows",2,1},{"ANfa","Frost Arrows",2,2},
                {"ANba","Dark Arrows",2,3},{"ANia","Incinerate",2,4}}
            for _,slot in ipairs(layouts) do
                for index,entry in ipairs(JTG.DodgeDangers) do
                    if entry.menuGroup=="Homing" and entry.ability==slot[1] then
                        local selected=index
                        choices[#choices+1]={label=slot[2],icon=entry.icon,tooltip=Stats(entry),column=slot[3],row=slot[4],x=slot[1]=="Aens" and -0.053 or nil,
                            action=function() state.dangerIndex=selected; showHow() end}
                        break
                    end
                end
            end
            present({body=BRIEFING.homing,titleSuffix="- Abilities",choices=choices,commandGridChoices=true,
                commandGridColumns=3,commandGridRows=6,commandGridButtonSize=0.027,
                commandGridStep=0.029,commandGridColumnStep=0.08,commandGridTop=-0.17,
                commandGridHeadings={{label="Missile",x=-0.125,y=-0.17,width=0.09},
                    {label="Orb Effects",x=0.035,y=-0.17,width=0.09}},backAction=showGroups}, "homing")
            return
        end
        local choices,headings={},{}
        for col,race in ipairs(RACES) do
            headings[#headings+1]={label=race[2],x=((col-1)*2-4)*0.055-0.04,y=-0.17,width=0.08,scale=1}
            local row=1
            for index,entry in ipairs(JTG.DodgeDangers) do
                if entry.menuGroup==filter and entry.race==race[1] then
                    local selected=index
                    choices[#choices+1]={label=entry.name,icon=entry.icon,tooltip=Stats(entry),column=(col-1)*2,row=row,
                        action=function() state.dangerIndex=selected; showHow() end}
                    row=row+1
                end
            end
        end
        present({body=BRIEFING.area,titleSuffix="- Area",choices=choices,commandGridChoices=true,
            commandGridColumns=9,commandGridRows=6,commandGridButtonSize=0.027,
            commandGridStep=0.030,commandGridColumnStep=0.055,commandGridTop=-0.17,
            contentDividerY=-0.145,commandGridHeadings=headings,backAction=showAreaIntro}, "area")
    end
    showAreaIntro=function()
        present({body=BRIEFING.areaIntro,titleSuffix="- Area",centerSingleChoice=true,
            choices={{label="Start Training",action=function() showHoming("Area") end}},
            backAction=showGroups},"area_intro")
    end
    showRangedRaces = function()
        local choices={}
        for _,race in ipairs(RACES) do
            local key=race[1]
            choices[#choices+1]={label=race[2],action=function() showRangedUnits(key) end}
        end
        present({body=BRIEFING.ranged,titleSuffix="- Attacks",choices=choices,backAction=showGroups}, "ranged_races")
    end
    showRangedUnits = function(race)
        state.rangedRace=race
        local choices={}
        local aliases={hmtt="hmtm",hmtn="hrtt",odem="ocat",o001="osp1",o002="osp2",o003="osp3",uin1="uinf",etot="edtm",Ewdn="Ewar",Edem="Edmm"}
        for col,column in ipairs(JTG.GetSurroundCustomRaceColumns(race)) do
            for row,unit in ipairs(column) do
                local raw=aliases[unit.rawcode] or unit.rawcode
                local selected
                for index,entry in ipairs(JTG.DodgeDangers) do
                    if entry.menuGroup=="Ranged" and entry.unit==raw then selected=index; break end
                end
                local attackInfo=selected and JTG.DodgeDangers[selected]
                if raw=="hrif" or raw=="nwe1" then selected=nil end
                choices[#choices+1]={label=raw=="Edmm" and "Demon Hunter (Demon Form)" or unit.label,tooltip=raw~="nwe1" and (selected and (Stats(attackInfo).."\nAttack range: "..attackInfo.range.." units") or
                    (raw=="hrif" and "This attack has no projectile to disjoin." or "This unit has no selectable ranged attack.")) or nil,tooltipColor="|cffbbbbbb",icon=raw=="Edmm" and attackInfo.icon or JTG.GetSurroundCustomUnitIcon(unit.rawcode),
                    column=col-1,row=row-1,enabled=selected~=nil,tooltipWhenDisabled=raw~="nwe1",unitRawcode=raw,
                    action=function() if selected then state.dangerIndex=selected; showHow() end end}
            end
        end
        present({body=BRIEFING.ranged,choices=choices,commandGridChoices=true,
            commandGridColumns=10,commandGridRows=5,commandGridButtonSize=0.029,
            commandGridStep=0.030,commandGridTop=-0.205,backAction=showRangedRaces}, "ranged_units")
    end
    showMovement = function(race)
        state.movementRace=race
        local choices = {}
        local aliases = {hmtt = "hmtm", hmtn = "hmtt", odem = "ocat", o001 = "osp1", o002 = "osp2",
            o003 = "osp3", uin1 = "uinf", etot = "edtm", Ewdn = "Ewar"}
        for columnIndex, column in ipairs(JTG.GetSurroundCustomRaceColumns(race)) do
            for rowIndex, definition in ipairs(column) do
                local entry = {race = race, unit = aliases[definition.rawcode] or definition.rawcode, name = definition.label, category = "Movement", statsKnown = false,
                    abilities = {}, icon = JTG.GetSurroundCustomUnitIcon(definition.rawcode)}
                choices[#choices + 1] = {label = entry.name, icon = entry.icon, enabled=eligible(entry), unitRawcode=entry.unit,
                    tooltip=InvalidTargetReason(JTG.DodgeDangers[state.dangerIndex],entry),tooltipWhenDisabled=true,tooltipColor="|cffbbbbbb",
                    column = columnIndex - 1, row = rowIndex - 1, action = function()
                        state.movementUnit = entry
                        if JTG.DodgeDangers[state.dangerIndex].menuGroup=="Artillery" then
                            showConfirm(entry,function() showMovement(race) end)
                        else startSelection() end
                    end}
            end
        end
        present({body = JTG.DodgeDangers[state.dangerIndex].menuGroup=="Devour" and BRIEFING.devourMovement or "Choose a unit to practice dodging with movement.", choices = choices,
            commandGridChoices = true, commandGridColumns = 10, commandGridRows = 5,
            commandGridButtonSize = 0.029, commandGridStep = 0.030, commandGridTop = -0.205,
            backAction = showRaces}, "movement_units")
    end
    showHow = function()
        local danger = JTG.DodgeDangers[state.dangerIndex]
        local arena = danger.menuGroup == "Artillery" or danger.menuGroup == "Area" or danger.menuGroup == "Devour"
        if not arena then showAbilities(); return end
        present({body = danger.menuGroup=="Devour" and BRIEFING.devour or BRIEFING.how,
            choices = {{label = "Movement", action = showRaces}, {label = "Ability", action = showAbilities}},
            backAction = backToDanger}, "how")
    end
    showRaces = function()
        local choices = {}
        for _, race in ipairs(RACES) do
            local key = race[1]
            choices[#choices + 1] = {label = race[2], action = function() showMovement(key) end}
        end
        present({body = JTG.DodgeDangers[state.dangerIndex].menuGroup=="Devour" and BRIEFING.devourMovement or "Choose your dodge method's race.\n\nDodging: " .. JTG.DodgeDangers[state.dangerIndex].name,
            choices = choices, backAction = showHow}, "movement_races")
    end
    showArtillery = function()
        local choices={}
        for index,entry in ipairs(JTG.DodgeDangers) do
            if entry.menuGroup=="Artillery" then
                local selected=index
                choices[#choices+1]={label=entry.name,icon=entry.icon,unitRawcode=entry.unit,
                    tooltip="Ground-targeted splash attack\n"..Stats(entry)..(entry.note and ("\n"..entry.note) or ""),
                    tooltipColor="|cffbbbbbb",action=function() state.dangerIndex=selected; showHow() end}
            end
        end
        present({body="Choose what to dodge.",choices=choices,commandGridChoices=true,
            commandGridColumns=4,commandGridRows=3,backAction=showGroups}, "artillery")
    end
    backToDanger = function()
        local group=JTG.DodgeDangers[state.dangerIndex].menuGroup
        if group=="Homing" or group=="Area" then showHoming(group)
        elseif group=="Ranged" then showRangedUnits(state.rangedRace or "human")
        elseif group=="Artillery" then showArtillery()
        else showGroups() end
    end
    local pages={root=showRoot,groups=showGroups,homing=function() showHoming("Homing") end,
        area=function() showHoming("Area") end,area_intro=showAreaIntro,artillery=showArtillery,
        ranged_races=showRangedRaces,ranged_units=function() showRangedUnits(state.rangedRace or "human") end,
        how=showHow,abilities=showAbilities,movement_races=showRaces,
        movement_units=function() showMovement(state.movementRace or "human") end,
        confirm=function()
            if state.confirmMethod=="movement" and state.movementUnit then
                showConfirm(state.movementUnit,function() showMovement(state.movementRace or "human") end)
            else showConfirm(JTG.DodgePawns[state.pawnIndex],showAbilities) end
        end}
    if not restorePage and pauseGame and active and active.id=="skills.missile_dodging" then
        local group=JTG.DodgeDangers[state.dangerIndex].menuGroup
        state.branch=(group=="Area" or group=="Devour") and "avoiding" or "disjoining"
        restorePage=({Homing="homing",Ranged="ranged_races",Area="area",Devour="how",Artillery="artillery"})[group]
    end
    (pages[restorePage] or showRoot)()
end

local function Alive(unit)
    return unit ~= nil and GetUnitTypeId(unit) ~= 0 and not IsUnitType(unit, UNIT_TYPE_DEAD)
end

local function PrepareAbilities(unit, abilities)
    if IsUnitType(unit, UNIT_TYPE_HERO) then
        SetHeroLevel(unit, 1, false)
        UnitModifySkillPoints(unit, -GetHeroSkillPoints(unit))
    end
    for _, rawcode in ipairs(abilities or {}) do
        local id = FourCC(rawcode)
        UnitAddAbility(unit, id)
        SetUnitAbilityLevel(unit, id, 1)
        local ability = BlzGetUnitAbility(unit, id)
        if ability ~= nil then
            BlzSetAbilityIntegerLevelField(ability, ABILITY_ILF_MANA_COST, 0, 0)
        end
    end
    SetUnitState(unit, UNIT_STATE_MANA, BlzGetUnitMaxMana(unit))
end

function JTG.CreateMissileDodgingActivity(session)
    local selection = session.restartData or {}
    local activity = {dangerIndex = selection.dangerIndex or 1,
        pawnIndex = selection.pawnIndex or 1, stage = selection.stage or 1,
        streak=selection.streak or 0, hitCount=0, attempts = 0, accepted = 0, trialTime = 0, castConfirmed = false, finished = false,
        damage = 0, lastDamage = 0, elapsed = 0, supports = {}, controlledUnits = {},
        presentationVisible = true, lastOrderText = "Waiting for the first attempt."}
    activity.danger = JTG.DodgeDangers[activity.dangerIndex]
    activity.movementUnit = selection.movementUnit
    activity.definition = activity.movementUnit or JTG.DodgePawns[activity.pawnIndex]
    if activity.danger.menuGroup=="Devour" and activity.definition.item=="pnvu" then
        local definition={}
        for key,value in pairs(activity.definition) do definition[key]=value end
        definition.unit="hfoo" -- Devour needs an organic non-hero item bearer.
        activity.definition=definition
    end
    activity.stageLimit=activity.definition.summon and 2 or (activity.danger.orbOrder and activity.definition.unit=="Obla" and 1 or 3)
    activity.stage=math.min(activity.stage,activity.stageLimit)
    if activity.stageLimit==1 then activity.stage=1 end
    local group = activity.danger.menuGroup
    activity.abilityDevour=group=="Devour" and not activity.movementUnit
    if activity.abilityDevour then activity.stageLimit=1; activity.stage=1 end
    activity.arena = group == "Artillery" or group == "Area" or (group == "Devour" and not activity.abilityDevour)
    activity.arenaHalf = group == "Devour" and 384 or math.max(128, math.min(256,
        ((activity.danger.range or 700) - (activity.danger.minRange or 0) - 96) / 3))

    if group=="Artillery" then
        activity.arenaHalf=activity.danger.range or 1000
        activity.arenaInner=activity.danger.minRange or 0
    end
    activity.areaDirectional=group=="Area" and
        (activity.danger.ability=="AOsh" or activity.danger.ability=="AUcs" or
         activity.danger.ability=="ANbf" or activity.danger.ability=="AUim")
    activity.areaChasing=group=="Area" and activity.danger.kind=="immediate"
    activity.areaChannel=group=="Area" and (activity.danger.ability=="AHbz" or activity.danger.ability=="ANrf")
    if group=="Area" then
        activity.arenaHalf=math.max(384,activity.danger.range or 0,(activity.danger.area or 0)*2)
        if activity.areaDirectional then activity.arenaHalf=activity.danger.waveDistance or activity.danger.range end
        activity.arenaMaximum=activity.arenaHalf
    end
    activity.circular=group=="Artillery" or group=="Devour" or group=="Area"

    local phaseColors={waiting={255,220,65},windup={255,75,75},activating={255,220,65},
        ready={90,255,110},active={90,255,110},fired={90,255,110}}
    local function phaseText(phase)
        local color=phaseColors[phase] or phaseColors.ready
        return string.format("|cff%02x%02x%02x",color[1],color[2],color[3])..phase.."|r"
    end
    local function tint(unit,phase)
        local color=phaseColors[phase]
        if Alive(unit) then SetUnitVertexColor(unit,color[1],color[2],color[3],255) end
    end
    function activity:setPhase(side,phase)
        local key=side=="enemy" and "enemyPhase" or "dodgePhase"
        if self[key]==phase then return end
        self[key]=phase
        if side=="enemy" then tint(self.caster,phase)
        else
            tint(self.pawn,phase)
            if self.helper and not IsUnitType(self.helper,UNIT_TYPE_STRUCTURE) then tint(self.helper,phase) end
            for _,unit in ipairs(self.phaseUnits or {}) do tint(unit,phase) end
        end
        self:refreshStatus()
    end
    function activity:beginDodgePhase(ability)
        local function is(raw) return ability==FourCC(raw) end
        local kind="immediate"
        if is("AOwk") or is("Aivs") or is("Ashm") or is("AIhm") or is("AIv1") or is("AIv2") or is("Abur") or is("Abu2") then kind="invisibility"
        elseif is("Astn") or is("Aave") or is("AEme") or is("Abrf") or is("Arav") or is("ANrg") then kind="form"
        elseif is("AHds") or is("AIvu") or is("AIvl") or is("AOvd") or is("AItp") then kind="invulnerable"
        elseif is("AOmi") or is("ANef") or is("Apsh") then kind="hidden"
        elseif is("Aams") or is("AIxs") then kind="buff"
        elseif is("Aloa") then kind="loading"
        elseif is("AOsf") or is("Aco2") or is("Aco3") or is("Acoa") or is("Acoh") or is("Adec") or is("Adtn") then kind="removal"
        elseif is("ANsa") or is("ANpr") or is("AEbl") then kind="teleport" end
        if kind=="immediate" then
            local relevant=is("ANcp") or is("Aloa")
            for _,list in ipairs({self.definition.abilities or {},self.definition.supportAbilities or {}}) do
                for _,raw in ipairs(list) do if is(raw) then relevant=true end end
            end
            if not relevant then return false end
        end
        self.phaseKind=kind
        return true
    end
    function activity:updateDodgePhase()
        local target=self.target or self.pawn
        local kind=self.phaseKind
        if kind=="removal" and self.phaseReplacementGroup then
            GroupEnumUnitsOfPlayer(self.phaseReplacementGroup,Player(0),nil)
            ForGroup(self.phaseReplacementGroup,function()
                local unit=GetEnumUnit()
                local id=GetHandleId(unit)
                local raw=GetUnitTypeId(unit)
                if not self.phaseKnownHandles[id] and Alive(unit) and
                        (raw==FourCC("earc") or raw==FourCC("ehip") or raw==FourCC("ehpr") or
                         self.definition.summon and raw==FourCC(self.definition.unit)) then
                    self.phaseKnownHandles[id]=true
                    self.phaseUnits[#self.phaseUnits+1]=unit
                    tint(unit,self.dodgePhase or "ready")
                end
            end)
            GroupClear(self.phaseReplacementGroup)
        end
        local active=false
        if kind=="invisibility" then active=Alive(target) and IsUnitInvisible(target,Player(1))
        elseif kind=="form" then active=Alive(self.pawn) and self.phaseInitialType and GetUnitTypeId(self.pawn)~=self.phaseInitialType
        elseif kind=="invulnerable" then active=Alive(target) and BlzIsUnitInvulnerable(target)
        elseif kind=="hidden" then
            active=Alive(target) and (IsUnitHidden(target) or BlzIsUnitInvulnerable(target) or IsUnitInvisible(target,Player(1)))
            if not active then
                for _,raw in ipairs(self.definition.buffs or {}) do if target and GetUnitAbilityLevel(target,FourCC(raw))>0 then active=true;break end end
            end
        elseif kind=="buff" then
            for _,raw in ipairs(self.definition.buffs or {}) do if Alive(target) and GetUnitAbilityLevel(target,FourCC(raw))>0 then active=true;break end end
        elseif kind=="loading" then active=Alive(target) and IsUnitHidden(target)
        elseif kind=="removal" then
            active=target and (not Alive(target) or IsUnitHidden(target))
            if active then self.dodgeReplaced=true end
        elseif kind=="teleport" and Alive(target) and self.phaseStartX then
            local dx,dy=GetUnitX(target)-self.phaseStartX,GetUnitY(target)-self.phaseStartY
            active=dx*dx+dy*dy>1
        end
        if active then self.phaseWasActive=true;self:setPhase("dodge","active")
        elseif self.phaseWasActive and (kind=="invisibility" or kind=="hidden" or kind=="invulnerable" or kind=="buff" or kind=="loading" or kind=="form") then
            self:setPhase("dodge","ready")
        end
    end
    function activity:setupPhases(current)
        self.phaseKnownHandles={};self.phaseUnits={}
        for unit in pairs(self.baselineUnits or {}) do self.phaseKnownHandles[GetHandleId(unit)]=true end
        for _,unit in pairs({self.pawn,self.helper,self.target}) do self.phaseKnownHandles[GetHandleId(unit)]=true end
        self.phaseReplacementGroup=JTG.ScopeTrackGroup(current.scope,CreateGroup())
        self:setPhase("enemy","waiting"); self:setPhase("dodge","ready")
        local trigger=JTG.ScopeTrackTrigger(current.scope,CreateTrigger())
        for _,owner in ipairs({Player(0),Player(1)}) do
            for _,event in ipairs({EVENT_PLAYER_UNIT_SPELL_CHANNEL,EVENT_PLAYER_UNIT_SPELL_EFFECT,
                EVENT_PLAYER_UNIT_SPELL_ENDCAST,EVENT_PLAYER_UNIT_ISSUED_ORDER,
                EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER,EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER,
                EVENT_PLAYER_UNIT_LOADED,EVENT_PLAYER_UNIT_CONSTRUCT_START}) do
                TriggerRegisterPlayerUnitEvent(trigger,owner,event,nil)
            end
        end
        TriggerAddAction(trigger,JTG.GuardSession(current,function()
            local event,unit=GetTriggerEventId(),GetTriggerUnit()
            if unit==self.caster then
                if event==EVENT_PLAYER_UNIT_SPELL_CHANNEL then
                    self.phaseEnemyEffect=false;self:setPhase("enemy","windup")
                elseif event==EVENT_PLAYER_UNIT_SPELL_EFFECT then
                    self.phaseEnemyEffect=true;self:setPhase("enemy","fired")
                elseif event==EVENT_PLAYER_UNIT_SPELL_ENDCAST and not self.phaseEnemyEffect then self:setPhase("enemy","waiting") end
                return
            end
            if event==EVENT_PLAYER_UNIT_CONSTRUCT_START and self.dodgePhase=="activating" then
                self.phaseKind="loading";self.phaseWasActive=true;self:setPhase("dodge","active");return
            end
            if event==EVENT_PLAYER_UNIT_LOADED and GetLoadedUnit()==self.target then
                self.phaseKind="loading";self.phaseWasActive=true;self:setPhase("dodge","active");return
            end
            if unit~=self.pawn and unit~=self.helper then return end
            if event==EVENT_PLAYER_UNIT_SPELL_CHANNEL then
                local ability=GetSpellAbilityId()
                if not self:beginDodgePhase(ability) then return end
                self.phaseCastUnit,self.phaseCastAbility=unit,ability
                self.phaseWasActive=false
                self.phaseInitialType=self.pawn and GetUnitTypeId(self.pawn)
                local target=self.target or self.pawn
                if target then self.phaseStartX,self.phaseStartY=GetUnitX(target),GetUnitY(target) end
                self.phaseDodgeEffect=false;self:setPhase("dodge","windup")
            elseif event==EVENT_PLAYER_UNIT_SPELL_EFFECT then
                -- Ignore setup summons whose channel began before this
                -- observer existed, and unrelated automatic spells.
                if self.phaseCastUnit~=unit or self.phaseCastAbility~=GetSpellAbilityId() then return end
                self.phaseDodgeEffect=true
                if self.phaseKind=="immediate" then self:setPhase("dodge","active")
                else self:setPhase("dodge","activating");self:updateDodgePhase() end
            elseif event==EVENT_PLAYER_UNIT_SPELL_ENDCAST and self.phaseCastUnit==unit and
                    self.phaseCastAbility==GetSpellAbilityId() and not self.phaseDodgeEffect then
                self:setPhase("dodge","ready")
            elseif event==EVENT_PLAYER_UNIT_ISSUED_ORDER or event==EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER or event==EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER then
                local order=GetIssuedOrderId()
                if self.definition.building and (order==FourCC("emow") or order==FourCC("otrb") or order==FourCC("ogre")) then
                    self.phaseKind="loading";self.phaseWasActive=false;self:setPhase("dodge","activating")
                elseif self.definition.item=="clsd" and order==OrderId("stop") or
                        self.definition.id=="dodge.17" and order==OrderId("ambush") then
                    self.phaseKind="invisibility";self.phaseWasActive=false;self:setPhase("dodge","activating")
                elseif event==EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER then
                    local destination=GetOrderTargetUnit()
                    if destination and (GetUnitTypeId(destination)==FourCC("egol") or
                            GetUnitTypeId(destination)==FourCC("otrb") or destination==self.target and self.definition.support=="nzep") then
                        self.phaseKind="loading";self.phaseWasActive=false;self:setPhase("dodge","activating")
                    end
                end
            end
        end))
        JTG.StartScopedTimer(current,current.scope,0.03,true,function() self:updateDodgePhase() end)
    end

    function activity:flash(text, color)
        if self.feedback == nil then return end
        BlzFrameSetText(self.feedback, (color or "|cffffcc00") .. text .. "|r")
        BlzFrameSetVisible(self.feedback, self.presentationVisible)
        self.flashUntil = self.trialTime + 1.2
    end

    function activity:spawn(owner, raw, x, y, facing)
        local unit = JTG.ScopeTrackUnit(session.scope, CreateUnit(owner, FourCC(raw), x, y,
            facing or (self.stage == 1 and 180 or 0)))
        if owner == Player(0) then self.controlledUnits[#self.controlledUnits + 1] = unit end
        return unit
    end

    function activity:chainLightningTarget()
        self.chainTargets=self.chainTargets or {}
        local offsets={{0,120},{-120,-80},{120,-80}}
        for i,offset in ipairs(offsets) do
            local unit=self.chainTargets[i]
            if not Alive(unit) then
                unit=self:spawn(Player(0),"hfoo",GetUnitX(self.target)+offset[1],GetUnitY(self.target)+offset[2])
                self.chainTargets[i]=unit
                SetUnitMoveSpeed(unit,0); SetUnitAcquireRange(unit,0)
                UnitRemoveAbility(unit,FourCC("Aatk")); IssueImmediateOrder(unit,"holdposition")
            end
            SetUnitState(unit,UNIT_STATE_LIFE,BlzGetUnitMaxHP(unit))
        end
        return self.chainTargets[1]
    end

    function activity:spawnOpponent()
        self.caster = self:spawn(Player(1), self.danger.unit, self.opponentX, self.opponentY, 180)
        -- This is a practice source, not a combat opponent. Prevent native
        -- damage reactions from interrupting its scripted movement/casting.
        SetUnitInvulnerable(self.caster,true)
        SetUnitCreepGuard(self.caster,false)
        RemoveGuardPosition(self.caster)
        SetUnitAcquireRange(self.caster, 0)
        if self.danger.menuGroup=="Ranged" then
            UnitRemoveAbility(self.caster,FourCC("Afae"))
            UnitRemoveAbility(self.caster,FourCC("Afa2"))
        end
        if self.danger.kind ~= "attack" and self.danger.category ~= "Ranged attacks" then
            UnitRemoveAbility(self.caster, FourCC("Aatk"))
        end
        if self.danger.ability then PrepareAbilities(self.caster, {self.danger.ability}) end
        if self.danger.weapon ~= nil then
            BlzSetUnitIntegerField(self.caster, UNIT_IF_ATTACKS_ENABLED, 2 ^ self.danger.weapon)
        end
        BlzSetUnitAttackCooldown(self.caster, 2.0, 0); BlzSetUnitAttackCooldown(self.caster, 2.0, 1)
    end

    function activity:refreshStatus()
        if not self.status then return end
        BlzFrameSetText(self.status,"|cffffcc00"..self.danger.name.."|r  â€”  "..self.definition.name..
            ((self.danger.menuGroup=="Area" or self.danger.menuGroup=="Devour" and not self.abilityDevour) and ("\nSurvive: "..math.max(0,math.ceil(15-self.trialTime)).." seconds") or
            self.arena and ("\nHits: "..self.hitCount) or ("\nStage "..self.stage.."/"..self.stageLimit.."   Consecutive dodges: "..self.streak.."/3"))..
            "\nEnemy: "..phaseText(self.enemyPhase or "waiting").."   Dodge: "..phaseText(self.dodgePhase or "ready"))
    end

    function activity:createPresentation()
        self.status = JTG.ScopeTrackFrame(session.presentationScope,
            BlzCreateFrameByType("TEXT", "JTGDodgeStatus", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0))
        BlzFrameSetSize(self.status, 0.46, 0.065)
        BlzFrameSetFont(self.status, "Fonts\\FRIZQT__.TTF", 0.014, 0)
        BlzFrameSetScale(self.status, 1.5)
        BlzFrameSetEnable(self.status, false)
        BlzFrameSetAbsPoint(self.status, FRAMEPOINT_TOP, 0.40, 0.505)
        BlzFrameSetTextAlignment(self.status, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_CENTER)
        self:refreshStatus()
        self.resultCard = JTG.UI.CreateResultCard(session, {name = "JTGDodgingResult", width = 0.40, detailsHeight = 0.09})
        self.feedback = JTG.ScopeTrackFrame(session.presentationScope,
            BlzCreateFrameByType("TEXT", "JTGDodgeFeedback", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0))
        BlzFrameSetSize(self.feedback, 0.26, 0.04)
        BlzFrameSetAbsPoint(self.feedback, FRAMEPOINT_CENTER, 0.40, 0.30)
        BlzFrameSetTextAlignment(self.feedback, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_CENTER)
        BlzFrameSetFont(self.feedback,"Fonts\\FRIZQT__.TTF",0.026,0); BlzFrameSetScale(self.feedback, 2.5); BlzFrameSetEnable(self.feedback, false)
        BlzFrameSetVisible(self.feedback, false)
        self.arenaImages = {}
        if self.arena then
            local half,x,y=self.arenaHalf,session.scene.centerX,session.scene.centerY
            local function marker(px,py,w,h)
                local image=JTG.ScopeTrackImage(session.presentationScope,
                    CreateImage(JTG.UnitSquarePlayerTexture,w,h,0,px,py,2,0,0,0,2))
                SetImageRenderAlways(image,true); SetImageAboveWater(image,true,true); ShowImage(image,true)
                self.arenaImages[#self.arenaImages+1]=image
            end
            if self.circular then
                for _,radius in ipairs({half,self.arenaInner or 0}) do
                    if radius>0 then
                        for index=0,127 do
                            local angle=index*2*math.pi/128
                            marker(x+math.cos(angle)*radius-4,y+math.sin(angle)*radius-4,8,8)
                        end
                    end
                end
            else
                marker(x-half,y-half,half*2,4); marker(x-half,y+half-4,half*2,4)
                marker(x-half,y-half,4,half*2); marker(x+half-4,y-half,4,half*2)
            end
        end
        self.devourImages={}
        if self.danger.menuGroup=="Devour" or self.danger.menuGroup=="Area" then
            for index=0,127 do
                local image=JTG.ScopeTrackImage(session.presentationScope,
                    CreateImage(JTG.UnitSquareEnemyTexture,self.danger.menuGroup=="Area" and 16 or 8,
                        self.danger.menuGroup=="Area" and 16 or 8,0,0,0,2,0,0,0,2))
                SetImageRenderAlways(image,true); SetImageAboveWater(image,true,true)
                self.devourImages[#self.devourImages+1]=image
            end
            if self.danger.menuGroup=="Devour" then self:updateDevourCircle() else self:updateAreaPresentation() end
        end
        self.areaFootprintImages={}
        if self.danger.menuGroup=="Area" then
            for index=1,128 do
                local image=JTG.ScopeTrackImage(session.presentationScope,
                    CreateImage(JTG.UnitSquareEnemyTexture,16,16,0,0,0,2,0,0,0,2))
                SetImageRenderAlways(image,true); SetImageAboveWater(image,true,true); ShowImage(image,false)
                self.areaFootprintImages[index]=image
            end
        end
        if selection.feedback then self:flash(selection.feedback,selection.feedback=="WELL DONE!" and "|cff00ff00" or "|cffff5555") end
    end

    function activity:updateDevourCircle()
        if not self.caster then return end
        local ability=BlzGetUnitAbility(self.caster,FourCC("Adev"))
        local range=ability and BlzGetAbilityRealLevelField(ability,ABILITY_RLF_CAST_RANGE,0) or 0
        if not range or range<=0 then range=self.danger.range or 100 end
        -- Targeted cast range is measured between collision edges. Show the
        -- distance at which this pawn's center enters Devour range.
        local radius=range+BlzGetUnitCollisionSize(self.caster)+
            (self.target and BlzGetUnitCollisionSize(self.target) or 0)
        self.devourRadius=radius
        for index,image in ipairs(self.devourImages or {}) do
            local angle=(index-1)*2*math.pi/math.max(1,#self.devourImages)
            SetImagePosition(image,GetUnitX(self.caster)+math.cos(angle)*radius-4,
                GetUnitY(self.caster)+math.sin(angle)*radius-4,2)
            ShowImage(image,self.presentationVisible)
        end
    end

    function activity:areaRadius()
        local radius=self.danger.area or 0
        if self.caster and self.danger.ability then
            local ability=BlzGetUnitAbility(self.caster,FourCC(self.danger.ability))
            if ability then
                local level=math.max(0,GetUnitAbilityLevel(self.caster,FourCC(self.danger.ability))-1)
                local native=BlzGetAbilityRealLevelField(ability,ABILITY_RLF_AREA_OF_EFFECT,level)
                if native and native>0 then radius=native end
            end
        end
        return radius
    end

    function activity:updateAreaPresentation()
        if not Alive(self.caster) then return end
        local radius=self.areaChasing and self:areaRadius() or
            (self.areaDirectional and (self.danger.waveDistance or self.danger.range) or self.danger.range)
        radius=math.max(0,radius or 0)
        for index,image in ipairs(self.devourImages or {}) do
            local angle=(index-1)*2*math.pi/128
            SetImagePosition(image,GetUnitX(self.caster)+math.cos(angle)*radius-8,
                GetUnitY(self.caster)+math.sin(angle)*radius-8,2)
            ShowImage(image,self.presentationVisible and radius>0)
        end
        for index,image in ipairs(self.arenaImages or {}) do
            local angle=(index-1)*2*math.pi/128
            SetImagePosition(image,session.scene.centerX+math.cos(angle)*self.arenaHalf-4,
                session.scene.centerY+math.sin(angle)*self.arenaHalf-4,2)
        end
        local footprint=self.areaFootprint
        local age=footprint and self.trialTime-footprint.time or math.huge
        for index,image in ipairs(self.areaFootprintImages or {}) do
            local visible=footprint and age<=footprint.duration
            if visible then
                local angle=(index-1)*2*math.pi/128
                local x,y,r=footprint.x,footprint.y,self:areaRadius()
                if self.areaDirectional then
                    local distance=self.danger.waveDistance or self.danger.range
                    local travelled=math.min(distance,age*(self.danger.missileSpeed or 0))
                    if self.danger.instantProjectile then travelled=distance end
                    local initial=self.danger.area or 0
                    if self.danger.instantProjectile then
                        local along=(index-1)%64/63*travelled
                        local side=index<=64 and -1 or 1
                        x=x+footprint.dx*along-footprint.dy*initial*side
                        y=y+footprint.dy*along+footprint.dx*initial*side
                    else
                        -- Wave position is reconstructed from native distance/speed;
                        -- it is an illustration, not an engine projectile handle.
                        local radius=initial+((self.danger.finalRadius or initial)-initial)*travelled/distance
                        x=x+footprint.dx*travelled+math.cos(angle)*radius
                        y=y+footprint.dy*travelled+math.sin(angle)*radius
                    end
                else x=x+math.cos(angle)*r; y=y+math.sin(angle)*r end
                SetImagePosition(image,x-8,y-8,3)
            end
            ShowImage(image,self.presentationVisible and visible or false)
        end
    end

    function activity:showAreaFootprint(tx,ty)
        local x,y=GetUnitX(self.caster),GetUnitY(self.caster)
        local dx,dy=tx-x,ty-y
        local distance=math.sqrt(dx*dx+dy*dy)
        if distance==0 then
            local angle=GetUnitFacing(self.caster)*math.pi/180; dx,dy=math.cos(angle),math.sin(angle)
        else dx,dy=dx/distance,dy/distance end
        local lifetime=0.65
        if self.areaDirectional then
            lifetime=(self.danger.waveDistance or self.danger.range)/math.max(1,self.danger.missileSpeed or 0)+0.25
            if self.danger.instantProjectile then lifetime=0.65 end
        elseif self.danger.waveInterval then lifetime=self.danger.resolveWindow or 2
        elseif self.danger.kind=="target" then lifetime=distance/math.max(1,self.danger.missileSpeed or 0)+0.65 end
        self.areaFootprint={x=(self.areaDirectional or self.danger.kind=="immediate") and x or tx,
            y=(self.areaDirectional or self.danger.kind=="immediate") and y or ty,
            dx=dx,dy=dy,time=self.trialTime,duration=lifetime}
        self:updateAreaPresentation()
    end

    function activity:stopAreaChannel()
        if not self.areaChannel or not self.areaChannelUntil then return end
        self.areaChannelUntil=nil
        IssueImmediateOrder(self.caster,"stop")
        self.casting=false; self.castConfirmed=false
        if self.areaFootprint then self.areaFootprint.duration=self.trialTime-self.areaFootprint.time+0.2 end
        local cooldown=BlzGetUnitAbilityCooldownRemaining(self.caster,FourCC(self.danger.ability))
        if cooldown and cooldown>0 then self.areaCastAt=self.trialTime+cooldown end
    end

    function activity:updateAreaOrders()
        if not Alive(self.caster) or not Alive(self.target) then return end
        if self.areaDirectional then
            self.arenaHalf=self.arenaMaximum*(self.trialTime>=10 and 0.6 or self.trialTime>=5 and 0.8 or 1)
            SetUnitX(self.caster,session.scene.centerX); SetUnitY(self.caster,session.scene.centerY)
        elseif self.areaChasing and self.danger.hero and self.trialTime>=10 and not self.areaBoots then
            self.areaBoots=true
            UnitAddAbility(self.caster,FourCC("AInv"))
            local item=UnitAddItemById(self.caster,FourCC("bspd"))
            JTG.ScopeAdd(session.scope,function() if item~=nil then RemoveItem(item) end end)
        end
        self:updateAreaPresentation()
        -- There is no native wave-impact event when the wave hits no unit.
        -- Damage events stop a channel immediately on a hit; the native wave
        -- interval supplies the missed-wave fallback.
        if self.areaChannelUntil and self.trialTime>=self.areaChannelUntil then self:stopAreaChannel() end
        if self.casting or self.areaChannelUntil then return end
        if not self.areaChannel and not self.areaDirectional and not self.areaChasing and self.castConfirmed and
                self.trialTime<self.castTime+(self.danger.resolveWindow or 2) then return end
        local dx,dy=GetUnitX(self.caster)-GetUnitX(self.target),GetUnitY(self.caster)-GetUnitY(self.target)
        local radius=self:areaRadius()
        local inArea=not self.areaChasing or dx*dx+dy*dy<=radius^2
        local close=self.areaChasing and dx*dx+dy*dy<=(radius*0.5)^2
        local enteredHalf=close and not self.areaTargetClose
        self.areaTargetClose=close
        -- Entering half range permits one early cast; remaining there does
        -- not turn the polling loop into repeated casts every frame.
        if enteredHalf or (self.trialTime>=(self.areaCastAt or 0) and inArea) then
            self.areaCastAt=self.trialTime+GetRandomReal(2,2.5)
            self.areaMoveAt=self.trialTime+GetRandomReal(0.5,1)
            self:tryAttack()
        elseif self.trialTime>=(self.areaMoveAt or 0) and (self.areaDirectional or self.areaChasing) then
            IssuePointOrder(self.caster,"move",GetUnitX(self.target),GetUnitY(self.target))
            self.areaMoveAt=self.trialTime+GetRandomReal(0.5,1)
        end
    end

    function activity:clearFeedback()
        self.flashUntil=nil
        selection.feedback=nil
        if self.feedback then BlzFrameSetVisible(self.feedback,false); BlzFrameSetText(self.feedback,"") end
    end
    function activity:showDevourResult()
        local eaten=self.devourEaten
        JTG.UI.HideToolbar()
        self:clearFeedback()
        JTG.UI.ShowResultCard(self.resultCard,{title=eaten and "DODGE FAILED" or "DODGE SUCCESSFUL",
            tone=eaten and "failure" or "success",details=eaten and "The Kodo devoured your unit." or "You avoided Devour for 15 seconds.",
            visible=self.presentationVisible,actions={retry={},menu={}}})
    end
    function activity:finishDevour(eaten)
        if self.finished then return end
        if self.abilityDevour then
            if eaten then self:verdict("TOO LATE!") end
            return
        end
        self.finished=true; self.devourEaten=eaten
        local function show()
            self.devourResultReady=true
            if Alive(self.caster) then PauseUnit(self.caster,true) end
            self:showDevourResult()
        end
        if eaten then
            -- Do not pause the native Devour transition at SPELL_EFFECT.
            JTG.StartScopedTimer(session,session.scope,1,false,show)
        else show() end
    end

    function activity:updateDevourOrders()
        if self.finished or not Alive(self.caster) or not Alive(self.target) then return end
        local dx,dy=GetUnitX(self.caster)-GetUnitX(self.target),GetUnitY(self.caster)-GetUnitY(self.target)
        local half=(self.devourRadius or 0)*0.5
        local close=half>0 and dx*dx+dy*dy<=half*half
        local entered=close and not self.devourTargetClose
        self.devourTargetClose=close
        if entered then
            self:tryAttack(true)
        elseif self.trialTime+0.000001 >= (self.devourRetryAt or 0) then
            self:tryAttack()
        elseif self.trialTime+0.000001 >= (self.devourMoveAt or math.huge) then
            IssueTargetOrder(self.caster,"move",self.target)
            self.devourMoveAt=self.trialTime+GetRandomReal(0.5,1)
        end
    end

    function activity:showAreaResult()
        JTG.UI.HideToolbar(); self:clearFeedback()
        JTG.UI.ShowResultCard(self.resultCard,{title=self.areaHit and "DODGE FAILED" or "DODGE SUCCESSFUL",
            tone=self.areaHit and "failure" or "success",
            details=self.areaHit and "The enemy ability hit your unit." or "You avoided the ability for 15 seconds.",
            visible=self.presentationVisible,actions={retry={},menu={}}})
    end
    function activity:finishArea(hit)
        if self.finished then return end
        self.finished=true; self.areaHit=hit
        if Alive(self.caster) then PauseUnit(self.caster,true) end
        self:showAreaResult()
    end

    -- Every timing verdict uses the same one-second transition.
    function activity:verdict(text)
        if self.arena or self.finished then return end
        if self.pendingVerdict and (self.pendingVerdict~="WELL DONE!" or text=="WELL DONE!") then return end
        self.pendingVerdict=text
        self.resetPending=true
        self.verdictVersion=(self.verdictVersion or 0)+1
        local version=self.verdictVersion
        self:flash(text,text=="WELL DONE!" and "|cff00ff00" or "|cffff5555")
        local timer = JTG.StartScopedTimer(session, session.scope, 1, false, function()
            if self.verdictVersion~=version then return end
            if text=="WELL DONE!" then
                self.streak=self.streak+1
                self:refreshStatus()
                if self.streak>=3 then
                    self.finished=true; self.resetPending=false
                    if Alive(self.caster) then PauseUnit(self.caster,true) end
                    self:showSuccess()
                    return
                end
                self.repeatPending=true
            else self.streak=0; self.repeatPending=false end
            self.restartFeedback=nil
            JTG.ResetActivity()
        end)
    end
    function activity:recordDodge()
        if self.countdownRemaining or self.arena or self.finished or self.resetPending then return end
        self.dodgeUsed=true
        -- The caster cancellation or the launched missile outcome decides the verdict.
    end
    function activity:resetAfterHit()
        if self.finished then return end
        if self.danger.menuGroup=="Area" then
            self.hitCount=self.hitCount+1; self:finishArea(true)
        elseif self.arena and self.danger.menuGroup~="Devour" then
            self.hitCount=self.hitCount+1; self:flash("HIT!","|cffff5555"); self:refreshStatus()
        elseif not self.arena then
            self:verdict("TOO LATE!")
        end
    end

    function activity:preLaunchVerdict()
        local fading=InvisibilityMethod(self.definition) and self.definition.unit~="Obla"
        local hidden=self.target and (IsUnitInvisible(self.target,Player(1)) or IsUnitHidden(self.target))
        if fading and self.danger.ability~="Aens" and self.dodgeUsed and hidden then
            self:verdict("WELL DONE!")
        else self:verdict("TOO EARLY!") end
    end

    function activity:castStopped()
        if self.finished or self.resetPending or self.castConfirmed then return end
        if self.casting then
            self.casting=false
            self:preLaunchVerdict()
        end
    end

    function activity:confirmCast()
        if self.castConfirmed or self.resetPending or self.finished then return end
        self.castConfirmed = true
        self.casting=false
        self.waitingForRange=false
        self.castTime = self.trialTime
        local speed = self.danger.missileSpeed or 0
        local dx, dy = GetUnitX(self.caster) - GetUnitX(self.target), GetUnitY(self.caster) - GetUnitY(self.target)
        local distance = math.sqrt(dx * dx + dy * dy)
        -- Allow for a fleeing target. An unusually slow homing missile is not
        -- declared dodged merely because a fixed timeout elapsed.
        local flight = speed > 522 and distance / (speed - 522) or
            (speed > 0 and distance / speed + 8 or 0)
        self.resolveAfter = math.max(self.danger.resolveWindow or 2, flight + 1)
        if not self.arena and self.stage==1 and Alive(self.target) then
            self:flash("GO!","|cff00ff00")
        end
    end

    function activity:showSuccess()
        JTG.UI.HideToolbar()
        self:clearFeedback()
        JTG.UI.ShowResultCard(self.resultCard, {title = "DODGE SUCCESSFUL", tone = "success",
            details = "Three consecutive dodges\nStage " .. self.stage .. " of "..self.stageLimit.."\n" .. self.danger.name .. "\n" .. self.definition.name,
            visible = self.presentationVisible,
            actions = {retry = {}, next = self.stage < self.stageLimit and {label = "Next Stage"} or nil, menu = {}}})
    end

    function activity:updateTrial()
        if self.finished then return end
        if self.resetPending then
            if self.pendingVerdict=="WELL DONE!" then
                for _,raw in ipairs(self.danger.buffs or {}) do
                    if self.target and GetUnitAbilityLevel(self.target,FourCC(raw))>0 then self:resetAfterHit(); break end
                end
            end
            return
        end
        self.trialTime = self.trialTime + 0.05
        if self.danger.menuGroup=="Area" then
            self:updateAreaOrders()
            self:refreshStatus()
            if not Alive(self.target) then self:finishArea(true); return end
            if self.trialTime>=15 then self:finishArea(false); return end
        end
        if self.danger.menuGroup=="Devour" then
            self:updateDevourCircle(); self:refreshStatus()
            if not Alive(self.target) or (self.devourEffectSeen and IsUnitHidden(self.target)) then
                self:finishDevour(true); return
            end
            if self.abilityDevour then
                if self.dodgeUsed and not self.casting and not self.devourEffectSeen and
                        (IsUnitHidden(self.target) or GetUnitCurrentOrder(self.caster)==0) then
                    self:verdict("WELL DONE!")
                end
                return
            else
                if self.trialTime>=15 then self:finishDevour(false); return end
                if self.trialTime>=10 and not self.devourAuraHero then
                    self.devourAuraHero=self:spawn(Player(1),"Otch",session.scene.centerX,
                        session.scene.centerY+self.arenaHalf+128,270)
                    PrepareAbilities(self.devourAuraHero,{"AOae"})
                    UnitRemoveAbility(self.devourAuraHero,FourCC("Aatk"))
                    SetUnitAcquireRange(self.devourAuraHero,0)
                    IssueImmediateOrder(self.devourAuraHero,"holdposition")
                end
                self:updateDevourOrders()
            end
        end
        if self.waitingForRange and Alive(self.caster) and Alive(self.target) then
            local dx,dy=GetUnitX(self.caster)-GetUnitX(self.target),GetUnitY(self.caster)-GetUnitY(self.target)
            if dx*dx+dy*dy<=((self.testRange or 450)+8)^2 then
                self.waitingForRange=false
                self.attempts=0
                self:tryAttack()
            end
        end
        if self.approaching and Alive(self.caster) and Alive(self.target) then
            local dx,dy=GetUnitX(self.caster)-GetUnitX(self.target),GetUnitY(self.caster)-GetUnitY(self.target)
            local px,py=self.approachX or GetUnitX(self.target),self.approachY or GetUnitY(self.target)
            local ax,ay=GetUnitX(self.caster)-px,GetUnitY(self.caster)-py
            if ax*ax+ay*ay<=16^2 then
                self.approaching=false; self.halfApproach=false; self.attempts=0
                self:tryAttack()
            elseif GetUnitCurrentOrder(self.caster)==0 then
                IssuePointOrder(self.caster,"move",px,py)
            end
        end
        if self.flashUntil and self.trialTime >= self.flashUntil then
            if self.feedback then BlzFrameSetVisible(self.feedback, false) end
            self.flashUntil = nil
        end
        if self.arena then
            local x, y, half = session.scene.centerX, session.scene.centerY, self.arenaHalf
            local function clamp(unit)
                if not Alive(unit) or IsUnitType(unit, UNIT_TYPE_STRUCTURE) then return end
                local ux, uy = GetUnitX(unit), GetUnitY(unit)
                local nx,ny=math.max(x-half,math.min(x+half,ux)),math.max(y-half,math.min(y+half,uy))
                if self.circular then
                    local dx,dy=ux-x,uy-y
                    local distance=math.sqrt(dx*dx+dy*dy)
                    local bounded=math.max((self.arenaInner or 0)+8,math.min(half-8,distance))
                    if distance>0 then nx,ny=x+dx*bounded/distance,y+dy*bounded/distance
                    else nx,ny=x+bounded,y end
                end
                if nx ~= ux then SetUnitX(unit, nx) end
                if ny ~= uy then SetUnitY(unit, ny) end
            end
            for _, unit in ipairs(self.controlledUnits) do clamp(unit) end
            if self.arenaGroup and self.baselineUnits then
                GroupEnumUnitsOfPlayer(self.arenaGroup, Player(0), nil)
                ForGroup(self.arenaGroup, function()
                    local unit = GetEnumUnit()
                    if not self.baselineUnits[unit] then clamp(unit) end
                end)
                GroupClear(self.arenaGroup)
            end
            clamp(self.pawn); clamp(self.target)
            if self.danger.menuGroup == "Devour" or self.areaChasing then clamp(self.caster) end
        end
        if not self.arena and self.pawn and IsUnitHidden(self.pawn) and (self.definition.mine or self.definition.support=="otrb" or self.definition.support=="nzep") then
            self:recordDodge()
        end
        if self.target and not Alive(self.target) and not self.definition.summon and not self.dodgeReplaced and
                not (self.phaseKind=="removal" and self.phaseDodgeEffect) then
            self.resetPending=true
            local timer = JTG.StartScopedTimer(session, session.scope, 0, false, function() JTG.ResetActivity() end)
            return
        end
        if self.artilleryLaunchAt and self.trialTime >= self.artilleryLaunchAt then
            self.artilleryLaunchAt = nil
            if GetUnitCurrentOrder(self.caster) == OrderId("attackground") then
                self:confirmCast()
                IssueImmediateOrder(self.caster, "stop")
            end
        end
        if self.castConfirmed then
            local buffHit=false
            for _,raw in ipairs(self.danger.buffs or {}) do
                if self.target and GetUnitAbilityLevel(self.target,FourCC(raw))>0 then buffHit=true; break end
            end
            if buffHit then
                self.buffObservedAt=self.buffObservedAt or self.trialTime
                -- Brief visual/transition states are not sufficient proof of a net landing.
                if self.danger.ability~="Aens" or self.trialTime-self.buffObservedAt>=0.1 then
                    self:resetAfterHit()
                end
            else self.buffObservedAt=nil end
        end
        if not self.arena and self.castConfirmed and not self.resetPending and
                self.trialTime>=self.castTime+self.resolveAfter then self:verdict("WELL DONE!") end
    end

    function activity:tryAttack(forceDevour)
        if self.finished or self.resetPending then return end
        if self.danger.menuGroup=="Devour" then
            if not Alive(self.caster) or not Alive(self.target) then return end
            if self.abilityDevour and self.attempts>0 then return end
            if not forceDevour and self.trialTime+0.000001<(self.devourRetryAt or 0) then return end
            -- Schedule from the issued command, even when Warcraft rejects it.
            -- No native cast event or secondary timer may accelerate retries.
            self.devourRetryAt=self.trialTime+GetRandomReal(2,2.5)
            self.devourMoveAt=self.trialTime+GetRandomReal(0.5,1)
            BlzEndUnitAbilityCooldown(self.caster,FourCC("Adev"))
            self.attempts=self.attempts+1
            if IssueTargetOrder(self.caster,"devour",self.target) then
                self.accepted=self.accepted+1
            else self.attempts=0 end
            return
        end
        if not self.arena and self.castConfirmed then return end
        if not self.arena and self.attempts>0 and self.dodgeUsed and not self.approaching and
                Alive(self.caster) and GetUnitCurrentOrder(self.caster)==0 then
            self:preLaunchVerdict(); return
        end
        if not self.arena and self.attempts>0 then
            -- A native target order can remain active after its approach stalls.
            -- Retry an unlaunched cast after its casting window, rather than
            -- waiting for the stationary pawn to change position.
            if Alive(self.caster) and (GetUnitCurrentOrder(self.caster)==0 or
                    self.trialTime >= (self.launchRetryAt or math.huge)) then
                self.attempts=0
            else return end
        end
        if self.danger.menuGroup=="Area" and self.casting then return end
        if self.arena then self.castConfirmed = false end
        if not Alive(self.caster) then
            if self.arena then self:spawnOpponent() else
            self.lastOrderText = "Opponent removed. Press Redo to repeat the test."
            self:refreshStatus()
            return
            end
        end
        if not Alive(self.target) then
            self.lastOrderText = "Pawn removed or replaced. Press Redo to repeat the test."
            self:refreshStatus()
            return
        end
        if self.halfApproach then
            local tx,ty=GetUnitX(self.target),GetUnitY(self.target)
            local dx,dy=GetUnitX(self.caster)-tx,GetUnitY(self.caster)-ty
            local distance=math.sqrt(dx*dx+dy*dy)
            local half=(self.testRange or self.danger.range or 450)*0.5
            if distance>half+8 then
                self.approachX,self.approachY=tx+dx*half/distance,ty+dy*half/distance
                if not self.approaching then IssuePointOrder(self.caster,"move",self.approachX,self.approachY) end
                self.approaching=true
                return
            end
            self.halfApproach=false; self.approaching=false
        end
        self.attempts = self.attempts + 1
        if not self.arena then
            local dx,dy=GetUnitX(self.caster)-GetUnitX(self.target),GetUnitY(self.caster)-GetUnitY(self.target)
            self.waitingForRange=dx*dx+dy*dy>((self.testRange or 450)+8)^2
            self.launchRetryAt=self.trialTime+math.max(2,
                (self.danger.castTime or 0)+(self.danger.abilityCastTime or 0)+1)
        end
        SetUnitState(self.caster, UNIT_STATE_MANA, BlzGetUnitMaxMana(self.caster))
        local accepted
        if self.arena and self.danger.kind == "immediate" then
            local dx, dy = GetUnitX(self.caster) - GetUnitX(self.target), GetUnitY(self.caster) - GetUnitY(self.target)
            if dx * dx + dy * dy > self:areaRadius() ^ 2 then
                IssuePointOrder(self.caster, "move", GetUnitX(self.target), GetUnitY(self.target))
                self.attempts = self.attempts - 1
                return
            end
        end
        if self.danger.kind == "attack" or self.danger.orbOrder then
            if self.danger.orbOrder then IssueImmediateOrder(self.caster, self.danger.orbOrder) end
            if self.danger.groundAttack then
                accepted = IssuePointOrder(self.caster, "attackground", GetUnitX(self.target), GetUnitY(self.target))
                self.artilleryLaunchAt = self.trialTime + (self.danger.castTime or 0) + 0.05
            elseif self.danger.orbOrder then
                accepted=IssueTargetOrder(self.caster,self.danger.order,self.target)
                if not accepted then accepted=IssueTargetOrder(self.caster,"attack",self.target) end
            else accepted=IssueTargetOrder(self.caster,"attack",self.target) end
        else
            if self.areaChannel then
                local remaining=BlzGetUnitAbilityCooldownRemaining(self.caster,FourCC(self.danger.ability))
                if remaining and remaining>0 then
                    self.areaCastAt=self.trialTime+remaining
                    self.attempts=self.attempts-1
                    return
                end
            else BlzEndUnitAbilityCooldown(self.caster, FourCC(self.danger.ability)) end
            if self.danger.kind == "point" then
                local tx,ty=GetUnitX(self.target),GetUnitY(self.target)
                if self.areaDirectional then
                    -- Native point orders outside cast range try to approach.
                    -- Project onto the same ray so a stationary caster fires
                    -- toward the pawn even beyond its targeting range.
                    local cx,cy=GetUnitX(self.caster),GetUnitY(self.caster)
                    local dx,dy=tx-cx,ty-cy
                    local distance=math.sqrt(dx*dx+dy*dy)
                    local range=math.max(1,(self.danger.range or 0)-16)
                    if distance>range then tx,ty=cx+dx*range/distance,cy+dy*range/distance end
                end
                accepted = IssuePointOrder(self.caster, self.danger.order, tx,ty)
            elseif self.danger.kind == "immediate" then
                accepted = IssueImmediateOrder(self.caster, self.danger.order)
            else
                accepted = IssueTargetOrder(self.caster, self.danger.order,
                    self.danger.ability=="AOcl" and self:chainLightningTarget() or self.target)
            end
        end
        if accepted then
            if self.areaChannel then self.areaCastAt=self.trialTime+(self.danger.cooldown or 6) end
            self.accepted = self.accepted + 1
            self.lastOrderText = "Order accepted. This does not guarantee a hit."
        else
            self.lastOrderText = "Order rejected: check range, target type, visibility or status."
            self.attempts = 0
        end
        self:refreshStatus()
    end

    function activity:placeBelowBuilding(unit,building,footprintHalf,southOffset)
        local padding=BlzGetUnitCollisionSize(unit)+16
        local x,y=GetUnitX(unit),GetUnitY(unit)
        -- Wisps ignore ground pathing, and a mine's collision field is much
        -- smaller than its footprint. Use the footprint, not terrain probes.
        -- Move the building north rather than moving the target/camera south.
        local distance=math.max(BlzGetUnitCollisionSize(building),footprintHalf)+padding
        -- Match tutorial scene placement: prevent native collision correction
        -- from moving the building sideways, while retaining its pathing mask.
        SetUnitPathing(building,false)
        SetUnitPosition(building,x,y+distance-(southOffset or 0))
        SetUnitPathing(building,true)
        BlzSetUnitFacingEx(building,270)
        SetUnitX(unit,x);SetUnitY(unit,y)
        BlzSetUnitFacingEx(unit,90)
    end

    function activity:setup(current)
        local p0, p1 = Player(0), Player(1)
        JTG.BorrowCamera(current.scope, p0)
        local oldController = GetPlayerController(p1)
        JTG.ScopeBorrow(current.scope, function() SetPlayerController(p1, oldController) end)
        -- All enemy actions are scripted; computer micro can otherwise cast
        -- Faerie Fire or another native ability during an attack-only test.
        SetPlayerController(p1, MAP_CONTROL_USER)
        for _, pair in ipairs({{p0, p1}, {p1, p0}}) do
            local left, right = pair[1], pair[2]
            local old = GetPlayerAlliance(left, right, ALLIANCE_PASSIVE)
            JTG.ScopeBorrow(current.scope, function() SetPlayerAlliance(left, right, ALLIANCE_PASSIVE, old) end)
            SetPlayerAlliance(left, right, ALLIANCE_PASSIVE, false)
        end
        for _, resource in ipairs({PLAYER_STATE_RESOURCE_GOLD, PLAYER_STATE_RESOURCE_LUMBER}) do
            local old = GetPlayerState(p0, resource)
            JTG.ScopeBorrow(current.scope, function() SetPlayerState(p0, resource, old) end)
            SetPlayerState(p0, resource, (self.definition.building or self.definition.resources) and 10000 or 0)
        end
        if self.definition.unit=="uobs" then
            local oldFood=GetPlayerState(p0,PLAYER_STATE_RESOURCE_FOOD_CAP)
            JTG.ScopeBorrow(current.scope,function() SetPlayerState(p0,PLAYER_STATE_RESOURCE_FOOD_CAP,oldFood) end)
            SetPlayerState(p0,PLAYER_STATE_RESOURCE_FOOD_CAP,5)
        end
        local x, y = current.scene.centerX, current.scene.centerY
        if self.areaDirectional then x=x+self.arenaMaximum end
        -- Record the pre-existing scene population. Native morphs, loading,
        -- entangling and summon effects can create handles without a summon
        -- event; remove only new activity-owned handles on exit/reset.
        local baseline = {}
        local function sceneUnits(callback)
            local group = CreateGroup()
            for _, player in ipairs({p0, p1}) do
                GroupEnumUnitsOfPlayer(group, player, nil)
                ForGroup(group, function() callback(GetEnumUnit()) end)
                GroupClear(group)
            end
            DestroyGroup(group)
        end
        sceneUnits(function(unit) baseline[unit] = true end)
        self.baselineUnits = baseline
        self.arenaGroup = JTG.ScopeTrackGroup(current.scope, CreateGroup())
        JTG.ScopeAdd(current.scope, function()
            sceneUnits(function(unit)
                if not baseline[unit] then
                    for slot = 0, 5 do
                        local item = UnitItemInSlot(unit, slot)
                        if item ~= nil then RemoveItem(item) end
                    end
                    RemoveUnit(unit)
                end
            end)
        end)
        -- Track engine-created summons and player-built structures as well as
        -- scripted spawns, so leaving or redoing the test removes them all.
        local createdTrigger = JTG.ScopeTrackTrigger(current.scope, CreateTrigger())
        TriggerRegisterPlayerUnitEvent(createdTrigger, p0, EVENT_PLAYER_UNIT_SUMMON, nil)
        TriggerRegisterPlayerUnitEvent(createdTrigger, p0, EVENT_PLAYER_UNIT_CONSTRUCT_START, nil)
        TriggerAddAction(createdTrigger, JTG.GuardSession(current, function()
            local unit
            if GetTriggerEventId() == EVENT_PLAYER_UNIT_SUMMON then
                unit = GetSummonedUnit()
            else
                unit = GetConstructingStructure()
            end
            if unit ~= nil then
                if GetTriggerEventId()==EVENT_PLAYER_UNIT_CONSTRUCT_START and self.definition.building then self:recordDodge() end
                JTG.ScopeTrackUnit(current.scope, unit)
                self.controlledUnits[#self.controlledUnits + 1] = unit
                if self.definition.summon and GetTriggerEventId()==EVENT_PLAYER_UNIT_SUMMON and
                        (GetUnitTypeId(unit)==FourCC("osw1") or GetUnitTypeId(unit)==FourCC("osw2") or
                         GetUnitTypeId(unit)==FourCC("osw3")) then
                    -- Re-summoned wolves must stay passive and stationary too.
                    SetUnitMoveSpeed(unit,0)
                    SetUnitAcquireRange(unit,0)
                    UnitRemoveAbility(unit,FourCC("Aatk"))
                    IssueImmediateOrder(unit,"holdposition")
                end
                if self.definition.summon and self.pawn == nil and
                        GetUnitTypeId(unit) == FourCC(self.definition.unit) then
                    self.pawn, self.target = unit, unit
                    SetUnitX(unit, x); SetUnitY(unit, y)
                    BlzSetUnitFacingEx(unit, self.stage == 1 and 180 or 0)
                    if not self.arena and self.stage > 1 then SetUnitMoveSpeed(unit, 0) end
                end
            end
        end))
        if self.definition.summon then
            local cooldownTrigger=JTG.ScopeTrackTrigger(current.scope,CreateTrigger())
            TriggerRegisterPlayerUnitEvent(cooldownTrigger,p0,EVENT_PLAYER_UNIT_SPELL_ENDCAST,nil)
            TriggerAddAction(cooldownTrigger,JTG.GuardSession(current,function()
                local unit=GetTriggerUnit()
                if unit==self.helper and GetSpellAbilityId()==FourCC("AOsf") then
                    local timer = JTG.StartScopedTimer(current, current.scope, 0, false, function()
                        if Alive(unit) then
                            BlzEndUnitAbilityCooldown(unit,FourCC("AOsf"))
                            SetUnitState(unit,UNIT_STATE_MANA,BlzGetUnitMaxMana(unit))
                        end
                    end)
                end
            end))
        end
        if not self.definition.summon then
            self.pawn = self:spawn(p0, self.definition.unit, x, y)
            self.target = self.pawn
        PrepareAbilities(self.pawn, self.definition.abilities)
        for _,raw in ipairs(self.definition.removeAbilities or {}) do UnitRemoveAbility(self.pawn,FourCC(raw)) end
        SetUnitAcquireRange(self.pawn, 0)
        IssueImmediateOrder(self.pawn, "holdposition")
        end
        self.opponentX, self.opponentY = x + self.danger.distance * (self.stage == 3 and 0.5 or 1) + (self.definition.summon and 200 or 0), y
        if self.arena then
            if self.danger.menuGroup == "Devour" or self.danger.kind == "immediate" then self.opponentX = x + self.arenaHalf * 0.7
            elseif self.danger.menuGroup == "Artillery" then self.opponentX=x
            elseif self.areaDirectional then
                self.opponentX=current.scene.centerX
            else self.opponentX = x + (self.danger.range or 600) * 0.5 end
        end
        self:spawnOpponent()
        if self.areaDirectional then SetUnitMoveSpeed(self.caster,0) end
        local function research(owner, rawcode)
            local upgrade = FourCC(rawcode)
            local old = GetPlayerTechCount(owner, upgrade, true)
            JTG.ScopeBorrow(current.scope, function() SetPlayerTechResearched(owner, upgrade, old) end)
            SetPlayerTechResearched(owner, upgrade, math.max(old, 3))
        end
        for _,raw in ipairs(JTG.DodgeTech or {}) do research(p0,raw); research(p1,raw) end
        for _, raw in ipairs(self.definition.research or {}) do research(p0, raw) end
        for _, raw in ipairs(self.danger.research or {}) do research(p1, raw) end
        if self.danger.menuGroup=="Artillery" and self.danger.unit=="ocat" then
            local old=GetPlayerTechCount(p1,FourCC("Rolf"),true)
            JTG.ScopeBorrow(current.scope,function() SetPlayerTechResearched(p1,FourCC("Rolf"),old) end)
            SetPlayerTechResearched(p1,FourCC("Rolf"),0)
        end
        if (self.danger.unit=="hrtt" or self.danger.ability=="Auco") and self.definition.unit=="edot" then
            IssueImmediateOrder(self.pawn,"ravenform")
        end
        if self.definition.support then
            local supportOwner=p0
            if self.definition.supportOwner=="neutral" then
                supportOwner=Player(PLAYER_NEUTRAL_PASSIVE)
                for _,pair in ipairs({{p0,supportOwner,true},{supportOwner,p0,true},{p1,supportOwner,false},{supportOwner,p1,false}}) do
                    local left,right=pair[1],pair[2]
                    local old=GetPlayerAlliance(left,right,ALLIANCE_PASSIVE)
                    JTG.ScopeBorrow(current.scope,function() SetPlayerAlliance(left,right,ALLIANCE_PASSIVE,old) end)
                    SetPlayerAlliance(left,right,ALLIANCE_PASSIVE,pair[3])
                end
            end
            self.helper = self:spawn(supportOwner, self.definition.support, x - 64, y)
            PrepareAbilities(self.helper, self.definition.supportAbilities)
            for _,raw in ipairs(self.definition.removeSupportAbilities or {}) do UnitRemoveAbility(self.helper,FourCC(raw)) end
            IssueImmediateOrder(self.helper, "holdposition")
            self.supports[#self.supports + 1] = self.helper
            if self.definition.summon then
                IssueImmediateOrder(self.helper, "spiritwolf")
                local timer = JTG.StartScopedTimer(current, current.scope, 0, false, function()
                    if Alive(self.helper) then BlzEndUnitAbilityCooldown(self.helper,FourCC("AOsf")) end
                end)
            end
            if self.definition.supportItem then
                UnitAddAbility(self.helper, FourCC("AInv"))
                local item = UnitAddItemById(self.helper, FourCC(self.definition.supportItem))
                JTG.ScopeAdd(current.scope, function() if item ~= nil then RemoveItem(item) end end)
            end
            if self.definition.targetSupport then
                self.target = self.helper
            end
        end
        if self.danger.support then
            local helper = self:spawn(p1, self.danger.support, x + self.danger.distance + 60, y)
            IssueTargetOrder(helper, "smart", self.caster)
        end
        if self.definition.item then
            UnitAddAbility(self.pawn, FourCC("AInv"))
            local item = UnitAddItemById(self.pawn, FourCC(self.definition.item))
            JTG.ScopeAdd(current.scope, function() if item ~= nil then RemoveItem(item) end end)
        end
        local mountingPair=self.helper and
            ((self.definition.unit=="earc" and self.definition.support=="ehip") or
             (self.definition.unit=="ehip" and self.definition.support=="earc"))
        if mountingPair then
            -- Flying and ground units can share coordinates. Avoid an approach
            -- before the mount command, including while walking is disabled.
            SetUnitX(self.helper,GetUnitX(self.pawn)); SetUnitY(self.helper,GetUnitY(self.pawn))
            BlzSetUnitFacingEx(self.helper,180)
        elseif self.helper and not IsUnitType(self.helper,UNIT_TYPE_STRUCTURE) then
            local controlled=self.definition.targetSupport and self.pawn or self.helper
            if self.target then SetUnitX(self.target,x); SetUnitY(self.target,y) end
            if controlled then
                SetUnitX(controlled,x); SetUnitY(controlled,y+200); BlzSetUnitFacingEx(controlled,270)
            end
        end
        if self.definition.home then
            self.home = self:spawn(p0, self.definition.home, x - 1000, y)
            self.supports[#self.supports + 1] = self.home
        end
        if self.definition.mine then
            local tree = self:spawn(p0, "etol", x - 550, y,270)
            local mine = self:spawn(p0, "egol", x, y+160,270)
            SetResourceAmount(mine, 100000)
            self.supports[#self.supports + 1] = tree
            self.supports[#self.supports+1]=mine
            -- Two 64-unit building squares closer; retain the pawn/camera anchor.
            self:placeBelowBuilding(self.pawn,mine,256,128)
        end
        if self.definition.support=="otrb" and self.helper then
            self:placeBelowBuilding(self.pawn,self.helper,96)
        end
        if self.definition.hauntedMine then
            local mine=self:spawn(p0,"ugol",x-250,y)
            SetResourceAmount(mine,100000)
            self.supports[#self.supports+1]=mine
        end
        if not self.arena then
            local range
            if self.danger.kind=="attack" or self.danger.orbOrder then
                range=BlzGetUnitWeaponRealField(self.caster,UNIT_WEAPON_RF_ATTACK_RANGE,self.danger.weapon or 0)
            elseif self.danger.ability then
                local ability=BlzGetUnitAbility(self.caster,FourCC(self.danger.ability))
                if ability then range=BlzGetAbilityRealLevelField(ability,ABILITY_RLF_CAST_RANGE,0) end
            end
            if not range or range<=0 then range=self.danger.range or 450 end
            self.testRange=range
            self.halfApproach=self.stage==3 or (self.definition.summon and self.stage==2)
            local stationary=GetUnitMoveSpeed(self.caster)<=0
            local distance=stationary and range or range+(self.definition.summon and 400 or 200)
            if stationary and self.halfApproach then distance=range*0.5; self.halfApproach=false end
            self.opponentX=(self.target and GetUnitX(self.target) or x)+distance
            self.opponentY=self.target and GetUnitY(self.target) or y
            SetUnitX(self.caster,self.opponentX); SetUnitY(self.caster,self.opponentY)
        elseif self.danger.menuGroup=="Artillery" and self.pawn then
            local range=BlzGetUnitWeaponRealField(self.caster,UNIT_WEAPON_RF_ATTACK_RANGE,self.danger.weapon or 0)
            if range and range>0 then self.arenaHalf=range end
            SetUnitX(self.pawn,x+(self.arenaHalf+self.arenaInner)/2)
        end
        if self.definition.night or self.definition.race=="nightelf" then
            local oldTime = GetFloatGameState(GAME_STATE_TIME_OF_DAY)
            local oldScale = GetTimeOfDayScale()
            JTG.ScopeBorrow(current.scope, function()
                SetFloatGameState(GAME_STATE_TIME_OF_DAY, oldTime); SetTimeOfDayScale(oldScale)
            end)
            local night=self.definition.night and (self.definition.race~="nightelf" or self.definition.name=="Shadowmeld")
            SetFloatGameState(GAME_STATE_TIME_OF_DAY, night and 0 or 12); SetTimeOfDayScale(0)
        end
        if self.pawn ~= nil then
            BlzSetUnitFacingEx(self.pawn,(self.definition.mine or self.definition.support=="otrb") and 90 or
                (self.definition.targetSupport and 270 or (self.stage == 1 and 180 or 0)))
            if not self.arena and (self.stage > 1 or self.abilityDevour) then SetUnitMoveSpeed(self.pawn, 0) end
        end
        if not self.arena and self.target then
            BlzSetUnitFacingEx(self.target,(self.definition.mine or self.definition.support=="otrb") and 90 or (self.stage==1 and 180 or 0))
            if self.stage>1 or self.abilityDevour then SetUnitMoveSpeed(self.target,0) end
        end
        if self.danger.ability=="AOcl" and self.target then self:chainLightningTarget() end
        self.devourValid = self.target ~= nil and not IsUnitType(self.target, UNIT_TYPE_HERO) and
            not IsUnitType(self.target, UNIT_TYPE_FLYING) and not IsUnitType(self.target, UNIT_TYPE_MECHANICAL) and
            not IsUnitType(self.target, UNIT_TYPE_STRUCTURE) and GetUnitLevel(self.target) <= 5
        JTG.ClearBlightAfterActivity(current, p0, x, y, 1800)
        JTG.ClearBlightAfterActivity(current, p1, x, y, 1800)
        self:setupPhases(current)
        local damageTrigger = JTG.ScopeTrackTrigger(current.scope, CreateTrigger())
        TriggerRegisterPlayerUnitEvent(damageTrigger, p0, EVENT_PLAYER_UNIT_DAMAGED, nil)
        if self.definition.supportOwner=="neutral" then TriggerRegisterPlayerUnitEvent(damageTrigger,Player(PLAYER_NEUTRAL_PASSIVE),EVENT_PLAYER_UNIT_DAMAGED,nil) end
        TriggerAddAction(damageTrigger, JTG.GuardSession(current, function()
            if self.areaChannel and GetEventDamageSource()==self.caster and GetEventDamage()>0 then
                self:stopAreaChannel()
            end
            if GetTriggerUnit() == self.target and GetEventDamageSource()==self.caster then
                self.lastDamage = math.max(0, GetEventDamage())
                self.damage = self.damage + self.lastDamage
                self:refreshStatus()
                if self.lastDamage > 0 then self:resetAfterHit() end
            end
        end))
        local castLifecycle=JTG.ScopeTrackTrigger(current.scope,CreateTrigger())
        TriggerRegisterPlayerUnitEvent(castLifecycle,p1,EVENT_PLAYER_UNIT_SPELL_CHANNEL,nil)
        TriggerRegisterPlayerUnitEvent(castLifecycle,p1,EVENT_PLAYER_UNIT_SPELL_ENDCAST,nil)
        TriggerAddAction(castLifecycle,JTG.GuardSession(current,function()
            if GetTriggerUnit()~=self.caster or not self.danger.ability or GetSpellAbilityId()~=FourCC(self.danger.ability) then return end
            if GetTriggerEventId()==EVENT_PLAYER_UNIT_SPELL_CHANNEL then
                self.casting=true
            elseif self.danger.menuGroup=="Devour" then
                self.casting=false
                if self.abilityDevour and not self.devourEffectSeen and self.dodgeUsed then self:verdict("WELL DONE!") end
            else self:castStopped() end
        end))
        local castTrigger = JTG.ScopeTrackTrigger(current.scope, CreateTrigger())
        TriggerRegisterPlayerUnitEvent(castTrigger, p1, EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
        TriggerAddAction(castTrigger, JTG.GuardSession(current, function()
            if GetTriggerUnit() == self.caster and self.danger.ability and
                    GetSpellAbilityId() == FourCC(self.danger.ability) then
                if self.danger.ability == "Adev" then
                    -- SPELL_EFFECT precedes the engine hiding the swallowed
                    -- unit. Observe the completed native transition on update.
                    self.devourEffectSeen=true
                else
                    self:confirmCast()
                    if self.danger.menuGroup=="Area" then
                        local unit=GetSpellTargetUnit()
                        local tx,ty=GetSpellTargetX(),GetSpellTargetY()
                        if unit then tx,ty=GetUnitX(unit),GetUnitY(unit) end
                        self:showAreaFootprint(tx,ty)
                        if self.areaChannel then
                            self.areaChannelUntil=self.trialTime+(self.danger.waveInterval or 1)+0.05
                        end
                    end
                end
            end
        end))
        local dodgeTrigger = JTG.ScopeTrackTrigger(current.scope, CreateTrigger())
        TriggerRegisterPlayerUnitEvent(dodgeTrigger, p0, EVENT_PLAYER_UNIT_SPELL_CAST, nil)
        TriggerRegisterPlayerUnitEvent(dodgeTrigger, p0, EVENT_PLAYER_UNIT_USE_ITEM, nil)
        TriggerAddAction(dodgeTrigger, JTG.GuardSession(current, function()
            if self.arena or self.finished or self.resetPending then return end
            local unit=GetTriggerUnit()
            if unit==self.pawn or unit==self.helper then self:recordDodge() end
        end))
        local attackTrigger = JTG.ScopeTrackTrigger(current.scope, CreateTrigger())
        TriggerRegisterPlayerUnitEvent(attackTrigger, p0, EVENT_PLAYER_UNIT_ATTACKED, nil)
        if self.definition.supportOwner=="neutral" then TriggerRegisterPlayerUnitEvent(attackTrigger,Player(PLAYER_NEUTRAL_PASSIVE),EVENT_PLAYER_UNIT_ATTACKED,nil) end
        TriggerAddAction(attackTrigger, JTG.GuardSession(current, function()
            if GetAttacker() ~= self.caster or GetTriggerUnit() ~= self.target then return end
            self:setPhase("enemy","windup")
            JTG.StartScopedTimer(current,current.scope,math.max(0.01,self.danger.castTime or 0),false,function()
                if Alive(self.caster) then
                    self:setPhase("enemy",GetUnitCurrentOrder(self.caster)~=0 and "fired" or "waiting")
                end
            end)
            local timer = JTG.StartScopedTimer(current, current.scope, math.max(0.01, (self.danger.castTime or 0) + 0.05), false, function()
                -- Attacked fires before launch; confirm only if the native
                -- attack order survived its damage point.
                -- A manually fired orb arrow can finish its single-shot order
                -- before this callback. Its completed order is not a cast failure.
                if Alive(self.caster) and GetUnitCurrentOrder(self.caster)~=0 then
                    self:confirmCast()
                    if not self.arena then IssueImmediateOrder(self.caster, "stop") end
                end
            end)
        end))
        local orderTrigger = JTG.ScopeTrackTrigger(current.scope, CreateTrigger())
        TriggerRegisterPlayerUnitEvent(orderTrigger, p0, EVENT_PLAYER_UNIT_ISSUED_ORDER, nil)
        TriggerRegisterPlayerUnitEvent(orderTrigger, p0, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, nil)
        TriggerRegisterPlayerUnitEvent(orderTrigger, p0, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, nil)
        TriggerAddAction(orderTrigger, JTG.GuardSession(current, function()
            local abilityIds = self.definition.abilities or {}
            if not self.arena and (self.stage > 1 or self.definition.summon or self.abilityDevour) and
                    (GetTriggerUnit() == self.pawn or GetTriggerUnit() == self.target) then
                local unit, order = GetTriggerUnit(), GetIssuedOrderId()
                local walking = order == OrderId("move") or order == OrderId("patrol") or
                    (order == OrderId("smart") and GetTriggerEventId() == EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
                if walking then
                    local timer = JTG.StartScopedTimer(current, current.scope, 0.0, false, function()
                        if Alive(unit) and GetUnitCurrentOrder(unit) == order then IssueImmediateOrder(unit, "stop") end
                    end)
                end
            end
            local unit,order=GetTriggerUnit(),GetIssuedOrderId()
            if self.attempts > 0 and (GetTriggerUnit() == self.pawn or GetTriggerUnit() == self.helper) then
                self.dodgeUsed = true
            end
            -- Refresh between manual casts, never end an active form or buff.
            if GetTriggerUnit() == self.pawn then
                for _, raw in ipairs(abilityIds) do BlzEndUnitAbilityCooldown(self.pawn, FourCC(raw)) end
                SetUnitState(self.pawn, UNIT_STATE_MANA, BlzGetUnitMaxMana(self.pawn))
            elseif GetTriggerUnit() == self.helper then
                for _, raw in ipairs(self.definition.supportAbilities or {}) do
                    BlzEndUnitAbilityCooldown(self.helper, FourCC(raw))
                end
                SetUnitState(self.helper, UNIT_STATE_MANA, BlzGetUnitMaxMana(self.helper))
            end
        end))
        local quest = JTG.ScopeTrackQuest(current.scope, CreateQuest())
        QuestSetTitle(quest, "Dodging")
        QuestSetRequired(quest, true); QuestSetDiscovered(quest, true)
        QuestSetIconPath(quest, "ReplaceableTextures\\CommandButtons\\BTNPhaseShift.blp")
        QuestSetDescription(quest, JTG.FormatSurroundQuestText(
            "Opponent: " .. self.danger.name .. "\nCategory: " .. self.danger.category ..
            "\nDodge method: " .. self.definition.name .. "\n\n" ..
            (self.danger.menuGroup=="Devour" and (self.abilityDevour and "Your pawn cannot move. Dodge the approaching Kodo's Devour three times in a row. There is one stage.\n\n" or "Avoid being devoured for 15 seconds. The Kodo issues Devour every 2â€“2.5 seconds and Move every 0.5â€“1 second. Entering half range triggers Devour immediately. The red circle shows its Devour range.\n\n") or
            self.danger.menuGroup=="Area" and "Avoid being hit by the enemy ability for 15 seconds.\n\n" or self.arena and "This is an unscored enclosed-arena test. Your units remain within the marked boundary. " ..
                "The opponent repeatedly uses the selected attack or spell. Devour continually pursues its target.\n\n" or
                "Avoid one successfully cast missile. A hit immediately restarts this stage. " ..
                "Stage 1 starts at maximum range facing away and allows running. " ..
                "Stage 2 uses maximum range without walking. Stage 3 uses half range without walking. " ..
                "TOO EARLY means the caster stopped before launching; TOO LATE means the missile hit. " ..
                "WELL DONE means a confirmed cast did not hit during its resolution window.\n\n") ..
            "Enemy colours: yellow before wind-up, red during wind-up, green after firing. "..
            "Dodger colours: green when ready, red during casting, yellow during activation or fade, green once the effect is active. "..
            "Green does not mean the unit is safe from every attack. Attack wind-up colours use estimated animation timing.\n\n"..
            (InvisibilityMethod(self.definition) and "Invisibility must finish fading before it can protect the unit. Preventing targeting before firing and disjoining an airborne projectile are different outcomes. This timing may require becoming invisible before the shot.\n\n" or "")..
            "Dodge abilities remain usable. Some targets are invalid for some spells.\n\n" ..
            "{Button: Redo} restores the same test. {Button: Setups} lets you select another " ..
            "opponent or dodge method. Helpers are provided only where the dodge needs one. " ..
            "Select a helper yourself to use a staff, load a unit or cast on the pawn.\n\n" ..
            (self.danger.note or "") .. "\n" .. (self.definition.note or "")))
        JTG.ResetWorldFog(p0); JTG.ScopeRevealScene(current.scope, current.scene, p0)
        JTG.ScopeRevealScene(current.scope,current.scene,p1)
        if self.danger.menuGroup=="Area" then
            local cx,cy=current.scene.centerX,current.scene.centerY
            for _,player in ipairs({p0,p1}) do
                JTG.ScopeRevealRect(current.scope,player,cx-self.arenaMaximum-256,cy-self.arenaMaximum-256,
                    cx+self.arenaMaximum+256,cy+self.arenaMaximum+256)
            end
        end
        if not self.arena and self.caster and self.target then
            -- The staged start can extend beyond the scene's reveal rectangle.
            -- Fog must not stop an explicitly ordered approach/cast there.
            local tx,ty=GetUnitX(self.target),GetUnitY(self.target)
            local cx,cy=GetUnitX(self.caster),GetUnitY(self.caster)
            for _,player in ipairs({p0,p1}) do
                JTG.ScopeRevealRect(current.scope,player,math.min(tx,cx)-256,
                    math.min(ty,cy)-256,math.max(tx,cx)+256,math.max(ty,cy)+256)
            end
        end
        self:createPresentation()
    end

    function activity:start()
        if GetLocalPlayer() == Player(0) then
            SetCameraPosition(session.scene.centerX, session.scene.centerY + 400)
            ClearSelection(); SelectUnit(self.definition.selectSupport and self.helper or self.pawn or self.helper, true)
        end
        local function beginTrial()
            self.countdownRemaining=nil
            self:clearFeedback()
            if self.danger.menuGroup=="Area" then self:updateAreaOrders() else self:tryAttack() end
            if self.danger.menuGroup~="Devour" and self.danger.menuGroup~="Area" then
                JTG.StartScopedTimer(session,session.scope,2.0,true,function() self:tryAttack() end)
            end
            JTG.StartScopedTimer(session,session.scope,0.05,true,function() self:updateTrial() end)
        end
        if selection.startDelay or self.areaDirectional then
            JTG.Training.Countdown(self,session,3,function(remaining)
                self.countdownRemaining=remaining
                self:flash(tostring(remaining),"|cffffcc00")
            end,beginTrial)
        else beginTrial() end
    end
    function activity:captureResetState()
        return {dangerIndex = self.dangerIndex, pawnIndex = self.pawnIndex, stage = self.stage,
            movementUnit=self.movementUnit, streak=self.repeatPending and self.streak or 0, feedback=self.restartFeedback}
    end
    function activity:nextStage()
        if self.arena or self.stage >= self.stageLimit or not self.finished then return false end
        self.stage = self.stage + 1; JTG.ResetActivity(); return true
    end
    activity.resultActions = {
        next = function(self) return self:nextStage() end,
    }
    function activity:toggleSetups() JTG.OpenActivityMenu("skills.missile_dodging", "skills") end
    function activity:hidePresentationForMenu()
        JTG.Training.SetPresentation(self,session,false)
        for _, image in ipairs(self.arenaImages or {}) do ShowImage(image, false) end
        for _, image in ipairs(self.devourImages or {}) do ShowImage(image, false) end
        for _, image in ipairs(self.areaFootprintImages or {}) do ShowImage(image, false) end
    end
    function activity:restorePresentation()
        JTG.Training.SetPresentation(self,session,true)
        for _, image in ipairs(self.arenaImages or {}) do ShowImage(image, true) end
        if self.danger.menuGroup=="Area" then self:updateAreaPresentation() else self:updateDevourCircle() end
        if self.countdownRemaining then self:flash(tostring(self.countdownRemaining),"|cffffcc00") end
        if self.finished then
            if self.danger.menuGroup=="Area" then self:showAreaResult()
            elseif self.danger.menuGroup=="Devour" and not self.abilityDevour then
                if self.devourResultReady then self:showDevourResult() end
            else self:showSuccess() end
        end
    end
    function activity:discardPresentationForLoad() self.status = nil; self.resultCard = nil; self.feedback = nil; self.arenaImages = {}; self.devourImages={}; self.areaFootprintImages={} end
    function activity:rebuildPresentation() self:createPresentation(); self:restorePresentation() end
    function activity:cleanup()
        self.finished=true
        self:clearFeedback()
        if GetLocalPlayer()==Player(0) then ClearSelection() end
        JTG.UI.HideActivityBriefing()
        self.status, self.feedback, self.resultCard = nil, nil, nil
        self.pawn, self.target, self.caster, self.helper, self.home = nil, nil, nil, nil, nil
        self.supports, self.controlledUnits, self.arenaImages, self.devourImages = {}, {}, {}, {}
        self.areaFootprintImages={}; self.areaFootprint=nil; self.devourAuraHero=nil
        self.baselineUnits, self.arenaGroup, self.chainTargets = nil, nil, nil
    end
    return activity
end
