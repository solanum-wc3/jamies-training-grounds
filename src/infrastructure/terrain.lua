-- Temporary terrain belongs to the same scope as the buildings which affect
-- it. Shared cells retain their original state until their final user leaves.
JTG=JTG or {}
local cells={}
local arenaBaseline={}
local baselineInitialized=false
local STEP=128
local function key(x,y) return x..':'..y end
local pendingViews={}
local viewRefresh
local function recordView(message)
    local history=JTG.TerrainCleanupHistory
    if not history then return end
    history[#history+1]='view-'..message
    if #history>60 then table.remove(history,1) end
end
local function rememberView(cell)
    pendingViews[key(cell.x,cell.y)]=cell
end
local function visibleCount(entries)
    local visible=0
    for _,cell in ipairs(entries) do
        if not IsMaskedToPlayer(cell.x+STEP/2,cell.y+STEP/2,Player(0)) and
                not IsFoggedToPlayer(cell.x+STEP/2,cell.y+STEP/2,Player(0)) then visible=visible+1 end
    end
    return visible
end
function JTG.CancelTerrainViewRefresh(finished)
    if not viewRefresh then return end
    local refresh=viewRefresh;viewRefresh=nil
    PauseTimer(refresh.timer);DestroyTimer(refresh.timer)
    local visible=visibleCount(refresh.cells)
    recordView((finished and 'finished' or 'cancelled')..',cells='..#refresh.cells..',visible='..visible)
    if not finished then for _,cell in ipairs(refresh.cells) do rememberView(cell) end end
    for _,area in ipairs(refresh.areas) do
        FogModifierStop(area.modifier);DestroyFogModifier(area.modifier)
        -- Only previously fogged/explored cells were temporarily revealed.
        SetFogStateRect(Player(0),FOG_OF_WAR_FOGGED,area.rect,false)
        RemoveRect(area.rect)
    end
end
function JTG.RefreshTerrainView()
    JTG.CancelTerrainViewRefresh()
    local rows,refreshedCells={},{};local player=Player(0)
    local requested,masked,protected,visible=0,0,0,0
    for id,cell in pairs(pendingViews) do
        requested=requested+1
        local current=cells[id]
        if current and (current~=cell or current.sources>0) then
            protected=protected+1
            pendingViews[id]=nil -- Never reveal a replacement blight scene.
        elseif not IsMaskedToPlayer(cell.x+STEP/2,cell.y+STEP/2,player) then
            pendingViews[id]=nil
            if IsFoggedToPlayer(cell.x+STEP/2,cell.y+STEP/2,player) then
                rows[cell.y]=rows[cell.y] or {};table.insert(rows[cell.y],cell.x)
                refreshedCells[#refreshedCells+1]=cell
            else visible=visible+1 end
        else masked=masked+1 end -- Keep masked cells pending until explored.
    end
    local areas={}
    for y,xs in pairs(rows) do
        table.sort(xs)
        local first,last
        local function add()
            local rect=Rect(first,y,last+STEP-1,y+STEP-1)
            -- Match ScopeRevealRect: modifier startup alone did not establish
            -- sight during the short refresh in alpha23's native export.
            SetFogStateRect(player,FOG_OF_WAR_VISIBLE,rect,false)
            local modifier=CreateFogModifierRect(player,FOG_OF_WAR_VISIBLE,rect,false,false)
            areas[#areas+1]={rect=rect,modifier=modifier}
            FogModifierStart(modifier)
        end
        for _,x in ipairs(xs) do
            if last and x~=last+STEP then add();first=nil end
            first=first or x;last=x
        end
        if first then add() end
    end
    if requested>0 then
        recordView('requested='..requested..',masked='..masked..',protected='..protected..
            ',already-visible='..visible..',refresh='..#refreshedCells..',spans='..#areas)
    end
    if #areas==0 then return end
    -- Give the renderer a brief sight update; never disable global fog or
    -- explore masked terrain. Adjacent saved cells share one modifier.
    local refresh={areas=areas,cells=refreshedCells,timer=CreateTimer()};viewRefresh=refresh
    local polls,lastVisible=0,nil
    local function check()
        if viewRefresh~=refresh then return end
        polls=polls+1
        local visible=visibleCount(refresh.cells)
        if visible~=lastVisible then
            recordView('poll='..polls..',cells='..#refresh.cells..',visible='..visible)
            lastVisible=visible
        end
        if visible==#refresh.cells then JTG.CancelTerrainViewRefresh(true)
        elseif polls>=30 then
            recordView('timeout,cells='..#refresh.cells..',visible='..visible)
            JTG.CancelTerrainViewRefresh() -- Restore fog; keep an unrefreshed request pending.
        else TimerStart(refresh.timer,.1,false,check) end
    end
    TimerStart(refresh.timer,.1,false,check)
end
JTG.TerrainCleanupHistory={}
local function fullRestoreAllowed(entry)
    local cell=entry.cell
    return cells[key(cell.x,cell.y)]==cell and cell.users==0 and cell.generation==entry.generation
end
local function blightRestoreAllowed(entry)
    local cell=entry.cell
    return cells[key(cell.x,cell.y)]==cell and cell.sources==0 and cell.blightGeneration==entry.blightGeneration
end
local function record(phase,scope,entries)
    local count,dirty,first,blightOnly=0,0,nil,0
    for _,entry in ipairs(entries) do
        local cell=entry.cell
        if fullRestoreAllowed(entry) or blightRestoreAllowed(entry) then
            count=count+1
            if not fullRestoreAllowed(entry) then blightOnly=blightOnly+1 end
            if IsPointBlighted(cell.x,cell.y)~=cell.blight then
                dirty=dirty+1;first=first or (cell.x..'/'..cell.y)
            end
        end
    end
    local history=JTG.TerrainCleanupHistory
    history[#history+1]=phase..',scope='..tostring(scope.label)..',cells='..count..',changed='..dirty..
        ',blight-only='..blightOnly..',first='..tostring(first)
    if #history>60 then table.remove(history,1) end
end
local function snapshot(x,y)
    local original=arenaBaseline[key(x,y)]
    -- Baselines are immutable; ownership/generations belong to live leases.
    if original then
        return {x=x,y=y,blight=original.blight,terrain=original.terrain,
            variation=original.variation,owners={},users=0,sources=0,blightGeneration=0}
    end
    return {x=x,y=y,blight=IsPointBlighted(x,y),terrain=GetTerrainType(x,y),
        variation=GetTerrainVariance(x,y),owners={},users=0,sources=0,blightGeneration=0}
end
local function restoreBlight(cell)
    if IsPointBlighted(cell.x,cell.y)~=cell.blight then rememberView(cell) end
    -- SetBlightPoint edits a surrounding patch, not just this saved sample.
    -- Overlapping point writes can re-blight a neighbour or erase original
    -- blight depending on iteration order. Limit each write to its leased tile.
    local area=Rect(cell.x,cell.y,cell.x+STEP-1,cell.y+STEP-1)
    if not cell.blight then
        for owner in pairs(cell.owners) do SetBlightRect(owner,area,false) end
    elseif not IsPointBlighted(cell.x,cell.y) then
        SetBlightRect(next(cell.owners) or Player(PLAYER_NEUTRAL_PASSIVE),area,true)
    end
    RemoveRect(area)
end
local function restore(cell)
    -- Active replacement buildings retain their terrain/footprints. Only a
    -- fully released cell may have its tile and variation reapplied.
    if GetTerrainType(cell.x,cell.y)~=cell.terrain or GetTerrainVariance(cell.x,cell.y)~=cell.variation then rememberView(cell) end
    SetTerrainType(cell.x,cell.y,cell.terrain,cell.variation,1,0)
    restoreBlight(cell)
end
local function bounds()
    local area=GetWorldBounds()
    local result={GetRectMinX(area),GetRectMinY(area),GetRectMaxX(area),GetRectMaxY(area)}
    RemoveRect(area);return result
end
function JTG.InitializeTerrainBaseline()
    if baselineInitialized then return end
    assert(next(cells)==nil,'Arena terrain baseline must precede temporary buildings')
    local world=bounds()
    for _,id in ipairs({'arena.south','arena.north'}) do
        local scene=assert(JTG.Scenes[id],'Missing terrain baseline arena '..id)
        -- Include the existing 1024-unit building-preservation margin. The
        -- overlapping arenas share saved cells and are never recaptured.
        for x=math.max(world[1],math.floor((scene.minX-1024)/STEP)*STEP),math.min(world[3]-STEP,scene.maxX+1024),STEP do
            for y=math.max(world[2],math.floor((scene.minY-1024)/STEP)*STEP),math.min(world[4]-STEP,scene.maxY+1024),STEP do
                local cellId=key(x,y)
                if not arenaBaseline[cellId] then arenaBaseline[cellId]=snapshot(x,y) end
            end
        end
    end
    baselineInitialized=true
end
local function restoreReleased(scope,entries)
    local function apply(final)
        for _,entry in ipairs(entries) do
            local cell=entry.cell;local id=key(cell.x,cell.y)
            if fullRestoreAllowed(entry) then
                -- Fog memory can remain blighted even when the live tile is
                -- already clean. Include the retired source's entire lease.
                if cell.blightGeneration>0 then rememberView(cell) end
                restore(cell)
                if final then cells[id]=nil end
            elseif blightRestoreAllowed(entry) then
                -- Human (etc.) buildings keep a baseline lease, but do not
                -- justify retaining the departed Undead scene's late blight.
                if cell.blightGeneration>0 then rememberView(cell) end
                restoreBlight(cell)
            end
        end
    end
    record('immediate-before',scope,entries);apply(false)
    if #entries==0 then return end
    -- Native blight updates can follow RemoveUnit. Keep the original baseline
    -- available for new leases until the bounded post-removal checks finish.
    local timer=CreateTimer();local phase=0
    local function check()
        phase=phase+1
        record(phase==1 and 'next-tick-before' or 'settled-before',scope,entries)
        apply(phase==2)
        JTG.RefreshTerrainView()
        if phase==2 then PauseTimer(timer);DestroyTimer(timer)
        else TimerStart(timer,.5,false,check) end
    end
    TimerStart(timer,0,false,check)
end
function JTG.ScopePreserveTerrain(scope,owner,x,y,radius,reserveBlight)
    local state=scope.terrainState
    if not state then
        state={cells={},owners={},blightReservations={}};scope.terrainState=state
        -- Registered before owned units: reverse disposal removes every source
        -- first, then restores terrain. Child scene scopes use the same rule.
        JTG.ScopeAdd(scope,function()
            local released={}
            for id,cell in pairs(state.cells) do
                for player in pairs(state.owners) do cell.owners[player]=true end
                if state.blightReservations[id] then
                    cell.sources=cell.sources-1;cell.blightGeneration=cell.blightGeneration+1
                end
                cell.users=cell.users-1
                if cell.users==0 then
                    cell.generation=(cell.generation or 0)+1
                end
                released[#released+1]={cell=cell,generation=cell.generation,blightGeneration=cell.blightGeneration}
            end
            restoreReleased(scope,released)
        end)
    end
    state.owners[owner]=true
    local region={};local world=bounds()
    for tx=math.max(world[1],math.floor((x-radius)/STEP)*STEP),math.min(world[3]-STEP,x+radius),STEP do
        for ty=math.max(world[2],math.floor((y-radius)/STEP)*STEP),math.min(world[4]-STEP,y+radius),STEP do
            local id=key(tx,ty);local cell=cells[id]
            if not cell then cell=snapshot(tx,ty);cells[id]=cell end
            cell.owners[owner]=true
            if not state.cells[id] then
                cell.generation=(cell.generation or 0)+1
                state.cells[id]=cell;cell.users=cell.users+1
            end
            -- Explicit terrain mutations reserve write ownership by default.
            -- Ordinary building snapshots identify real sources after spawn.
            if reserveBlight~=false and not state.blightReservations[id] then
                state.blightReservations[id]=true
                cell.sources=cell.sources+1;cell.blightGeneration=cell.blightGeneration+1
            end
            region[#region+1]=cell
        end
    end
    -- Explicit early clears (the hidden Hotkey Setup prerequisite hall) still
    -- restore the saved baseline, rather than erasing original map blight.
    return function() for _,cell in ipairs(region) do restore(cell) end end,region
end
function JTG.PreserveUnitTerrain(scope,owner,raw,x,y)
    if IsUnitIdType(raw,UNIT_TYPE_STRUCTURE) then
        local _,region=JTG.ScopePreserveTerrain(scope,owner,x,y,1024,false)
        return region
    end
end
function JTG.TrackTerrainBlightSource(scope,unit,region)
    -- Native small/large/mine blight abilities, including inherited abilities
    -- on presentation copies. Do not infer source behavior from race alone.
    if GetUnitAbilityLevel(unit,FourCC('Abgs'))==0 and GetUnitAbilityLevel(unit,FourCC('Abgl'))==0
            and GetUnitAbilityLevel(unit,FourCC('Abgm'))==0 then return end
    for _,cell in ipairs(region) do
        cell.sources=cell.sources+1;cell.blightGeneration=cell.blightGeneration+1
    end
    -- Registered before ScopeTrackUnit, so removal precedes source release.
    JTG.ScopeAdd(scope,function()
        for _,cell in ipairs(region) do
            cell.sources=cell.sources-1;cell.blightGeneration=cell.blightGeneration+1
        end
    end)
end
function JTG.RememberTerrainOwner(scope,owner)
    -- Native removal/morphing can invalidate the unit before its tracked
    -- disposer runs. GetOwningPlayer then returns nil, not a player handle.
    if owner~=nil and scope.terrainState then scope.terrainState.owners[owner]=true end
end
