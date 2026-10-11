-- Crowd prototype only: no targets, rounds or scoring yet. Neutral ownership
-- keeps selection possible without player commands interrupting the walkers.
JTG = JTG or {}
local WIDTH, HEIGHT = 1800, 1000
local COPIES, COLUMNS, ROWS = 6, 15, 8
local TICK = 0.25

function JTG.OpenReflexTrainingMenu(originCategory, pauseGame, restorePage, restoreData)
    local category = originCategory or "skills"
    local function release() JTG.UI.SetGameplayMenuPaused(false) end
    local spec = {
        title = "Reflex Training", activityId = "skills.reflex",
        originCategory = category, pageId = "root", restoreData = {},
        pauseGame = pauseGame == true,
        body = "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        choices = {{label = "Start Training", action = function()
            release()
            JTG.StartActivityAfterCleanup("skills.reflex", category, {}, nil, "new-crowd")
        end}},
        backAction = function() JTG.UI.ShowCategory(category) end,
    }
    if pauseGame then
        spec.resumeAction = function() release(); JTG.ResumeActivity() end
        spec.exitAction = function()
            JTG.StopActivity("menu-exit")
            JTG.OpenReflexTrainingMenu(category, false)
        end
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
    local activity = {units = {}, elapsed = 0, finished = false}
    function activity:chooseDestination(walker)
        walker.targetX = GetRandomReal(self.minX + 64, self.maxX - 64)
        walker.targetY = GetRandomReal(self.minY + 64, self.maxY - 64)
        walker.stalled = 0
        IssuePointOrder(walker.unit, "move", walker.targetX, walker.targetY)
    end
    function activity:update()
        if self.finished then return end
        self.elapsed = self.elapsed + TICK
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
                    if walker.targetX == nil or tx * tx + ty * ty < 64 * 64 or walker.stalled >= 1.5 then
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
        -- Reuse the shared racial roster, including heroes and summon levels.
        -- Human entries marked unavailable here are the flying units.
        local choices, families = {}, {}
        for _, column in ipairs(JTG.GetSurroundCustomRaceColumns("human")) do
            for _, choice in ipairs(column) do
                if choice.kind == "unit" and choice.enabled then
                    choices[#choices + 1] = choice
                    local family = JTG.GetSurroundCustomSummonFamily(choice.rawcode)
                    if family then families[family] = (families[family] or 0) + 1 end
                end
            end
        end
        local familyIndices = {}
        for _, choice in ipairs(choices) do
            local count = choice.hero and 1 or COPIES
            local family = JTG.GetSurroundCustomSummonFamily(choice.rawcode)
            if family and not choice.hero then
                local index = (familyIndices[family] or 0) + 1
                familyIndices[family] = index
                -- Keep one population budget per summon type, split across
                -- its levels; distribute any remainder in roster order.
                count = math.floor(COPIES / families[family]) +
                    (index <= COPIES % families[family] and 1 or 0)
            end
            for _ = 1, count do roster[#roster + 1] = choice.rawcode end
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
        for index, rawcode in ipairs(roster) do
            local slot = slots[index]
            local unit = JTG.ScopeTrackUnit(current.scope,
                CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), FourCC(rawcode), slot.x, slot.y, GetRandomReal(0, 360)))
            SetUnitColor(unit, PLAYER_COLOR_BLUE)
            SetUnitInvulnerable(unit, true)
            SetUnitAcquireRange(unit, 0)
            SetUnitCreepGuard(unit, false)
            assert(not IsUnitType(unit, UNIT_TYPE_FLYING), "Flying unit in Reflex ground crowd")
            self.units[#self.units + 1] = {unit = unit, lastX = GetUnitX(unit), lastY = GetUnitY(unit),
                stalled = 0, nextChoice = GetRandomReal(0, 1.5)}
        end
    end
    function activity:start()
        if GetLocalPlayer() == Player(0) then
            SetCameraField(CAMERA_FIELD_ROTATION, 90, 0)
            SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, 304, 0)
            SetCameraPosition(self.centerX, self.centerY)
            ClearSelection()
        end
        JTG.StartScopedTimer(session, session.scope, TICK, true, function() self:update() end)
    end
    function activity:captureResetState() return {} end
    function activity:hidePresentationForMenu() JTG.Training.SetPresentation(self, session, false) end
    function activity:restorePresentation() JTG.Training.SetPresentation(self, session, true) end
    function activity:discardPresentationForLoad() end
    function activity:rebuildPresentation() self:restorePresentation() end
    function activity:cleanup()
        self.finished = true
        if GetLocalPlayer() == Player(0) then ClearSelection() end
        JTG.UI.HideActivityBriefing()
    end
    function activity:afterCleanup() self.units = {} end
    return activity
end
