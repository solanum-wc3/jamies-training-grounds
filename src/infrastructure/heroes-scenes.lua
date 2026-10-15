-- Heroes world scenes. Narration/presentation never owns these actors.
JTG=JTG or {}
local T,D=JTG.Tutorial,JTG.HeroesData
local PLAYER=Player(0)
local RACES={'human','orc','nightelf','undead'}
local COLORS={human=PLAYER_COLOR_BLUE,orc=PLAYER_COLOR_RED,nightelf=PLAYER_COLOR_CYAN,
    undead=PLAYER_COLOR_PURPLE,neutral=PLAYER_COLOR_LIGHT_GRAY}
local ALTARS={{id='human',raw='halt',x=-900,y=450},{id='orc',raw='oalt',x=0,y=450},
    {id='undead',raw='uaod',x=900,y=450},{id='nightelf',raw='eate',x=-450,y=-150},
    {id='neutral',raw='ntav',x=450,y=-150}}
function JTG.GetTutorialAltarHeroes(altar)
    local result={}
    for _,entry in ipairs(JTG.HotkeyCatalog) do
        if entry.source==altar and entry.heroRecruitment then result[#result+1]=entry end
    end
    table.sort(result,function(a,b) return a.nativeSlot<b.nativeSlot end)
    assert(#result>0,'Missing altar roster: '..altar)
    return result
end
function JTG.InstallHeroesScenes(activity,session)
    local function arena(id) return assert(JTG.Scenes[id],'Missing Heroes arena '..id) end
    activity.rosterArena=arena('arena.south');activity.practiceArena=arena('arena.north')
    activity.ownerScopes={};activity.levelActors={}
    function activity:sceneUnit(scope,raw,x,y,owner,color,level,hiddenIcons)
        local unit=T.CreateSceneUnit(scope,Player(PLAYER_NEUTRAL_PASSIVE),FourCC(raw),x,y,270)
        assert(unit and GetUnitTypeId(unit)~=0,'Heroes scene missing unit '..raw)
        self.ownerScopes[unit]=scope
        SetUnitColor(unit,color or PLAYER_COLOR_BLUE)
        SetUnitAcquireRange(unit,0);SetUnitCreepGuard(unit,false)
        if level then
            if level>GetHeroLevel(unit) then SetHeroLevel(unit,level,false) end
            SetUnitState(unit,UNIT_STATE_MANA,GetUnitState(unit,UNIT_STATE_MAX_MANA))
            BlzSetUnitBooleanField(unit,UNIT_BF_HERO_HIDE_HERO_INTERFACE_ICON,hiddenIcons==true)
        end
        SetUnitOwner(unit,owner or PLAYER,false)
        -- Demo Mode's passive-unit setup uses zero acquisition and Stop.
        -- Hold Position can still attack an enemy already in weapon range.
        IssueImmediateOrder(unit,'stop')
        return unit
    end
    function activity:teachAllSkills(unit,raw)
        for _,entry in ipairs(JTG.HotkeyCatalog) do
            if entry.source==raw and entry.heroSkills then
                for skill,levels in pairs(entry.heroSkills) do
                    for _=1,levels do SelectHeroSkill(unit,FourCC(skill)) end
                end
                return
            end
        end
    end
    function activity:makeRoster(mode)
        T.ClearScene(self,'heroes-roster')
        local scope=T.SceneScope(self,'heroes-roster');local center=self.rosterArena
        self.groups={};self.heroes={};self.buildings={};self.levelActors={}
        for _,spec in ipairs(ALTARS) do
            local x,y=center.centerX+spec.x,center.centerY+spec.y
            local altar=self:sceneUnit(scope,spec.raw,x,y,Player(PLAYER_NEUTRAL_PASSIVE),COLORS[spec.id])
            SetUnitInvulnerable(altar,true)
            local group={id=spec.id,altarRaw=spec.raw,altar=altar,x=x,y=y,color=COLORS[spec.id],heroes={}}
            self.groups[#self.groups+1]=group;self.buildings[spec.id]=altar
        end
        for _,group in ipairs(self.groups) do
            local heroes=JTG.GetTutorialAltarHeroes(group.altarRaw)
            local firstRow=group.id=='neutral' and math.ceil(#heroes/2) or #heroes
            for index,entry in ipairs(heroes) do
                local row=index<=firstRow and 0 or 1
                local count=row==0 and firstRow or #heroes-firstRow
                local column=row==0 and index-1 or index-firstRow-1
                local x,y=group.x+(column-(count-1)/2)*150,group.y-200-row*350
                if entry.raw=='Nplh' then x=x-200 end
                local owner=mode=='showcase' and PLAYER or Player(PLAYER_NEUTRAL_PASSIVE)
                local hero=self:sceneUnit(scope,entry.raw,x,y,owner,group.color,mode=='showcase' and 1 or 10,mode=='showcase')
                SuspendHeroXP(hero,true)
                group.heroes[#group.heroes+1]=hero;self.heroes[entry.raw]=hero
                self.levelActors[#self.levelActors+1]={unit=hero,raw=entry.raw,color=group.color,scope=scope}
            end
        end
        self.rosterMode=mode
    end
    function activity:hideRoster()
        for _,group in ipairs(self.groups or {}) do
            ShowUnit(group.altar,false)
            for _,hero in ipairs(group.heroes) do
                SetUnitOwner(hero,Player(PLAYER_NEUTRAL_PASSIVE),false)
                SuspendHeroXP(hero,true);PauseUnit(hero,true);ShowUnit(hero,false)
            end
        end
    end
    function activity:addActor(raw,x,y,level,color,owner,hiddenIcons)
        local scope=T.SceneScope(self,'heroes-active')
        local unit=self:sceneUnit(scope,raw,x,y,owner,color,level,hiddenIcons)
        self.actors[#self.actors+1]=unit
        return unit
    end
    function activity:setDummyHostile(dummy,hostile)
        for _,record in ipairs(self.dummies) do
            if record.unit==dummy then
                record.hostile=hostile==true
                SetUnitOwner(dummy,record.hostile and Player(6) or PLAYER,false)
                IssueImmediateOrder(dummy,'stop')
                for _,attacker in ipairs(record.autoAttackers or {}) do
                    if GetUnitTypeId(attacker)~=0 and GetWidgetLife(attacker)>.405 then
                        if record.hostile then IssueTargetOrder(attacker,'attack',dummy)
                        else IssueImmediateOrder(attacker,'stop') end
                    end
                end
                return true
            end
        end
        return false
    end
    function activity:addDummy(x,y,hostile,autoAttackers)
        local dummy=self:addActor('jHdm',x,y,nil,PLAYER_COLOR_LIGHT_GRAY,hostile and Player(6) or PLAYER)
        BlzSetUnitStringField(dummy,UNIT_SF_NAME,'Target Dummie')
        BlzSetUnitMaxHP(dummy,1000000);SetWidgetLife(dummy,1000000)
        local record={unit=dummy,x=x,y=y,hostile=hostile==true,autoAttackers=autoAttackers,armor=0,armorType=4}
        self.dummies[#self.dummies+1]=record
        self:applyDummyArmor(record)
        self:setDummyHostile(dummy,hostile)
        return dummy
    end
    function activity:applyDummyArmor(record)
        local types=D.dummyArmorTypes
        BlzSetUnitIntegerField(record.unit,UNIT_IF_DEFENSE_TYPE,types[record.armorType].defense)
        BlzSetUnitArmor(record.unit,record.armor)
        -- Hero armor supplies its native spell-damage multiplier. Resistant
        -- Skin supplies hero-duration debuffs without making this a hero unit.
        if types[record.armorType].defense==5 then
            UnitAddAbility(record.unit,FourCC('ACsk'))
            -- Its native passive icon otherwise occupies Raise Armor's cell.
            -- Hide this passive only; do not disable its effect or the grid.
            BlzUnitHideAbility(record.unit,FourCC('ACsk'),true)
        else UnitRemoveAbility(record.unit,FourCC('ACsk')) end
        -- Separate native buttons keep the current icon local to this dummy;
        -- changing a global ability icon would repaint every other dummy too.
        for _,kind in ipairs(types) do UnitRemoveAbility(record.unit,FourCC(kind.raw)) end
        UnitAddAbility(record.unit,FourCC(types[record.armorType].raw))
    end
    function activity:adjustDummyArmor(unit,delta)
        for _,record in ipairs(self.dummies) do
            if record.unit==unit then
                if delta then record.armor=record.armor+delta
                else record.armorType=record.armorType%#D.dummyArmorTypes+1 end
                self:applyDummyArmor(record)
                return true
            end
        end
        return false
    end
    function activity:showDummyDamage(unit,damage)
        if damage<=0 then return end
        local found=false
        for _,record in ipairs(self.dummies) do if record.unit==unit then found=true;break end end
        if not found then return end
        self.damagePopups=self.damagePopups or {}
        self.damagePopupIndex=(self.damagePopupIndex or 0)%16+1
        local popup=self.damagePopups[self.damagePopupIndex]
        if not popup then
            popup={tag=JTG.ScopeTrackTextTag(T.SceneScope(self,'heroes-active'),CreateTextTag())}
            self.damagePopups[self.damagePopupIndex]=popup
            SetTextTagPermanent(popup.tag,true)
        end
        popup.x,popup.y,popup.age=GetUnitX(unit),GetUnitY(unit),0
        SetTextTagText(popup.tag,string.format('%.1f',damage),.024)
        SetTextTagColor(popup.tag,255,220,80,255)
        SetTextTagPos(popup.tag,popup.x,popup.y,90);SetTextTagVisibility(popup.tag,true)
    end
    function activity:worldText(text,x,y)
        local tag=JTG.ScopeTrackTextTag(T.SceneScope(self,'heroes-active'),CreateTextTag())
        SetTextTagText(tag,text,0.027);SetTextTagPos(tag,x,y,32)
        SetTextTagColor(tag,255,255,255,255);SetTextTagPermanent(tag,true)
        return tag
    end
    function activity:xpCircle()
        local a=self.practiceArena;local radius=D.xpRange
        local image=JTG.ScopeTrackImage(T.SceneScope(self,'heroes-active'),
            CreateImage('JTGOverlay\\HeroesXPRing.dds',radius*2,radius*2,0,
                a.centerX-radius,a.centerY-radius,0,0,0,0,2))
        SetImageRenderAlways(image,true);SetImageAboveWater(image,true,true);ShowImage(image,true)
        return image
    end
    function activity:spawnGnoll(creep)
        local a=self.practiceArena
        local unit=self:addActor(creep and 'ngnb' or 'ngno',a.centerX,a.centerY,nil,nil,
            Player(creep and PLAYER_NEUTRAL_AGGRESSIVE or 1))
        PauseUnit(unit,true)
        if creep then SetWidgetLife(unit,BlzGetUnitMaxHP(unit)*.25) end
        self.gnoll=unit
    end
    function activity:xpArmy(kind)
        local a=self.practiceArena
        for index=1,4 do
            local footman=self:addActor('hfoo',a.centerX-1400,a.centerY+(index-2.5)*110)
            SetUnitInvulnerable(footman,true)
        end
        if kind:find('xp%-range') then
            for index,raw in ipairs({'Hpal','Hamg','Hmkg'}) do
                local hero=self:addActor(raw,a.centerX-1570,a.centerY+(index-2)*160,1)
                SetHeroXP(hero,D.xpNeeded[2]-1,false)
            end
        else
            local paladin=self:addActor('Hpal',a.centerX-1550,a.centerY-150,2)
            SetHeroXP(paladin,D.xpNeeded[3]-35,false)
            local king=self:addActor('Hmkg',a.centerX-1550,a.centerY+150,
                kind=='xp-modifier-4' and 4 or 5)
            self.paladin,self.mountainKing=paladin,king
        end
    end
    function activity:showDice()
        self.levelActors={};local groups={};local order={'2D4','2D6','2D12','2D11','3D10'}
        for _,group in ipairs(self.groups) do
            for _,entry in ipairs(JTG.GetTutorialAltarHeroes(group.altarRaw)) do
                local stat=assert(D.heroStats[entry.raw]);local key=stat.dice..'D'..stat.sides
                assert(key=='2D4' or key=='2D6' or key=='2D12' or key=='2D11' or key=='3D10','Unexpected hero dice '..key)
                groups[key]=groups[key] or {};groups[key][#groups[key]+1]={raw=entry.raw,color=group.color}
            end
        end
        local width=0
        for _,key in ipairs(order) do width=width+(math.ceil(#(groups[key] or {})/5)-1)*300+600 end
        width=width-600
        local x=self.practiceArena.centerX-width/2;self.diceTexts={}
        for _,key in ipairs(order) do
            local heroes=groups[key] or {}
            self.diceTexts[#self.diceTexts+1]={x=x,y=self.practiceArena.centerY-650}
            self:worldText(key,x,self.practiceArena.centerY-650)
            for index,entry in ipairs(heroes) do
                local hero=self:addActor(entry.raw,x+math.floor((index-1)/5)*300,
                    self.practiceArena.centerY-250+((index-1)%5)*300,1,entry.color,PLAYER,true)
                SuspendHeroXP(hero,true)
                self.levelActors[#self.levelActors+1]={unit=hero,raw=entry.raw,color=entry.color,
                    scope=T.SceneScope(self,'heroes-active')}
            end
            x=x+(math.ceil(#heroes/5)-1)*300+600
        end
    end
    function activity:showXPNumbers(choice)
        local a=self.practiceArena;self.xpNumberChoice=choice or 'hero';self.levelActors={}
        if self.xpNumberChoice=='hero' then
            for level=1,10 do
                local x=a.centerX+(level-5.5)*300
                local hero=self:addActor('Hpal',x,a.centerY,level,PLAYER_COLOR_BLUE,Player(PLAYER_NEUTRAL_PASSIVE))
                if level==1 or level==10 then BlzSetUnitSkin(hero,FourCC(level==1 and 'Hart' or 'Harf')) end
                PauseUnit(hero,true);SuspendHeroXP(hero,true)
                self:worldText('Level '..level..'\n'..D.heroXP[level]..' XP',x-85,a.centerY-250)
            end
        else
            local units=assert(D.racialUnits[self.xpNumberChoice]);local groups={};local ordered={}
            local function column(level,food)
                local key=level..':'..food
                if not groups[key] then
                    groups[key]={level=level,food=food,regular={},summons={}};ordered[#ordered+1]=groups[key]
                end
                return groups[key]
            end
            for _,entry in ipairs(units) do
                local group=column(entry.level,entry.summon and entry.level or entry.food)
                local list=entry.summon and group.summons or group.regular;list[#list+1]=entry
            end
            table.sort(ordered,function(left,right) return left.level<right.level or (left.level==right.level and left.food<right.food) end)
            local width=0
            for _,group in ipairs(ordered) do
                group.width=(math.ceil(math.max(1,#group.regular,#group.summons)/5)-1)*230
                width=width+group.width+360
            end
            width=width-360
            local x=math.max(a.minX+750,a.centerX-width/2)
            self.xpColumns=ordered
            -- Structures first, then mobile units, so pathing never pushes an
            -- earlier display unit away when a building is created.
            for _,group in ipairs(ordered) do group.x=x;x=x+group.width+360 end
            for _,structures in ipairs({true,false}) do
                for _,group in ipairs(ordered) do
                    for _,list in ipairs({group.regular,group.summons}) do
                        for index,row in ipairs(list) do
                            if row.building==structures then
                                local summoned=list==group.summons
                                local y=summoned and a.centerY-1000-((index-1)%5)*240 or a.centerY-180+((index-1)%5)*240
                                local unit=self:addActor(row.raw,group.x+math.floor((index-1)/5)*230,y,nil,COLORS[self.xpNumberChoice],Player(PLAYER_NEUTRAL_PASSIVE))
                                UnitRemoveAbility(unit,FourCC('Apiv'));PauseUnit(unit,true)
                            end
                        end
                    end
                end
            end
            for _,group in ipairs(ordered) do
                local regular=group.regular[1]
                if regular then self:worldText('Unit Level: '..regular.level..'\nFood Cost: '..regular.food..'\n'..regular.xp..' XP',group.x-80,a.centerY-620) end
                local summon=group.summons[1]
                if summon then
                    self:worldText('Summon\nUnit Level: '..summon.level..'\nFood Cost: '..summon.food..'\n'..summon.xp..' XP',group.x-80,
                        a.centerY-800)
                end
            end
        end
    end
    function activity:showItems()
        local a=self.practiceArena
        local halls={{'hcas',COLORS.human},{'ofrt',COLORS.orc},{'etoe',COLORS.nightelf},{'unp2',COLORS.undead}}
        for index,entry in ipairs(halls) do
            local hall=self:addActor(entry[1],index%2==1 and a.minX+300 or a.maxX-300,
                index<=2 and a.maxY-300 or a.minY+300,nil,entry[2])
            SetUnitInvulnerable(hall,true)
        end
        for index,raw in ipairs({'hvlt','ovln','eden','utom','ngme','nmrk'}) do
            local angle=(index-1)*math.pi/3
            local owner=index<=4 and PLAYER or Player(PLAYER_NEUTRAL_PASSIVE)
            local shop=self:addActor(raw,a.centerX+500*math.cos(angle),a.centerY+500*math.sin(angle),nil,
                index<=4 and COLORS[RACES[index]] or COLORS.neutral,owner)
            SetUnitInvulnerable(shop,true)
            local stock=D.shops[raw]
            if raw=='nmrk' then
                stock={};for _,group in ipairs(D.itemGroups) do
                    if #stock<6 then stock[#stock+1]=group.items[1] end
                end
            end
            for _,item in ipairs(stock or {}) do RemoveItemFromStock(shop,FourCC(item));AddItemToStock(shop,FourCC(item),1,1) end
        end
        for index,raw in ipairs({'Hpal','Hamg','Hmkg'}) do self:addActor(raw,a.centerX+(index-2)*180,a.centerY,1) end
        self:addDummy(a.centerX-1100,a.centerY,true)
        local column=0
        for _,group in ipairs(D.itemGroups) do
            local x=a.minX+250+column*480
            for index,raw in ipairs(group.items) do
                local item=CreateItem(FourCC(raw),x+((index-1)%3)*100,a.centerY-850-math.floor((index-1)/3)*110)
                assert(item,'Missing TM item '..raw)
                JTG.ScopeAdd(T.SceneScope(self,'heroes-active'),function() RemoveItem(item) end)
            end
            column=column+1
        end
        for _,state in ipairs({PLAYER_STATE_RESOURCE_GOLD,PLAYER_STATE_RESOURCE_LUMBER}) do SetPlayerState(PLAYER,state,10000) end
    end
    function activity:ensureWorld(kind,force)
        if self.worldScene==kind and not force then return false end
        T.ClearScene(self,'heroes-active')
        self:hideRoster();self.actors={};self.dummies={};self.damagePopups={};self.damagePopupIndex=0;self.levelActors={};self.selectedHero=nil
        self.gnoll=nil;self.paladin=nil;self.mountainKing=nil;self.worldScene=kind
        if kind=='overview' or kind=='showcase' then
            self:makeRoster(kind)
            if kind=='showcase' then for _,group in ipairs(self.groups) do self:addDummy(group.x,group.y-500) end end
        elseif kind=='archmages' or kind=='archmages-target' then
            local a=self.practiceArena
            local one=self:addActor('Hamg',a.centerX-300,a.centerY,1)
            local ten=self:addActor('Hamg',a.centerX+300,a.centerY,10)
            self:teachAllSkills(ten,'Hamg')
            if kind=='archmages-target' then
                self:addDummy(a.centerX,a.centerY-300,true,{one,ten})
            end
        elseif kind=='xp-initial' then self:xpCircle();self:spawnGnoll(false)
        elseif kind=='xp-empty' then self:xpCircle()
        elseif kind:find('xp%-range') then self:xpCircle();self:spawnGnoll(false);self:xpArmy(kind)
        elseif kind:find('xp%-modifier') then self:xpCircle();self:spawnGnoll(true);self:xpArmy(kind)
        elseif kind=='dice' then self:showDice()
        elseif kind=='xp-numbers' then self:showXPNumbers(self.xpNumberChoice)
        elseif kind=='items' then self:showItems()
        else assert(kind=='empty','Unknown Heroes world scene '..kind) end
        local a=(kind=='overview' or kind=='showcase') and self.rosterArena or self.practiceArena
        self.activeArena=a
        if GetLocalPlayer()==PLAYER then ClearSelection() end
        T.MoveCamera(PLAYER,a.centerX,a.centerY)
        return true
    end
    function activity:changeHeroLevel(delta)
        local unit=self.selectedHero
        for index,record in ipairs(self.levelActors) do
            if record.unit==unit and GetUnitTypeId(unit)~=0 then
                local level=GetHeroLevel(unit);local wanted=math.max(1,math.min(10,level+delta))
                if wanted==level then return end
                if delta>0 then
                    -- Demo Mode's selected-hero level-up operation; temporarily
                    -- release this tutorial's XP lock while applying it.
                    SuspendHeroXP(unit,false);SetHeroLevel(unit,wanted,true);SuspendHeroXP(unit,true)
                else
                    local x,y,owner=GetUnitX(unit),GetUnitY(unit),GetOwningPlayer(unit)
                    local inventory={}
                    for slot=0,5 do
                        local item=UnitItemInSlot(unit,slot)
                        if item then UnitRemoveItem(unit,item);inventory[#inventory+1]=item end
                    end
                    RemoveUnit(unit)
                    local hero=self:sceneUnit(record.scope,record.raw,x,y,owner,record.color,wanted,true)
                    for _,item in ipairs(inventory) do UnitAddItem(hero,item) end
                    SuspendHeroXP(hero,true)
                    record.unit=hero;self.selectedHero=hero
                    for _,group in ipairs(self.groups) do
                        for i,old in ipairs(group.heroes) do if old==unit then group.heroes[i]=hero end end
                    end
                    for i,old in ipairs(self.actors) do if old==unit then self.actors[i]=hero end end
                    if self.heroes[record.raw]==unit then self.heroes[record.raw]=hero end
                    if GetLocalPlayer()==PLAYER then ClearSelection();SelectUnit(hero,true) end
                end
                self:refreshControls();return
            end
        end
    end
    function activity:tickWorld()
        for _,popup in ipairs(self.damagePopups or {}) do
            popup.age=popup.age+.05
            SetTextTagVisibility(popup.tag,popup.age<1.2 and self.presentationVisible)
            if popup.age<1.2 then SetTextTagPos(popup.tag,popup.x,popup.y,90+popup.age*55) end
        end
        for _,record in ipairs(self.dummies or {}) do
            if GetUnitTypeId(record.unit)~=0 then
                if GetWidgetLife(record.unit)<=.405 then
                    RemoveUnit(record.unit)
                    record.unit=self:sceneUnit(T.SceneScope(self,'heroes-active'),'jHdm',record.x,record.y,
                        record.hostile and Player(6) or PLAYER,PLAYER_COLOR_LIGHT_GRAY)
                    BlzSetUnitStringField(record.unit,UNIT_SF_NAME,'Target Dummie')
                    BlzSetUnitMaxHP(record.unit,1000000)
                    self:applyDummyArmor(record)
                    self:setDummyHostile(record.unit,record.hostile)
                end
                SetWidgetLife(record.unit,1000000)
            end
        end
        if self.worldScene=='archmages' or self.worldScene=='archmages-target' then
            local a=self.practiceArena
            for _,unit in ipairs(self.actors) do
                if GetUnitTypeId(unit)~=0 and GetOwningPlayer(unit)==PLAYER and not IsUnitType(unit,UNIT_TYPE_STRUCTURE) then
                    local x,y=GetUnitX(unit),GetUnitY(unit)
                    if x<a.minX+64 or x>a.maxX-64 or y<a.minY+64 or y>a.maxY-64 then
                        SetUnitPosition(unit,math.max(a.minX+64,math.min(a.maxX-64,x)),math.max(a.minY+64,math.min(a.maxY-64,y)))
                    end
                end
            end
        end
    end
end
