-- Development-only physical footprint diagnostic. Unlike targeted movement,
-- each mover receives one point order through the stationary target. All
-- movement variables are normalized and the test is repeated at four small
-- world-grid phases so grid anchoring can be distinguished from unit geometry.
JTG = JTG or {}

local PLAYER = Player(0)
local TARGET_PLAYER = Player(1)
local EXPORT_FILE = "JamiesTrainingGrounds-collision-footprints.txt"
local EXPORT_PATH = "Documents\\Warcraft III\\CustomMapData\\" .. EXPORT_FILE
local CENTER_X = 4864.0
local CENTER_Y = 6016.0
local SAMPLE_PERIOD = 0.01
local MAX_CASE_DURATION = 3.0
local PASS_DISTANCE = 160.0
local START_CLEARANCE = 260.0
local THROUGH_DISTANCE = 700.0
local NORMALIZED_SPEED = 300.0

local SIZES = {
    {label = "16", rawcode = "hpea", name = "Peasant"},
    {label = "31", rawcode = "hfoo", name = "Footman"},
    {label = "32", rawcode = "ogru", name = "Grunt"},
    {label = "48", rawcode = "uabo", name = "Abomination"},
}

local DIRECTIONS = {
    {id = "east", x = 1.0, y = 0.0},
    {id = "north", x = 0.0, y = 1.0},
    {id = "west", x = -1.0, y = 0.0},
    {id = "south", x = 0.0, y = -1.0},
}

-- Moving the complete setup together reveals whether collision is anchored to
-- an unseen world grid. Diagonal phase shifts exercise both axes equally.
local PHASES = {
    {id = "0", offset = 0.0},
    {id = "4", offset = 4.0},
    {id = "8", offset = 8.0},
    {id = "12", offset = 12.0},
}

local TOTAL_CASES = #SIZES * #SIZES * #DIRECTIONS * #PHASES

local function Remove(unit)
    if unit ~= nil and GetUnitTypeId(unit) ~= 0 then RemoveUnit(unit) end
end

local function Export(results)
    local rows = {
        "Jamie's Training Grounds collision-footprint diagnostic",
        "cases=" .. tostring(#results),
        "mover_size,target_size,direction,phase,mover_collision,target_collision," ..
            "min_square,square_x,square_y,min_distance,distance_x,distance_y," ..
            "first_deflection_x,first_deflection_y,duration,final_order",
    }
    for _, result in ipairs(results) do
        rows[#rows + 1] = string.format(
            "%s,%s,%s,%s,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f," ..
                "%.3f,%.3f,%.3f,%d",
            result.moverSize, result.targetSize, result.direction, result.phase,
            result.moverCollision, result.targetCollision,
            result.minSquare, result.squareX, result.squareY,
            result.minDistance, result.distanceX, result.distanceY,
            result.deflectionX, result.deflectionY, result.duration,
            result.finalOrder)
    end
    if GetLocalPlayer() == PLAYER then
        PreloadGenClear()
        PreloadGenStart()
        for _, row in ipairs(rows) do
            Preload("\")\n" .. row .. "\n//")
        end
        PreloadGenEnd(EXPORT_FILE)
    end
end

local function CreateActivity(session)
    local activity = {
        results = {}, moverIndex = 1, targetIndex = 1,
        directionIndex = 1, phaseIndex = 1, complete = false,
    }

    function activity:updateStatus()
        if self.statusFrame == nil then return end
        if self.complete then
            BlzFrameSetText(self.statusFrame,
                "|cff80ff80FOOTPRINT TEST COMPLETE|r|n" ..
                tostring(#self.results) .. " / " .. tostring(TOTAL_CASES) ..
                " cases exported|n" .. EXPORT_PATH)
            return
        end
        local mover, target = SIZES[self.moverIndex], SIZES[self.targetIndex]
        local direction, phase = DIRECTIONS[self.directionIndex], PHASES[self.phaseIndex]
        BlzFrameSetText(self.statusFrame,
            "|cffffcc00PHYSICAL FOOTPRINT TEST|r|n" ..
            tostring(#self.results + 1) .. " / " .. tostring(TOTAL_CASES) ..
            "|n" .. mover.label .. " " .. mover.name .. " into " ..
            target.label .. " " .. target.name .. "|n" ..
            direction.id .. " / grid phase " .. phase.id)
    end

    function activity:removePair()
        Remove(self.mover)
        Remove(self.target)
        self.mover, self.target = nil, nil
    end

    function activity:advanceIndices()
        self.phaseIndex = self.phaseIndex + 1
        if self.phaseIndex <= #PHASES then return true end
        self.phaseIndex = 1
        self.directionIndex = self.directionIndex + 1
        if self.directionIndex <= #DIRECTIONS then return true end
        self.directionIndex = 1
        self.targetIndex = self.targetIndex + 1
        if self.targetIndex <= #SIZES then return true end
        self.targetIndex = 1
        self.moverIndex = self.moverIndex + 1
        return self.moverIndex <= #SIZES
    end

    function activity:startCase()
        local moverSpec, targetSpec = SIZES[self.moverIndex], SIZES[self.targetIndex]
        local direction, phase = DIRECTIONS[self.directionIndex], PHASES[self.phaseIndex]
        local moverId, targetId = FourCC(moverSpec.rawcode), FourCC(targetSpec.rawcode)
        local targetX, targetY = CENTER_X + phase.offset, CENTER_Y + phase.offset

        self.target = BlzCreateUnitWithSkin(TARGET_PLAYER, targetId,
            targetX, targetY, 0.0, targetId)
        SetUnitAcquireRange(self.target, 0.0)
        SetUnitInvulnerable(self.target, true)
        PauseUnit(self.target, true)
        SetUnitVertexColor(self.target, 255, 255, 255, 0)

        local probe = BlzCreateUnitWithSkin(PLAYER, moverId,
            targetX, targetY, 0.0, moverId)
        local moverCollision = BlzGetUnitCollisionSize(probe)
        RemoveUnit(probe)
        self.targetCollision = BlzGetUnitCollisionSize(self.target)
        self.mover = BlzCreateUnitWithSkin(PLAYER, moverId,
            targetX + direction.x * (moverCollision + self.targetCollision + START_CLEARANCE),
            targetY + direction.y * (moverCollision + self.targetCollision + START_CLEARANCE),
            0.0, moverId)
        SetUnitFacing(self.mover,
            math.atan(-direction.y, -direction.x) * 180.0 / math.pi)
        SetUnitTurnSpeed(self.mover, 1.0)
        SetUnitMoveSpeed(self.mover, NORMALIZED_SPEED)
        SetUnitAcquireRange(self.mover, 0.0)
        SetUnitInvulnerable(self.mover, true)
        SetUnitVertexColor(self.mover, 255, 255, 255, 0)

        self.moverCollision = BlzGetUnitCollisionSize(self.mover)
        self.targetX, self.targetY = targetX, targetY
        self.elapsed = 0.0
        self.minSquare, self.minDistance = 1000000.0, 1000000.0
        self.squareX, self.squareY = 0.0, 0.0
        self.distanceX, self.distanceY = 0.0, 0.0
        self.deflectionX, self.deflectionY = 0.0, 0.0
        self.deflectionRecorded = false
        self.previousX = GetUnitX(self.mover) - targetX
        self.previousY = GetUnitY(self.mover) - targetY

        IssuePointOrder(self.mover, "move",
            targetX - direction.x * THROUGH_DISTANCE,
            targetY - direction.y * THROUGH_DISTANCE)
        self:updateStatus()
    end

    function activity:finishCase()
        self.results[#self.results + 1] = {
            moverSize = SIZES[self.moverIndex].label,
            targetSize = SIZES[self.targetIndex].label,
            direction = DIRECTIONS[self.directionIndex].id,
            phase = PHASES[self.phaseIndex].id,
            moverCollision = self.moverCollision,
            targetCollision = self.targetCollision,
            minSquare = self.minSquare, squareX = self.squareX, squareY = self.squareY,
            minDistance = self.minDistance,
            distanceX = self.distanceX, distanceY = self.distanceY,
            deflectionX = self.deflectionX, deflectionY = self.deflectionY,
            duration = self.elapsed, finalOrder = GetUnitCurrentOrder(self.mover),
        }
        self:removePair()
        if not self:advanceIndices() then
            self.complete = true
            Export(self.results)
            self:updateStatus()
            DisplayTimedTextToPlayer(PLAYER, 0, 0, 30,
                "|cff80ff80Physical footprint test complete.|r\nReport: " .. EXPORT_PATH)
            return
        end
        self:startCase()
    end

    function activity:update()
        if self.complete or self.mover == nil or self.target == nil then return end
        local direction = DIRECTIONS[self.directionIndex]
        local rx = GetUnitX(self.mover) - GetUnitX(self.target)
        local ry = GetUnitY(self.mover) - GetUnitY(self.target)
        local square = math.max(math.abs(rx), math.abs(ry))
        local distance = math.sqrt(rx * rx + ry * ry)
        if square < self.minSquare then
            self.minSquare, self.squareX, self.squareY = square, rx, ry
        end
        if distance < self.minDistance then
            self.minDistance, self.distanceX, self.distanceY = distance, rx, ry
        end

        local lateral = math.abs(-direction.y * rx + direction.x * ry)
        if not self.deflectionRecorded and lateral >= 1.0 then
            self.deflectionRecorded = true
            self.deflectionX, self.deflectionY = self.previousX, self.previousY
        end
        self.previousX, self.previousY = rx, ry
        self.elapsed = self.elapsed + SAMPLE_PERIOD
        local progress = rx * direction.x + ry * direction.y
        if progress < -PASS_DISTANCE or self.elapsed >= MAX_CASE_DURATION then
            self:finishCase()
        end
    end

    function activity:setup(current)
        local oldForward = GetPlayerAlliance(PLAYER, TARGET_PLAYER, ALLIANCE_PASSIVE)
        local oldBackward = GetPlayerAlliance(TARGET_PLAYER, PLAYER, ALLIANCE_PASSIVE)
        JTG.ScopeBorrow(current.scope, function()
            SetPlayerAlliance(PLAYER, TARGET_PLAYER, ALLIANCE_PASSIVE, oldForward)
            SetPlayerAlliance(TARGET_PLAYER, PLAYER, ALLIANCE_PASSIVE, oldBackward)
            self:removePair()
        end)
        SetPlayerAlliance(PLAYER, TARGET_PLAYER, ALLIANCE_PASSIVE, true)
        SetPlayerAlliance(TARGET_PLAYER, PLAYER, ALLIANCE_PASSIVE, true)
        JTG.ResetWorldFog(PLAYER)
        JTG.ScopeRevealScene(current.scope, current.scene, PLAYER)

        local gameUI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        self.statusFrame = JTG.ScopeTrackFrame(current.presentationScope,
            BlzCreateFrameByType("TEXT", "JTGCollisionFootprintStatus", gameUI, "", 0))
        BlzFrameSetSize(self.statusFrame, 0.34, 0.14)
        BlzFrameSetAbsPoint(self.statusFrame, FRAMEPOINT_TOP, 0.40, 0.52)
        BlzFrameSetTextAlignment(self.statusFrame,
            TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_CENTER)
        BlzFrameSetScale(self.statusFrame, 1.35)
        BlzFrameSetEnable(self.statusFrame, false)
        self:startCase()
        self.timer = JTG.StartScopedTimer(current, current.scope,
            SAMPLE_PERIOD, true, function() self:update() end)
    end

    function activity:start()
        if GetLocalPlayer() == PLAYER then SetCameraPosition(CENTER_X, CENTER_Y) end
    end

    function activity:cleanup()
        self:removePair()
    end

    return activity
end

JTG.RegisterActivity({
    id = "dev.collision_footprints", category = "tools",
    title = "Physical Footprint Test",
    description = "Measure physical obstruction and possible grid offsets.",
    status = "available", hidden = true, sceneId = "arena.north",
    capabilities = {menu = false, pause = false, quests = false},
    factory = CreateActivity,
})

local function InitializeCollisionFootprintDiagnostic()
    local trigger = CreateTrigger()
    TriggerRegisterPlayerChatEvent(trigger, PLAYER,
        "-diag-collision-footprints", true)
    TriggerAddAction(trigger, function()
        JTG.StartActivity("dev.collision_footprints", "tools")
    end)
    JTG.Dev = JTG.Dev or {}
    JTG.Dev.collisionFootprintTrigger = trigger
end

JTG.RegisterBootstrapInitializer(InitializeCollisionFootprintDiagnostic)
