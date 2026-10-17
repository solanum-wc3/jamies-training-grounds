-- Shared native dummy controls. Actors and popup tags belong to the caller's scene.
JTG=JTG or {}
local PLAYER=Player(0)
local D=JTG.HeroesData
function JTG.InstallTargetDummies(activity,popupScope)
    function activity:setDummyHostile(dummy,hostile)
        for _,record in ipairs(self.dummies) do
            if record.unit==dummy then
                record.hostile=hostile==true
                UnitRemoveAbility(dummy,FourCC('JHdN'));UnitRemoveAbility(dummy,FourCC('JHdH'))
                UnitAddAbility(dummy,FourCC(record.hostile and 'JHdH' or 'JHdN'))
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
        for _,raw in ipairs({'JHdP','JHdM'}) do
            local ability=BlzGetUnitAbility(record.unit,FourCC(raw))
            if ability then
                BlzSetAbilityStringLevelField(ability,ABILITY_SLF_TOOLTIP_NORMAL_EXTENDED,0,
                    'Current: '..tostring(record.armor))
            end
        end
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
            popup={tag=JTG.ScopeTrackTextTag(popupScope(),CreateTextTag())}
            self.damagePopups[self.damagePopupIndex]=popup
            SetTextTagPermanent(popup.tag,true)
        end
        popup.x,popup.y,popup.age=GetUnitX(unit),GetUnitY(unit),0
        SetTextTagText(popup.tag,string.format('%.1f',damage),.024)
        SetTextTagColor(popup.tag,255,220,80,255)
        SetTextTagPos(popup.tag,popup.x,popup.y,90);SetTextTagVisibility(popup.tag,true)
    end
end
