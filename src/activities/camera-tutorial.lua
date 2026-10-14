-- Camera tutorial. The tutorial is checkpoint-driven so later sections can
-- restore their narration and scene state without replaying earlier material.
JTG = JTG or {}

local CAMERA_PLAYER = Player(0)
local BLUE_PLAYER_COLOR = ConvertPlayerColor(1)
-- The three tutorial bases use Twisted Meadows' original southern gold mines.
-- Scene coordinates are aimed at the halls rather than the mines themselves.
local MAIN_BASE_X = 3648.0
local MAIN_BASE_Y = -5120.0
local SECONDARY_BASE_X = -2240.0
local SECONDARY_BASE_Y = -6528.0
local TERTIARY_BASE_X = -4608.0
local TERTIARY_BASE_Y = -3904.0
local LAYOUT_EXPORT_FILE = "JamiesTrainingGrounds-camera-layout.txt"
local LAYOUT_EXPORT_DISPLAY_PATH =
    "Documents\\Warcraft III\\CustomMapData\\" .. LAYOUT_EXPORT_FILE
local CAMERA_MOVE_DURATION = JTG.Tutorial.cameraMoveDuration
local TICK_INTERVAL = 0.05
local NARRATION_DURATION = 3600.0
local SPIKED_BARRICADES = FourCC("Rosp")
local ORC_TUTORIAL_MUSIC = "Sound\\Music\\mp3Music\\Orc1.mp3"

local function RacePreferenceFor(race)
    if race == RACE_ORC then return RACE_PREF_ORC end
    if race == RACE_UNDEAD then return RACE_PREF_UNDEAD end
    if race == RACE_NIGHTELF then return RACE_PREF_NIGHTELF end
    return RACE_PREF_HUMAN
end

local TUTORIAL_STEPS = {
    {
        id = "camera.001",
        checkpoint = "welcome",
        groupStart = 1,
        wait = true,
        sectionEnd = true,
        lines = {
            "{Heading: WELCOME}",
            "Welcome to the Camera Tutorial!",
            "Let us first take a look at the basic camera controls of Warcraft III.",
            "Once you are done reading and playing around with whatever mechanic you learn, press the {Button: Continue} or {Button: Next} button to move on!",
        },
    },
    {
        id = "camera.002",
        checkpoint = "movement",
        groupStart = 2,
        wait = true,
        trigger = "mainBase",
        lines = {
            "{Heading: FREE CAMERA}",
            "There are four ways to freely move the camera.",
        },
    },
    {
        id = "camera.003",
        groupStart = 3,
        wait = true,
        lines = {
            "Firstly, you can use \"edge pan\" by {Input: moving the mouse} to the edges of the screen.",
            "Edge pan is the most common way to move the camera. It is quick and intuitive.",
            "The drawback is that your mouse cursor will have to leave the center of the screen, where the action happens. Moving it back may cost you some time.",
            "Try using edge pan!",
        },
    },
    {
        id = "camera.004",
        groupStart = 4,
        wait = true,
        lines = {
            "The second way to freely move the camera is to {Input: press and hold the Middle Mouse Button} and drag the screen.",
            "This is slower, but it allows you to make small adjustments quickly, without having to move the cursor away from the action.",
            "Try dragging the camera!",
        },
    },
    {
        id = "camera.005",
        groupStart = 5,
        wait = true,
        lines = {
            "The third way to move the camera is using the minimap. It is displayed on the bottom left of the screen.",
            "You can {Input: click on the map} to center the camera on that location, or {Input: click and drag across the map} to move it.",
            "Try moving the camera using the minimap!",
        },
    },
    {
        id = "camera.006",
        groupStart = 6,
        wait = true,
        sectionEnd = true,
        lines = {
            "The last way to freely move the camera is using the keyboard. The default keys for this are the {Input: arrow keys}.",
            "These are a bit out of the way for both your left and your right hand, but some people prefer moving the camera using their keyboard hand.",
            "Try moving the camera using the arrow keys!",
        },
    },
    {
        id = "camera.007",
        checkpoint = "zooming",
        groupStart = 7,
        wait = true,
        lines = {
            "{Heading: ZOOMING}",
            "The default camera distance is 1650 units. This can be changed in the settings.",
            "Click the Quest button on the top left, or press {Input: F9}, for more details.",
        },
        trigger = "zoomQuest",
    },
    {
        id = "camera.008",
        groupStart = 8,
        wait = true,
        lines = {
            "You can change the camera distance while in-game. The default control for this is rolling the {Input: Mouse Wheel}.",
        },
    },
    {
        id = "camera.zoom-advice",
        groupStart = 9, wait = true,
        lines = {
            "A closer camera makes controlling units easier, while having the camera further back can help to keep a clear view of a situation.",
            "It is best to set zoom to a default value that allows you to do both. You can always zoom in or out during play.",
            "Feel free to set the default value to something that feels right for you!",
        },
    },
    {
        id = "camera.009",
        groupStart = 10,
        wait = true,
        sectionEnd = true,
        lines = {
            "After zooming in or out using the {Input: Mouse Wheel}, you can reset the current camera distance back to the default value you chose.",
            "The default key to do this is {Input: F5}.",
            "Change the camera zoom, and then reset it!",
        },
    },
    {
        id = "camera.010",
        checkpoint = "baseControl",
        groupStart = 11,
        wait = true,
        trigger = "mainBase",
        lines = {
            "{Heading: BASE CAMERA}",
            "Now let us take a look at the camera commands you can use for your bases and units.",
            "In this tutorial, you are in control of three different bases.",
        },
    },
    {
        id = "camera.011",
        groupStart = 12,
        wait = true,
        trigger = "tertiaryBase",
        lines = {
            "Each of your bases has a main building at a different tier.",
            "For Orcs, the tier 1 building is called a Great Hall.",
        },
    },
    {
        id = "camera.012",
        groupStart = 13,
        wait = true,
        trigger = "secondaryBase",
        lines = {
            "The tier 2 building is called a Stronghold.",
        },
    },
    {
        id = "camera.013",
        groupStart = 14,
        wait = true,
        trigger = "mainBase",
        lines = {
            "And the tier 3 building is called a Fortress.",
        },
    },
    {
        id = "camera.014",
        groupStart = 15,
        wait = true,
        lines = {
            "{Heading: JUMP TO BASE}",
            "You can return to your main buildings, and cycle between them.",
            "The default key for this is {Input: Backspace}.",
            "When doing this, the first main building the camera will jump to is the one with the highest tier. The next will be of the next highest tier.",
            "If several have the same tier, the camera will jump to the oldest ones first.",
            "Try cycling through your main buildings!",
        },
    },
    {
        id = "camera.015",
        groupStart = 16,
        wait = true,
        trigger = "notificationProduction",
        lines = {
            "{Heading: NOTIFICATIONS}",
            "Throughout the game, you will receive notifications, with associated audio callouts.",
            "Each of the notifications has a location. You can jump to the most recent location, and then cycle through the 8 most recent ones.",
            "The default key for this is {Input: Space}.",
            "These notifications can be for finished units, buildings, or researches.",
        },
    },
    {
        id = "camera.016",
        groupStart = 17,
        wait = true,
        trigger = "notificationAttack",
        lines = {
            "You also get notified when you are being attacked.",
            "Once you are being attacked, pressing {Input: Space} is the quickest way to get to the action.",
            "This is easier than first checking on the minimap and manually clicking where the enemy units are shown to be.",
            "Try cycling through your notifications!",
        },
    },
    {
        id = "camera.017",
        groupStart = 18,
        wait = true,
        trigger = "idleWorkers",
        lines = {
            "{Heading: IDLE WORKERS}",
            "You can automatically center the camera on idle worker units, and cycle through them.",
            "The default key for this is {Input: Tilde}.",
            "Its label varies on your keyboard layout. It is between the Tabulator and the Escape keys.",
            "Try cycling through your workers!",
        },
    },
    {
        id = "camera.018",
        groupStart = 19,
        wait = true,
        sectionEnd = true,
        trigger = "idleWorkerQuest",
        lines = {
            "If you want to be able to just select idle workers without automatically centering the camera on them, you can set it to require a {Input: double-tap}.",
            "Click the Quest button on the top left, or press {Input: F9}, for more details.",
        },
    },
    {
        id = "camera.019",
        checkpoint = "armyControl",
        groupStart = 20,
        wait = true,
        trigger = "armyCenter",
        lines = {
            "{Heading: ARMY CAMERA}",
            "There are two main ways of navigating the camera to your army units.",
        },
    },
    {
        id = "camera.020",
        groupStart = 21,
        wait = true,
        lines = {
            "By pressing {Input: F1}, {Input: F2} or {Input: F3}, you can select your hero units.",
            "{Input: Double-tapping} the key centers the camera on the hero.",
        },
    },
    {
        id = "camera.021",
        groupStart = 22,
        wait = true,
        lines = {
            "Which hero is bound to which key depends on the order you trained them in the current game, with your first hero always being bound to {Input: F1} and so on.",
            "Alternatively, you can {Input: click the hero icons} on the top left of the screen.",
            "These keys cannot be changed in-game.",
            "",
            "Try moving the camera to your heroes!",
        },
    },
    {
        id = "camera.022",
        groupStart = 23,
        wait = true,
        lines = {
            "If you want to freely assign units or buildings to keys, you have to use {Term: Control Groups}.",
            "{Input: Click} one of your units, {Input: hold CTRL}, and then {Input: press 1} on your keyboard!",
            "{Input: (CTRL+1)}",
            "This assigns them to Control Group 1.",
            "You can create a control group for every number key.",
        },
    },
    {
        id = "camera.023",
        groupStart = 24,
        wait = true,
        lines = {
            "Control groups can be used to control and divide your army according to type and function.",
            "How to best use control groups will be covered in more detail in a later tutorial.",
        },
    },
    {
        id = "camera.024",
        groupStart = 25,
        wait = true,
        lines = {
            "After forming it, {Input: pressing 1} will select the units of Control Group 1.",
            "{Input: Double-tapping} the key moves the camera to the location of the group's units.",
            "Try to assign and use different control groups!",
        },
    },
    {
        id = "camera.025",
        groupStart = 26,
        wait = true,
        sectionEnd = true,
        lines = {
            "Instead of locking the camera, you can also center it on the unit by {Input: clicking its portrait} at the bottom of the screen, or follow the unit by {Input: clicking and holding} the portrait.",
            "Try using these commands!",
        },
    },
    {
        id = "camera.026",
        groupStart = 27,
        terminal = true,
        trigger = "highlightMenuAndOptional",
        lines = {
            "{Heading: END OF TUTORIAL}",
            "This concludes the camera tutorial. Press the {Button: Menu} button to choose another tutorial.",
            "There are also some mechanics that are a bit more niche, which you will probably not need for competitive play. If you are interested in those, press the {Button: Optional} button.",
        },
    },
}

local OPTIONAL_SECTIONS = {
    rotation = {
        title = "Camera Rotation",
        checkpoint = "Camera Rotation",
        steps = {
            {
                wait = true,
                sectionEnd = true,
                lines = {
                    "{Heading: BONUS: CAMERA ROTATION}",
                    "You can rotate the camera by 90 degrees left or right.",
                    "By default, hold {Input: Insert} to rotate left or {Input: Delete} to rotate right.",
                    "Usually there is no reason to do this while playing, but you might get in a situation where clicking something is easier when the camera is rotated.",
                    "Try rotating the camera!",
                },
            },
        },
    },
    lockOn = {
        title = "Lock-On",
        checkpoint = "Lock-On",
        steps = {
            {
                wait = true,
                lines = {
                    "{Heading: BONUS: LOCK-ON}",
                    "These commands lock the camera to the unit you have currently selected.",
                    "The default command for this is {Input: holding CTRL} and {Input: pressing C}.",
                    "{Input: (CTRL+C)}",
                    "To unlock the camera again, use the same command.",
                },
            },
            {
                wait = true,
                sectionEnd = true,
                lines = {
                    "When multiple units are selected, the camera locks onto the one that is displayed on the very left of the selection.",
                },
            },
        },
    },
}

local FormatNarration = JTG.Tutorial.FormatNarration

local function StepText(step)
    return table.concat(step.lines or {}, "\n")
end

local function CopyArray(source)
    local copy = {}
    for index, value in ipairs(source or {}) do copy[index] = value end
    return copy
end

-- Captured in-game with -export-layout. Worker records additionally store the
-- activity and target needed to resume their gold or lumber cycle.
local IMPORTED_LAYOUT = {
    {"Obla", 2448.538, -5011.333, 25.446},
    {"Ofar", -3467.286, -3814.245, 175.456},
    {"Otch", -707.917, -4571.783, 46.163},
    {"oalt", 4000.000, -4704.000, 270.000},
    {"obar", 3392.000, -4608.000, 270.000},
    {"obea", 2880.000, -4608.000, 270.000},
    {"ofor", -2464.000, -7200.000, 270.000},
    {"ofor", 4192.000, -5024.000, 270.000},
    {"ofrt", 3648.000, -5120.000, 270.000},
    {"ogre", -4608.000, -3904.000, 270.000},
    {"ogru", -258.117, -5049.367, 78.529},
    {"ogru", -419.765, -5108.777, 85.306},
    {"ogru", -558.678, -5150.339, 125.310},
    {"ogru", -767.611, -5156.375, 148.249},
    {"okod", -3990.376, -3486.313, 197.388},
    {"opeo", -2319.215, -7322.300, 334.548, "harvesting lumber", "destructable", -2240.000, -7360.000},
    {"opeo", -2493.461, -6649.590, 255.389, "harvesting gold", "unit", -2944.000, -6912.000},
    {"opeo", -2526.917, -6686.724, 44.930, "harvesting gold", "unit", -2944.000, -6912.000},
    {"opeo", -2689.630, -6849.027, 44.974, "harvesting gold", "unit", -2944.000, -6912.000},
    {"opeo", -2754.165, -6736.034, 214.713, "harvesting gold", "unit", -2944.000, -6912.000},
    {"opeo", -2755.812, -6854.491, 196.994, "harvesting gold", "unit", -2944.000, -6912.000},
    {"opeo", -4867.988, -4036.759, 45.422, "harvesting gold", "unit", -5248.000, -4352.000},
    {"opeo", -5003.155, -4176.529, 225.006, "harvesting gold", "unit", -5248.000, -4352.000},
    {"opeo", -5005.824, -4257.692, 81.496, "harvesting gold", "unit", -5248.000, -4352.000},
    {"opeo", -5059.661, -4167.123, 224.469, "harvesting gold", "unit", -5248.000, -4352.000},
    {"opeo", -5060.544, -4232.416, 212.638, "harvesting gold", "unit", -5248.000, -4352.000},
    {"opeo", 3897.390, -5337.248, 151.499, "harvesting gold", "unit", 4160.000, -5696.000},
    {"opeo", 3938.108, -5518.035, 111.728, "harvesting gold", "unit", 4160.000, -5696.000},
    {"opeo", 3950.696, -5489.844, 271.009, "harvesting gold", "unit", 4160.000, -5696.000},
    {"opeo", 4005.770, -5581.824, 323.487, "harvesting gold", "unit", 4160.000, -5696.000},
    {"opeo", 4007.720, -5511.722, 309.568, "harvesting gold", "unit", 4160.000, -5696.000},
    {"opeo", 4478.370, -4564.495, 14.307, "harvesting lumber", "destructable", 4608.000, -4544.000},
    {"opeo", 4513.640, -4635.129, 37.777, "harvesting lumber", "destructable", 4608.000, -4544.000},
    {"opeo", 4525.099, -5470.767, 310.451, "harvesting lumber", "destructable", 4608.000, -5568.000},
    {"opeo", 4797.968, -4947.427, 3.920, "harvesting lumber", "destructable", 4928.000, -4928.000},
    {"opeo", 4823.990, -5007.974, 34.693, "harvesting lumber", "destructable", 4928.000, -4928.000},
    {"oshm", -3536.971, -3778.988, 315.625},
    {"oshm", -3659.701, -3343.084, 88.763},
    {"osld", 2944.000, -5184.000, 270.000},
    {"ospm", -451.368, -5332.873, 319.653},
    {"ospm", -670.330, -5377.836, 306.719},
    {"ostr", -2240.000, -6528.000, 270.000},
    {"otau", -350.843, -4806.144, 78.014},
    {"otau", -515.530, -4873.796, 77.196},
    {"otau", -674.377, -4937.061, 99.986},
    {"otau", -867.893, -4984.915, 89.502},
    {"otbk", -3576.513, -3623.319, 168.668},
    {"otbk", -3666.729, -3912.337, 227.273},
    {"otbk", -3744.470, -3674.474, 193.546},
    {"otbk", -3826.314, -3438.581, 157.552},
    {"otbk", -3833.089, -3968.458, 225.033},
    {"otbk", -3909.768, -3728.998, 198.563},
    {"otrb", -2720.000, -6560.000, 270.000},
    {"otrb", -4640.000, -4320.000, 270.000},
    {"otrb", -4896.000, -4320.000, 270.000},
    {"otrb", 3168.000, -4256.000, 270.000},
    {"otrb", 3744.000, -5536.000, 270.000},
    {"otrb", 4064.000, -4448.000, 270.000},
    {"otrb", 4192.000, -5344.000, 270.000},
    {"otto", 2560.000, -4160.000, 270.000},
    {"ovln", 3904.000, -4160.000, 270.000},
    {"owtw", -2432.000, -6912.000, 270.000},
    {"owtw", -2560.000, -6272.000, 270.000},
    {"owtw", -5056.000, -3904.000, 270.000},
    {"owtw", 2368.000, -4608.000, 270.000},
    {"owtw", 2560.000, -5376.000, 270.000},
    {"owtw", 3008.000, -3904.000, 270.000},
    {"owtw", 3776.000, -3776.000, 270.000},
}

local CreateTutorialButton = JTG.Tutorial.CreateButton

local function CreateBaseUnit(scope, owner, rawcode, x, y, facing)
    if rawcode=='opeo' then
        return JTG.Tutorial.CreateMobileUnit(scope,owner,FourCC(rawcode),x,y,facing)
    end
    return JTG.Tutorial.CreateSceneUnit(scope,owner,FourCC(rawcode),x,y,facing)
end

local function RawcodeToString(rawcode)
    local first = math.floor(rawcode / 16777216) % 256
    local second = math.floor(rawcode / 65536) % 256
    local third = math.floor(rawcode / 256) % 256
    local fourth = rawcode % 256
    return string.char(first, second, third, fourth)
end

function JTG.CreateCameraTutorialActivity(session)
    local activity = {
        checkpoint = "welcome",
        step = 0,
        cameraRemaining = 0.0,
        advanceRemaining = nil,
        waitingForContinue = false,
        complete = false,
        locallyPaused = false,
        objectivesOpen = false,
        optionalOpen = false,
        optionalSection = nil,
        optionalStep = 0,
        optionalReturnState = nil,
        presentationVisible = true,
        narrationBlocks = {},
        workerActivities = {},
        buttonEnabled = {},
        frames = {},
        actions = {},
        arrowActive = false,
        arrowVisible = false,
        arrowElapsed = 0,
        arrowBlinks = 0,
    }

    function activity:refreshControls()
        local frames = self.frames
        if frames.continue == nil then return end
        local currentStep = TUTORIAL_STEPS[self.step]
        local optional = self.optionalSection ~= nil and
            OPTIONAL_SECTIONS[self.optionalSection] or nil
        local optionalStep = optional ~= nil and
            optional.steps[self.optionalStep] or nil
        local optionalComplete = optional ~= nil and
            self.optionalStep > #optional.steps
        local terminal = optional == nil and currentStep ~= nil and
            currentStep.terminal == true
        local canContinue = self.waitingForContinue and
            (optional ~= nil or not terminal)
        BlzFrameSetText(frames.continue,
            (optionalComplete or
            (optional == nil and currentStep ~= nil and
                currentStep.sectionEnd == true)) and
            "Next" or "Continue")
        self:setButtonEnabled(frames.continue, canContinue)
        self:setButtonEnabled(frames.back,
            optional ~= nil or self.step > 1 or self.complete)
        local paused = JTG.UI and JTG.UI.exercisePaused == true
        BlzFrameSetText(frames.pause, paused and
            "|cffffffffUnpause|r" or "|cffffcc00Pause|r")
        local menusClosed = not self.objectivesOpen and not self.optionalOpen
        if frames.arrow ~= nil then
            BlzFrameSetVisible(frames.arrow, self.arrowActive and self.arrowVisible and
                self.presentationVisible and menusClosed)
        end
        if frames.continueHighlight ~= nil then
            BlzFrameSetVisible(frames.continueHighlight,
                canContinue and self.presentationVisible and
                menusClosed)
        end
        if frames.menuHighlight ~= nil then
            BlzFrameSetVisible(frames.menuHighlight,
                terminal and self.presentationVisible and menusClosed)
        end
        if frames.optionalHighlight ~= nil then
            BlzFrameSetVisible(frames.optionalHighlight,
                terminal and self.presentationVisible and menusClosed)
        end
    end

    function activity:clearArrow()
        self.arrowActive = false
        self.arrowVisible = false
        self.arrowElapsed = 0
        if self.frames.arrow ~= nil then BlzFrameSetVisible(self.frames.arrow, false) end
    end

    function activity:showWelcomeArrow()
        self.arrowActive = true
        self.arrowVisible = true
        self.arrowElapsed = 0
        self.arrowBlinks = 0
        self:refreshControls()
    end


    function activity:appendNarration(text, recordInLog)
        if text == nil or text == "" then return end
        local formatted = FormatNarration(text)
        table.insert(self.narrationBlocks, formatted)
        if self.presentationVisible and not self.objectivesOpen and
                not self.optionalOpen then
            DisplayTimedTextToPlayer(CAMERA_PLAYER, 0, 0,
                NARRATION_DURATION,
                formatted)
        end
    end

    function activity:announceQuestDiscovery()
        FlashQuestDialogButton()
        local sound = CreateSoundFromLabel("QuestNew", false, false,
            false, 10, 10)
        if sound ~= nil then
            StartSound(sound)
            KillSoundWhenDone(sound)
        end
    end

    function activity:createZoomQuest(discover, silent)
        if self.zoomQuest == nil then
            local quest = JTG.ScopeTrackQuest(session.scope, CreateQuest())
            QuestSetTitle(quest, "Changing Default Camera Distance")
            QuestSetDescription(quest, FormatNarration(
                "To change the default camera distance, go to " ..
                "{Menu: Gameplay -> Camera Settings}, enable " ..
                "{Menu: Improved Zoom}, and enter your preferred value.\n\n" ..
                "To do this, you need to leave this map temporarily. " ..
                "Before you do, you should make a {Term: Quicksave}. " ..
                "The default key for this is {Input: F6}."))
            QuestSetIconPath(quest,
                "ReplaceableTextures\\CommandButtons\\BTNReveal.blp")
            QuestSetRequired(quest, false)
            QuestSetDiscovered(quest, false)
            QuestSetEnabled(quest, true)
            self.zoomQuest = quest
        end
        if discover == true and not self.zoomQuestDiscovered then
            self.zoomQuestDiscovered = true
            QuestSetDiscovered(self.zoomQuest, true)
            if not silent then self:announceQuestDiscovery() end
        end
    end

    function activity:createIdleWorkerQuest(discover, silent)
        if self.idleWorkerQuest == nil then
            local quest = JTG.ScopeTrackQuest(session.scope, CreateQuest())
            QuestSetTitle(quest, "Idle Worker Double-Tap")
            QuestSetDescription(quest, FormatNarration(
                "To make centering the camera on an idle worker require a " ..
                "double-tap, go to {Menu: Gameplay -> Game Behavior}, and " ..
                "enable {Menu: Snap Camera to Worker on Double Click}."))
            QuestSetIconPath(quest,
                "ReplaceableTextures\\CommandButtons\\BTNPeon.blp")
            QuestSetRequired(quest, false)
            QuestSetDiscovered(quest, false)
            QuestSetEnabled(quest, true)
            self.idleWorkerQuest = quest
        end
        if discover == true and not self.idleWorkerQuestDiscovered then
            self.idleWorkerQuestDiscovered = true
            QuestSetDiscovered(self.idleWorkerQuest, true)
            if not silent then self:announceQuestDiscovery() end
        end
    end

    function activity:revealQuestsThrough(stepIndex)
        if stepIndex >= JTG.Tutorial.StepIndex(TUTORIAL_STEPS,'camera.007') then self:createZoomQuest(true, true) end
        if stepIndex >= JTG.Tutorial.StepIndex(TUTORIAL_STEPS,'camera.018') then self:createIdleWorkerQuest(true, true) end
    end

    function activity:findOwnedUnit(rawcode, x, y, radius)
        local group = CreateGroup()
        GroupEnumUnitsInRange(group, x, y, radius or 320.0, nil)
        local result = nil
        local bestDistance = 1000000000.0
        while true do
            local unit = FirstOfGroup(group)
            if unit == nil then break end
            GroupRemoveUnit(group, unit)
            if GetOwningPlayer(unit) == CAMERA_PLAYER and
                    GetUnitTypeId(unit) == FourCC(rawcode) then
                local dx = GetUnitX(unit) - x
                local dy = GetUnitY(unit) - y
                local distance = dx * dx + dy * dy
                if distance < bestDistance then
                    result = unit
                    bestDistance = distance
                end
            end
        end
        DestroyGroup(group)
        return result
    end

    function activity:findNearestLumberPeons(x, y, count)
        local candidates = {}
        local group = CreateGroup()
        GroupEnumUnitsOfPlayer(group, CAMERA_PLAYER, nil)
        while true do
            local unit = FirstOfGroup(group)
            if unit == nil then break end
            GroupRemoveUnit(group, unit)
            if GetUnitTypeId(unit) == FourCC("opeo") then
                local activity = self.workerActivities[GetHandleId(unit)]
                if activity ~= nil and
                        activity.activity == "harvesting lumber" then
                    local dx = GetUnitX(unit) - x
                    local dy = GetUnitY(unit) - y
                    table.insert(candidates, {
                        unit = unit,
                        distance = dx * dx + dy * dy,
                    })
                end
            end
        end
        DestroyGroup(group)
        table.sort(candidates,
            function(a, b) return a.distance < b.distance end)
        local result = {}
        for index = 1, math.min(count or 2, #candidates) do
            table.insert(result, candidates[index].unit)
        end
        return result
    end

    function activity:schedule(delay, callback)
        return JTG.Tutorial.ScheduleStep(session,self,delay,callback)
    end

    function activity:provideNotificationResources()
        if self.notificationResourcesAdded then
            -- Explicit revisits must still be able to train and research.
            for _,state in ipairs({PLAYER_STATE_RESOURCE_GOLD,PLAYER_STATE_RESOURCE_LUMBER}) do
                SetPlayerState(CAMERA_PLAYER,state,math.max(2000,GetPlayerState(CAMERA_PLAYER,state)))
            end
            return
        end
        self.notificationResourcesAdded = true
        local oldGold = GetPlayerState(CAMERA_PLAYER,
            PLAYER_STATE_RESOURCE_GOLD)
        local oldLumber = GetPlayerState(CAMERA_PLAYER,
            PLAYER_STATE_RESOURCE_LUMBER)
        SetPlayerState(CAMERA_PLAYER, PLAYER_STATE_RESOURCE_GOLD,
            oldGold + 2000)
        SetPlayerState(CAMERA_PLAYER, PLAYER_STATE_RESOURCE_LUMBER,
            oldLumber + 2000)
        JTG.ScopeBorrow(session.scope, function()
            SetPlayerState(CAMERA_PLAYER, PLAYER_STATE_RESOURCE_GOLD,
                oldGold)
            SetPlayerState(CAMERA_PLAYER, PLAYER_STATE_RESOURCE_LUMBER,
                oldLumber)
        end)
    end

    function activity:suppressCheatMessage()
        -- Cheat() always writes its own status line. Clear it immediately and
        -- redraw the current tutorial message stack on the following tick too.
        self:renderNarration()
        self:schedule(0.01, function() self:renderNarration() end)
    end

    function activity:enableWarpTen()
        if self.warpTenActive then return end
        Cheat("warpten")
        self.warpTenActive = true
        self:suppressCheatMessage()
        JTG.ScopeBorrow(session.scope, function()
            if self.warpTenActive then
                Cheat("warpten")
                self.warpTenActive = false
                ClearTextMessages()
            end
        end)
    end

    function activity:disableWarpTen()
        if not self.warpTenActive then return end
        Cheat("warpten")
        self.warpTenActive = false
        self:suppressCheatMessage()
    end

    function activity:orderDemoBurrow(peon)
        if peon == nil then return false end
        local sites = {
            {3072.0, -5760.0},
            {3328.0, -6016.0},
            {2816.0, -5760.0},
            {3328.0, -4096.0},
        }
        for _,site in ipairs(sites) do
            if not IsTerrainPathable(site[1],site[2],PATHING_TYPE_BUILDABILITY) then
                self.demoBurrowSite=site
                if IssueBuildOrderById(peon,FourCC('otrb'),site[1],site[2]) then return true end
                self.demoBurrowSite=nil
            end
        end
        -- If the footprint test rejected every nearby site, put the Peon on
        -- the clearest approach and retry the first site after pathing settles.
        SetUnitPosition(peon, 2944.0, -5760.0)
        self.demoBurrowSite=sites[1]
        local accepted=IssueBuildOrderById(peon,FourCC('otrb'),sites[1][1],sites[1][2])
        if not accepted then self.demoBurrowSite=nil end
        return accepted
    end

    function activity:startNotificationProduction()
        if self.notificationProductionStarted then return end
        self.notificationProductionStarted = true
        local scope=self.tutorialStepScope or session.scope
        local oldResearch=GetPlayerTechCount(CAMERA_PLAYER,FourCC('Rome'),true)
        JTG.ScopeBorrow(scope,function() SetPlayerTechResearched(CAMERA_PLAYER,FourCC('Rome'),oldResearch) end)
        SetPlayerTechResearched(CAMERA_PLAYER,FourCC('Rome'),0)
        self:provideNotificationResources()
        self:enableWarpTen()

        local fortress = self:findOwnedUnit("ofrt",
            MAIN_BASE_X, MAIN_BASE_Y, 256.0)
        local barracks = self:findOwnedUnit("obar",
            MAIN_BASE_X, MAIN_BASE_Y, 900.0)
        local warMill = self:findOwnedUnit("ofor",
            4192.0, -5024.0, 256.0)

        self.notificationProductionBuildings={fortress,barracks,warMill}

        local completionTrigger = JTG.ScopeTrackTrigger(scope,
            CreateTrigger())
        TriggerRegisterPlayerUnitEvent(completionTrigger, CAMERA_PLAYER,
            EVENT_PLAYER_UNIT_TRAIN_FINISH, nil)
        TriggerRegisterPlayerUnitEvent(completionTrigger, CAMERA_PLAYER,
            EVENT_PLAYER_UNIT_CONSTRUCT_START, nil)
        TriggerRegisterPlayerUnitEvent(completionTrigger, CAMERA_PLAYER,
            EVENT_PLAYER_UNIT_CONSTRUCT_FINISH, nil)
        TriggerAddAction(completionTrigger, JTG.Tutorial.GuardStep(session,self,
            function()
                local eventId = GetTriggerEventId()
                if eventId == EVENT_PLAYER_UNIT_TRAIN_FINISH then
                    local source=GetTriggerUnit()
                    if source~=fortress and source~=barracks then return end
                    local trained = GetTrainedUnit()
                    if trained~=nil and (GetUnitTypeId(trained)==FourCC('opeo') or GetUnitTypeId(trained)==FourCC('ogru')) then
                        JTG.ScopeTrackUnit(scope,trained)
                    end
                    if trained ~= nil and
                            GetUnitTypeId(trained) == FourCC("opeo") then
                        self.demoPeon = trained
                        -- The demonstration build belongs to this production visit.
                        JTG.Tutorial.ScheduleStep(session,self,0.10,function()
                            self:orderDemoBurrow(trained)
                        end)
                    elseif trained ~= nil and
                            GetUnitTypeId(trained) == FourCC("ogru") then
                        IssuePointOrder(trained, "move", -708.0, -4572.0)
                    end
                elseif eventId == EVENT_PLAYER_UNIT_CONSTRUCT_START then
                    local structure=GetConstructingStructure()
                    local site=self.demoBurrowSite
                    if structure and site and GetUnitTypeId(structure)==FourCC('otrb') and
                        math.abs(GetUnitX(structure)-site[1])<64 and math.abs(GetUnitY(structure)-site[2])<64 then
                        JTG.ScopeTrackUnit(scope,structure)
                    end
                elseif eventId == EVENT_PLAYER_UNIT_CONSTRUCT_FINISH then
                    local structure = GetConstructedStructure()
                    if structure ~= nil and
                            GetUnitTypeId(structure) == FourCC("otrb") and
                            self.demoPeon ~= nil then
                        IssueImmediateOrder(self.demoPeon, "stop")
                    end
                end
            end))

        if fortress ~= nil then
            IssueImmediateOrderById(fortress, FourCC("opeo"))
        end
        if barracks ~= nil then
            IssueImmediateOrderById(barracks, FourCC("ogru"))
        end
        if warMill ~= nil then
            IssueImmediateOrderById(warMill, FourCC("Rome"))
        end

    end

    function activity:stopNotificationProduction()
        self:disableWarpTen()
        for _,building in pairs(self.notificationProductionBuildings or {}) do
            if GetUnitTypeId(building)~=0 then IssueImmediateOrder(building,'cancel') end
        end
        self.notificationProductionBuildings=nil
        self.notificationProductionStarted=false
        self.demoPeon=nil;self.demoBurrowSite=nil
    end

    function activity:stopNotificationAttack()
        for _,ghoul in ipairs(self.demoGhouls or {}) do
            if GetUnitTypeId(ghoul)~=0 and GetWidgetLife(ghoul)>0.405 then KillUnit(ghoul) end
        end
        JTG.Tutorial.ClearScene(self,'notification-attack')
        self.demoGhouls={}
        for _,task in ipairs(self.attackRepairTasks or {}) do
            if task.started and task.tree and GetUnitTypeId(task.unit)~=0 and GetWidgetLife(task.unit)>0.405 then
                IssueTargetOrder(task.unit,'harvest',task.tree)
            end
        end
        self.attackRepairTasks={}
    end

    function activity:startNotificationAttack()
        self:stopNotificationAttack()

        local mainTower = self:findOwnedUnit("owtw",
            3776.0, -3776.0, 256.0)
        local tertiaryTower = self:findOwnedUnit("owtw",
            -5056.0, -3904.0, 256.0)
        local repairPeons = self:findNearestLumberPeons(
            3776.0, -3776.0, 2)
        for _,peon in ipairs(repairPeons) do
            local work=self.workerActivities[GetHandleId(peon)]
            self.attackRepairTasks[#self.attackRepairTasks+1]={unit=peon,
                tree=work and work.targetKind=='destructable' and self:findDestructable(work.targetX,work.targetY) or nil}
        end
        -- Each revisit restores the live targets before launching the attack.
        for _,tower in ipairs({mainTower,tertiaryTower}) do
            SetUnitState(tower,UNIT_STATE_LIFE,BlzGetUnitMaxHP(tower))
        end
        local spawnedGhouls = {}

        local function spawnAttacker(x, y, facing, target)
            if target == nil then return end
            local ghoul = JTG.ScopeTrackUnit(JTG.Tutorial.SceneScope(self,'notification-attack'),
                CreateUnit(Player(1), FourCC("ugho"), x, y, facing))
            table.insert(spawnedGhouls, ghoul)
            table.insert(self.demoGhouls, ghoul)
            IssueTargetOrder(ghoul, "attack", target)
            self:schedule(2.0, function()
                if GetUnitTypeId(ghoul) ~= 0 and
                        GetWidgetLife(target) > 0.405 then
                    UnitDamageTarget(ghoul, target, 35.0, true, false,
                        ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL,
                        WEAPON_TYPE_WHOKNOWS)
                    IssueTargetOrder(ghoul, "attack", target)
                end
            end)
        end

        -- Spawn both attackers live so revisiting this tutorial step can
        -- reconstruct the demonstration without relying on a hidden unit.
        spawnAttacker(3861.0, -3493.0, 180.0, mainTower)
        spawnAttacker(-4254.447, -3550.447, 225.0, tertiaryTower)

        self:schedule(3.0, function()
            for index, peon in ipairs(repairPeons) do
                if peon ~= nil and mainTower ~= nil then
                    self.attackRepairTasks[index].started=true
                    IssueImmediateOrder(peon, "stop")
                    IssueTargetOrder(peon, "repair", mainTower)
                end
            end
        end)
        -- Retiring these exact spawned handles remains valid after narration.
        JTG.Tutorial.SceneTimer(session,self,'notification-attack',10.0,false,function()
            for _, ghoul in ipairs(spawnedGhouls) do
                if ghoul ~= nil and GetUnitTypeId(ghoul) ~= 0 then
                    KillUnit(ghoul)
                end
            end
        end)
    end

    function activity:prepareNotificationGhoul()
        local enemy = Player(1)
        local oldEnemyColor = GetPlayerColor(enemy)
        local passiveFromEnemy = GetPlayerAlliance(enemy, CAMERA_PLAYER,
            ALLIANCE_PASSIVE)
        local passiveFromCamera = GetPlayerAlliance(CAMERA_PLAYER, enemy,
            ALLIANCE_PASSIVE)
        SetPlayerAlliance(enemy, CAMERA_PLAYER, ALLIANCE_PASSIVE, false)
        SetPlayerAlliance(CAMERA_PLAYER, enemy, ALLIANCE_PASSIVE, false)
        JTG.ScopeBorrow(session.scope, function()
            SetPlayerColor(enemy, oldEnemyColor)
            SetPlayerAlliance(enemy, CAMERA_PLAYER, ALLIANCE_PASSIVE,
                passiveFromEnemy)
            SetPlayerAlliance(CAMERA_PLAYER, enemy, ALLIANCE_PASSIVE,
                passiveFromCamera)
        end)
        SetPlayerColor(enemy, ConvertPlayerColor(0))
    end

    function activity:prepareIdleWorkers()
        if not self.idleWorkersScope then
            self.idleWorkersScope=JTG.CreateScope('camera-idle-workers')
            local scope=self.idleWorkersScope
            JTG.ScopeAdd(session.scope,function() JTG.DisposeScope(scope) end)
            self.idleWorkers={}
            for _,point in ipairs({{3456,-5440},{-2432,-6848},{-4800,-4224}}) do
                local worker=JTG.ScopeTrackUnit(scope,CreateUnit(CAMERA_PLAYER,FourCC('opeo'),point[1],point[2],270))
                self.idleWorkers[#self.idleWorkers+1]=worker
            end
        end
        for _,worker in ipairs(self.idleWorkers) do
            IssueImmediateOrder(worker,'stop')
        end
    end

    function activity:runStepTrigger(step)
        if not step or step.trigger~='notificationAttack' then self:stopNotificationAttack() end
        local idleStep=step and (step.trigger=='idleWorkers' or step.trigger=='idleWorkerQuest')
        if not idleStep and self.idleWorkersScope then
            JTG.DisposeScope(self.idleWorkersScope)
            self.idleWorkersScope=nil;self.idleWorkers=nil
        end
        if step ~= nil and step.trigger == "zoomQuest" then
            self:createZoomQuest(true)
        elseif step ~= nil and step.trigger == "mainBase" then
            self:takeCameraTo(MAIN_BASE_X, MAIN_BASE_Y,
                CAMERA_MOVE_DURATION)
        elseif step ~= nil and step.trigger == "secondaryBase" then
            self:takeCameraTo(SECONDARY_BASE_X, SECONDARY_BASE_Y,
                CAMERA_MOVE_DURATION)
        elseif step ~= nil and step.trigger == "tertiaryBase" then
            self:takeCameraTo(TERTIARY_BASE_X, TERTIARY_BASE_Y,
                CAMERA_MOVE_DURATION)
        elseif step ~= nil and step.trigger == "notificationProduction" then
            self:startNotificationProduction()
        elseif step ~= nil and step.trigger == "notificationAttack" then
            self:startNotificationAttack()
        elseif step ~= nil and step.trigger == "armyCenter" then
            self:takeCameraTo(-708.0, -4572.0, CAMERA_MOVE_DURATION)
        elseif step ~= nil and step.trigger == "idleWorkers" then
            self:prepareIdleWorkers()
        elseif step ~= nil and step.trigger == "idleWorkerQuest" then
            self:prepareIdleWorkers()
            self:createIdleWorkerQuest(true)
        end
    end

    function activity:restoreNarrationThrough(index, recordInLog)
        local target = TUTORIAL_STEPS[index]
        if target == nil then return end
        self:clearNarration()
        for stepIndex = target.groupStart, index do
            self:appendNarration(StepText(TUTORIAL_STEPS[stepIndex]),
                recordInLog == true)
        end
    end

    function activity:showStep(index, recordInLog)
        local spec = TUTORIAL_STEPS[index]
        if spec == nil then
            self:showCompletion(recordInLog)
            return
        end
        self.step = index
        self.complete = spec.terminal == true
        self.checkpoint = spec.checkpoint or self.checkpoint
        self.waitingForContinue = spec.wait == true and
            spec.terminal ~= true
        if spec.terminal == true or self.waitingForContinue then
            self.advanceRemaining = nil
        else
            self.advanceRemaining = spec.delay or 4.0
        end
        if index == spec.groupStart then self:clearNarration() end
        self:appendNarration(StepText(spec), recordInLog ~= false)
        if index == 1 then self:showWelcomeArrow() end
        self:runStepTrigger(spec)
        self:refreshControls()
    end

    function activity:showCompletion(recordInLog)
        self:stopNotificationAttack()
        self.step = #TUTORIAL_STEPS
        self.complete = true
        self.waitingForContinue = false
        self.advanceRemaining = nil
        self:clearNarration()
        self:appendNarration(
            "This concludes the camera tutorial. Press the {Button: Menu} button to choose another tutorial.\n" ..
            "There are also some mechanics that are a bit more niche, which you will probably not need for competitive play. If you are interested in those, press the {Button: Optional} button.",
            recordInLog ~= false)
        self:refreshControls()
    end

    function activity:takeCameraTo(x, y, duration)
        if GetLocalPlayer() == CAMERA_PLAYER then
            JTG.Tutorial.MoveCamera(CAMERA_PLAYER,x,y,duration)
        end
    end

    function activity:moveToMainBase()
        self:stopNotificationAttack()
        -- Open on the southernmost tower; later base demonstrations target the hall.
        self:takeCameraTo(2560.0, -5376.0, CAMERA_MOVE_DURATION)
        self.cameraRemaining = CAMERA_MOVE_DURATION
        self.advanceRemaining = nil
        self.waitingForContinue = false
        self.complete = false
        self.step = 0
        self:clearNarration()
        self:refreshControls()
    end

    function activity:restoreWelcomeCheckpoint()
        self.optionalSection = nil
        self.optionalStep = 0
        self.optionalReturnState = nil
        self.objectivesOpen = false
        self.optionalOpen = false
        self:setObjectivesVisible(false)
        self:setOptionalVisible(false)
        self:moveToMainBase()
    end

    function activity:showOptionalStep(index)
        local optional = OPTIONAL_SECTIONS[self.optionalSection]
        local spec = optional ~= nil and optional.steps[index] or nil
        if spec == nil then
            self:returnFromOptionalSection()
            return
        end
        self.optionalStep = index
        self.waitingForContinue = spec.wait == true
        self.advanceRemaining = nil
        self:clearNarration()
        self:appendNarration(StepText(spec), true)
        self:refreshControls()
    end

    function activity:showOptionalCompletion()
        local optional = OPTIONAL_SECTIONS[self.optionalSection]
        if optional == nil then
            self:returnFromOptionalSection()
            return
        end
        self.optionalStep = #optional.steps + 1
        self.waitingForContinue = true
        self.advanceRemaining = nil
        self:clearNarration()
        self:appendNarration(table.concat({
            "{Heading: OPTIONAL TOPIC COMPLETE}",
            "This optional topic is complete.",
            "Press {Button: Next} to return to the tutorial section you previously left.",
        }, "\n"), true)
        self:refreshControls()
    end

    function activity:beginOptionalSection(sectionId)
        local optional = OPTIONAL_SECTIONS[sectionId]
        if optional == nil then return end
        self:stopNotificationAttack()
        if self.optionalReturnState == nil then
            self.optionalReturnState = {
                step = self.step,
                checkpoint = self.checkpoint,
                complete = self.complete,
                waitingForContinue = self.waitingForContinue,
                advanceRemaining = self.advanceRemaining,
                cameraRemaining = self.cameraRemaining,
                narrationBlocks = CopyArray(self.narrationBlocks),
            }
        end
        self.objectivesOpen = false
        self.optionalOpen = false
        self:setObjectivesVisible(false)
        self:setOptionalVisible(false)
        self.optionalSection = sectionId
        self.optionalStep = 0
        self.complete = false
        self:showOptionalStep(1)
    end

    function activity:returnFromOptionalSection()
        local saved = self.optionalReturnState
        self.optionalSection = nil
        self.optionalStep = 0
        self.optionalReturnState = nil
        self.optionalOpen = false
        self:setOptionalVisible(false)
        if saved ~= nil then
            self.step = saved.step
            self.checkpoint = saved.checkpoint
            self.complete = saved.complete
            self.waitingForContinue = saved.waitingForContinue
            self.advanceRemaining = saved.advanceRemaining
            self.cameraRemaining = saved.cameraRemaining
            self.narrationBlocks = CopyArray(saved.narrationBlocks)
            self:runStepTrigger(TUTORIAL_STEPS[self.step])
            self.tutorialActiveStep=TUTORIAL_STEPS[self.step]
        end
        self:renderNarration()
        self:refreshControls()
    end

    function activity:abandonOptionalSection()
        self.optionalSection = nil
        self.optionalStep = 0
        self.optionalReturnState = nil
        self.optionalOpen = false
        self:setOptionalVisible(false)
    end

    function activity:continueTutorial()
        if self.optionalSection ~= nil then
            if not self.waitingForContinue then return end
            local optional = OPTIONAL_SECTIONS[self.optionalSection]
            if optional ~= nil and self.optionalStep < #optional.steps then
                self:showOptionalStep(self.optionalStep + 1)
            elseif optional ~= nil and
                    self.optionalStep == #optional.steps then
                self:showOptionalCompletion()
            else
                self:returnFromOptionalSection()
            end
            return
        end
        if self.complete then return end
        if not self.waitingForContinue then return end
        local currentStep = TUTORIAL_STEPS[self.step]
        if currentStep ~= nil and
                currentStep.trigger == "notificationProduction" then
            self:disableWarpTen()
        end
        local nextStep = TUTORIAL_STEPS[self.step + 1]
        if nextStep ~= nil and nextStep.terminal == true then
            self.waitingForContinue = false
            self:setButtonEnabled(self.frames.continue, false)
            if self.frames.continueHighlight ~= nil then
                BlzFrameSetVisible(self.frames.continueHighlight, false)
            end
        end
        -- A Continue checkpoint closes the preceding campaign-style message
        -- stack before the next section begins.
        self:clearNarration()
        self:showStep(self.step + 1, true)
    end

    function activity:goBack()
        if self.optionalSection ~= nil then
            local optional = OPTIONAL_SECTIONS[self.optionalSection]
            if optional ~= nil and self.optionalStep > #optional.steps then
                self:showOptionalStep(#optional.steps)
            elseif self.optionalStep > 1 then
                self:showOptionalStep(self.optionalStep - 1)
            else
                self:returnFromOptionalSection()
            end
            return
        end
        local targetIndex=math.max(1,self.step-1)
        if targetIndex == self.step and not self.complete then return end
        self:restoreCheckpoint(targetIndex)
    end

    function activity:restoreCheckpoint(index)
        self:abandonOptionalSection()
        self.objectivesOpen=false
        self:setObjectivesVisible(false)
        JTG.Tutorial.RestoreAt(self,index,nil,function(targetIndex)
            local spec=TUTORIAL_STEPS[targetIndex]
            self:revealQuestsThrough(targetIndex)
            self.step=targetIndex
            self.checkpoint=spec.checkpoint or self.checkpoint
            self.complete=spec.terminal==true
            self.waitingForContinue=spec.wait==true and not self.complete
            if spec.terminal or self.waitingForContinue then self.advanceRemaining=nil
            else self.advanceRemaining=spec.delay or 4.0 end
            self:restoreNarrationThrough(targetIndex,true)
            self:runStepTrigger(spec)
            self:refreshControls()
            self.tutorialActiveStep=spec
        end)
    end

    function activity:captureResetState()
        local saved=self.optionalReturnState
        return JTG.Tutorial.CaptureCheckpoint(self,saved and saved.step or self.step)
    end

    function activity:restoreZoomCheckpoint()
        self:restoreCheckpoint(JTG.Tutorial.StepIndex(TUTORIAL_STEPS,'camera.007'))
    end

    function activity:restoreMovementCheckpoint()
        self:restoreCheckpoint(JTG.Tutorial.StepIndex(TUTORIAL_STEPS,'camera.002'))
    end

    function activity:restoreBaseControlCheckpoint()
        self:restoreCheckpoint(JTG.Tutorial.StepIndex(TUTORIAL_STEPS,'camera.010'))
    end

    function activity:restoreArmyControlCheckpoint()
        self:restoreCheckpoint(JTG.Tutorial.StepIndex(TUTORIAL_STEPS,'camera.019'))
    end

    function activity:openMenu()
        JTG.Tutorial.OpenMenu(self,"learn")
    end

    function activity:togglePause()
        JTG.Tutorial.TogglePause(self)
    end

    function activity:setObjectivesVisible(visible)
        self.objectivesOpen = visible == true
        if self.objectivesOpen then
            self.optionalOpen = false
            if self.frames.optionalMenu ~= nil then
                BlzFrameSetVisible(self.frames.optionalMenu, false)
            end
        end
        if self.frames.objectives ~= nil then
            BlzFrameSetVisible(self.frames.objectives,
                self.presentationVisible and self.objectivesOpen)
        end
        self:renderNarration()
        self:refreshControls()
    end

    function activity:toggleObjectives()
        if self.objectivesOpen then
            self:setObjectivesVisible(false)
            return
        end
        if self.optionalSection ~= nil then
            self:returnFromOptionalSection()
        end
        self:setObjectivesVisible(true)
    end

    function activity:setOptionalVisible(visible)
        self.optionalOpen = visible == true
        if self.optionalOpen then
            self.objectivesOpen = false
            if self.frames.objectives ~= nil then
                BlzFrameSetVisible(self.frames.objectives, false)
            end
        end
        if self.frames.optionalMenu ~= nil then
            BlzFrameSetVisible(self.frames.optionalMenu,
                self.presentationVisible and self.optionalOpen)
        end
        self:renderNarration()
        self:refreshControls()
    end

    function activity:toggleOptional()
        self:setOptionalVisible(not self.optionalOpen)
    end

    function activity:createPresentation()
        local root = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        local scope = session.presentationScope
        local suffix = tostring(session.generation) .. "x" ..
            tostring((JTG.UI and JTG.UI.epoch) or 0)
        self.frames = {}
        self.actions = {}
        self.buttonEnabled = {}

        -- In current Reforged builds the idle-worker control is the fourth
        -- child of ConsoleBottomBar. It is not an origin-frame type; the old
        -- numeric lookup therefore targeted an unrelated frame. Keep this
        -- activity-local overlay as a fallback for clients which do not
        -- reload the map's native IdlePeon skin immediately.
        local consoleBottomBar = BlzGetFrameByName("ConsoleBottomBar", 0)
        local idleWorkerContainer = nil
        local idleWorkerButton = nil
        if consoleBottomBar ~= nil then
            idleWorkerContainer = BlzFrameGetChild(consoleBottomBar, 3)
        end
        if idleWorkerContainer ~= nil then
            idleWorkerButton = BlzFrameGetChild(idleWorkerContainer, 0)
        end
        if idleWorkerButton ~= nil then
            local idleWorkerIcon = JTG.ScopeTrackFrame(scope,
                BlzCreateFrameByType("BACKDROP",
                    "JTGCameraIdleWorkerIcon" .. suffix,
                    idleWorkerButton, "", 0))
            BlzFrameSetPoint(idleWorkerIcon, FRAMEPOINT_TOPLEFT,
                idleWorkerButton, FRAMEPOINT_TOPLEFT, 0.0015, -0.0015)
            BlzFrameSetPoint(idleWorkerIcon, FRAMEPOINT_BOTTOMRIGHT,
                idleWorkerButton, FRAMEPOINT_BOTTOMRIGHT, -0.0015, 0.0015)
            BlzFrameSetTexture(idleWorkerIcon,
                "ReplaceableTextures\\CommandButtons\\BTNPeon.blp",
                0, true)
            BlzFrameSetLevel(idleWorkerIcon, 20)
            BlzFrameSetEnable(idleWorkerIcon, false)
            self.frames.idleWorkerIcon = idleWorkerIcon
        end

        local labels = {
            {"menu", "Menu", 1},
            {"back", "Back", 2},
            {"objectivesButton", "Topics", 3},
            {"optionalButton", "Optional", 4},
            {"continue", "Continue", 5},
            {"pause", "Pause", 7},
        }
        local bar = JTG.Tutorial.CreateToolbar(self, scope, root, "JTGCameraTutorial", suffix, labels)
        JTG.Tutorial.CreateHighlight(self, scope, "JTGCamera", suffix, "continue")
        JTG.Tutorial.CreateHighlight(self, scope, "JTGCamera", suffix, "menu")
        JTG.Tutorial.CreateHighlight(self, scope, "JTGCamera", suffix, "pause")

        local arrow = JTG.ScopeTrackFrame(scope, BlzCreateFrameByType("BACKDROP",
            "JTGCameraTutorialContinueArrow" .. suffix, root, "", 0))
        BlzFrameSetSize(arrow, 0.052, 0.052)
        BlzFrameSetTexture(arrow, "JTGMenu\\TutorialArrowUp.dds", 0, true)
        BlzFrameSetPoint(arrow, FRAMEPOINT_TOP, self.frames.continue,
            FRAMEPOINT_BOTTOM, 0, -0.004)
        BlzFrameSetEnable(arrow, false)
        BlzFrameSetLevel(arrow, 30)
        BlzFrameSetVisible(arrow, false)
        self.frames.arrow = arrow

        JTG.Tutorial.CreateHighlight(self, scope, "JTGCamera", suffix, "optional", "optionalButton")

        local objectives = JTG.ScopeTrackFrame(scope, BlzCreateFrameByType("FRAME",
            "JTGCameraTutorialObjectives" .. suffix, root, "", 0))
        BlzFrameSetSize(objectives, 0.185, JTG.TutorialMenuHeight(5))
        BlzFrameSetAbsPoint(objectives, FRAMEPOINT_TOPRIGHT, 0.795, 0.500)
        local skin = JTG.ScopeTrackFrame(scope, BlzCreateFrame("EscMenuBackdrop",
            objectives, 0, 600 + session.generation))
        BlzFrameSetPoint(skin, FRAMEPOINT_TOPLEFT, objectives,
            FRAMEPOINT_TOPLEFT, 0, 0)
        BlzFrameSetPoint(skin, FRAMEPOINT_BOTTOMRIGHT, objectives,
            FRAMEPOINT_BOTTOMRIGHT, 0, 0)
        BlzFrameSetEnable(skin, false)
        local welcome = JTG.ScopeTrackFrame(scope, CreateTutorialButton(
            "JTGCameraTutorialWelcomeCheckpoint" .. suffix,
            objectives, "Welcome", 0.115))
        BlzFrameSetSize(welcome, 0.115, 0.026)
        BlzFrameSetPoint(welcome, FRAMEPOINT_TOP, objectives,
            FRAMEPOINT_TOP, 0, -0.041)
        local movement = JTG.ScopeTrackFrame(scope, CreateTutorialButton(
            "JTGCameraTutorialMovementCheckpoint" .. suffix,
            objectives, "Free Camera", 0.115))
        BlzFrameSetSize(movement, 0.115, 0.026)
        BlzFrameSetPoint(movement, FRAMEPOINT_TOP, welcome,
            FRAMEPOINT_BOTTOM, 0, -0.003)
        local zooming = JTG.ScopeTrackFrame(scope, CreateTutorialButton(
            "JTGCameraTutorialZoomingCheckpoint" .. suffix,
            objectives, "Zooming", 0.115))
        BlzFrameSetSize(zooming, 0.115, 0.026)
        BlzFrameSetPoint(zooming, FRAMEPOINT_TOP, movement,
            FRAMEPOINT_BOTTOM, 0, -0.003)
        local baseControl = JTG.ScopeTrackFrame(scope, CreateTutorialButton(
            "JTGCameraTutorialBaseControlCheckpoint" .. suffix,
            objectives, "Base Camera", 0.115))
        BlzFrameSetSize(baseControl, 0.115, 0.026)
        BlzFrameSetPoint(baseControl, FRAMEPOINT_TOP, zooming,
            FRAMEPOINT_BOTTOM, 0, -0.003)
        local armyControl = JTG.ScopeTrackFrame(scope, CreateTutorialButton(
            "JTGCameraTutorialArmyControlCheckpoint" .. suffix,
            objectives, "Army Camera", 0.115))
        BlzFrameSetSize(armyControl, 0.115, 0.026)
        BlzFrameSetPoint(armyControl, FRAMEPOINT_TOP, baseControl,
            FRAMEPOINT_BOTTOM, 0, -0.003)
        local close = JTG.ScopeTrackFrame(scope, CreateTutorialButton(
            "JTGCameraTutorialObjectivesClose" .. suffix,
            objectives, "Close", 0.10))
        BlzFrameSetSize(close, 0.10, 0.026)
        BlzFrameSetPoint(close, FRAMEPOINT_BOTTOM, objectives,
            FRAMEPOINT_BOTTOM, 0, 0.025)
        self.frames.objectives = objectives

        -- Optional tutorial branches use the same panel geometry and button
        -- arrangement as Topics, but never participate in the main sequence.
        local optionalMenu = JTG.ScopeTrackFrame(scope, BlzCreateFrameByType("FRAME",
            "JTGCameraTutorialOptionalMenu" .. suffix, root, "", 0))
        BlzFrameSetSize(optionalMenu, 0.185, JTG.TutorialMenuHeight(2))
        BlzFrameSetAbsPoint(optionalMenu, FRAMEPOINT_TOPRIGHT, 0.795, 0.500)
        local optionalSkin = JTG.ScopeTrackFrame(scope, BlzCreateFrame(
            "EscMenuBackdrop", optionalMenu, 0, 700 + session.generation))
        BlzFrameSetPoint(optionalSkin, FRAMEPOINT_TOPLEFT, optionalMenu,
            FRAMEPOINT_TOPLEFT, 0, 0)
        BlzFrameSetPoint(optionalSkin, FRAMEPOINT_BOTTOMRIGHT, optionalMenu,
            FRAMEPOINT_BOTTOMRIGHT, 0, 0)
        BlzFrameSetEnable(optionalSkin, false)
        local rotation = JTG.ScopeTrackFrame(scope, CreateTutorialButton(
            "JTGCameraTutorialOptionalRotation" .. suffix,
            optionalMenu, OPTIONAL_SECTIONS.rotation.title, 0.115))
        BlzFrameSetSize(rotation, 0.115, 0.026)
        BlzFrameSetPoint(rotation, FRAMEPOINT_TOP, optionalMenu,
            FRAMEPOINT_TOP, 0, -0.041)
        local lockOn = JTG.ScopeTrackFrame(scope, CreateTutorialButton(
            "JTGCameraTutorialOptionalLockOn" .. suffix,
            optionalMenu, OPTIONAL_SECTIONS.lockOn.title, 0.115))
        BlzFrameSetSize(lockOn, 0.115, 0.026)
        BlzFrameSetPoint(lockOn, FRAMEPOINT_TOP, rotation,
            FRAMEPOINT_BOTTOM, 0, -0.003)
        local optionalClose = JTG.ScopeTrackFrame(scope, CreateTutorialButton(
            "JTGCameraTutorialOptionalClose" .. suffix,
            optionalMenu, "Close", 0.10))
        BlzFrameSetSize(optionalClose, 0.10, 0.026)
        BlzFrameSetPoint(optionalClose, FRAMEPOINT_BOTTOM, optionalMenu,
            FRAMEPOINT_BOTTOM, 0, 0.025)
        self.frames.optionalMenu = optionalMenu

        JTG.Tutorial.BindClicks(self, scope)
        self:registerClick(self.frames.continue,
            function() self:continueTutorial() end)
        self:registerClick(self.frames.menu,
            function() self:openMenu() end)
        self:registerClick(self.frames.pause,
            function() self:togglePause() end,
            function() return JTG.UI.exercisePaused and "return" or "normal" end)
        self:registerClick(self.frames.back,
            function() self:goBack() end, "return")
        self:registerClick(self.frames.objectivesButton,
            function() self:toggleObjectives() end)
        self:registerClick(self.frames.optionalButton,
            function() self:toggleOptional() end)
        self:registerClick(welcome,
            function() self:restoreWelcomeCheckpoint() end)
        self:registerClick(zooming,
            function() self:restoreZoomCheckpoint() end)
        self:registerClick(movement,
            function() self:restoreMovementCheckpoint() end)
        self:registerClick(baseControl,
            function() self:restoreBaseControlCheckpoint() end)
        self:registerClick(armyControl,
            function() self:restoreArmyControlCheckpoint() end)
        self:registerClick(close,
            function() self:setObjectivesVisible(false) end, "return")
        self:registerClick(rotation,
            function() self:beginOptionalSection("rotation") end)
        self:registerClick(lockOn,
            function() self:beginOptionalSection("lockOn") end)
        self:registerClick(optionalClose,
            function() self:setOptionalVisible(false) end, "return")

        self:refreshControls()
        self:setObjectivesVisible(self.objectivesOpen)
        self:setOptionalVisible(self.optionalOpen)
        self:setPresentationVisible(self.presentationVisible)
    end

    function activity:setPresentationVisible(visible)
        self.presentationVisible = visible == true
        if self.frames.bar ~= nil then
            BlzFrameSetVisible(self.frames.bar, self.presentationVisible)
        end
        if self.frames.objectives ~= nil then
            BlzFrameSetVisible(self.frames.objectives,
                self.presentationVisible and self.objectivesOpen)
        end
        if self.frames.optionalMenu ~= nil then
            BlzFrameSetVisible(self.frames.optionalMenu,
                self.presentationVisible and self.optionalOpen)
        end
        self:renderNarration()
        self:refreshControls()
    end

    function activity:tick()
        if self.locallyPaused or self.objectivesOpen or
                self.optionalOpen or self.optionalSection ~= nil then return end
        if self.arrowActive and self.presentationVisible and (self.arrowBlinks < 10 or not self.arrowVisible) then
            self.arrowElapsed = self.arrowElapsed + TICK_INTERVAL
            if self.arrowElapsed >= 0.35 then
                self.arrowElapsed = self.arrowElapsed - 0.35
                self.arrowVisible = not self.arrowVisible
                if not self.arrowVisible then
                    self.arrowBlinks = self.arrowBlinks + 1
                end
                self:refreshControls()
            end
        end
        if self.cameraRemaining > 0.0 then
            self.cameraRemaining = math.max(0.0,
                self.cameraRemaining - TICK_INTERVAL)
            if self.cameraRemaining <= 0.0 then self:showStep(1, true) end
            return
        end
        if self.advanceRemaining ~= nil then
            self.advanceRemaining = self.advanceRemaining - TICK_INTERVAL
            if self.advanceRemaining <= 0.0 then
                self.advanceRemaining = nil
                self:showStep(self.step + 1, true)
            end
        end
    end

    function activity:exportLayout()
        local rows = {}
        local group = CreateGroup()
        GroupEnumUnitsOfPlayer(group, CAMERA_PLAYER, nil)
        while true do
            local unit = FirstOfGroup(group)
            if unit == nil then break end
            GroupRemoveUnit(group, unit)
            local rawcode = RawcodeToString(GetUnitTypeId(unit))
            local orderId = GetUnitCurrentOrder(unit)
            local orderName = OrderId2String(orderId)
            if orderName == nil or orderName == "" then
                orderName = tostring(orderId)
            end
            local worker = IsUnitType(unit, UNIT_TYPE_PEON)
            local work = self.workerActivities[GetHandleId(unit)] or {}
            table.insert(rows, string.format(
                '{rawcode="%s", x=%.3f, y=%.3f, facing=%.3f, player=%d, ' ..
                'worker=%s, orderId=%d, order="%s", activity="%s", ' ..
                'targetKind="%s", targetRawcode="%s", targetX=%.3f, targetY=%.3f},',
                rawcode, GetUnitX(unit), GetUnitY(unit), GetUnitFacing(unit),
                GetPlayerId(GetOwningPlayer(unit)), tostring(worker), orderId,
                orderName, work.activity or (worker and "idle" or ""),
                work.targetKind or "", work.targetRawcode or "",
                work.targetX or 0.0, work.targetY or 0.0))
        end
        DestroyGroup(group)
        table.sort(rows)

        PreloadGenClear()
        PreloadGenStart()
        Preload("-- Jamie's Training Grounds camera tutorial layout")
        Preload("-- Unit placement plus worker order/activity and last work target")
        for _, row in ipairs(rows) do Preload(row) end
        PreloadGenEnd(LAYOUT_EXPORT_FILE)

        DisplayTimedTextToPlayer(CAMERA_PLAYER, 0, 0, 20,
            "|cffffcc00Layout exported.|r\n" ..
            "File: " .. LAYOUT_EXPORT_DISPLAY_PATH .. "\n" ..
            "Units and buildings recorded: " .. tostring(#rows))
    end

    function activity:recordWorkerOrder()
        local unit = GetTriggerUnit()
        if unit == nil or not IsUnitType(unit, UNIT_TYPE_PEON) then return end
        local orderId = GetIssuedOrderId()
        local orderName = OrderId2String(orderId)
        if orderName == nil or orderName == "" then
            orderName = tostring(orderId)
        end
        local targetUnit = GetOrderTargetUnit()
        local targetDestructable = GetOrderTargetDestructable()
        local entry = {activity = orderName}
        if targetUnit ~= nil then
            local targetRawcode = GetUnitTypeId(targetUnit)
            entry.targetKind = "unit"
            entry.targetRawcode = RawcodeToString(targetRawcode)
            entry.targetX = GetUnitX(targetUnit)
            entry.targetY = GetUnitY(targetUnit)
            if targetRawcode == FourCC("ngol") or
                    targetRawcode == FourCC("egol") then
                entry.activity = "harvesting gold"
            end
        elseif targetDestructable ~= nil then
            entry.targetKind = "destructable"
            entry.targetRawcode = RawcodeToString(
                GetDestructableTypeId(targetDestructable))
            entry.targetX = GetDestructableX(targetDestructable)
            entry.targetY = GetDestructableY(targetDestructable)
            if orderName == "harvest" or orderName == "smart" then
                entry.activity = "harvesting lumber"
            end
        elseif GetOrderPointX() ~= 0.0 or GetOrderPointY() ~= 0.0 then
            entry.targetKind = "point"
            entry.targetX = GetOrderPointX()
            entry.targetY = GetOrderPointY()
        end
        self.workerActivities[GetHandleId(unit)] = entry
    end

    function activity:installLayoutCapture()
        self.exportTrigger = JTG.ScopeTrackTrigger(session.scope,
            CreateTrigger())
        TriggerRegisterPlayerChatEvent(self.exportTrigger, CAMERA_PLAYER,
            "-export-layout", true)
        TriggerAddAction(self.exportTrigger,
            function() self:exportLayout() end)

        self.workerOrderTrigger = JTG.ScopeTrackTrigger(session.scope,
            CreateTrigger())
        TriggerRegisterPlayerUnitEvent(self.workerOrderTrigger, CAMERA_PLAYER,
            EVENT_PLAYER_UNIT_ISSUED_ORDER, nil)
        TriggerRegisterPlayerUnitEvent(self.workerOrderTrigger, CAMERA_PLAYER,
            EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, nil)
        TriggerRegisterPlayerUnitEvent(self.workerOrderTrigger, CAMERA_PLAYER,
            EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, nil)
        TriggerAddAction(self.workerOrderTrigger,
            function() self:recordWorkerOrder() end)
    end

    function activity:findGoldMine(x, y)
        local group = CreateGroup()
        GroupEnumUnitsInRange(group, x, y, 192.0, nil)
        local result = nil
        while true do
            local unit = FirstOfGroup(group)
            if unit == nil then break end
            GroupRemoveUnit(group, unit)
            local rawcode = GetUnitTypeId(unit)
            if rawcode == FourCC("ngol") or rawcode == FourCC("egol") then
                result = unit
                break
            end
        end
        DestroyGroup(group)
        return result
    end

    function activity:findDestructable(x, y)
        local area = Rect(x - 96.0, y - 96.0, x + 96.0, y + 96.0)
        local result = nil
        local distance = 1000000.0
        EnumDestructablesInRect(area, nil, function()
            local candidate = GetEnumDestructable()
            local dx = GetDestructableX(candidate) - x
            local dy = GetDestructableY(candidate) - y
            local nextDistance = dx * dx + dy * dy
            if nextDistance < distance then
                result = candidate
                distance = nextDistance
            end
        end)
        RemoveRect(area)
        return result
    end

    function activity:suspendHostiles(x, y, radius)
        local group = CreateGroup()
        GroupEnumUnitsInRange(group, x, y, radius, nil)
        while true do
            local unit = FirstOfGroup(group)
            if unit == nil then break end
            GroupRemoveUnit(group, unit)
            if GetOwningPlayer(unit) == Player(PLAYER_NEUTRAL_AGGRESSIVE) then
                local restoredUnit = unit
                ShowUnit(restoredUnit, false)
                PauseUnit(restoredUnit, true)
                JTG.ScopeBorrow(session.scope, function()
                    PauseUnit(restoredUnit, false)
                    ShowUnit(restoredUnit, true)
                end)
            end
        end
        DestroyGroup(group)
    end

    function activity:clearOwnedArenaUnits()
        local group = CreateGroup()
        GroupEnumUnitsOfPlayer(group, CAMERA_PLAYER, nil)
        while true do
            local unit = FirstOfGroup(group)
            if unit == nil then break end
            GroupRemoveUnit(group, unit)
            local x = GetUnitX(unit)
            local y = GetUnitY(unit)
            if x >= 2048.0 and x <= 7808.0 and
                    y >= 2048.0 and y <= 7552.0 then
                RemoveUnit(unit)
            end
        end
        DestroyGroup(group)
    end

    function activity:createImportedLayout()
        self:installLayoutCapture()
        self.importedUnits = {}
        local assignments = {}
        local orderedLayout={}
        for _,structures in ipairs({true,false}) do
            for _,placement in ipairs(IMPORTED_LAYOUT) do
                if IsUnitIdType(FourCC(placement[1]),UNIT_TYPE_STRUCTURE)==structures then
                    orderedLayout[#orderedLayout+1]=placement
                end
            end
        end
        for _, placement in ipairs(orderedLayout) do
            local unit = CreateBaseUnit(session.scope, CAMERA_PLAYER,
                placement[1], placement[2], placement[3], placement[4])
            -- Keep the tutorial army from crossing an upkeep threshold while
            -- it is assembled. That threshold produces a global announcement
            -- before the first tutorial narration is visible.
            SetPlayerState(CAMERA_PLAYER, PLAYER_STATE_RESOURCE_FOOD_USED, 0)
            self.importedUnits[GetHandleId(unit)] = true
            if placement[5] ~= nil then
                self.workerActivities[GetHandleId(unit)] = {
                    activity = placement[5],
                    targetKind = placement[6],
                    targetX = placement[7],
                    targetY = placement[8],
                }
                table.insert(assignments, {
                    unit = unit,
                    activity = placement[5],
                    targetKind = placement[6],
                    targetX = placement[7],
                    targetY = placement[8],
                })
            end
        end

        for _, assignment in ipairs(assignments) do
            local target = nil
            if assignment.targetKind == "unit" then
                target = self:findGoldMine(
                    assignment.targetX, assignment.targetY)
            elseif assignment.targetKind == "destructable" then
                target = self:findDestructable(
                    assignment.targetX, assignment.targetY)
            end
            if target ~= nil then
                IssueTargetOrder(assignment.unit, "harvest", target)
            end
        end
        ClearSelection()
    end

    function activity:setup(current)
        JTG.BorrowCamera(current.scope, CAMERA_PLAYER)
        local previousRacePreference = RacePreferenceFor(
            GetPlayerRace(CAMERA_PLAYER))
        SetPlayerRacePreference(CAMERA_PLAYER, RACE_PREF_ORC)
        StopMusic(false)
        PlayMusic(ORC_TUTORIAL_MUSIC)
        JTG.ScopeBorrow(current.scope, function()
            SetPlayerRacePreference(CAMERA_PLAYER,
                previousRacePreference)
            StopMusic(false)
            SetMapMusic("Music", true, 0)
        end)
        local oldColor = GetPlayerColor(CAMERA_PLAYER)
        JTG.ScopeBorrow(current.scope,
            function() SetPlayerColor(CAMERA_PLAYER, oldColor) end)
        SetPlayerColor(CAMERA_PLAYER, BLUE_PLAYER_COLOR)

        -- Any native notification without a unit source falls back to the
        -- player's start location. Point that fallback at the tutorial base
        -- so Space never jumps back into the training arenas.
        local previousStartX = GetStartLocationX(0)
        local previousStartY = GetStartLocationY(0)
        DefineStartLocation(0, MAIN_BASE_X, MAIN_BASE_Y)
        SetPlayerStartLocation(CAMERA_PLAYER, 0)
        JTG.ScopeBorrow(current.scope, function()
            DefineStartLocation(0, previousStartX, previousStartY)
            SetPlayerStartLocation(CAMERA_PLAYER, 0)
        end)

        -- The tutorial bases should visibly begin with the first Spiked
        -- Barricades level. Restore the player's prior tech state on exit.
        local oldSpikedBarricades = GetPlayerTechCount(
            CAMERA_PLAYER, SPIKED_BARRICADES, true)
        SetPlayerTechResearched(CAMERA_PLAYER, SPIKED_BARRICADES,
            math.max(1, oldSpikedBarricades))
        JTG.ScopeBorrow(current.scope, function()
            SetPlayerTechResearched(CAMERA_PLAYER, SPIKED_BARRICADES,
                oldSpikedBarricades)
        end)

        -- Regular-map tutorials begin with explored terrain. Current vision is
        -- still supplied solely by the imported units and buildings.
        JTG.UseExploredWorldFog(CAMERA_PLAYER)

        local oldFoodUsed = GetPlayerState(CAMERA_PLAYER,
            PLAYER_STATE_RESOURCE_FOOD_USED)
        SetPlayerState(CAMERA_PLAYER, PLAYER_STATE_RESOURCE_FOOD_USED, 0)
        JTG.ScopeBorrow(current.scope, function()
            SetPlayerState(CAMERA_PLAYER, PLAYER_STATE_RESOURCE_FOOD_USED,
                oldFoodUsed)
        end)

        -- These camps were cleared while the reference bases were built. Hide
        -- only the overlapping camps; neutral hostiles elsewhere remain live.
        self:suspendHostiles(-4608.0, -3904.0, 1550.0)
        self:suspendHostiles(-2240.0, -6528.0, 1250.0)
        self:suspendHostiles(3648.0, -5120.0, 1700.0)
        self:suspendHostiles(-600.0, -5050.0, 1000.0)
        -- No Camera Tutorial event should originate in either legacy arena.
        -- Clear any player unit left there by a previous exercise or loaded
        -- activity before the tutorial begins producing notifications.
        self:clearOwnedArenaUnits()
        self:createImportedLayout()
        self:prepareNotificationGhoul()
        self:createZoomQuest(false)
        self:createIdleWorkerQuest(false)
        SetPlayerState(CAMERA_PLAYER, PLAYER_STATE_RESOURCE_FOOD_USED, 0)
        self.tickTimer = JTG.StartScopedTimer(current, current.scope,
            TICK_INTERVAL, true, function() self:tick() end)
    end

    function activity:start()
        if JTG.UI then JTG.UI.HideToolbar() end
        self:createPresentation()
        local target=JTG.Tutorial.ResolveStep(TUTORIAL_STEPS,session.restartData)
        if target>1 then self:restoreCheckpoint(target) else self:restoreWelcomeCheckpoint() end
    end

    function activity:setPaused(paused)
        self.locallyPaused = paused == true
        self:refreshControls()
    end

    function activity:setOverlayVisible(visible)
        self:setPresentationVisible(visible)
    end

    function activity:hidePresentationForMenu()
        self:setPresentationVisible(false)
    end

    function activity:restorePresentation()
        if JTG.UI then
            JTG.UI.HideToolbar()
            JTG.UI.currentView = {kind = "gameplay"}
        end
        self:setPresentationVisible(true)
        self:refreshControls()
    end

    function activity:rebuildPresentation()
        self.frames = {}
        self.actions = {}
        self.clickTrigger = nil
        self:createPresentation()
        self:renderNarration()
        if self.cameraRemaining > 0.0 and GetLocalPlayer() == CAMERA_PLAYER then
            self:takeCameraTo(MAIN_BASE_X, MAIN_BASE_Y,
                self.cameraRemaining)
        end
    end

    function activity:discardPresentationForLoad()
        self.frames = {}
        self.actions = {}
        self.clickTrigger = nil
    end

    function activity:cleanup()
        self:stopNotificationAttack()
        self:clearArrow()
        ClearTextMessages()
        -- Units made manually while refining the imported layout are not
        -- scope-owned. Remove only those extras here; imported units are
        -- removed by the activity scope itself.
        local group = CreateGroup()
        GroupEnumUnitsOfPlayer(group, CAMERA_PLAYER, nil)
        while true do
            local unit = FirstOfGroup(group)
            if unit == nil then break end
            GroupRemoveUnit(group, unit)
            if not (self.importedUnits or {})[GetHandleId(unit)] then
                RemoveUnit(unit)
            end
        end
        DestroyGroup(group)
        self.frames = {}
        self.actions = {}
    end

    JTG.Tutorial.InstallRunner(activity, session, {id="learn.camera", player=CAMERA_PLAYER, steps=TUTORIAL_STEPS, requireStableIds=true, entries = {"showStep", "showOptionalStep", "showOptionalCompletion", "showCompletion",
            "restoreWelcomeCheckpoint", "restoreZoomCheckpoint", "restoreMovementCheckpoint",
            "restoreBaseControlCheckpoint", "restoreArmyControlCheckpoint", "returnFromOptionalSection"},
        sceneExit=function(self,previous,nextStep)
            if previous.trigger=='notificationAttack' and (not nextStep or nextStep.trigger~='notificationAttack') then self:stopNotificationAttack() end
            if previous.trigger=='notificationProduction' then self:stopNotificationProduction() end
        end})
    return activity
end
