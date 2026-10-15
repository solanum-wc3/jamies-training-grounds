-- Native-mock orchestration: a delayed foundation must hold all ten lanes.
-- Construction/pathing speed remains a Warcraft acceptance check.
JTG = {UI={}}
function JTG.UI.ShowToolbar() end
function FourCC(raw) return raw end
function Player(index) return index end
UNIT_STATE_LIFE, UNIT_STATE_MAX_LIFE = 'life', 'maxLife'
PLAYER_STATE_RESOURCE_GOLD, PLAYER_STATE_RESOURCE_LUMBER = 'gold', 'lumber'
local world, tags, resources, repairs = {}, {}, {}, {}
local scope = {units={}, tags={}}
function JTG.ScopeTrackUnit(s, unit) s.units[#s.units+1]=unit; return unit end
function JTG.CreateScopedUnit(scope,...) return JTG.ScopeTrackUnit(scope,CreateUnit(...)) end
function JTG.ScopeTrackTextTag(s, tag) s.tags[#s.tags+1]=tag; return tag end
function CreateUnit(owner, raw, x, y)
    local unit = {owner=owner, raw=raw, x=x, y=y, life=1, maxLife=100}
    world[#world+1]=unit; return unit
end
function SetUnitInvulnerable(unit, value) unit.invulnerable=value end
function ShowUnit(unit, value) unit.visible=value end
function PauseUnit(unit, value) unit.paused=value end
function GetUnitX(unit) return unit.x end
function GetUnitY(unit) return unit.y end
function GetOwningPlayer(unit) return unit.owner end
function GetUnitTypeId(unit) return unit.raw end
function GetUnitState(unit, key) return unit[key] end
function GetPlayerState(owner, key) return resources[owner][key] end
function ClearSelection() end
function CreateTextTag() local tag={};tags[#tags+1]=tag;return tag end
function SetTextTagPermanent(tag, value) tag.permanent=value end
function SetTextTagVisibility(tag, value) tag.visible=value end
function SetTextTagPos(tag, x, y) tag.x=x;tag.y=y end
function SetTextTagText(tag, value) tag.text=value end
function DestroyTextTag(tag) tag.destroyed=true end
function IssueBuildOrderById(worker, raw, x, y)
    worker.build = {raw=raw,x=x,y=y}
    return true -- Native acceptance does not imply that a foundation exists yet.
end
function IssueTargetOrder(worker, order, target)
    assert(not worker.paused and not target.paused, 'Repair began before release')
    repairs[#repairs+1]={worker=worker,order=order,target=target};return true
end
function UnitSetConstructionProgress(unit, value) unit.progress=value end
function CreateGroup() return {} end
function GroupEnumUnitsInRange(group, x, y, radius)
    for _, unit in ipairs(world) do
        if (unit.x-x)^2+(unit.y-y)^2 <= radius^2 then group[#group+1]=unit end
    end
end
function FirstOfGroup(group) return group[1] end
function GroupRemoveUnit(group, unit)
    for index, candidate in ipairs(group) do
        if candidate == unit then table.remove(group,index);return end
    end
end
function DestroyGroup() end
dofile('src/activities/power-building.lua')

for _, raw in ipairs({'htow','hbla','hgra'}) do
    world, tags, repairs = {}, {}, {}
    scope = {units={},tags={}}
    for owner=1,10 do resources[owner]={gold=1000,lumber=1000} end
    local run = JTG.CreatePowerBuildingActivity({scope=scope, presentationScope=scope,
        descriptor={capabilities={}},
        scene={centerX=0,centerY=0,minX=-4000,minY=-3000},
        restartData={buildingId=raw,prerequisites={'hcas','hlum'}}})
    run:createScenario()
    assert(#run.workers==10 and #world==30, 'Assistants spawned before foundations')
    for index,lane in ipairs(run.lanes) do
        assert(lane.x%64==0 and lane.y%64==0)
        assert(lane.workers[1].build.raw==raw)
        assert(#lane.workers==1 and not lane.ready)
    end
    local function foundation(index)
        local lane=run.lanes[index]
        return CreateUnit(lane.owner,raw,lane.x,lane.y)
    end
    -- A wrong owner and wrong building must never satisfy a lane.
    local lane=run.lanes[10]
    CreateUnit(99,raw,lane.x,lane.y)
    CreateUnit(lane.owner,'hfoo',lane.x,lane.y)
    for index=1,9 do foundation(index) end
    run:setPaused(true);run:captureTick()
    assert(run.readyCount==0 and run.captureElapsed==0)
    run:setPaused(false);run:captureTick()
    assert(run.readyCount==9 and not run.released and #repairs==0)
    for index=1,9 do
        local ready=run.lanes[index]
        assert(ready.building.progress==1 and ready.building.paused)
        assert(#ready.workers==index)
        for _,worker in ipairs(ready.workers) do assert(worker.paused) end
    end
    foundation(10);run:captureTick()
    assert(run.released and run.readyCount==10 and #run.workers==55 and #repairs==55)
    for _,repair in ipairs(repairs) do
        assert(repair.order=='repair' and repair.worker.owner==repair.target.owner)
    end
    run:captureTick();assert(#run.workers==55 and #repairs==55, 'Comparison released twice')
    run:setPaused(true);run:updateTick();assert(run.elapsed==0)
    run:setPaused(false)
    run.lanes[1].building.life=100;run:updateTick()
    assert(run.completeCount==1 and run.lanes[1].completionTime==0.1)
    for index=2,10 do run.lanes[index].building.life=100 end
    run:updateTick();assert(run.completeCount==10 and run.lanes[10].completionTime==0.2)
    run:updateTick();assert(run.elapsed==0.2, 'Completed comparison clock advanced')

    local unitCount, repairCount = #world, #repairs
    local oldTags={table.unpack(tags)}
    run:hidePresentationForMenu()
    for _,tag in ipairs(tags) do assert(not tag.visible) end
    run:restorePresentation()
    for _,tag in ipairs(tags) do assert(tag.visible) end
    run:discardPresentationForLoad()
    for _,tag in ipairs(oldTags) do assert(tag.destroyed) end
    run:rebuildPresentation()
    assert(#world==unitCount and #repairs==repairCount, 'Presentation rebuild restarted construction')
    assert(run.completeCount==10 and run.lanes[1].completionTime==0.1)
end
print('Passed: Power Building staggered capture, synchronized repair, pause/completion and presentation-only rebuild.')
