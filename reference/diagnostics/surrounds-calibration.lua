-- Archived automated square-display calibration used during v0.0.11 research.
JTG = JTG or {}

local Calibration = {}
JTG.SurroundCalibration = Calibration

local EXPORT_FILE = "JamiesTrainingGrounds-square-calibration.txt"
local EXPORT_PATH =
    "Documents\\Warcraft III\\CustomMapData\\" .. EXPORT_FILE

-- Standard melee ground rosters and racial heroes. Flying units and flying
-- forms are excluded; Neutral contains the tavern heroes.
local UNITS = {
    {"human", "hpea", "Peasant"}, {"human", "hmil", "Militia"},
    {"human", "hfoo", "Footman"}, {"human", "hrif", "Rifleman"},
    {"human", "hkni", "Knight"}, {"human", "hmpr", "Priest"},
    {"human", "hsor", "Sorceress"}, {"human", "hspt", "Spell Breaker"},
    {"human", "hmtm", "Mortar Team"}, {"human", "hmtt", "Siege Engine"},
    {"human", "Hpal", "Paladin"}, {"human", "Hamg", "Archmage"},
    {"human", "Hmkg", "Mountain King"}, {"human", "Hblm", "Blood Mage"},
    {"orc", "opeo", "Peon"}, {"orc", "ogru", "Grunt"},
    {"orc", "ohun", "Headhunter"}, {"orc", "otbk", "Berserker"},
    {"orc", "ocat", "Demolisher"}, {"orc", "orai", "Raider"},
    {"orc", "okod", "Kodo Beast"}, {"orc", "oshm", "Shaman"},
    {"orc", "odoc", "Witch Doctor"}, {"orc", "ospw", "Spirit Walker"},
    {"orc", "otau", "Tauren"}, {"orc", "Obla", "Blademaster"},
    {"orc", "Ofar", "Far Seer"}, {"orc", "Otch", "Tauren Chieftain"},
    {"orc", "Oshd", "Shadow Hunter"},
    {"undead", "uaco", "Acolyte"}, {"undead", "ugho", "Ghoul"},
    {"undead", "ucry", "Crypt Fiend"},
    {"undead", "uabo", "Abomination"},
    {"undead", "umtw", "Meat Wagon"},
    {"undead", "unec", "Necromancer"}, {"undead", "uban", "Banshee"},
    {"undead", "ushd", "Shade"},
    {"undead", "uobs", "Obsidian Statue"},
    {"undead", "Udea", "Death Knight"}, {"undead", "Udre", "Dreadlord"},
    {"undead", "Ulic", "Lich"}, {"undead", "Ucrl", "Crypt Lord"},
    {"nightelf", "ewsp", "Wisp"}, {"nightelf", "earc", "Archer"},
    {"nightelf", "esen", "Huntress"},
    {"nightelf", "ebal", "Glaive Thrower"},
    {"nightelf", "edry", "Dryad"},
    {"nightelf", "edoc", "Druid of the Claw"},
    {"nightelf", "edot", "Druid of the Talon"},
    {"nightelf", "emtg", "Mountain Giant"},
    {"nightelf", "Edem", "Demon Hunter"},
    {"nightelf", "Ekee", "Keeper of the Grove"},
    {"nightelf", "Emoo", "Priestess of the Moon"},
    {"nightelf", "Ewar", "Warden"},
    {"neutral", "Nngs", "Naga Sea Witch"},
    {"neutral", "Nbrn", "Dark Ranger"},
    {"neutral", "Npbm", "Pandaren Brewmaster"},
    {"neutral", "Nbst", "Beastmaster"}, {"neutral", "Nplh", "Pit Lord"},
    {"neutral", "Nfir", "Firelord"}, {"neutral", "Ntin", "Goblin Tinker"},
    {"neutral", "Nalc", "Goblin Alchemist"},
    {"neutral", "Npal", "Forsaken Paladin"},
}

local function Percentile(values, fraction)
    if #values == 0 then return nil end
    local sorted = {}
    for index, value in ipairs(values) do sorted[index] = value end
    table.sort(sorted)
    local position = 1 + (#sorted - 1) * fraction
    local lower = math.floor(position)
    local upper = math.ceil(position)
    if lower == upper then return sorted[lower] end
    local weight = position - lower
    return sorted[lower] * (1 - weight) + sorted[upper] * weight
end

local function CollisionStep(collision)
    return math.floor(collision / 16.0) * 16.0
end

function Calibration.DisplayHalfSize(collision)
    return CollisionStep(collision) + 12.0
end

local function Remove(unit)
    if unit ~= nil and GetUnitTypeId(unit) ~= 0 then RemoveUnit(unit) end
end

local function Track(activity, unit)
    JTG.ScopeAdd(activity.calibrationSession.scope, function() Remove(unit) end)
    return unit
end

local Finish
local StartPass

local function Export(activity)
    local paddings = {}
    for _, result in ipairs(activity.calibrationResults) do
        table.insert(paddings, result.padding)
    end
    local median = Percentile(paddings, 0.5) or 0
    local low = Percentile(paddings, 0.1) or 0
    local high = Percentile(paddings, 0.9) or 0
    local rows = {
        "Jamie's Training Grounds square display calibration",
        string.format("unit_types=%d measurements=%d", #paddings,
            #paddings * 2),
        string.format("recommended_half_width_padding=%.3f", median),
        string.format("middle_80_percent=%.3f,%.3f", low, high),
        "formula=displayed side = 2 * (floor(collision size / 16) * 16 + padding)",
        "race,rawcode,name,collision_size,collision_step,NE_min_Q,SW_min_Q,effective_half_width,padding",
    }
    for _, result in ipairs(activity.calibrationResults) do
        table.insert(rows, string.format(
            "%s,%s,%s,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f",
            result.race, result.rawcode, result.name,
            result.collision, result.collisionStep, result.ne, result.sw,
            result.effectiveHalf, result.padding))
    end
    if GetLocalPlayer() == Player(0) then
        PreloadGenClear()
        PreloadGenStart()
        for _, row in ipairs(rows) do
            Preload("\")\n" .. row .. "\n//")
        end
        PreloadGenEnd(EXPORT_FILE)
    end
end

local function Advance(activity)
    activity.calibrationIndex = activity.calibrationIndex + 1
    if activity.calibrationIndex > #UNITS then
        Finish(activity)
        return
    end
    activity.calibrationPassValues = {}
    activity.calibrationTarget = nil
    StartPass(activity, 1)
end

local function CompletePass(activity)
    local value = activity.calibrationMinSquare or 0
    table.insert(activity.calibrationPassValues, value)
    Remove(activity.calibrationMover)
    activity.calibrationMover = nil
    if activity.calibrationPass < 2 then
        StartPass(activity, activity.calibrationPass + 1)
        return
    end
    local spec = UNITS[activity.calibrationIndex]
    local effectiveHalf = (activity.calibrationPassValues[1] +
        activity.calibrationPassValues[2]) * 0.25
    local collisionStep = CollisionStep(activity.calibrationCollision)
    table.insert(activity.calibrationResults, {
        race = spec[1], rawcode = spec[2], name = spec[3],
        collision = activity.calibrationCollision,
        collisionStep = collisionStep,
        ne = activity.calibrationPassValues[1],
        sw = activity.calibrationPassValues[2],
        effectiveHalf = effectiveHalf,
        padding = effectiveHalf - collisionStep,
    })
    Remove(activity.calibrationTarget)
    activity.calibrationTarget = nil
    Advance(activity)
end

StartPass = function(activity, pass)
    activity.calibrationPass = pass
    local spec = UNITS[activity.calibrationIndex]
    if spec == nil then
        Finish(activity)
        return
    end
    local diagonal = 1.0 / math.sqrt(2.0)
    local directions = {
        {x = diagonal, y = diagonal, name = "NE"},
        {x = -diagonal, y = -diagonal, name = "SW"},
    }
    local direction = directions[pass]
    local unitId = FourCC(spec[2])
    local targetX = (activity.startX + activity.finishX) * 0.5
    local targetY = activity.laneY
    if activity.calibrationTarget == nil then
        activity.calibrationTarget = Track(activity,
            BlzCreateUnitWithSkin(Player(1), unitId,
                targetX, targetY, 0, unitId))
        SetUnitAcquireRange(activity.calibrationTarget, 0)
        SetUnitInvulnerable(activity.calibrationTarget, true)
        PauseUnit(activity.calibrationTarget, true)
        activity.calibrationCollision = BlzGetUnitCollisionSize(
            activity.calibrationTarget)
    end
    local contact = activity.calibrationCollision * 2.0
    local startDistance = contact + 180
    activity.calibrationMover = Track(activity,
        BlzCreateUnitWithSkin(Player(0), unitId,
            targetX + direction.x * startDistance,
            targetY + direction.y * startDistance, 0, unitId))
    SetUnitFacing(activity.calibrationMover,
        math.atan(-direction.y, -direction.x) * 180.0 / math.pi)
    SetUnitAcquireRange(activity.calibrationMover, 0)
    SetUnitInvulnerable(activity.calibrationMover, true)
    SetUnitMoveSpeed(activity.calibrationMover, 522)
    activity.calibrationDirection = direction
    activity.calibrationElapsed = 0
    activity.calibrationMinSquare = nil
    IssuePointOrder(activity.calibrationMover, "move",
        targetX - direction.x * 700, targetY - direction.y * 700)
    activity:updateStatus()
end

Finish = function(activity)
    if activity.calibrationComplete then return end
    activity.calibrationComplete = true
    Remove(activity.calibrationMover)
    Remove(activity.calibrationTarget)
    activity.calibrationMover = nil
    activity.calibrationTarget = nil
    Export(activity)
    activity:updateStatus()
    DisplayTimedTextToPlayer(Player(0), 0, 0, 30,
        "|cff80ff80Square calibration complete.|r\n" ..
        "Report: " .. EXPORT_PATH)
end

function Calibration.Start(activity, session)
    activity.calibrationSession = session
    activity.calibrationResults = {}
    activity.calibrationIndex = 0
    activity.calibrationComplete = false
    Advance(activity)
end

function Calibration.UnitCount()
    return #UNITS
end

function Calibration.Update(activity)
    local mover, target = activity.calibrationMover,
        activity.calibrationTarget
    if mover == nil or target == nil or activity.calibrationComplete then return end
    local rx = GetUnitX(mover) - GetUnitX(target)
    local ry = GetUnitY(mover) - GetUnitY(target)
    local squareDistance = math.max(math.abs(rx), math.abs(ry))
    activity.calibrationMinSquare = math.min(
        activity.calibrationMinSquare or squareDistance, squareDistance)
    activity.calibrationElapsed = activity.calibrationElapsed +
        (activity.updatePeriod or 0.01)
    local direction = activity.calibrationDirection
    local passedTarget = rx * direction.x + ry * direction.y < -150
    if passedTarget or activity.calibrationElapsed >= 4.0 then
        CompletePass(activity)
    end
end

function Calibration.StatusLines(activity)
    local current = UNITS[activity.calibrationIndex]
    local name = current and current[3] or "Complete"
    local paddings = {}
    for _, result in ipairs(activity.calibrationResults) do
        table.insert(paddings, result.padding)
    end
    local median = Percentile(paddings, 0.5)
    local low = Percentile(paddings, 0.1)
    local high = Percentile(paddings, 0.9)
    local lines = {
        "|cffffcc00SQUARE DISPLAY CALIBRATION|r",
        string.format("Unit %d / %d: %s   Pass %d / 2",
            math.min(activity.calibrationIndex, #UNITS),
            #UNITS, name, activity.calibrationPass),
        string.format("Completed unit types: %d   Measurements: %d",
            #activity.calibrationResults,
            #activity.calibrationResults * 2),
    }
    if median ~= nil then
        table.insert(lines, string.format(
            "Current recommendation: add %.1f to every half-width", median))
        table.insert(lines, string.format(
            "Middle 80%% of unit results: %+.1f to %+.1f", low, high))
        table.insert(lines,
            "Displayed side = 2 x (collision step + recommendation)")
    end
    if activity.calibrationComplete then
        table.insert(lines, "|cff80ff80REPORT EXPORTED|r")
        table.insert(lines, EXPORT_PATH)
    end
    return lines
end
