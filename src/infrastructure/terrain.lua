-- Temporary terrain belongs to the same scope as the buildings which affect
-- it. Shared cells retain their original state until their final user leaves.
JTG=JTG or {}
local cells={}
local STEP=128
local function key(x,y) return x..':'..y end
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
    return {x=x,y=y,blight=IsPointBlighted(x,y),terrain=GetTerrainType(x,y),
        variation=GetTerrainVariance(x,y),owners={},users=0,sources=0,blightGeneration=0}
end
local function restoreBlight(cell)
    if not cell.blight then
        for owner in pairs(cell.owners) do SetBlightPoint(owner,cell.x,cell.y,false) end
    elseif not IsPointBlighted(cell.x,cell.y) then
        SetBlightPoint(next(cell.owners) or Player(PLAYER_NEUTRAL_PASSIVE),cell.x,cell.y,true)
    end
end
local function restore(cell)
    -- Active replacement buildings retain their terrain/footprints. Only a
    -- fully released cell may have its tile and variation reapplied.
    SetTerrainType(cell.x,cell.y,cell.terrain,cell.variation,1,0)
    restoreBlight(cell)
end
local function bounds()
    local area=GetWorldBounds()
    local result={GetRectMinX(area),GetRectMinY(area),GetRectMaxX(area),GetRectMaxY(area)}
    RemoveRect(area);return result
end
local function restoreReleased(scope,entries)
    local function apply(final)
        for _,entry in ipairs(entries) do
            local cell=entry.cell;local id=key(cell.x,cell.y)
            if fullRestoreAllowed(entry) then
                restore(cell)
                if final then cells[id]=nil end
            elseif blightRestoreAllowed(entry) then
                -- Human (etc.) buildings keep a baseline lease, but do not
                -- justify retaining the departed Undead scene's late blight.
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
    if scope.terrainState then scope.terrainState.owners[owner]=true end
end
