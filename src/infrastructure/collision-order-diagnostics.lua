-- Development-only movement-order diagnostic. It verifies whether direct
-- unit targeting reaches the same physical obstruction boundary as a move to
-- the target's coordinates or a move forced through the target.
JTG = JTG or {}

local PLAYER = Player(0)
local TARGET_PLAYER = Player(1)
local EXPORT_FILE = "JamiesTrainingGrounds-collision-orders.txt"
local EXPORT_PATH = "Documents\\Warcraft III\\CustomMapData\\" .. EXPORT_FILE
local CENTER_X = 4864.0
local CENTER_Y = 6016.0
local SAMPLE_PERIOD = 0.01
local ORDER_PERIOD = 0.10
local MIN_CASE_DURATION = 0.50
local STABLE_DURATION = 0.40
local MAX_CASE_DURATION = 2.50
local IMPROVEMENT_EPSILON = 0.01

local SIZES = {
    {label = "16", rawcode = "hpea", name = "Peasant"},
    {label = "31", rawcode = "hfoo", name = "Footman"},
    {label = "32", rawcode = "ogru", name = "Grunt"},
    {label = "48", rawcode = "uabo", name = "Abomination"},
}

local METHODS = {
    {id = "move_target", name = "targeted Move command"},
    {id = "smart_target", name = "right-click Smart command"},
    {id = "center", name = "target coordinates"},
    {id = "through", name = "forced through"},
}

local DIAGONAL = 1.0 / math.sqrt(2.0)
local DIRECTIONS = {
    {id = "east", x = 1.0, y = 0.0},
    {id = "northeast", x = DIAGONAL, y = DIAGONAL},
    {id = "north", x = 0.0, y = 1.0},
    {id = "northwest", x = -DIAGONAL, y = DIAGONAL},
    {id = "west", x = -1.0, y = 0.0},
    {id = "southwest", x = -DIAGONAL, y = -DIAGONAL},
    {id = "south", x = 0.0, y = -1.0},
    {id = "southeast", x = DIAGONAL, y = -DIAGONAL},
}

local TOTAL_CASES = #SIZES * #SIZES * #METHODS * #DIRECTIONS

local function Remove(unit)
    if unit ~= nil and GetUnitTypeId(unit) ~= 0 then RemoveUnit(unit) end
end

local function Export(results)
    local rows = {
        "Jamie's Training Grounds collision-order diagnostic",
        "cases=" .. tostring(#results),
        "mover_size,target_size,method,direction,mover_collision,target_collision,min_distance,min_abs_x,min_abs_y,min_square_distance,final_distance,final_abs_x,final_abs_y,final_square_distance,orders_issued,final_order",
    }
    for _, result in ipairs(results) do
        rows[#rows + 1] = string.format(
            "%s,%s,%s,%s,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%d,%d",
            result.moverSize, result.targetSize, result.method,
            result.direction, result.moverCollision, result.targetCollision,
            result.minDistance, result.minAbsX, result.minAbsY,
            result.minSquare, result.finalDistance, result.finalAbsX,
            result.finalAbsY, result.finalSquare, result.ordersIssued,
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
        methodIndex = 1, directionIndex = 1,
        elapsed = 0, complete = false,
    }

    function activity:updateStatus()
        if self.statusFrame == nil then return end
        if self.complete then
            BlzFrameSetText(self.statusFrame,
                "|cff80ff80COLLISION-ORDER TEST COMPLETE|r|n" ..
                tostring(#self.results) .. " / " .. tostring(TOTAL_CASES) ..
                " cases exported|n" ..
                EXPORT_PATH)
            return
        end
        local mover = SIZES[self.moverIndex]
        local target = SIZES[self.targetIndex]
        local method = METHODS[self.methodIndex]
        local direction = DIRECTIONS[self.directionIndex]
        BlzFrameSetText(self.statusFrame,
            "|cffffcc00COLLISION-ORDER TEST|r|n" ..
            tostring(#self.results + 1) .. " / " ..
            tostring(TOTAL_CASES) .. "|n" ..
            mover.label .. " " .. mover.name .. " into " ..
            target.label .. " " .. target.name .. "|n" ..
            method.name .. " / " .. direction.id)
    end

    function activity:removePair()
        Remove(self.mover)
        Remove(self.target)
        self.mover = nil
        self.target = nil
    end

    function activity:advanceIndices()
        self.directionIndex = self.directionIndex + 1
        if self.directionIndex <= #DIRECTIONS then return true end
        self.directionIndex = 1
        self.methodIndex = self.methodIndex + 1
        if self.methodIndex <= #METHODS then return true end
        self.methodIndex = 1
        self.targetIndex = self.targetIndex + 1
        if self.targetIndex <= #SIZES then return true end
        self.targetIndex = 1
        self.moverIndex = self.moverIndex + 1
        return self.moverIndex <= #SIZES
    end

    function activity:startCase()
        local moverSpec = SIZES[self.moverIndex]
        local targetSpec = SIZES[self.targetIndex]
        local method = METHODS[self.methodIndex]
        local direction = DIRECTIONS[self.directionIndex]
        local moverId = FourCC(moverSpec.rawcode)
        local targetId = FourCC(targetSpec.rawcode)

        self.target = BlzCreateUnitWithSkin(TARGET_PLAYER, targetId,
            CENTER_X, CENTER_Y, 0.0, targetId)
        SetUnitAcquireRange(self.target, 0.0)
        SetUnitInvulnerable(self.target, true)
        PauseUnit(self.target, true)
        SetUnitVertexColor(self.target, 255, 255, 255, 0)

        local probe = BlzCreateUnitWithSkin(PLAYER, moverId,
            CENTER_X, CENTER_Y, 0.0, moverId)
        local moverCollision = BlzGetUnitCollisionSize(probe)
        RemoveUnit(probe)
        local targetCollision = BlzGetUnitCollisionSize(self.target)
        local startDistance = moverCollision + targetCollision + 240.0
        self.mover = BlzCreateUnitWithSkin(PLAYER, moverId,
            CENTER_X + direction.x * startDistance,
            CENTER_Y + direction.y * startDistance, 0.0, moverId)
        SetUnitFacing(self.mover,
            math.atan(-direction.y, -direction.x) * 180.0 / math.pi)
        SetUnitAcquireRange(self.mover, 0.0)
        SetUnitInvulnerable(self.mover, true)
        SetUnitMoveSpeed(self.mover, 522.0)
        SetUnitVertexColor(self.mover, 255, 255, 255, 0)

        self.moverCollision = BlzGetUnitCollisionSize(self.mover)
        self.targetCollision = targetCollision
        self.elapsed = 0.0
        self.orderElapsed = 0.0
        self.stableElapsed = 0.0
        self.ordersIssued = 0
        self.minDistance = 1000000.0
        self.minAbsX = 1000000.0
        self.minAbsY = 1000000.0
        self.minSquare = 1000000.0
        self:issueOrder()
        self:updateStatus()
    end

    function activity:issueOrder()
        local method = METHODS[self.methodIndex]
        local direction = DIRECTIONS[self.directionIndex]
        if method.id == "move_target" then
            IssueTargetOrder(self.mover, "move", self.target)
        elseif method.id == "smart_target" then
            IssueTargetOrder(self.mover, "smart", self.target)
        elseif method.id == "center" then
            IssuePointOrder(self.mover, "move", CENTER_X, CENTER_Y)
        else
            IssuePointOrder(self.mover, "move",
                CENTER_X - direction.x * 700.0,
                CENTER_Y - direction.y * 700.0)
        end
        self.ordersIssued = self.ordersIssued + 1
        self.orderElapsed = 0.0
    end

    function activity:finishCase()
        local dx = math.abs(GetUnitX(self.mover) - GetUnitX(self.target))
        local dy = math.abs(GetUnitY(self.mover) - GetUnitY(self.target))
        self.results[#self.results + 1] = {
            moverSize = SIZES[self.moverIndex].label,
            targetSize = SIZES[self.targetIndex].label,
            method = METHODS[self.methodIndex].id,
            direction = DIRECTIONS[self.directionIndex].id,
            moverCollision = self.moverCollision,
            targetCollision = self.targetCollision,
            minDistance = self.minDistance,
            minAbsX = self.minAbsX,
            minAbsY = self.minAbsY,
            minSquare = self.minSquare,
            finalDistance = math.sqrt(dx * dx + dy * dy),
            finalAbsX = dx,
            finalAbsY = dy,
            finalSquare = math.max(dx, dy),
            ordersIssued = self.ordersIssued,
            finalOrder = GetUnitCurrentOrder(self.mover),
        }
        self:removePair()
        if not self:advanceIndices() then
            self.complete = true
            Export(self.results)
            self:updateStatus()
            DisplayTimedTextToPlayer(PLAYER, 0, 0, 30,
                "|cff80ff80Collision-order test complete.|r\nReport: " ..
                EXPORT_PATH)
            return
        end
        self:startCase()
    end

    function activity:update()
        if self.complete or self.mover == nil or self.target == nil then return end
        local dx = math.abs(GetUnitX(self.mover) - GetUnitX(self.target))
        local dy = math.abs(GetUnitY(self.mover) - GetUnitY(self.target))
        local distance = math.sqrt(dx * dx + dy * dy)
        if distance < self.minDistance - IMPROVEMENT_EPSILON then
            self.minDistance = distance
            self.minAbsX = dx
            self.minAbsY = dy
            self.stableElapsed = 0.0
        else
            self.stableElapsed = self.stableElapsed + SAMPLE_PERIOD
        end
        self.minSquare = math.min(self.minSquare, math.max(dx, dy))
        self.elapsed = self.elapsed + SAMPLE_PERIOD
        self.orderElapsed = self.orderElapsed + SAMPLE_PERIOD
        if self.orderElapsed >= ORDER_PERIOD then self:issueOrder() end
        if (self.elapsed >= MIN_CASE_DURATION and
                self.stableElapsed >= STABLE_DURATION) or
                self.elapsed >= MAX_CASE_DURATION then
            self:finishCase()
        end
    end

    function activity:setup(current)
        local oldForward = GetPlayerAlliance(PLAYER, TARGET_PLAYER,
            ALLIANCE_PASSIVE)
        local oldBackward = GetPlayerAlliance(TARGET_PLAYER, PLAYER,
            ALLIANCE_PASSIVE)
        JTG.ScopeBorrow(current.scope, function()
            SetPlayerAlliance(PLAYER, TARGET_PLAYER, ALLIANCE_PASSIVE,
                oldForward)
            SetPlayerAlliance(TARGET_PLAYER, PLAYER, ALLIANCE_PASSIVE,
                oldBackward)
            self:removePair()
        end)
        SetPlayerAlliance(PLAYER, TARGET_PLAYER, ALLIANCE_PASSIVE, true)
        SetPlayerAlliance(TARGET_PLAYER, PLAYER, ALLIANCE_PASSIVE, true)
        JTG.ResetWorldFog(PLAYER)
        JTG.ScopeRevealScene(current.scope, current.scene, PLAYER)

        local gameUI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        self.statusFrame = JTG.ScopeTrackFrame(current.presentationScope,
            BlzCreateFrameByType("TEXT", "JTGCollisionOrderStatus",
                gameUI, "", 0))
        BlzFrameSetSize(self.statusFrame, 0.32, 0.14)
        BlzFrameSetAbsPoint(self.statusFrame, FRAMEPOINT_TOP,
            0.40, 0.52)
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
    id = "dev.collision_orders", category = "tools",
    title = "Collision Order Test",
    description = "Compare movement-order stopping distances by size.",
    status = "available", hidden = true, sceneId = "arena.north",
    capabilities = {menu = false, pause = false, quests = false},
    factory = CreateActivity,
})

local function InitializeCollisionOrderDiagnostic()
    local trigger = CreateTrigger()
    TriggerRegisterPlayerChatEvent(trigger, PLAYER,
        "-diag-collision-orders", true)
    TriggerAddAction(trigger, function()
        JTG.StartActivity("dev.collision_orders", "tools")
    end)
    JTG.Dev = JTG.Dev or {}
    JTG.Dev.collisionOrderTrigger = trigger
end

JTG.RegisterBootstrapInitializer(InitializeCollisionOrderDiagnostic)
