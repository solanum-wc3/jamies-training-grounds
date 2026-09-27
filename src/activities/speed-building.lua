-- Speed Building: compare one through ten Human workers constructing the same
-- building. Every lane is captured at genuine 1% construction before the
-- comparison is released, preserving Warcraft III's native power-build rules.
JTG = JTG or {}

local BUILDINGS = {
    {FourCC("htow"), "Town Hall", 390.0, nil, 385, 205},
    {FourCC("hhou"), "Farm", 270.0, nil, 80, 20},
    {FourCC("hbar"), "Barracks", 360.0, nil, 160, 60},
    {FourCC("halt"), "Altar of Kings", 360.0, nil, 180, 50},
    {FourCC("hlum"), "Lumber Mill", 330.0, nil, 120, 0},
    -- The Blacksmith rawcode is hbla. Give its otherwise empty lane owner the
    -- completed Town Hall that exists in an ordinary Human game.
    {FourCC("hbla"), "Blacksmith", 390.0, {FourCC("htow")}, 140, 40},
    {FourCC("hwtw"), "Scout Tower", 250.0, nil, 30, 20},
    {FourCC("hvlt"), "Arcane Vault", 300.0, nil, 130, 30},
    -- Advanced production structures need completed prerequisite buildings.
    -- Those are created hidden and outside the arena for each lane owner.
    {FourCC("hars"), "Arcane Sanctum", 360.0, {FourCC("hkee")}, 150, 140},
    {FourCC("harm"), "Workshop", 390.0, {FourCC("hkee"), FourCC("hbla")}, 140, 140},
    {FourCC("hgra"), "Gryphon Aviary", 390.0, {FourCC("hcas"), FourCC("hlum")}, 140, 150},
}

local BUILD_OFFSETS = {
    {0.0, 0.0}, {128.0, 0.0}, {-128.0, 0.0},
    {0.0, 128.0}, {0.0, -128.0},
    {128.0, 128.0}, {-128.0, 128.0},
    {128.0, -128.0}, {-128.0, -128.0},
}

local SPEED_BUILDING_INTRO =
    "Human peasants can assist each other in the construction of a building, finishing it sooner at the cost of additional Gold and Lumber.|n|n" ..
    "Each peasant after the first contributes 60% of the first builder's build speed, decreasing the time it takes to finish the building, but increases both gold and lumber cost of the build by around 15% across its entire build time.|n|n" ..
    "Using more peasants to build has diminishing returns, but can be worth it. For example, the seconds gained from building a Town Hall at an expansion are always worth it in the long run, because you can start mining gold earlier. You just have to be able to afford the investment.|n|n" ..
    "You can choose a building to see a demonstration comparing 1 through 10 peasants!"

local function TrackFrame(scope, frame)
    JTG.ScopeAdd(scope, function()
        if frame ~= nil then BlzDestroyFrame(frame) end
    end)
    return frame
end

local function TrackTextTag(scope, tag)
    JTG.ScopeAdd(scope, function()
        if tag ~= nil then DestroyTextTag(tag) end
    end)
    return tag
end

local function FormatTime(seconds)
    local tenths = math.floor(seconds * 10.0 + 0.5)
    local secondsPart = math.floor(tenths / 10)
    local decimal = tenths % 10
    return tostring(secondsPart) .. "." .. tostring(decimal)
end

function JTG.OpenSpeedBuildingMenu(originCategory, pauseGame)
    local selection = {buildingId = FourCC("htow"), buildingName = "Town Hall"}
    local function releaseMenuPause()
        if JTG.UI then JTG.UI.SetGameplayMenuPaused(false) end
    end
    local function resumeCurrentRun()
        releaseMenuPause()
        JTG.ResumeActivity()
    end
    local function launch()
        releaseMenuPause()
        JTG.StartActivity("tools.speed_building", originCategory or "tools", selection)
    end
    local showRoot
    local function show(spec)
        spec.title = "Speed Building"
        spec.headingArtwork = "JTGMenu\\SpeedBuilding.dds"
        spec.headingArtworkWidth = 0.150
        spec.headingArtworkHeight = 0.0735
        spec.pauseGame = pauseGame == true
        if pauseGame then
            spec.resumeAction = resumeCurrentRun
            spec.exitAction = function()
                JTG.StopActivity("menu-exit")
                pauseGame = false
                showRoot()
            end
        end
        JTG.UI.ShowActivityBriefing(spec)
    end
    showRoot = function()
        local choices = {}
        for _, building in ipairs(BUILDINGS) do
            local unitId, unitName, workerRadius, prerequisites, goldCost, lumberCost =
                building[1], building[2], building[3], building[4], building[5], building[6]
            table.insert(choices, {
                label = unitName,
                tooltip = "Compare one through ten Peasants constructing a " .. unitName .. ".",
                action = function()
                    selection.buildingId = unitId
                    selection.buildingName = unitName
                    selection.workerRadius = workerRadius
                    selection.prerequisites = prerequisites
                    selection.goldCost = goldCost
                    selection.lumberCost = lumberCost
                    launch()
                end,
            })
        end
        show({
            body = SPEED_BUILDING_INTRO,
            choices = choices,
            compactChoices = true,
            backAction = function()
                if pauseGame then JTG.UI.ShowCategory(originCategory or "tools")
                else releaseMenuPause(); JTG.UI.ShowCategory(originCategory or "tools") end
            end,
        })
    end
    showRoot()
end

function JTG.CreateSpeedBuildingActivity(session)
    local selection = session.restartData or {}
    local activity = {
        buildingId = selection.buildingId or FourCC("htow"),
        buildingName = selection.buildingName or "Town Hall",
        workerRadius = selection.workerRadius or 390.0,
        prerequisites = selection.prerequisites or {},
        goldCost = selection.goldCost or 385,
        lumberCost = selection.lumberCost or 205,
        lanes = {},
        workers = {},
        readyCount = 0,
        completeCount = 0,
        elapsed = 0.0,
        captureElapsed = 0.0,
        released = false,
    }

    function activity:lanePoint(index)
        local column = (index - 1) % 5
        local row = math.floor((index - 1) / 5)
        local x = session.scene.centerX - 2000.0 + column * 1000.0
        local y = session.scene.centerY - 570.0 + row * 1140.0
        -- Scripted construction is less forgiving than the player's placement
        -- cursor. Snap every target to Warcraft's building grid.
        return math.floor(x / 64.0 + 0.5) * 64.0,
            math.floor(y / 64.0 + 0.5) * 64.0
    end

    function activity:updateLaneTag(index)
        local lane = self.lanes[index]
        if lane == nil or lane.tag == nil then return end
        local workerText = index == 1 and "1 Peasant" or tostring(index) .. " Peasants"
        local completionPercent = 0
        if lane.building ~= nil then
            local maximumLife = GetUnitState(lane.building, UNIT_STATE_MAX_LIFE)
            if maximumLife > 0.0 then
                completionPercent = math.min(100, math.floor(
                    GetUnitState(lane.building, UNIT_STATE_LIFE) * 100.0 /
                    maximumLife + 0.5))
            end
        end
        if lane.completed then completionPercent = 100 end
        local displayedTime = lane.completed and lane.completionTime or self.elapsed
        local savedText = ""
        if lane.completed then
            local speedMultiplier = 1.0 + 0.6 * (index - 1)
            local savedPercent = (1.0 - 1.0 / speedMultiplier) * 100.0
            savedText = " (-" .. string.format("%.1f", savedPercent) .. "%)"
        end
        local timeText = "|cff40e0d0" .. FormatTime(displayedTime) ..
            " s" .. savedText .. "|r"
        local gold = math.max(0,
            1000 - GetPlayerState(lane.owner, PLAYER_STATE_RESOURCE_GOLD))
        local lumber = math.max(0,
            1000 - GetPlayerState(lane.owner, PLAYER_STATE_RESOURCE_LUMBER))
        local goldPercent = lane.goldCost > 0 and math.max(0,
            (gold / lane.goldCost - 1.0) * 100.0) or 0
        local lumberPercent = lane.lumberCost > 0 and math.max(0,
            (lumber / lane.lumberCost - 1.0) * 100.0) or 0
        SetTextTagText(lane.tag,
            "|cffffffff" .. workerText .. "  " ..
            tostring(completionPercent) .. "%|r|n|n" ..
            "|cffffcc00" .. tostring(gold) .. " Gold (+" .. string.format("%.1f", goldPercent) .. "%)|r|n|n" ..
            "|cff80ff80" .. tostring(lumber) .. " Lumber (+" .. string.format("%.1f", lumberPercent) .. "%)|r|n|n" ..
            timeText, 0.026)
    end

    function activity:setOverlayVisible(visible)
        for _, lane in ipairs(self.lanes or {}) do
            if lane.tag ~= nil then SetTextTagVisibility(lane.tag, visible == true) end
        end
    end

    function activity:createWorker(lane, workerIndex, workerCount)
        local angle = 2.0 * math.pi * (workerIndex - 1) / workerCount
        local centerX, centerY, radius = lane.x, lane.y, self.workerRadius
        if workerIndex > 1 and lane.building ~= nil then
            -- Assistants appear inside or immediately beside the active
            -- footprint. Warcraft's collision resolves their final positions,
            -- avoiding unequal approach walks before repair begins.
            centerX = GetUnitX(lane.building)
            centerY = GetUnitY(lane.building)
            radius = 32.0
        end
        local worker = JTG.ScopeTrackUnit(session.scope,
            CreateUnit(lane.owner, FourCC("hpea"),
                centerX + radius * math.cos(angle),
                centerY + radius * math.sin(angle),
                math.deg(angle) + 180.0))
        SetUnitInvulnerable(worker, true)
        lane.workers[workerIndex] = worker
        table.insert(self.workers, worker)
        return worker
    end

    function activity:issueBuild(index)
        local lane = self.lanes[index]
        if lane == nil or lane.building ~= nil or lane.workers[1] == nil then return end
        lane.buildAttempt = (lane.buildAttempt or 0) + 1
        local offset = BUILD_OFFSETS[(lane.buildAttempt - 1) % #BUILD_OFFSETS + 1]
        lane.targetX = lane.x + offset[1]
        lane.targetY = lane.y + offset[2]
        IssueBuildOrderById(lane.workers[1], self.buildingId,
            lane.targetX, lane.targetY)
    end

    function activity:releaseComparison()
        self.released = true
        self.elapsed = 0.0
        for index = 1, 10 do
            local lane = self.lanes[index]
            PauseUnit(lane.building, false)
            for workerIndex = 1, index do
                local worker = lane.workers[workerIndex]
                PauseUnit(worker, false)
                IssueTargetOrder(worker, "repair", lane.building)
            end
        end
    end

    function activity:captureTick()
        if self.released then return end
        self.captureElapsed = self.captureElapsed + 0.05
        for index = 1, 10 do
            local lane = self.lanes[index]
            if not lane.ready then
                local group = CreateGroup()
                GroupEnumUnitsInRange(group, lane.x, lane.y, 460.0, nil)
                local candidate = FirstOfGroup(group)
                while candidate ~= nil do
                    GroupRemoveUnit(group, candidate)
                    if GetOwningPlayer(candidate) == lane.owner and
                        GetUnitTypeId(candidate) == self.buildingId then
                        lane.building = JTG.ScopeTrackUnit(session.scope, candidate)
                        lane.ready = true
                        UnitSetConstructionProgress(candidate, 1)
                        PauseUnit(candidate, true)
                        PauseUnit(lane.workers[1], true)
                        -- Assistants are created only after the building has
                        -- successfully begun. This keeps their pathing from
                        -- invalidating large or unusually shaped footprints.
                        for workerIndex = 2, index do
                            PauseUnit(self:createWorker(lane, workerIndex, index), true)
                        end
                        self.readyCount = self.readyCount + 1
                        self:updateLaneTag(index)
                        break
                    end
                    candidate = FirstOfGroup(group)
                end
                DestroyGroup(group)
                if not lane.ready and math.floor(self.captureElapsed * 20.0) % 20 == 0 then
                    self:issueBuild(index)
                end
            end
        end
        if self.readyCount >= 10 then self:releaseComparison() end
    end

    function activity:updateTick()
        if not self.released or self.completeCount >= 10 then return end
        self.elapsed = self.elapsed + 0.10
        for index = 1, 10 do
            local lane = self.lanes[index]
            if not lane.completed and lane.building ~= nil and
                GetUnitState(lane.building, UNIT_STATE_LIFE) >=
                GetUnitState(lane.building, UNIT_STATE_MAX_LIFE) - 1.0 then
                lane.completed = true
                lane.completionTime = self.elapsed
                self.completeCount = self.completeCount + 1
            end
            self:updateLaneTag(index)
        end
    end

    function activity:createScenario()
        for index = 1, 10 do
            local x, y = self:lanePoint(index)
            local owner = Player(index)
            local lane = {
                x = x, y = y, workers = {}, building = nil, ready = false,
                completed = false, completionTime = 0.0,
                goldCost = self.goldCost, lumberCost = self.lumberCost,
                owner = owner,
            }
            self.lanes[index] = lane
            lane.tag = TrackTextTag(session.scope, CreateTextTag())
            SetTextTagPermanent(lane.tag, true)
            SetTextTagVisibility(lane.tag, true)
            SetTextTagPos(lane.tag, x - 150.0, y + 330.0, 45.0)
            self:updateLaneTag(index)
            for prerequisiteIndex, prerequisiteId in ipairs(self.prerequisites) do
                local prerequisite = JTG.ScopeTrackUnit(session.scope,
                    CreateUnit(owner, prerequisiteId,
                        session.scene.minX - 650.0 - prerequisiteIndex * 32.0,
                        session.scene.minY - 650.0 - index * 24.0, 270.0))
                ShowUnit(prerequisite, false)
            end
            -- Only the primary builder exists until construction has started;
            -- assistants are added during capture and released together.
            self:createWorker(lane, 1, 1)
            self:issueBuild(index)
        end
        ClearSelection()
    end

    function activity:setup(current)
        local scene = current.scene
        local p0 = Player(0)
        JTG.BorrowCamera(current.scope, p0)

        local resourceGold = {}
        local resourceLumber = {}
        local playerControllers = {}
        local techLimits = {}
        local alliances = {}
        for ownerIndex = 0, 10 do
            local owner = Player(ownerIndex)
            resourceGold[ownerIndex] = GetPlayerState(owner, PLAYER_STATE_RESOURCE_GOLD)
            resourceLumber[ownerIndex] = GetPlayerState(owner, PLAYER_STATE_RESOURCE_LUMBER)
            playerControllers[ownerIndex] = GetPlayerController(owner)
            techLimits[ownerIndex] = GetPlayerTechMaxAllowed(owner, self.buildingId)
            alliances[ownerIndex] = {}
            for otherIndex = 0, 10 do
                alliances[ownerIndex][otherIndex] = GetPlayerAlliance(owner,
                    Player(otherIndex), ALLIANCE_PASSIVE)
            end
        end
        JTG.ScopeAdd(current.scope, function()
            for ownerIndex = 0, 10 do
                local owner = Player(ownerIndex)
                SetPlayerState(owner, PLAYER_STATE_RESOURCE_GOLD, resourceGold[ownerIndex])
                SetPlayerState(owner, PLAYER_STATE_RESOURCE_LUMBER, resourceLumber[ownerIndex])
                SetPlayerController(owner, playerControllers[ownerIndex])
                SetPlayerTechMaxAllowed(owner, self.buildingId, techLimits[ownerIndex])
                for otherIndex = 0, 10 do
                    SetPlayerAlliance(owner, Player(otherIndex), ALLIANCE_PASSIVE,
                        alliances[ownerIndex][otherIndex])
                end
            end
        end)
        for ownerIndex = 1, 10 do
            local owner = Player(ownerIndex)
            SetPlayerController(owner, MAP_CONTROL_COMPUTER)
            SetPlayerTechMaxAllowed(owner, self.buildingId, 10)
            SetPlayerState(owner, PLAYER_STATE_RESOURCE_GOLD, 1000)
            SetPlayerState(owner, PLAYER_STATE_RESOURCE_LUMBER, 1000)
        end
        for ownerIndex = 0, 10 do
            for otherIndex = 0, 10 do
                SetPlayerAlliance(Player(ownerIndex), Player(otherIndex),
                    ALLIANCE_PASSIVE, true)
            end
        end

        JTG.ResetWorldFog(p0)
        local visible = Rect(scene.minX, scene.minY, scene.maxX, scene.maxY)
        SetFogStateRect(p0, FOG_OF_WAR_VISIBLE, visible, true)
        local vision = CreateFogModifierRect(p0, FOG_OF_WAR_VISIBLE,
            visible, false, false)
        FogModifierStart(vision)
        JTG.ScopeAdd(current.scope, function()
            FogModifierStop(vision)
            DestroyFogModifier(vision)
        end)
        RemoveRect(visible)

        self.captureTimer = JTG.ScopeTrackTimer(current.scope, CreateTimer())
        TimerStart(self.captureTimer, 0.05, true,
            JTG.GuardSession(current, function() self:captureTick() end))
        self.updateTimer = JTG.ScopeTrackTimer(current.scope, CreateTimer())
        TimerStart(self.updateTimer, 0.10, true,
            JTG.GuardSession(current, function() self:updateTick() end))
        self:createScenario()
    end

    function activity:start(current)
        if GetLocalPlayer() == Player(0) then
            SetCameraPosition(current.scene.centerX, current.scene.centerY)
            if JTG.defaultCameraDistance ~= nil then
                SetCameraField(CAMERA_FIELD_TARGET_DISTANCE,
                    JTG.defaultCameraDistance, 0)
            end
        end
    end

    function activity:restorePresentation()
        self:setOverlayVisible(true)
        if JTG.UI then JTG.UI.ShowToolbar(session.descriptor.capabilities) end
    end

    function activity:cleanup()
        if JTG.UI then JTG.UI.HideActivityBriefing() end
        self.lanes = {}
        self.workers = {}
    end

    return activity
end
