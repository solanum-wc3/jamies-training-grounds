-- Heroes world scenes. Narration/presentation never owns these actors.
JTG=JTG or {}
local T,D=JTG.Tutorial,JTG.HeroesData
local PLAYER=Player(0)
local CONTROL=Player(8)
-- Keep hidden shop prerequisites inside the arena's walkable interior;
-- its bounding-rectangle corners include impassable terrain.
local ITEM_HALL_POSITIONS={{-1500,700},{1500,700},{-1500,-300},{1500,-300}}
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
    function activity:rememberActorScope(unit,scope)
        if self.ownerScopes[unit] then return end
        self.ownerScopes[unit]=scope
        JTG.ScopeAdd(scope,function()
            if self.ownerScopes[unit]==scope then self.ownerScopes[unit]=nil end
        end)
    end
    function activity:sceneUnit(scope,raw,x,y,owner,color,level,hiddenIcons)
        -- Create for the intended owner directly. Neutral heroes can
        -- receive engine initialization before a later ownership transfer.
        local unit=T.CreateSceneUnit(scope,owner or PLAYER,FourCC(raw),x,y,270)
        assert(unit and GetUnitTypeId(unit)~=0,'Heroes scene missing unit '..raw)
        if JTG.Dev and JTG.Dev.HeroesAudioTrace then JTG.Dev.HeroesAudioTrace(self,'created-before-food-disable:'..raw) end
        -- Instructional actors retain their native stats but do not form an
        -- economy army or trigger upkeep while spawning/changing ownership.
        SetUnitUseFood(unit,false)
        self:rememberActorScope(unit,scope)
        SetUnitColor(unit,color or PLAYER_COLOR_BLUE)
        SetUnitAcquireRange(unit,0);SetUnitCreepGuard(unit,false)
        if level then
            if level>GetHeroLevel(unit) then SetHeroLevel(unit,level,false) end
            SetUnitState(unit,UNIT_STATE_MANA,GetUnitState(unit,UNIT_STATE_MAX_MANA))
            -- Shared-control ownership already keeps these heroes out of the
            -- local player's portrait list, as in Demo. Do not mutate the
            -- native hero-interface flag during creation/removal cycles.
        end
        if JTG.Dev and JTG.Dev.HeroesAudioUnit then JTG.Dev.HeroesAudioUnit(self,raw,unit,x,y) end
        -- Passive scene actors use zero acquisition and Stop.
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
                local owner=mode=='showcase' and CONTROL or Player(PLAYER_NEUTRAL_PASSIVE)
                local hero=self:sceneUnit(scope,entry.raw,x,y,owner,group.color,mode=='showcase' and 1 or 10,mode=='showcase')
                SuspendHeroXP(hero,true)
                group.heroes[#group.heroes+1]=hero;self.heroes[entry.raw]=hero
                self.levelActors[#self.levelActors+1]={unit=hero,raw=entry.raw,color=group.color,scope=scope}
            end
        end
        self.rosterMode=mode
    end
    function activity:hideRoster()
        -- Hidden Undead altars still spread blight. Retire the previous
        -- display, including its terrain lease; returning recreates the roster.
        T.ClearScene(self,'heroes-roster')
        self.groups={};self.heroes={};self.buildings={}
    end
    function activity:addActor(raw,x,y,level,color,owner,hiddenIcons)
        local scope=T.SceneScope(self,'heroes-active')
        local unit=self:sceneUnit(scope,raw,x,y,owner,color,level,hiddenIcons)
        self.actors[#self.actors+1]=unit
        return unit
    end
    JTG.InstallTargetDummies(activity,function() return T.SceneScope(activity,'heroes-active') end)
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
        for _,spec in ipairs(ALTARS) do
            for _,entry in ipairs(JTG.GetTutorialAltarHeroes(spec.raw)) do
                local stat=assert(D.heroStats[entry.raw]);local key=stat.dice..'D'..stat.sides
                assert(key=='2D4' or key=='2D6' or key=='2D12' or key=='2D11' or key=='3D10','Unexpected hero dice '..key)
                groups[key]=groups[key] or {};groups[key][#groups[key]+1]={raw=entry.raw,color=COLORS[spec.id]}
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
                    self.practiceArena.centerY-250+((index-1)%5)*300,1,entry.color,CONTROL,true)
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
                local row=math.floor((level-1)/5)
                local x=a.centerX+((level-1)%5-2)*300
                local y=a.centerY+350-row*700
                local hero=self:addActor('Hpal',x,y,level,PLAYER_COLOR_BLUE,CONTROL)
                if level==1 or level==10 then BlzSetUnitSkin(hero,FourCC(level==1 and 'Hart' or 'Harf')) end
                PauseUnit(hero,true);SuspendHeroXP(hero,true)
                self:worldText('Level '..level..'\n'..D.heroXP[level]..' XP',x-85,y-250)
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
                local buildings=false
                for _,entry in ipairs(group.regular) do buildings=buildings or entry.building end
                group.rows=buildings and 2 or 5
                group.step=buildings and 576 or 240
                group.columnStep=buildings and 576 or 230
                group.gap=buildings and 576 or 360
                group.width=(math.ceil(math.max(1,#group.regular,#group.summons)/group.rows)-1)*group.columnStep
                width=width+group.width+group.gap
            end
            width=width-ordered[#ordered].gap
            local x=math.max(a.minX+750,a.centerX-width/2)
            self.xpColumns=ordered
            -- Structures first, then mobile units, so pathing never pushes an
            -- earlier display unit away when a building is created.
            for _,group in ipairs(ordered) do group.x=x;x=x+group.width+group.gap end
            for _,structures in ipairs({true,false}) do
                for _,group in ipairs(ordered) do
                    for _,list in ipairs({group.regular,group.summons}) do
                        for index,row in ipairs(list) do
                            if row.building==structures then
                                local summoned=list==group.summons
                                local y=summoned and a.centerY-1200-((index-1)%group.rows)*group.step or a.centerY-180+((index-1)%group.rows)*group.step
                                local ux=group.x+math.floor((index-1)/group.rows)*group.columnStep
                                if row.building then ux=math.floor(ux/64+.5)*64;y=math.floor(y/64+.5)*64 end
                                local displayRaw=row.building and assert(D.presentationBuildings[row.raw]) or row.raw
                                local unit=self:addActor(displayRaw,ux,y,nil,COLORS[self.xpNumberChoice],Player(PLAYER_NEUTRAL_PASSIVE))
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
                        a.centerY-1000)
                end
            end
        end
    end
    function activity:showItemPrerequisite(index)
        local a=self.practiceArena
        local halls={{'hcas',COLORS.human},{'ofrt',COLORS.orc},{'etoe',COLORS.nightelf},{'unp2',COLORS.undead}}
        local entry=assert(halls[index])
        local position=assert(ITEM_HALL_POSITIONS[index])
        local hall=self:addActor(entry[1],a.centerX+position[1],a.centerY+position[2],nil,entry[2])
        -- Retain the owned tier-three prerequisite for racial shop stock,
        -- but keep these support buildings out of the item presentation.
        ShowUnit(hall,false)
    end
    function activity:showItemPrerequisites()
        for index=1,4 do self:showItemPrerequisite(index) end
    end
    function activity:showItemShop(index)
        local a=self.practiceArena
        local raw=assert(({'hvlt','ovln','eden','utom','ngme','nmrk'})[index])
        local angle=(index-1)*math.pi/3
        local owner=index<=4 and PLAYER or Player(PLAYER_NEUTRAL_PASSIVE)
        local shop=self:addActor(raw,a.centerX+500*math.cos(angle),a.centerY+500*math.sin(angle),nil,
            index<=4 and COLORS[RACES[index]] or COLORS.neutral,owner)
        -- Standard shops already declare their native stock. Only the
        -- Marketplace needs explicit examples for this demonstration.
        if raw=='nmrk' then
            local stock={};for _,group in ipairs(D.itemGroups) do
                if #stock<6 then stock[#stock+1]=group.items[1] end
            end
            for _,item in ipairs(stock) do RemoveItemFromStock(shop,FourCC(item));AddItemToStock(shop,FourCC(item),1,1) end
        end
    end
    function activity:showItemShops()
        for index=1,6 do self:showItemShop(index) end
    end
    function activity:showItemHero(index)
        local a=self.practiceArena
        self:addActor(assert(({'Hpal','Hamg','Hmkg'})[index]),a.centerX+(index-2)*180,a.centerY,1)
    end
    function activity:showItemDummy()
        local a=self.practiceArena
        self:addDummy(a.centerX-1100,a.centerY)
    end
    function activity:showItemActors()
        for index=1,3 do self:showItemHero(index) end
        self:showItemDummy()
    end
    function activity:showGroundItems()
        local a=self.practiceArena
        local column=0
        for _,group in ipairs(D.itemGroups) do
            local x=a.minX+250+column*480
            for index,raw in ipairs(group.items) do
                local item=CreateItem(FourCC(raw),x+((index-1)%3)*100,a.centerY-850-math.floor((index-1)/3)*110)
                assert(item,'Missing TM item '..raw)
                JTG.ScopeTrackItem(T.SceneScope(self,'heroes-active'),item)
            end
            column=column+1
        end
    end
    function activity:showItems()
        self:showItemPrerequisites()
        self:showItemShops()
        self:showItemActors()
        self:showGroundItems()
        for _,state in ipairs({PLAYER_STATE_RESOURCE_GOLD,PLAYER_STATE_RESOURCE_LUMBER}) do SetPlayerState(PLAYER,state,10000) end
    end
    function activity:ensureWorld(kind,force)
        if self.worldScene==kind and not force then return false end
        -- Detach native selection/portrait references before removing actors.
        if GetLocalPlayer()==PLAYER then ClearSelection() end
        T.ClearScene(self,'heroes-active')
        self:hideRoster();self.actors={};self.dummies={};self.damagePopups={};self.damagePopupIndex=0;self.levelActors={};self.selectedHero=nil
        self.gnoll=nil;self.paladin=nil;self.mountainKing=nil;self.worldScene=kind
        if kind=='overview' or kind=='showcase' then
            self:makeRoster(kind)
            if kind=='showcase' then for _,group in ipairs(self.groups) do self:addDummy(group.x,group.y-500) end end
        elseif kind=='archmages' or kind=='archmages-target' then
            local a=self.practiceArena
            local one=self:addActor('Hamg',a.centerX-300,a.centerY,1,nil,CONTROL)
            local ten=self:addActor('Hamg',a.centerX+300,a.centerY,10,nil,CONTROL)
            self:teachAllSkills(ten,'Hamg')
            if kind=='archmages-target' then
                self:addDummy(a.centerX,a.centerY-300,false,{one,ten})
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
                    -- Temporarily
                    -- release this tutorial's XP lock while applying it.
                    SuspendHeroXP(unit,false);SetHeroLevel(unit,wanted,true);SuspendHeroXP(unit,true)
                else
                    local x,y,owner=GetUnitX(unit),GetUnitY(unit),GetOwningPlayer(unit)
                    local inventory={}
                    for slot=0,5 do
                        local item=UnitItemInSlot(unit,slot)
                        if item then UnitRemoveItem(unit,item);inventory[#inventory+1]=item end
                    end
                    if GetLocalPlayer()==PLAYER then ClearSelection() end
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
                if GetUnitTypeId(unit)~=0 and (GetOwningPlayer(unit)==PLAYER or GetOwningPlayer(unit)==CONTROL) and not IsUnitType(unit,UNIT_TYPE_STRUCTURE) then
                    local x,y=GetUnitX(unit),GetUnitY(unit)
                    if x<a.minX+64 or x>a.maxX-64 or y<a.minY+64 or y>a.maxY-64 then
                        SetUnitPosition(unit,math.max(a.minX+64,math.min(a.maxX-64,x)),math.max(a.minY+64,math.min(a.maxY-64,y)))
                    end
                end
            end
        end
    end
end
