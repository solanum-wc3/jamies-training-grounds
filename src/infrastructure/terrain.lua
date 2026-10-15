-- Temporary terrain belongs to the same scope as the buildings which affect
-- it. Shared cells retain their original state until their final user leaves.
JTG=JTG or {}
local cells={}
local STEP=128
local function key(x,y) return x..':'..y end
local function snapshot(x,y)
    return {x=x,y=y,blight=IsPointBlighted(x,y),terrain=GetTerrainType(x,y),
        variation=GetTerrainVariance(x,y),owners={},users=0}
end
local function restore(cell)
    -- Reapply the original tile/variation to refresh the terrain's grass too;
    -- do not flatten heights or replace the map's authored tiles with grass.
    SetTerrainType(cell.x,cell.y,cell.terrain,cell.variation,1,0)
    if not cell.blight then
        for owner in pairs(cell.owners) do SetBlightPoint(owner,cell.x,cell.y,false) end
    elseif not IsPointBlighted(cell.x,cell.y) then
        SetBlightPoint(next(cell.owners) or Player(PLAYER_NEUTRAL_PASSIVE),cell.x,cell.y,true)
    end
end
local function bounds()
    local area=GetWorldBounds()
    local result={GetRectMinX(area),GetRectMinY(area),GetRectMaxX(area),GetRectMaxY(area)}
    RemoveRect(area);return result
end
function JTG.ScopePreserveTerrain(scope,owner,x,y,radius)
    local state=scope.terrainState
    if not state then
        state={cells={},owners={}};scope.terrainState=state
        -- Registered before owned units: reverse disposal removes every source
        -- first, then restores terrain. Child scene scopes use the same rule.
        JTG.ScopeAdd(scope,function()
            for id,cell in pairs(state.cells) do
                for player in pairs(state.owners) do cell.owners[player]=true end
                cell.users=cell.users-1
                if cell.users==0 then restore(cell);cells[id]=nil end
            end
        end)
    end
    state.owners[owner]=true
    local region={};local world=bounds()
    for tx=math.max(world[1],math.floor((x-radius)/STEP)*STEP),math.min(world[3]-STEP,x+radius),STEP do
        for ty=math.max(world[2],math.floor((y-radius)/STEP)*STEP),math.min(world[4]-STEP,y+radius),STEP do
            local id=key(tx,ty);local cell=cells[id]
            if not cell then cell=snapshot(tx,ty);cells[id]=cell end
            cell.owners[owner]=true
            if not state.cells[id] then state.cells[id]=cell;cell.users=cell.users+1 end
            region[#region+1]=cell
        end
    end
    -- Explicit early clears (the hidden Hotkey Setup prerequisite hall) still
    -- restore the saved baseline, rather than erasing original map blight.
    return function() for _,cell in ipairs(region) do restore(cell) end end
end
function JTG.PreserveUnitTerrain(scope,owner,raw,x,y)
    if IsUnitIdType(raw,UNIT_TYPE_STRUCTURE) then
        JTG.ScopePreserveTerrain(scope,owner,x,y,1024)
    end
end
function JTG.RememberTerrainOwner(scope,owner)
    if scope.terrainState then scope.terrainState.owners[owner]=true end
end
