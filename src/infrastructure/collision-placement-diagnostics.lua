-- Development-only placement probe. It asks Warcraft to place a mover at
-- exact coordinates around a stationary target and records which requested
-- positions are accepted. This removes movement orders and route selection
-- from the collision-footprint measurement.
JTG = JTG or {}

local PLAYER = Player(0)
local TARGET_PLAYER = Player(1)
local EXPORT_FILE = "JamiesTrainingGrounds-collision-placement.txt"
local EXPORT_PATH = "Documents\\Warcraft III\\CustomMapData\\" .. EXPORT_FILE
local CENTER_X = 4864.0
local CENTER_Y = 6016.0
local MAX_DISTANCE = 180
local ACCEPT_EPSILON = 0.25
local STAGING_DISTANCE = 500.0

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

local PHASES = {
    {id = "0", offset = 0.0},
    {id = "4", offset = 4.0},
    {id = "8", offset = 8.0},
    {id = "12", offset = 12.0},
    {id = "16", offset = 16.0},
    {id = "20", offset = 20.0},
    {id = "24", offset = 24.0},
    {id = "28", offset = 28.0},
    {id = "32", offset = 32.0},
    {id = "36", offset = 36.0},
}

local TOTAL_CASES = #SIZES * #SIZES * #DIRECTIONS * #PHASES

local function Remove(unit)
    if unit ~= nil and GetUnitTypeId(unit) ~= 0 then RemoveUnit(unit) end
end

local function Export(results)
    local rows = {
        "Jamie's Training Grounds collision-placement diagnostic",
        "cases=" .. tostring(#results),
        "mover_size,target_size,direction,phase,mover_collision,target_collision," ..
            "first_accepted,accepted_x,accepted_y,last_rejected," ..
            "rejected_x,rejected_y,rejected_error,origin_x,origin_y," ..
            "origin_error,accepted_count,acceptance_mask",
    }
    for _, result in ipairs(results) do
        rows[#rows + 1] = string.format(
            "%s,%s,%s,%s,%.3f,%.3f,%d,%.3f,%.3f,%d,%.3f,%.3f,%.3f," ..
                "%.3f,%.3f,%.3f,%d,%s",
            result.moverSize, result.targetSize, result.direction, result.phase,
            result.moverCollision, result.targetCollision,
            result.firstAccepted, result.acceptedX, result.acceptedY,
            result.lastRejected, result.rejectedX, result.rejectedY,
            result.rejectedError, result.originX, result.originY,
            result.originError, result.acceptedCount, result.mask)
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
                "|cff80ff80PLACEMENT TEST COMPLETE|r|n" ..
                tostring(#self.results) .. " / " .. tostring(TOTAL_CASES) ..
                " cases exported|n" .. EXPORT_PATH)
            return
        end
        local mover, target = SIZES[self.moverIndex], SIZES[self.targetIndex]
        local direction, phase = DIRECTIONS[self.directionIndex], PHASES[self.phaseIndex]
        BlzFrameSetText(self.statusFrame,
            "|cffffcc00COLLISION PLACEMENT TEST|r|n" ..
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

    function activity:runCase()
        if self.complete then return end
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
        self.mover = BlzCreateUnitWithSkin(PLAYER, moverId,
            targetX + STAGING_DISTANCE, targetY + STAGING_DISTANCE, 0.0, moverId)
        SetUnitAcquireRange(self.mover, 0.0)
        SetUnitInvulnerable(self.mover, true)
        PauseUnit(self.mover, true)
        SetUnitVertexColor(self.mover, 255, 255, 255, 0)

        local firstAccepted = MAX_DISTANCE + 1
        local acceptedX, acceptedY = 0.0, 0.0
        local lastRejected = -1
        local rejectedX, rejectedY, rejectedError = 0.0, 0.0, 0.0
        local originX, originY, originError = 0.0, 0.0, 0.0
        local acceptedCount, mask = 0, {}
        for distance = 0, MAX_DISTANCE do
            SetUnitPosition(self.mover,
                targetX + STAGING_DISTANCE, targetY + STAGING_DISTANCE)
            local requestedX = targetX + direction.x * distance
            local requestedY = targetY + direction.y * distance
            SetUnitPosition(self.mover, requestedX, requestedY)
            local rx = GetUnitX(self.mover) - targetX
            local ry = GetUnitY(self.mover) - targetY
            local error = math.sqrt(
                (GetUnitX(self.mover) - requestedX) ^ 2 +
                (GetUnitY(self.mover) - requestedY) ^ 2)
            local accepted = error <= ACCEPT_EPSILON
            mask[#mask + 1] = accepted and "1" or "0"
            if accepted then
                acceptedCount = acceptedCount + 1
                if firstAccepted > MAX_DISTANCE then
                    firstAccepted, acceptedX, acceptedY = distance, rx, ry
                end
            else
                lastRejected = distance
                rejectedX, rejectedY, rejectedError = rx, ry, error
            end
            if distance == 0 then
                originX, originY, originError = rx, ry, error
            end
        end

        self.results[#self.results + 1] = {
            moverSize = moverSpec.label, targetSize = targetSpec.label,
            direction = direction.id, phase = phase.id,
            moverCollision = BlzGetUnitCollisionSize(self.mover),
            targetCollision = BlzGetUnitCollisionSize(self.target),
            firstAccepted = firstAccepted, acceptedX = acceptedX, acceptedY = acceptedY,
            lastRejected = lastRejected, rejectedX = rejectedX,
            rejectedY = rejectedY, rejectedError = rejectedError,
            originX = originX, originY = originY, originError = originError,
            acceptedCount = acceptedCount, mask = table.concat(mask),
        }
        self:removePair()
        if not self:advanceIndices() then
            self.complete = true
            Export(self.results)
            self:updateStatus()
            DisplayTimedTextToPlayer(PLAYER, 0, 0, 30,
                "|cff80ff80Collision placement test complete.|r\nReport: " .. EXPORT_PATH)
            return
        end
        self:updateStatus()
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
            BlzCreateFrameByType("TEXT", "JTGCollisionPlacementStatus", gameUI, "", 0))
        BlzFrameSetSize(self.statusFrame, 0.34, 0.14)
        BlzFrameSetAbsPoint(self.statusFrame, FRAMEPOINT_TOP, 0.40, 0.52)
        BlzFrameSetTextAlignment(self.statusFrame,
            TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_CENTER)
        BlzFrameSetScale(self.statusFrame, 1.35)
        BlzFrameSetEnable(self.statusFrame, false)
        self:updateStatus()
        self.timer = JTG.StartScopedTimer(current, current.scope,
            0.03, true, function() self:runCase() end)
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
    id = "dev.collision_placement", category = "tools",
    title = "Collision Placement Test",
    description = "Probe collision-aware coordinate placement by size.",
    status = "available", hidden = true, sceneId = "arena.north",
    capabilities = {menu = false, pause = false, quests = false},
    factory = CreateActivity,
})

local function InitializeCollisionPlacementDiagnostic()
    local trigger = CreateTrigger()
    TriggerRegisterPlayerChatEvent(trigger, PLAYER,
        "-diag-collision-placement", true)
    TriggerAddAction(trigger, function()
        JTG.StartActivity("dev.collision_placement", "tools")
    end)
    JTG.Dev = JTG.Dev or {}
    JTG.Dev.collisionPlacementTrigger = trigger
end

JTG.RegisterBootstrapInitializer(InitializeCollisionPlacementDiagnostic)
