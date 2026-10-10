-- Run in a Lua runtime from the repository root. Native order routing is mocked;
-- this checks orchestration, not Warcraft III's dodge mechanics.
JTG = {}
dofile('src/infrastructure/training.lua')
UNIT_TYPE_DEAD = 'dead'
UNIT_STATE_MANA = 'mana'
function FourCC(value) return value end
function GetUnitTypeId(unit) return unit.removed and 0 or unit.id end
function IsUnitType(unit, kind) return kind == UNIT_TYPE_DEAD and unit.dead == true end
function GetUnitX(unit) return unit.x end
function GetUnitY(unit) return unit.y end
function BlzGetUnitMaxMana() return 100 end
function SetUnitState() end
function BlzEndUnitAbilityCooldown() end
function GetUnitAbilityLevel() return 0 end
local last, accept
function IssueTargetOrder(unit, order, target) last = {'target', order, target}; return accept end
function IssuePointOrder(unit, order, x, y) last = {'point', order, x, y}; return accept end
function IssueImmediateOrder(unit, order) last = {'immediate', order}; return accept end
function GetRandomReal(minimum, maximum) return (minimum + maximum) / 2 end
function BlzGetUnitAbilityCooldownRemaining() return 0 end
function BlzGetUnitAbility() return nil end
function GetRandomInt(minimum) return minimum end
dofile('src/generated/melee-tech.lua')
dofile('src/generated/dodge-catalog.lua')
dofile('src/activities/missile-dodging.lua')
dofile('src/activities/bat-splitting.lua')
assert(#JTG.DodgeDangers == 105 and #JTG.DodgePawns == 34)
for index, danger in ipairs(JTG.DodgeDangers) do
    local activity = JTG.CreateMissileDodgingActivity({restartData = {dangerIndex = index}})
    activity.caster = {id = danger.unit, x = 100, y = 34}
    activity.target = {id = 'pawn', x = 12, y = 34}
    local chainTarget={id='hfoo',x=12,y=154}
    if danger.ability=='AOcl' then activity.chainLightningTarget=function() return chainTarget end end
    accept = true
    activity:tryAttack()
    local expected = (danger.kind == 'point' or danger.groundAttack) and 'point' or
        danger.kind == 'immediate' and 'immediate' or 'target'
    assert(last[1] == expected, danger.name)
    if danger.ability=='AOcl' then assert(last[3]==chainTarget) end
    assert(last[2] == (danger.groundAttack and 'attackground' or danger.kind == 'attack' and 'attack' or danger.order), danger.name)
    assert(activity.attempts == 1 and activity.accepted == 1)
    accept = false
    activity.attempts = 0
    activity.devourRetryAt = nil
    activity:tryAttack()
    assert(activity.attempts == 0 and activity.accepted == 1)
    activity.target.removed = true
    activity:tryAttack()
    assert(activity.attempts == 0)
    activity.target.removed = false
    activity:confirmCast()
    assert(activity.castConfirmed and activity.resolveAfter >= 2)
end
local bat = JTG.CreateBatSplittingActivity({})
assert(#bat.plan.targets == 6)
assert(bat.plan.groups[1] + bat.plan.groups[2] == 6)
local replay = JTG.CreateBatSplittingActivity({restartData = bat:captureResetState()})
assert(replay.plan == bat.plan)
JTG.ResetActivity = function() end
bat.finished=true; bat:nextStage()
local nextBattle = JTG.CreateBatSplittingActivity({restartData = bat:captureResetState()})
assert(nextBattle.plan ~= bat.plan)
assert(nextBattle.count == 8 and #nextBattle.plan.targets == 8)
bat.gryphons = {{id = 'hgry'}, {id = 'hgry', dead = true}, {id = 'hgry', removed = true}}
assert(bat:survivors() == 1)
print('Passed: 105 order routes, attack-ground artillery, rejection/removal handling, stage replay/new plan, survivor counting.')
