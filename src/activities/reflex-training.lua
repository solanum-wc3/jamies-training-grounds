-- Recognition and reaction training. Neutral ownership
-- keeps selection possible without player commands interrupting the walkers.
JTG = JTG or {}
JTG.ReflexHighScores=JTG.ReflexHighScores or {}
local WIDTH, HEIGHT = 1800, 1000
local MIN_COPIES, MAX_COPIES, COLUMNS, ROWS = 2, 4, 15, 8
local IDENTIFY_POPULATION, REFLEX_POPULATION = 62, 50
local WAR_MACHINES = {ocat=true, ebal=true, hmtt=true, umtw=true}
local OTHER_SUMMONS={uske=true,uskm=true,ucs1=true,ucs2=true,ucs3=true}
local TICK = 0.25
local TARGETS = {"hfoo", "hfoo", "hmpr", "hkni"}
local CUE_TICK, CUE_HOLD, CUE_MOVE = 0.02, 0.4, 0.3
local RACES = {{id='human',name='Human',symbol='Human',color=1},
    {id='orc',name='Orc',symbol='Orc',color=0},
    {id='nightelf',name='Night Elf',symbol='NightElf',color=2},
    {id='undead',name='Undead',symbol='Undead',color=3}}
-- Native ability IDs, order strings and buff IDs verified against the installed
-- AbilityData.slk and the melee hotkey catalogue. No aura effects are included.
JTG.ReflexEffects = {
    {race='human',name='Inner Fire',ability='Ainf',caster='hmpr',research={Rhpt=2},order='innerfire',buffs={'Binf'}},
    {race='human',name='Slow',ability='Aslo',caster='hsor',order='slow',buffs={'Bslo'},debuff=true},
    {race='human',name='Polymorph',ability='Aply',caster='hsor',research={Rhst=2},order='polymorph',buffs={'Bply'},debuff=true,noHeroes=true},
    {race='human',name='Banish',ability='AHbn',caster='Hblm',order='banish',buffs={'BHbn'},debuff=true},
    {race='orc',name='Bloodlust',ability='Ablo',caster='oshm',research={Rost=2},order='bloodlust',buffs={'Bblo'}},
    {race='orc',name='Lightning Shield',ability='Alsh',caster='oshm',research={Rost=1},order='lightningshield',buffs={'Blsh','Blsa'},area=true},
    {race='orc',name='Spirit Link',ability='Aspl',caster='ospw',order='spiritlink',buffs={'Bspl'},area=true},
    {race='orc',name='Hex',ability='AOhx',caster='Oshd',order='hex',buffs={'BOhx'},debuff=true},
    {race='orc',name='Ensnare',ability='Aens',caster='orai',research={Roen=1},order='ensnare',buffs={'Bena','Beng'},debuff=true},
    {race='nightelf',name='Roar',ability='Aroa',caster='edoc',order='roar',buffs={'Broa'},area=true,immediate=true},
    {race='nightelf',name='Rejuvenation',ability='Arej',caster='edoc',research={Redc=1},order='rejuvination',buffs={'Brej'}},
    {race='nightelf',name='Entangling Roots',ability='AEer',caster='Ekee',order='entanglingroots',buffs={'BEer'},debuff=true},
    {race='nightelf',name='Faerie Fire',ability='Afae',caster='edot',order='faeriefire',buffs={'Bfae'},debuff=true},
    {race='nightelf',name='Cyclone',ability='Acyc',caster='edot',research={Redt=2},order='cyclone',buffs={'Bcyc','Bcy2'},debuff=true},
    {race='nightelf',name='Shadow Strike',ability='AEsh',caster='Ewar',order='shadowstrike',buffs={'BEsh'},debuff=true},
    {race='undead',name='Frost Armor',ability='AUfu',caster='Ulic',order='frostarmor',buffs={'BUfa'}},
    {race='undead',name='Anti-magic Shell',ability='Aam2',caster='uban',research={Ruba=1},order='antimagicshell',buffs={'Bams','Bam2'}},
    {race='undead',name='Unholy Frenzy',ability='Auhf',caster='unec',research={Rune=1},order='unholyfrenzy',buffs={'BUhf'}},
    {race='undead',name='Curse',ability='Acrs',caster='uban',order='curse',buffs={'Bcrs'},debuff=true},
    {race='undead',name='Cripple',ability='Acri',caster='unec',research={Rune=2},order='cripple',buffs={'Bcri'},debuff=true},
    {race='undead',name='Sleep',ability='AUsl',caster='Udre',order='sleep',buffs={'BUsl','BUsp','Bust'},debuff=true},
}
local AUTOCAST_OFF={Ainf='innerfireoff',Aslo='slowoff',Ablo='bloodlustoff',
    Afae='faeriefireoff',AUfu='frostarmoroff',Acrs='curseoff'}
local RACE_TARGETS = {human=TARGETS,orc={'ogru','ogru','oshm','otau'},
    nightelf={'earc','earc','edry','emtg'},undead={'ugho','ugho','ucry','uabo'}}

function JTG.OpenReflexTrainingMenu(originCategory, pauseGame, restorePage, restoreData)
    local category = originCategory or "tools"
    local current=JTG.Controller and JTG.Controller.session
    if pauseGame and current and current.activity and current.activity.finished then
        JTG.StopActivity('result-menu')
        pauseGame=false
    end
    local function release() JTG.UI.SetGameplayMenuPaused(false) end
    local spec = {
        title = "Reflex Training", activityId = "skills.reflex",
        originCategory = category, pageId = "root", restoreData = {},
        pauseGame = pauseGame == true,
        body = JTG.Training.BriefingText('skills.reflex','root'),
        headingArtwork='JTGMenu\\ReflexTrainingBriefing.dds',headingArtworkWidth=0.16,headingArtworkHeight=0.08,
        choices = {},
        backAction = function() JTG.UI.ShowCategory(category) end,
    }
    for _, mode in ipairs({{id="identify",label="Identify Units"},{id="reflex",label="Reflex Test"}}) do
        local id=mode.id
        spec.choices[#spec.choices+1]={label=mode.label,primary=true,action=function()
            JTG.OpenReflexTrainingMenu(category,pauseGame,'races',{mode=id,races=(restoreData or {}).races})
        end}
    end
    if restorePage=='races' then
        local mode=(restoreData or {}).mode or 'identify'
        local selected={}
        for _,id in ipairs((restoreData or {}).races or {}) do selected[id]=true end
        local ids,names={},{}
        for _,race in ipairs(RACES) do
            if selected[race.id] then ids[#ids+1]=race.id end
            names[#names+1]=(selected[race.id] and '|cffffcc00' or '|cff909090')..race.name..'|r'
        end
        spec.pageId='races';spec.restoreData={mode=mode,races=ids};spec.headingArtwork=nil
        spec.body=JTG.Training.BriefingText('skills.reflex','races')..table.concat(names,', ')
        spec.choices={}
        for index,race in ipairs(RACES) do
            local id=race.id
            spec.choices[index]={label=race.name,primary=true,selected=selected[id]==true,
                icon='UI\\Glues\\Loading\\Backgrounds\\Campaigns\\'..race.symbol..'Symbol.dds',
                iconSize=0.0396,iconOffsetX=0.051,
                action=function()
                    selected[id]=not selected[id]
                    local nextIds={}
                    for _,entry in ipairs(RACES) do if selected[entry.id] then nextIds[#nextIds+1]=entry.id end end
                    JTG.OpenReflexTrainingMenu(category,pauseGame,'races',{mode=mode,races=nextIds})
                end}
        end
        spec.primaryLabel='Start Training';spec.primaryEnabled=#ids>0
        spec.primaryAction=function()
            if #ids==0 then return end
            release();JTG.StartActivityAfterCleanup('skills.reflex',category,{mode=mode,races=ids},nil,'new-crowd')
        end
        spec.backAction=function() JTG.OpenReflexTrainingMenu(category,pauseGame,'root',{races=ids}) end
    end
    if pauseGame then
        spec.resumeAction = function() release(); JTG.ResumeActivity() end
        spec.exitAction = JTG.ExitActivityFromMenu
    end
    JTG.UI.ShowActivityBriefing(spec)
end

local function Shuffle(list)
    for index = #list, 2, -1 do
        local other = GetRandomInt(1, index)
        list[index], list[other] = list[other], list[index]
    end
end

function JTG.CreateReflexTrainingActivity(session)
    local carry=session.restartData or {}
    local activity = {mode=carry.mode or "identify", layout=GetRandomInt(1,3), vertical=GetRandomInt(0,1)==1, reactions={}, reactionElapsed=0, units = {}, walkersByUnit = {}, elapsed = 0, finished = false,
        started = false, completed = {}, correct = 0, countdown = 3, presentationVisible = true}
    activity.races=carry.races or {'human','orc'}
    activity.stage=carry.identifyStage or 1
    activity.score=carry.identifyScore or 0
    activity.stageStartScore=activity.score
    activity.incorrect=0
    activity.targetPlan=carry.identifyPlan or {}
    local types,seen={},{}
    for _,raw in ipairs(RACE_TARGETS[activity.races[1]] or TARGETS) do
        if not seen[raw] then types[#types+1]=raw;seen[raw]=true end
    end
    if #activity.targetPlan==0 then
        local counts={}
        for index=1,10 do
            local candidates={}
            for _,raw in ipairs(types) do if (counts[raw] or 0)<4 then candidates[#candidates+1]=raw end end
            local raw=candidates[GetRandomInt(1,#candidates)]
            activity.targetPlan[index]=raw;counts[raw]=(counts[raw] or 0)+1
        end
    end
    function activity:prepareTargets()
        self.targets={}
        for index=1,self.stage do self.targets[index]=self.targetPlan[index] end
        local rank={};for index,raw in ipairs(types) do rank[raw]=index end
        table.sort(self.targets,function(a,b) return rank[a]<rank[b] end)
        self.addedIndex=nil
        for index,raw in ipairs(self.targets) do if raw==self.targetPlan[self.stage] then self.addedIndex=index end end
    end
    activity:prepareTargets()
    function activity:scoreStyle()
        return JTG.Training.ScoreStyle(self.score)
    end
    function activity:refreshScore()
        local color,scale=self:scoreStyle()
        for _,frame in ipairs({self.scoreFrame,self.resultScore}) do
            BlzFrameSetText(frame,color..'Score: '..self.score..'|r')
            BlzFrameSetScale(frame,scale)
            BlzFrameSetSize(frame,0.4/scale,0.04/scale)
            BlzFrameSetVisible(frame,self.presentationVisible and self.mode=='identify' and
                (frame==self.resultScore and self.finished or frame==self.scoreFrame and not self.finished))
        end
    end
    function activity:refreshStatus()
        if not self.status then return end
        local text = not self.started and (self.countdown>0 and tostring(self.countdown) or "") or
            (self.elapsed < 0.5 and "GO!" or "")
        if self.started and self.mode=="reflex" then
            text=(text~="" and text.."\n" or "")..(self.effectReady and self.nativeEffect and ("Find: "..self.nativeEffect.name) or "Preparing effect").."\n"..self.correct.."/10"
        end
        if self.mode=='identify' and self.started then text=text..'\nStage '..self.stage..'/10' end
        self:refreshScore()
        BlzFrameSetText(self.status, "|cffffcc00" .. text .. "|r")
        BlzFrameSetVisible(self.status,self.presentationVisible and not self.finished and text~="")
    end
    function activity:refreshIcons()
        if not self.icons then return end
        local t = math.max(0, math.min(1, ((self.cueElapsed or 0) - CUE_HOLD) / CUE_MOVE))
        -- Smoothly translate and shrink the entire row after its central flash.
        t = t * t * (3 - 2 * t)
        for index, icon in ipairs(self.icons) do
            local count=#self.targets
            local endX=0.77-(count-index)*0.035
            local moving=index==self.addedIndex
            local progress=moving and t or 1
            BlzFrameClearAllPoints(icon)
            BlzFrameSetAbsPoint(icon,FRAMEPOINT_CENTER,0.40+(endX-0.40)*progress,0.30+(0.484-0.30)*progress)
            local size=0.064+(0.032-0.064)*progress
            BlzFrameSetSize(icon,size,size)
            if self.targets[index] then BlzFrameSetTexture(icon,JTG.GetSurroundCustomUnitIcon(self.targets[index]),0,true) end
            BlzFrameSetAlpha(icon,self.completed[index] and 65 or 255)
            BlzFrameSetVisible(icon,index<=count and self.mode=='identify' and self.presentationVisible and self.cueVisible and not self.finished)
        end
    end

    function activity:showResult()
        JTG.UI.HideToolbar()
        self:refreshStatus(); self:refreshIcons()
        local details='\n\n\nStage '..self.stage..'/10: '..#self.targets..' requested units found.\nIncorrect clicks: '..self.incorrect
        if self.mode=='identify' then
            local race=self.races[1]
            JTG.ReflexHighScores[race]=math.max(JTG.ReflexHighScores[race] or self.score,self.score)
            details=details..'\nHigh score: '..JTG.ReflexHighScores[race]
        end
        if self.mode=="reflex" then
            local sum,best=0,math.huge
            for _,time in ipairs(self.reactions) do sum=sum+time;best=math.min(best,time) end
            details=self.effectError or string.format("10 targets clicked. Average: %.2fs. Fastest: %.2fs.",sum/math.max(1,#self.reactions),best)
        end
        JTG.UI.ShowResultCard(self.resultCard,{title=self.effectError and "Effect unavailable" or "Well done!",tone=self.effectError and "failure" or "success",
            details=details,visible=self.presentationVisible,
            actions={next={visible=self.mode=="identify" and self.stage<10,label="Continue"},retry={label=self.mode=='identify' and 'Start Over' or 'Redo'},menu={}}})
        self:refreshScore()
    end
    function activity:createPresentation()
        local root = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0)
        self.status = JTG.ScopeTrackFrame(session.presentationScope,
            BlzCreateFrameByType("TEXT","JTGReflexCountdown",root,"",0))
        BlzFrameSetSize(self.status,0.3,0.055)
        BlzFrameSetAbsPoint(self.status,FRAMEPOINT_CENTER,0.40,0.38)
        BlzFrameSetTextAlignment(self.status,TEXT_JUSTIFY_MIDDLE,TEXT_JUSTIFY_CENTER)
        BlzFrameSetScale(self.status,2)
        BlzFrameSetEnable(self.status,false)
        self.icons = {}
        for index=1,10 do
            local rawcode=self.targets[index] or self.targetPlan[index]
            local icon = JTG.ScopeTrackFrame(session.presentationScope,
                BlzCreateFrameByType("BACKDROP","JTGReflexTarget"..index,root,"",0))
            BlzFrameSetTexture(icon,JTG.GetSurroundCustomUnitIcon(rawcode),0,true)
            BlzFrameSetEnable(icon,false)
            self.icons[index] = icon
        end
        self.resultCard=JTG.UI.CreateResultCard(session,{name="JTGReflexResult",width=0.46,detailsHeight=0.12})
        self.scoreFrame=JTG.ScopeTrackFrame(session.presentationScope,BlzCreateFrameByType('TEXT','JTGReflexScore',root,'',0))
        self.resultScore=JTG.ScopeTrackFrame(session.presentationScope,BlzCreateFrameByType('TEXT','JTGReflexResultScore',self.resultCard.panel or root,'',0))
        for _,frame in ipairs({self.scoreFrame,self.resultScore}) do
            BlzFrameSetAbsPoint(frame,FRAMEPOINT_CENTER,0.40,frame==self.scoreFrame and 0.425 or 0.33)
            BlzFrameSetTextAlignment(frame,TEXT_JUSTIFY_MIDDLE,TEXT_JUSTIFY_CENTER)
            BlzFrameSetEnable(frame,false)
        end
        if self.resultCard.title then
            BlzFrameClearAllPoints(self.resultScore)
            BlzFrameSetPoint(self.resultScore,FRAMEPOINT_TOP,self.resultCard.title,FRAMEPOINT_BOTTOM,0,-0.015)
        end
        self:refreshStatus(); self:refreshIcons()
    end
    function activity:nativeBuffPresent()
        if not self.marked or not self.nativeEffect then return false end
        for _,buff in ipairs(self.nativeEffect.buffs) do
            if GetUnitAbilityLevel(self.marked,FourCC(buff))>0 then return true end
        end
        return false
    end
    function activity:clearNativeEffect()
        if self.marked and self.nativeEffect then
            -- Area and linked native effects may also touch nearby units.
            -- Clear the previous trial everywhere before announcing the next.
            for _,walker in ipairs(self.units) do
                for _,effect in ipairs(self.effectPool or {}) do
                    for _,buff in ipairs(effect.buffs) do UnitRemoveAbility(walker.unit,FourCC(buff)) end
                end
            end
            SetUnitState(self.marked,UNIT_STATE_LIFE,BlzGetUnitMaxHP(self.marked))
            SetUnitInvulnerable(self.marked,true)
        end
        if self.effectScope then JTG.DisposeScope(self.effectScope);self.effectScope=nil end
        self.marked,self.nativeEffect,self.effectCaster,self.effectReady=nil,nil,nil,false
    end
    function activity:effectCandidates(effect,previous)
        local targets={}
        for _,walker in ipairs(self.units) do
            local sameRace=walker.raceId==effect.race
            if walker.unit~=previous and not walker.summon and not WAR_MACHINES[walker.rawcode]
                and (effect.debuff and not sameRace or not effect.debuff and sameRace)
                and not IsUnitType(walker.unit,UNIT_TYPE_MAGIC_IMMUNE)
                and not IsUnitType(walker.unit,UNIT_TYPE_MECHANICAL)
                and not (effect.noHeroes and walker.hero) then
                targets[#targets+1]=walker.unit
            end
        end
        return targets
    end
    function activity:castNativeEffect()
        local effect,target=self.nativeEffect,self.marked
        self.effectScope=JTG.CreateScope('reflex-native-effect')
        local owner=Player(effect.debuff and PLAYER_NEUTRAL_AGGRESSIVE or PLAYER_NEUTRAL_PASSIVE)
        -- Real caster types and native research avoid relying on a zero-mana
        -- worker gaining a researched spell through mutable ability fields.
        for raw,level in pairs(effect.research or {}) do
            local tech=FourCC(raw)
            local previous=GetPlayerTechCount(owner,tech,true)
            JTG.ScopeBorrow(self.effectScope,function() SetPlayerTechResearched(owner,tech,previous) end)
            SetPlayerTechResearched(owner,tech,math.max(previous,level))
        end
        local caster=JTG.ScopeTrackUnit(self.effectScope,CreateUnit(owner,FourCC(effect.caster),GetUnitX(target),GetUnitY(target),0))
        assert(caster,'Missing Reflex caster: '..effect.caster)
        BlzSetUnitMaxMana(caster,1000)
        SetUnitState(caster,UNIT_STATE_MANA,1000)
        if effect.caster:match('^[A-Z]') then
            SetHeroLevel(caster,10,false)
            SelectHeroSkill(caster,FourCC(effect.ability))
        end
        self.effectCaster=caster
        UnitAddAbility(caster,FourCC('Aloc'))
        SetUnitPathing(caster,false);SetUnitX(caster,GetUnitX(target));SetUnitY(caster,GetUnitY(target))
        SetUnitVertexColor(caster,255,255,255,0)
        SetUnitInvulnerable(caster,true);SetUnitAcquireRange(caster,0)
        SetUnitCreepGuard(caster,false)
        BlzSetUnitRealField(caster,UNIT_RF_CAST_POINT,0)
        BlzSetUnitRealField(caster,UNIT_RF_CAST_BACK_SWING,0)
        UnitAddAbility(caster,FourCC(effect.ability))
        local ability=BlzGetUnitAbility(caster,FourCC(effect.ability))
        BlzSetAbilityBooleanField(ability,ABILITY_BF_CHECK_DEPENDENCIES,false)
        if AUTOCAST_OFF[effect.ability] then IssueImmediateOrder(caster,AUTOCAST_OFF[effect.ability]) end
        BlzSetAbilityIntegerLevelField(ability,ABILITY_ILF_MANA_COST,0,0)
        BlzSetAbilityRealLevelField(ability,ABILITY_RLF_COOLDOWN,0,0)
        BlzSetAbilityRealLevelField(ability,ABILITY_RLF_DURATION_NORMAL,0,120)
        BlzSetAbilityRealLevelField(ability,ABILITY_RLF_DURATION_HERO,0,120)
        if effect.area then BlzSetAbilityRealLevelField(ability,ABILITY_RLF_AREA_OF_EFFECT,0,1) end
        if effect.ability=='Aspl' then BlzSetAbilityIntegerLevelField(ability,ABILITY_ILF_MAXIMUM_NUMBER_OF_TARGETS_SPL2,0,1) end
        SetUnitInvulnerable(target,false)
        if effect.ability=='Arej' then SetUnitState(target,UNIT_STATE_LIFE,BlzGetUnitMaxHP(target)-1) end
        self.castAccepted=effect.immediate and IssueImmediateOrder(caster,effect.order) or
            not effect.immediate and IssueTargetOrder(caster,effect.order,target)
        self.effectWait=0
        self.effectReady=false
        self:refreshStatus()
    end
    function activity:markNextTarget(previous)
        if self.marked then previous=previous or self.marked;self:clearNativeEffect() end
        local available={}
        self.failedEffects=self.failedEffects or {}
        for _,effect in ipairs(self.effectPool) do
            if not self.failedEffects[effect.ability] then
                local targets=self:effectCandidates(effect,previous)
                if #targets>0 then available[#available+1]={effect=effect,targets=targets} end
            end
        end
        if #available==0 then
            self.effectError='No native effect could be applied to an eligible unit. Try another race selection.'
            self.finished=true;self:showResult();return
        end
        local entry=available[GetRandomInt(1,#available)]
        self.nativeEffect=entry.effect
        self.marked=entry.targets[GetRandomInt(1,#entry.targets)]
        self.effectAttempts=1;self.reactionElapsed=0
        self:castNativeEffect()
    end
    function activity:updateNativeEffect()
        if not self.marked or self.finished or self.paused or not self.presentationVisible then return end
        SetUnitState(self.marked,UNIT_STATE_LIFE,BlzGetUnitMaxHP(self.marked)-(self.nativeEffect.ability=='Arej' and 1 or 0))
        if self:nativeBuffPresent() then
            if not self.effectReady then self.effectReady=true;self.reactionElapsed=0;self:refreshStatus();return end
            self.reactionElapsed=self.reactionElapsed+0.01
            return
        end
        local wasReady=self.effectReady
        self.effectReady=false;self.effectWait=self.effectWait+0.01
        if wasReady then self:refreshStatus() end
        if self.effectWait<1 then return end
        if self.effectAttempts<3 then
            self.effectAttempts=self.effectAttempts+1
            local effect,previous=self.nativeEffect,self.marked
            local targets=self:effectCandidates(effect,previous)
            self:clearNativeEffect()
            self.nativeEffect=effect
            self.marked=#targets>0 and targets[GetRandomInt(1,#targets)] or previous
            self:castNativeEffect()
        else
            self.failedEffects[self.nativeEffect.ability]=true
            self:markNextTarget()
        end
    end
    function activity:selectTarget(unit)
        local walker = self.walkersByUnit[unit]
        if not self.started or self.finished or self.paused or not self.presentationVisible or not walker or self.mode=="identify" and walker.accepted then return end
        if self.mode=="reflex" then
            if unit~=self.marked or not self.effectReady or not self:nativeBuffPresent() then return end
            self.reactions[#self.reactions+1]=self.reactionElapsed
            self.correct=self.correct+1
            local previous=self.marked
            self:clearNativeEffect()
            if self.correct==10 then
                self.finished=true
                for _,entry in ipairs(self.units) do PauseUnit(entry.unit,true) end
                self:showResult()
            else
                self:markNextTarget(previous)
                self:refreshStatus()
            end
            return
        end
        local code = GetUnitTypeId(unit)
        for index, target in ipairs(self.targets) do
            if not self.completed[index] and code == FourCC(target) then
                self.completed[index], walker.accepted = true, true
                self.correct = self.correct + 1
                local now=self.scoreElapsed or self.elapsed
                local response=now-(self.lastCorrectAt or 0)
                self.score=self.score+JTG.Training.ResponseAward(response)
                self.lastCorrectAt=now
                -- Persistent Banish-like appearance; do not apply its slow or
                -- alter collision/pathing while the crowd keeps walking.
                SetUnitVertexColor(unit,120,255,180,100)
                local effect=AddSpecialEffectTarget("Abilities\\Spells\\Human\\Banish\\BanishTarget.mdl",unit,"origin")
                JTG.ScopeAdd(self.identifyScope or session.scope,function()
                    -- Destroy alone plays a lingering native death animation.
                    BlzSetSpecialEffectAlpha(effect,0)
                    BlzSetSpecialEffectScale(effect,0)
                    DestroyEffect(effect)
                end)
                self:refreshIcons()
                if self.correct == #self.targets then
                    self.finished = true
                    for _, entry in ipairs(self.units) do PauseUnit(entry.unit,true) end
                    self:showResult()
                end
                return
            end
        end
        self.incorrect=self.incorrect+1;self.score=self.score-10;self:refreshScore()
    end
    function activity:nextStage()
        if self.mode~='identify' or not self.finished or self.stage>=10 then return false end
        JTG.Training.BeginAttempt(session)
        self.stage=self.stage+1;self:prepareTargets()
        self.stageStartScore=self.score
        self.finished=false;self.correct=0;self.completed={};self.incorrect=0
        self.started=false;self.lastCorrectAt=0;self.elapsed=0;self.scoreElapsed=0;self.cueElapsed=0;self.cueVisible=true
        if self.identifyScope then JTG.DisposeScope(self.identifyScope) end
        self.identifyScope=JTG.CreateScope('reflex-identification-marks')
        for _,walker in ipairs(self.units) do
            walker.accepted=false;SetUnitVertexColor(walker.unit,255,255,255,255);PauseUnit(walker.unit,false)
        end
        JTG.UI.HideResultCard(self.resultCard)
        JTG.UI.ShowToolbar(session.descriptor.capabilities)
        self:refreshIcons();self:refreshStatus()
        return true
    end
    activity.resultActions={next=function() return activity:nextStage() end,
        retry=function()
            if activity.mode~='identify' then return JTG.ResetActivity() end
            JTG.StartActivityAfterCleanup('skills.reflex',session.originCategory or 'tools',
                {mode=activity.mode,races=activity.races,identifyPlan=activity.targetPlan},nil,'identify-start-over')
            return true
        end}
    function activity:setPaused(paused) self.paused = paused end
    function activity:chooseDestination(walker)
        walker.targetX = GetRandomReal(self.minX + 64, self.maxX - 64)
        walker.targetY = GetRandomReal(self.minY + 64, self.maxY - 64)
        walker.stalled = 0
        IssuePointOrder(walker.unit, self.layout==2 and "attack" or "move", walker.targetX, walker.targetY)
    end
    function activity:update()
        if self.finished or not self.started or self.paused then return end
        self.elapsed = self.elapsed + TICK
        self:refreshStatus()
        if self.mode=="reflex" then return end
        for _, walker in ipairs(self.units) do
            local unit = walker.unit
            if GetUnitTypeId(unit) ~= 0 and not IsUnitType(unit, UNIT_TYPE_DEAD) then
                local x, y = GetUnitX(unit), GetUnitY(unit)
                if x < self.minX or x > self.maxX or y < self.minY or y > self.maxY then
                    -- Recover collision pushes at an edge; destinations alone
                    -- cannot guarantee that a dense native crowd stays inside.
                    SetUnitPosition(unit, math.max(self.minX + 48, math.min(self.maxX - 48, x)),
                        math.max(self.minY + 48, math.min(self.maxY - 48, y)))
                    x, y = GetUnitX(unit), GetUnitY(unit)
                    self:chooseDestination(walker)
                end
                local dx, dy = x - walker.lastX, y - walker.lastY
                walker.stalled = dx * dx + dy * dy < 4 and walker.stalled + TICK or 0
                walker.lastX, walker.lastY = x, y
                if self.elapsed >= walker.nextChoice then
                    local tx, ty = x - (walker.targetX or x), y - (walker.targetY or y)
                    if walker.targetX == nil or tx * tx + ty * ty < 64 * 64 or walker.stalled >= 1.5 and self.layout~=2 then
                        self:chooseDestination(walker)
                        walker.nextChoice = self.elapsed + GetRandomReal(0.5, 1.5)
                    end
                end
            end
        end
    end
    function activity:setup(current)
        local scene, player = current.scene, Player(0)
        self.centerX, self.centerY = scene.centerX, scene.centerY
        self.minX, self.maxX = self.centerX - WIDTH / 2, self.centerX + WIDTH / 2
        self.minY, self.maxY = self.centerY - HEIGHT / 2, self.centerY + HEIGHT / 2
        JTG.BorrowCamera(current.scope, player)
        local time, scale = GetFloatGameState(GAME_STATE_TIME_OF_DAY), GetTimeOfDayScale()
        JTG.ScopeBorrow(current.scope, function()
            SetFloatGameState(GAME_STATE_TIME_OF_DAY, time); SetTimeOfDayScale(scale)
        end)
        SetFloatGameState(GAME_STATE_TIME_OF_DAY, 12); SetTimeOfDayScale(0)
        JTG.ResetWorldFog(player)
        JTG.ScopeRevealRect(current.scope, player, self.minX - 200, self.minY - 200,
            self.maxX + 200, self.maxY + 200)

        local roster, slots = {}, {}
        -- Selected races share one fixed screen population.
        local choices, families = {}, {}
        local activeRaces={}
        for _,id in ipairs(self.races) do
            for _,race in ipairs(RACES) do
                if race.id==id then activeRaces[#activeRaces+1]={id=id,color=ConvertPlayerColor(race.color)} end
            end
        end
        assert(#activeRaces>0,'Reflex needs at least one race')
        self.raceCount=#activeRaces
        for raceIndex,race in ipairs(activeRaces) do
            for _, column in ipairs(JTG.GetSurroundCustomRaceColumns(race.id)) do
                for _, choice in ipairs(column) do
                    if choice.kind == "unit" and choice.enabled and choice.rawcode~="osw3" and choice.rawcode~="ushd" then
                        choices[#choices + 1] = {definition=choice,color=race.color,raceIndex=raceIndex}
                        local family = JTG.GetSurroundCustomSummonFamily(choice.rawcode)
                        if family then families[family] = (families[family] or 0) + 1 end
                    end
                end
            end
        end
        local familyIndices, familyBudgets = {}, {}
        for _, entry in ipairs(choices) do
            local choice=entry.definition
            local count = choice.hero and 1 or GetRandomInt(MIN_COPIES, MAX_COPIES)
            if choice.rawcode=="hfoo" then count=GetRandomInt(4,6) end
            local family = JTG.GetSurroundCustomSummonFamily(choice.rawcode)
            if family and not choice.hero then
                local index = (familyIndices[family] or 0) + 1
                familyIndices[family] = index
                -- Keep one population budget per summon type, split across
                -- its levels; distribute any remainder in roster order.
                familyBudgets[family] = familyBudgets[family] or GetRandomInt(3,6)
                local budget = familyBudgets[family]
                count = math.floor(budget / families[family]) +
                    (index <= budget % families[family] and 1 or 0)
            end
            if choice.rawcode=='espv' or choice.rawcode=='hphx' then count=1 end
            local rawcode=({Ewdn='Ewar',uin1='ninf'})[choice.rawcode] or JTG.GetSurroundCustomSpawnRawcode(choice.rawcode)
            if WAR_MACHINES[rawcode] then count=math.min(count,2) end
            for _ = 1, count do roster[#roster + 1] = {
                rawcode=rawcode,color=entry.color,raceIndex=entry.raceIndex,hero=choice.hero,
                summon=family~=nil or OTHER_SUMMONS[rawcode] or choice.rawcode=='espv' or choice.rawcode=='hphx'} end
        end
        -- Extra slots use regular units only, preserving hero uniqueness,
        -- summon-family budgets and the two-per-side war-machine cap.
        local fillers={}
        for _,entry in ipairs(choices) do
            local choice=entry.definition
            local rawcode=JTG.GetSurroundCustomSpawnRawcode(choice.rawcode)
            if not choice.hero and not JTG.GetSurroundCustomSummonFamily(choice.rawcode)
                and choice.rawcode~='espv' and choice.rawcode~='hphx' and not OTHER_SUMMONS[rawcode] and not WAR_MACHINES[rawcode] then
                fillers[entry.raceIndex]=fillers[entry.raceIndex] or {}
                table.insert(fillers[entry.raceIndex],{rawcode=rawcode,color=entry.color,raceIndex=entry.raceIndex})
            end
        end
        -- Divide the exact total evenly; earlier races receive remainder slots.
        -- Prefer keeping each model, but allow a random subset when four races
        -- provide more distinct models than the smaller reaction crowd can fit.
        local population=self.mode=='reflex' and REFLEX_POPULATION or IDENTIFY_POPULATION
        local minimums={}
        if self.mode=='identify' then
            for _,raw in ipairs(self.targetPlan) do minimums[raw]=(minimums[raw] or 0)+1 end
        end
        for raceIndex=1,#activeRaces do
            local wanted=math.floor(population/#activeRaces)+(raceIndex<=population%#activeRaces and 1 or 0)
            local count,counts=0,{}
            for _,entry in ipairs(roster) do
                if entry.raceIndex==raceIndex then count=count+1;counts[entry.rawcode]=(counts[entry.rawcode] or 0)+1 end
            end
            if raceIndex==1 then
                for raw,minimum in pairs(minimums) do
                    while (counts[raw] or 0)<minimum do
                        roster[#roster+1]={rawcode=raw,color=activeRaces[1].color,raceIndex=1}
                        counts[raw]=(counts[raw] or 0)+1;count=count+1
                    end
                end
            end
            while count>wanted do
                local removable={}
                for index,entry in ipairs(roster) do
                    local minimum=raceIndex==1 and minimums[entry.rawcode] or nil
                    if entry.raceIndex==raceIndex and counts[entry.rawcode]>(minimum or 1) then
                        removable[#removable+1]=index
                    end
                end
                if #removable==0 then
                    for index,entry in ipairs(roster) do
                        if entry.raceIndex==raceIndex and counts[entry.rawcode]>(raceIndex==1 and minimums[entry.rawcode] or 0) then
                            removable[#removable+1]=index
                        end
                    end
                end
                assert(#removable>0,'Reflex crowd budget cannot fit required targets')
                local index=removable[GetRandomInt(1,#removable)]
                counts[roster[index].rawcode]=counts[roster[index].rawcode]-1
                table.remove(roster,index);count=count-1
            end
            local candidates=fillers[raceIndex] or {}
            assert(#candidates>0,'Reflex race needs regular units to fill its crowd budget')
            while count<wanted do
                local entry=candidates[GetRandomInt(1,#candidates)]
                roster[#roster+1]={rawcode=entry.rawcode,color=entry.color,raceIndex=raceIndex}
                count=count+1
            end
        end
        self.fullPopulation=IDENTIFY_POPULATION
        self.combat=self.mode=="identify" and self.layout==2 and #activeRaces>1
        if self.combat then
            local alliances={}
            for index=1,#activeRaces do
                alliances[#alliances+1]={Player(0),Player(index),true}
                alliances[#alliances+1]={Player(index),Player(0),true}
                for other=1,#activeRaces do
                    if other~=index then alliances[#alliances+1]={Player(index),Player(other),false} end
                end
            end
            for _,pair in ipairs(alliances) do
                local left,right,allied=pair[1],pair[2],pair[3]
                local previous=GetPlayerAlliance(left,right,ALLIANCE_PASSIVE)
                JTG.ScopeBorrow(current.scope,function() SetPlayerAlliance(left,right,ALLIANCE_PASSIVE,previous) end)
                SetPlayerAlliance(left,right,ALLIANCE_PASSIVE,allied)
            end
            local damage=JTG.ScopeTrackTrigger(current.scope,CreateTrigger())
            for index=1,#activeRaces do
                TriggerRegisterPlayerUnitEvent(damage,Player(index),EVENT_PLAYER_UNIT_DAMAGED,nil)
            end
            TriggerAddAction(damage,JTG.GuardSession(current,function()
                if self.walkersByUnit[GetTriggerUnit()] then
                    -- Keep a concentrated volley from killing a target between refreshes.
                    local life=GetUnitState(GetTriggerUnit(),UNIT_STATE_LIFE)
                    BlzSetEventDamage(math.min(GetEventDamage(),math.max(0,life-1)))
                end
            end))
        end
        for row = 0, ROWS - 1 do
            for column = 0, COLUMNS - 1 do
                slots[#slots + 1] = {
                    x = self.minX + (column + 0.5) * WIDTH / COLUMNS + GetRandomReal(-3, 3),
                    y = self.minY + (row + 0.5) * HEIGHT / ROWS + GetRandomReal(-3, 3),
                }
            end
        end
        assert(#roster <= #slots, "Reflex crowd exceeds separated spawn capacity")
        Shuffle(roster); Shuffle(slots)
        local raceSlots,raceIndices={},{}
        if self.layout~=1 then
            self.regions={}
            for index,race in ipairs(activeRaces) do
                local x1,x2,y1,y2=self.minX,self.maxX,self.minY,self.maxY
                if #activeRaces==4 then
                    x1=self.minX+((index-1)%2)*WIDTH/2; x2=x1+WIDTH/2
                    y1=self.minY+math.floor((index-1)/2)*HEIGHT/2; y2=y1+HEIGHT/2
                elseif self.vertical then
                    x1=self.minX+(index-1)*WIDTH/#activeRaces; x2=x1+WIDTH/#activeRaces
                else
                    y1=self.minY+(index-1)*HEIGHT/#activeRaces; y2=y1+HEIGHT/#activeRaces
                end
                self.regions[index]={minX=x1,maxX=x2,minY=y1,maxY=y2}
                local count=0
                for _,entry in ipairs(roster) do if entry.raceIndex==index then count=count+1 end end
                local columns=math.max(1,math.ceil(math.sqrt(count*(x2-x1)/(y2-y1))))
                local rows=math.ceil(count/columns)
                raceSlots[race.color]={}
                for row=0,rows-1 do for column=0,columns-1 do
                    table.insert(raceSlots[race.color],{x=x1+(column+0.5)*(x2-x1)/columns+GetRandomReal(-3,3),
                        y=y1+(row+0.5)*(y2-y1)/rows+GetRandomReal(-3,3)})
                end end
                Shuffle(raceSlots[race.color])
            end
        end
        local selected = JTG.ScopeTrackTrigger(current.scope,CreateTrigger())
        -- Register the selecting PLAYER, not an event on neutral-owned units.
        -- Unit-event context does not reliably supply GetTriggerPlayer().
        TriggerRegisterPlayerUnitEvent(selected,Player(0),EVENT_PLAYER_UNIT_SELECTED,nil)
        TriggerAddAction(selected,JTG.GuardSession(current,function()
            if GetTriggerPlayer() ~= Player(0) then return end
            self:selectTarget(GetTriggerUnit())
            -- Allow a second click on the same model without allowing it to
            -- count twice, and keep selection circles out of the next search.
            if GetLocalPlayer()==Player(0) then ClearSelection() end
        end))
        for index, entry in ipairs(roster) do
            local rawcode=entry.rawcode
            local slot = slots[index]
            if self.layout~=1 then
                raceIndices[entry.color]=(raceIndices[entry.color] or 0)+1
                slot=raceSlots[entry.color][raceIndices[entry.color]]
                assert(slot,"Reflex race exceeds its region capacity")
            end
            local unit = JTG.ScopeTrackUnit(current.scope,
                CreateUnit(self.combat and Player(entry.raceIndex) or Player(PLAYER_NEUTRAL_PASSIVE), FourCC(rawcode), slot.x, slot.y, GetRandomReal(0, 360)))
            assert(unit ~= nil,"Reflex could not create native unit "..rawcode)
            SetUnitColor(unit, entry.color)
            SetUnitInvulnerable(unit, not self.combat)
            SetUnitAcquireRange(unit, self.combat and 600 or 0)
            SetUnitCreepGuard(unit, false)
            assert(not IsUnitType(unit, UNIT_TYPE_FLYING), "Flying unit in Reflex ground crowd")
            local walker = {unit = unit, color=entry.color,raceIndex=entry.raceIndex, raceId=activeRaces[entry.raceIndex].id,rawcode=rawcode,hero=entry.hero,summon=entry.summon, lastX = GetUnitX(unit), lastY = GetUnitY(unit),
                stalled = 0, nextChoice = GetRandomReal(0, 1.5)}
            self.units[#self.units + 1] = walker
            self.walkersByUnit[unit] = walker
        end
        self.effectPool={}
        if self.mode=='reflex' then
            local selected={}
            for _,race in ipairs(activeRaces) do selected[race.id]=true end
            for _,effect in ipairs(JTG.ReflexEffects) do
                if selected[effect.race] and (not effect.debuff or #activeRaces>1) then
                    self.effectPool[#self.effectPool+1]=effect
                end
            end
            local enemy,neutral=Player(PLAYER_NEUTRAL_AGGRESSIVE),Player(PLAYER_NEUTRAL_PASSIVE)
            for _,pair in ipairs({{enemy,neutral},{neutral,enemy}}) do
                local left,right=pair[1],pair[2]
                local old=GetPlayerAlliance(left,right,ALLIANCE_PASSIVE)
                JTG.ScopeBorrow(current.scope,function() SetPlayerAlliance(left,right,ALLIANCE_PASSIVE,old) end)
                SetPlayerAlliance(left,right,ALLIANCE_PASSIVE,false)
            end
            JTG.ScopeAdd(current.scope,function() self:clearNativeEffect() end)
        end
        self:createPresentation()
    end
    function activity:crossCrowd()
        for _,walker in ipairs(self.units) do
            if self.raceCount==4 or self.raceCount==3 then
                local nextIndex=self.raceCount==4 and (5-walker.raceIndex) or (walker.raceIndex%self.raceCount+1)
                local region=self.regions[nextIndex]
                walker.targetX=GetRandomReal(region.minX+48,region.maxX-48)
                walker.targetY=GetRandomReal(region.minY+48,region.maxY-48)
            else
                walker.targetX=self.vertical and (2*self.centerX-GetUnitX(walker.unit)) or GetUnitX(walker.unit)
                walker.targetY=self.vertical and GetUnitY(walker.unit) or (2*self.centerY-GetUnitY(walker.unit))
            end
            walker.stalled=0
            IssuePointOrder(walker.unit,"attack",walker.targetX,walker.targetY)
        end
    end
    function activity:start()
        if GetLocalPlayer() == Player(0) then
            SetCameraField(CAMERA_FIELD_ROTATION, 90, 0)
            SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, 304, 0)
            SetCameraPosition(self.centerX, self.centerY)
            ClearSelection()
        end
        if self.combat then
            JTG.StartScopedTimer(session,session.scope,1,true,function()
                if self.finished or self.paused then return end
                for _,walker in ipairs(self.units) do
                    if GetUnitTypeId(walker.unit)~=0 and not IsUnitType(walker.unit,UNIT_TYPE_DEAD) then
                        SetUnitState(walker.unit,UNIT_STATE_LIFE,BlzGetUnitMaxHP(walker.unit))
                    end
                end
            end)
        end
        if self.layout==2 and self.mode=="identify" then self:crossCrowd() end
        self.identifyScope=JTG.CreateScope('reflex-identification-marks')
        self.cueTimer = JTG.StartScopedTimer(session, session.scope, CUE_TICK, true, function()
            if self.finished or self.paused or not self.presentationVisible then return end
            if self.started then self.scoreElapsed=(self.scoreElapsed or 0)+CUE_TICK end
            if not self.cueVisible or self.cueElapsed >= CUE_HOLD+CUE_MOVE then return end
            self.cueElapsed = math.min(CUE_HOLD+CUE_MOVE,self.cueElapsed+CUE_TICK)
            if not self.started and self.cueElapsed>=CUE_HOLD then
                self.started=true
                self.elapsed=0
                self.scoreElapsed=0
                if self.layout==3 and self.mode=="identify" then
                    for _,walker in ipairs(self.units) do self:chooseDestination(walker) end
                end
                if self.mode=="reflex" then
                    self:markNextTarget()
                    JTG.StartScopedTimer(session,session.scope,0.01,true,function()
                        if not self.finished and not self.paused and self.marked then
                            self:updateNativeEffect()
                        end
                    end)
                end
                if GetLocalPlayer()==Player(0) then ClearSelection() end
                if not self.movementTimer then self.movementTimer=JTG.StartScopedTimer(session,session.scope,TICK,true,function() self:update() end) end
            end
            self:refreshIcons(); self:refreshStatus()
            -- This timer also measures click responses independently of AI ticks.
        end)
        JTG.Training.Countdown(self,session,3,function(remaining)
            self.countdown = remaining; self:refreshStatus()
        end,function()
            self.countdown,self.cueVisible,self.cueElapsed = 0,true,0
            self:refreshStatus(); self:refreshIcons()
        end)
    end
    function activity:captureResetState() return {mode=self.mode,races=self.races,identifyStage=self.stage,identifyPlan=self.targetPlan,identifyScore=self.stageStartScore} end
    JTG.Training.InstallPresentation(activity,session,{
        roots={'status','scoreFrame','resultScore'},lists={'icons'},
        references={'status','icons','resultCard','scoreFrame','resultScore'},
        refresh={'refreshIcons'},result='showResult',
    })
    function activity:cleanup()
        self:clearNativeEffect()
        if self.identifyScope then JTG.DisposeScope(self.identifyScope);self.identifyScope=nil end
        self.finished = true
        self.presentationVisible = false
        self:refreshStatus(); self:refreshIcons()
        if GetLocalPlayer() == Player(0) then ClearSelection() end
        JTG.UI.HideActivityBriefing()
    end
    function activity:afterCleanup() self.units = {}; self.walkersByUnit = {} end
    return activity
end
