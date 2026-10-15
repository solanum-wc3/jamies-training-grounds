-- Hotkey Setup tutorial. File exports are suspended until clean distribution
-- is available; retain their authored narration for possible future use.
JTG = JTG or {}

local HOTKEY_PLAYER = Player(0)
local TICK_INTERVAL = 0.05
local NARRATION_DURATION = 3600.0
local EXPORT_ENABLED = false

local STEPS = {
    {
        id = "hotkeys.001",
        checkpoint = "welcome", wait = true, sectionEnd = true,
        lines = {
            "{Heading: WELCOME}",
            "Welcome to the Hotkeys Tutorial!",
            "This tutorial is going to be a bit different. We are not going to talk about game mechanics, but instead talk about how to best set up your {Term: hotkeys}.",
            "Once you are done reading, press the {Button: Continue} or {Button: Next} button to move on!",
        },
    },
    {
        id = "hotkeys.002",
        checkpoint = "why", wait = true,
        lines = {
            "{Heading: WHY USE HOTKEYS?}",
            "Should you use {Term: hotkeys}?",
            "The answer is simple: Yes!",
            "If you want to get good at the game, you basically have to.",
        },
    },
    {
        id = "hotkeys.003",
        wait = true,
        lines = {
            "Manually clicking every button for every ability or command slows you down significantly.",
            "For every ability, you have to move the mouse cursor away from the action, to the command grid, click a button, and then move it back to the action.",
            "It takes time away from giving unit commands or moving the camera, and it introduces a lot of room for error.",
        },
    },
    {
        id = "hotkeys.004",
        wait = true,
        lines = {
            "You are effectively playing with one hand tied behind your back - your keyboard hand - and you are doing everything with your mouse hand.",
        },
    },
    {
        id = "hotkeys.005",
        wait = true,
        lines = {
            "When using hotkeys, you distribute the load pretty evenly between your mouse hand and your keyboard hand.",
            "The mouse hand aims, clicks, and adjusts the camera, while the keyboard hand chooses commands and navigates the interface.",
        },
    },
    {
        id = "hotkeys.006",
        wait = true, sectionEnd = true,
        lines = {
            "One measurement of play is \"actions per minute\", or {Term: APM}.",
            "You can even go to the game options and choose to have the game display them live while you play.",
            "When playing without hotkeys, you limit your {Term: APM} to what you can do with one hand.",
        },
    },
    {
        id = "hotkeys.007",
        checkpoint = "which", wait = true,
        lines = {
            "{Heading: LEGACY HOTKEYS}",
            "By default, Warcraft III uses {Term: Legacy} Hotkeys.",
            "These are the ones the game came with back in 2002 and 2003.",
            "They are oriented around the names of abilities, units and buildings, and spread all over the keyboard.",
        },
    },
    {
        id = "hotkeys.008",
        wait = true, trigger = "commandArrow",
        lines = {
            "You can check out some of the units under your control.",
            "Hover over their buttons in the command grid, to see their {Term: Tooltips}!",
            "Usually one letter will be highlighted in yellow. This is the hotkey for that button.",
        },
    },
    {
        id = "hotkeys.009",
        wait = true,
        lines = {
            "These days, nobody will seriously recommend playing with {Term: Legacy} Hotkeys.",
            "This hotkey set requires a lot of acrobatics of your hand.",
            "If you are not a pianist, you will struggle.",
        },
    },
    {
        id = "hotkeys.010",
        wait = true,
        lines = {
            "{Heading: GRID HOTKEYS}",
            "Warcraft III Reforged introduced {Term: Grid} Hotkeys.",
            "These compact all major hotkeys into the 4x3 cluster of QWER, ASDF and ZXCV (or YXCV).",
            "This is the best option, if you want to have a simple solution.",
            "There are better solutions, but they get complicated.",
            "If you want to have it simple for now, it is recommended you simply go with {Term: Grid}.",
        },
    },
    {
        id = "hotkeys.011",
        wait = true,
        lines = {
            "You can change your hotkey setup to Grid by going to {Menu: Input} -> {Menu: Key Bindings} in the game options, and selecting Grid there.",
            "This cannot be done while you are in a map, so {Term: Quicksave} your game with {Input: F6}, leave this map, and check it out!",
        },
    },
    {
        id = "hotkeys.012",
        wait = true,
        lines = {
            "{Heading: CUSTOM HOTKEYS}",
            "From here on out, we are going into the better solutions.",
            "This is where it gets complicated.",
            "If you want to proceed using {Term: Grid}, you can jump to the next {Input: Topic}.",
        },
    },
    {
        id = "hotkeys.013",
        wait = true,
        lines = {
            "When setting your hotkeys to {Term: Grid}, you probably saw that there is a third option: {Term: Custom}.",
            "This allows you to freely assign hotkeys as you see fit.",
            "It also allows you to change the positions of buttons.",
        },
    },
    {
        id = "hotkeys.014",
        wait = true,
        lines = {
            "This is of course complicated, especially for a newbie.",
            "For this reason, you can use this map to help set you up. (Assuming you use Windows)",
        },
    },
    {
        id = "hotkeys.015",
        wait = true,
        lines = {
            "Again, to change the hotkey setup, you have to {Term: Quicksave} your game with {Input: F6}, leave this map, and go to the game options!",
        },
    },
    {
        id = "hotkeys.016",
        wait = true,
        lines = {
            "Changing custom tooltips also requires you to go to {Menu: \\Users\\YourUserName\\Documents\\Warcraft III}, and into the folder {Menu: CustomKeyBindings}.",
            "There you will find a file called {Green Font: CustomKeys.txt}, which contains a list of key bindings.",
        },
    },
    {
        id = "hotkeys.017",
        wait = true, trigger = "highlightExport",
        lines = {
            "In the {Menu: Warcraft III} folder, there is also a folder called {Menu: CustomMapData}.",
            "Press the {Input: Export} button! Three files will appear in that folder. One for a {Green Font: QWERTY}, one for a {Green Font: QWERTZ} keyboard layout, and one you do not need yet.",
            "You can now rename the one that fits your layout to {Green Font: \"CustomKeys.txt\"}, and put it into the {Menu: CustomKeyBindings} folder.",
            "It is recommended you first {Input: rename your old key bindings file}, so it does not get deleted. (Just add a number to the name.)",
        },
    },
    {
        id = "hotkeys.018",
        wait = true,
        lines = {
            "This sets you up with a pretty involved adjustment of the hotkeys.",
            "Notably, the command grid buttons are moved so they fit the key arrangement on the keyboard.",
            "This means that a button with the hotkey {Input: Q} will always be displayed on the top left spot, for example.",
        },
    },
    {
        id = "hotkeys.019",
        wait = true,
        lines = {
            "It also changes around some of the positions of buttons.",
            "For example, the layout of the build menus of workers, so they are more consistent across races.",
            "Or the item arrangement in shops, so the items better fit the order in which they are unlocked and remain consistent across all shops.",
        },
    },
    {
        id = "hotkeys.020",
        wait = true,
        lines = {
            "Of course you do not have to keep this hotkey setup.",
            "It is included here as a demonstration of what can be done.",
        },
    },
    {
        id = "hotkeys.021",
        wait = true, sectionEnd = true,
        lines = {
            "Tip: If you want to play the campaign \"The Founding of Durotar\", or the new campaign of The Forsaken Kingdom, it is recommended you change your hotkey layout to {Term: Grid} again while you do.",
            "The different campaigns have a lot of special units with complicated ability combinations, and a {Term: Custom} setup can cause some confusion here.",
        },
    },
    {
        id = "hotkeys.022",
        checkpoint = "resources", wait = true,
        lines = {
            "{Heading: HOTKEY RESOURCES}",
            "If you have looked into the hotkeys file, you will have seen that all the buttons only have a coded description.",
            "Without knowing which code corresponds to which button, you cannot do anything here directly.",
        },
    },
    {
        id = "hotkeys.023",
        wait = true,
        lines = {
            "You have probably noticed that there is a part of the options menu called {Hotkeys}.",
            "When setting up custom hotkeys, you can start by using this one.",
            "However, it only allows you to change the keys, not the position of buttons.",
        },
    },
    {
        id = "hotkeys.024",
        wait = true,
        lines = {
            "People from the community have created their own interfaces to allow easy editing of all aspects of hotkeys.",
            "One of the simplest can be found by using a search engine and typing in \"{Input: warcraft 3 hotkey editor}\".",
            "The first result should lead you to a GitHub page belonging to a {Yellow Font: J.C.Fields}, where you can upload your hotkey file, edit it, and download the changed version.",
            "This page allows you to change hotkey positions by simply dragging and dropping the buttons in the displayed command grid.",
        },
    },
    {
        id = "hotkeys.025",
        wait = true, sectionEnd = true,
        lines = {
            "Another such resource is the more involved hotkey editor by {Yellow Font: clemenscodes}.",
            "The main problem with setting up custom hotkeys is that abilities are shared between a lot of units, so making a position change can conflict down the line.",
            "This one is very good at showing you where hotkeys or button positions conflict. Warcraft III can show this too, but not nearly as well.",
            "However, this tool will automatically change the button tooltips, so it is only recommended if you don't mind this, or if you know how to change them back.",
        },
    },
    {
        id = "hotkeys.026",
        checkpoint = "inventory", wait = true,
        lines = {
            "{Heading: CHANGING INVENTORY HOTKEYS}",
            "By default, inventory spots are tied to the {Input: Numpad}.",
            "These are far away from the other keys, and some keyboards do not have the buttons at all.",
            "For this reason, many players rebind them.",
            "This can be done in the Warcraft III options.",
        },
    },
    {
        id = "hotkeys.027",
        wait = true,
        lines = {
            "When using {Term: Grid} or {Term: Custom}, an obvious location to put them in is the 2x3 cluster of TY (or TZ), GH and BN.",
            "However, many people, especially coming from the MOBA scene, prefer using a Modifier key (Alt, Shift, CTRL) and using the cluster of QW, AS and ZX (or YX).",
            "The problem: Warcraft III does not support this.",
        },
    },
    {
        id = "hotkeys.028",
        wait = true,
        lines = {
            "The only way to do this is to use an extra program just to rebind a key combination onto the relevant {Input: Numpad} keyboard keys.",
            "This little program has to run in the background while Warcraft III is running.",
        },
    },
    {
        id = "hotkeys.029",
        wait = true,
        lines = {
            "The simplest tool to use for this can be found by using a search engine and typing in \"{Input: warcraft inventory hotkeys}\".",
            "The first result should be the tool by {Yellow Font: AucT}.",
            "You can use it to customize your inventory buttons in any way you want.",
        },
    },
    {
        id = "hotkeys.030",
        wait = true,
        lines = {
            "However, be aware that this tool does not work properly if you have rebound the inventory hotkeys away from the {Input: Numpad} in the Warcraft options.",
            "You have to reset them to default before using it.",
            "The tool makes your operating system believe that {Input: Alt+Q} is really {Input: Num1} (for example). If Num1 is not the right key, nothing will happen.",
        },
    },
    {
        id = "hotkeys.031",
        wait = true, sectionEnd = true,
        lines = {
            "Since you need to have the program running while the game is running, it is easiest to start them at the same time.",
            "Even simpler, you can do this using the same shortcut on your Desktop. (assuming you are using Windows)",
            "Pressing the {Button: Export} button earlier also exported a file called {Green Font: README_ShortcutSetup.txt}, which has instructions on how to do this.",
        },
    },
    {
        id = "hotkeys.032",
        terminal = true, trigger = "highlightMenu",
        lines = {
            "{Heading: END OF TUTORIAL}",
            "This concludes the hotkeys tutorial. Press the {Button: Menu} button to choose another tutorial!",
        },
    },
}

-- Preserve authored step indices and Topics destinations while omitting the
-- unavailable export workflow and descriptions that depend on its files.
if not EXPORT_ENABLED then
    for _, index in ipairs({14, 17, 18, 19, 20}) do
        STEPS[index].hidden = true
    end
end

local TOPICS = JTG.Tutorial.TopicSteps(STEPS, {
    {label = "Welcome", stepId = "hotkeys.001"},
    {label = "Why Use Hotkeys", stepId = "hotkeys.002"},
    {label = "Which Hotkeys?", stepId = "hotkeys.007"},
    {label = "Hotkey Resources", stepId = "hotkeys.022"},
    {label = "The Inventory", stepId = "hotkeys.026"},
})

local UNIT_LAYOUT = {
    {rawcode = "Huth", x = 4864, y = 3510, facing = 270, hero = true},
    {rawcode = "hpea", x = 4384, y = 4010, facing = 270},
    {rawcode = "opeo", x = 4704, y = 4010, facing = 270},
    {rawcode = "uaco", x = 5024, y = 4010, facing = 270},
    {rawcode = "ewsp", x = 5344, y = 4010, facing = 270},
    {rawcode = "hvlt", x = 3464, y = 2700, facing = 90, shop = true},
    {rawcode = "ovln", x = 4164, y = 2700, facing = 90, shop = true},
    {rawcode = "utom", x = 4864, y = 2700, facing = 90, shop = true},
    {rawcode = "eden", x = 5564, y = 2700, facing = 90, shop = true},
    {rawcode = "ngme", x = 6264, y = 2700, facing = 90, shop = true},
}

local FormatNarration = JTG.Tutorial.FormatNarration

local CreateTutorialButton = JTG.Tutorial.CreateButton

function JTG.CreateHotkeySetupTutorialActivity(session)
    local activity = {
        step = 1,
        checkpoint = "welcome",
        waitingForContinue = true,
        complete = false,
        locallyPaused = false,
        topicsOpen = false,
        presentationVisible = true,
        narrationBlocks = {},
        frames = {},
        actions = {},
        buttonEnabled = {},
        units = {},
        arrowActive = false,
        arrowBlinking = false,
        arrowElapsed = 0,
        arrowBlinkElapsed = 0,
        arrowVisible = false,
    }

    function activity:refreshControls()
        JTG.UI.RefreshWelcomeArrow(self)
        if self.frames.continue == nil then return end
        local current = STEPS[self.step]
        local canContinue = self.waitingForContinue and not self.complete
        BlzFrameSetText(self.frames.continue,
            current ~= nil and current.sectionEnd and "Next" or "Continue")
        self:setButtonEnabled(self.frames.continue, canContinue)
        self:setButtonEnabled(self.frames.back, self.step > 1 or self.complete)
        local paused = JTG.UI and JTG.UI.exercisePaused == true
        BlzFrameSetText(self.frames.pause, paused and
            "|cffffffffUnpause|r" or "|cffffcc00Pause|r")
        if self.frames.continueHighlight ~= nil then
            BlzFrameSetVisible(self.frames.continueHighlight,
                canContinue and self.presentationVisible and not self.topicsOpen)
        end
    end

    function activity:clearArrow()
        self.arrowActive = false
        self.arrowBlinking = false
        self.arrowElapsed = 0
        self.arrowBlinkElapsed = 0
        self.arrowVisible = false
        if self.frames.arrow ~= nil then
            BlzFrameSetVisible(self.frames.arrow, false)
        end
    end


    function activity:showCommandArrow()
        local target = BlzGetOriginFrame(ORIGIN_FRAME_COMMAND_BUTTON, 0)
        if target == nil or self.frames.arrow == nil then return end
        BlzFrameClearAllPoints(self.frames.arrow)
        BlzFrameSetPoint(self.frames.arrow, FRAMEPOINT_BOTTOM, target,
            FRAMEPOINT_TOP, 0.048, 0.004)
        self.arrowActive = true
        self.arrowBlinking = true
        self.arrowElapsed = 0
        self.arrowBlinkElapsed = 0
        self.arrowVisible = true
        BlzFrameSetVisible(self.frames.arrow,
            self.presentationVisible and not self.topicsOpen)
    end

    function activity:runStepTrigger(spec)
        local trigger = spec and spec.trigger
        if trigger == "commandArrow" then
            self:showCommandArrow()
        elseif trigger == "highlightExport" and EXPORT_ENABLED then
            if self.frames.exportHighlight ~= nil then
                BlzFrameSetVisible(self.frames.exportHighlight,
                    self.presentationVisible and not self.topicsOpen)
            end
        elseif trigger == "highlightMenu" then
            if self.frames.menuHighlight ~= nil then
                BlzFrameSetVisible(self.frames.menuHighlight,
                    self.presentationVisible and not self.topicsOpen)
            end
        end
    end

    function activity:showStep(index, direction)
        while STEPS[index] and STEPS[index].hidden do
            index = index + (direction or 1)
        end
        local spec = STEPS[index]
        if spec == nil then return end
        self.step = index
        self.checkpoint = spec.checkpoint or self.checkpoint
        self.complete = spec.terminal == true
        self.waitingForContinue = spec.wait == true and not self.complete
        self:clearNarration()
        local lines = {}
        for _, line in ipairs(spec.lines or {}) do
            if EXPORT_ENABLED or not line:find("{Button: Export}", 1, true) then
                lines[#lines + 1] = line
            end
        end
        local text = FormatNarration(table.concat(lines, "\n"))
        table.insert(self.narrationBlocks, text)
        if self.presentationVisible and not self.topicsOpen then
            DisplayTimedTextToPlayer(HOTKEY_PLAYER, 0, 0,
                NARRATION_DURATION, text)
        end
        self:runStepTrigger(spec)
        if index==1 then JTG.UI.StartWelcomeArrow(self) end
        self:refreshControls()
    end

    function activity:continueTutorial()
        if not self.waitingForContinue or self.complete then return end
        self:showStep(math.min(#STEPS, self.step + 1))
    end

    function activity:goBack()
        if self.step <= 1 and not self.complete then return end
        self:setTopicsVisible(false)
        local target=math.max(1,self.step-1)
        while STEPS[target] and STEPS[target].hidden do target=target-1 end
        JTG.Tutorial.RestoreAt(self,target,nil,function(index) self:showStep(index,-1) end)
    end

    function activity:restoreTopic(index)
        self:setTopicsVisible(false)
        JTG.Tutorial.RestoreAt(self,index,nil,function(target) self:showStep(target) end)
    end

    function activity:restoreCheckpoint(index) return self:restoreTopic(index) end

    function activity:openMenu()
        JTG.Tutorial.OpenMenu(self,"learn")
    end

    function activity:togglePause()
        JTG.Tutorial.TogglePause(self)
    end

    function activity:exportCustomKeys()
        if not EXPORT_ENABLED then return false end
        if GetLocalPlayer() == HOTKEY_PLAYER then
            for _, export in ipairs(JTG.CustomKeyExports or {}) do
                PreloadGenClear()
                PreloadGenStart()
                for _, chunk in ipairs(export.chunks or {}) do
                    -- Close the generated preload call, place the INI text in
                    -- the file, and comment out the remainder of that line.
                    Preload("\")\n" .. chunk .. "\n//")
                end
                PreloadGenEnd(export.filename)
            end
        end
        DisplayTimedTextToPlayer(HOTKEY_PLAYER, 0, 0, 20,
            "|cffffcc00Hotkey setup files exported.|r\n" ..
            "Documents\\Warcraft III\\CustomMapData\\\n" ..
            "CustomKeys-SolanumQWERTY.txt\n" ..
            "CustomKeys-SolanumQWERTZ.txt\n" ..
            "README_ShortcutSetup.txt")
    end

    function activity:setTopicsVisible(visible)
        self.topicsOpen = visible == true
        if self.frames.topicsMenu ~= nil then
            BlzFrameSetVisible(self.frames.topicsMenu,
                self.presentationVisible and self.topicsOpen)
        end
        if self.frames.arrow ~= nil then
            BlzFrameSetVisible(self.frames.arrow,
                self.presentationVisible and self.arrowActive and
                self.arrowVisible and not self.topicsOpen)
        end
        self:renderNarration()
        self:refreshControls()
    end

    function activity:createPresentation()
        local root = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        local scope = session.presentationScope
        local suffix = tostring(session.generation) .. "x" ..
            tostring((JTG.UI and JTG.UI.epoch) or 0)
        self.frames = {}
        self.actions = {}
        self.buttonEnabled = {}

        local labels = {
            {"menu", "Menu", 1}, {"back", "Back", 2},
            {"topics", "Topics", 3}, {"continue", "Continue", 5},
            {"pause", "Pause", 7},
        }
        if EXPORT_ENABLED then labels[#labels + 1] = {"export", "Export", 8} end
        local bar = JTG.Tutorial.CreateToolbar(self, scope, root, "JTGHotkeyTutorial", suffix, labels)
        JTG.Tutorial.CreateHighlight(self, scope, "JTGHotkey", suffix, "continue")
        JTG.Tutorial.CreateHighlight(self, scope, "JTGHotkey", suffix, "menu")
        JTG.Tutorial.CreateHighlight(self, scope, "JTGHotkey", suffix, "pause")
        if EXPORT_ENABLED then JTG.Tutorial.CreateHighlight(self, scope, "JTGHotkey", suffix, "export") end

        local arrow = JTG.ScopeTrackFrame(scope, BlzCreateFrameByType("BACKDROP",
            "JTGHotkeyCommandArrow" .. suffix, root, "", 0))
        BlzFrameSetSize(arrow, 0.078, 0.078)
        BlzFrameSetTexture(arrow, "JTGMenu\\TutorialArrowDown.dds", 0, true)
        BlzFrameSetEnable(arrow, false)
        BlzFrameSetLevel(arrow, 30)
        BlzFrameSetVisible(arrow, false)
        self.frames.arrow = arrow
        self.frames.welcomeArrow=JTG.UI.CreateWelcomeArrow(scope,root,self.frames.continue,
            "JTGHotkeyWelcomeArrow"..suffix)

        local topics = JTG.ScopeTrackFrame(scope, BlzCreateFrameByType("FRAME",
            "JTGHotkeyTopics" .. suffix, root, "", 0))

        local skin = JTG.ScopeTrackFrame(scope, BlzCreateFrame("EscMenuBackdrop",
            topics, 0, 980 + session.generation))
        BlzFrameSetPoint(skin, FRAMEPOINT_TOPLEFT, topics,
            FRAMEPOINT_TOPLEFT, 0, 0)
        BlzFrameSetPoint(skin, FRAMEPOINT_BOTTOMRIGHT, topics,
            FRAMEPOINT_BOTTOMRIGHT, 0, 0)
        BlzFrameSetEnable(skin, false)
        self.frames.topicsMenu = topics

        local topicButtons = {}
        for index, topic in ipairs(TOPICS) do
            local button = JTG.ScopeTrackFrame(scope, CreateTutorialButton(
                "JTGHotkeyTopic" .. index .. suffix, topics,
                topic.label, 0.125))

            topicButtons[index] = button
        end
        local close = JTG.ScopeTrackFrame(scope, CreateTutorialButton(
            "JTGHotkeyTopicsClose" .. suffix, topics, "Close", 0.10))

        JTG.LayoutChoicePopup(topics,topicButtons,close)
        JTG.Tutorial.BindClicks(self, scope)
        self:registerClick(self.frames.continue,
            function() self:continueTutorial() end)
        self:registerClick(self.frames.back, function() self:goBack() end, "return")
        self:registerClick(self.frames.menu, function() self:openMenu() end)
        self:registerClick(self.frames.pause, function() self:togglePause() end,
            function() return JTG.UI.exercisePaused and "return" or "normal" end)
        if EXPORT_ENABLED then
            self:registerClick(self.frames.export,
                function() self:exportCustomKeys() end)
        end
        self:registerClick(self.frames.topics,
            function() self:setTopicsVisible(not self.topicsOpen) end)
        for index, topic in ipairs(TOPICS) do
            self:registerClick(topicButtons[index],
                function() self:restoreTopic(topic.step) end)
        end
        self:registerClick(close,
            function() self:setTopicsVisible(false) end, "return")

        self:setTopicsVisible(self.topicsOpen)
        self:refreshControls()
    end

    function activity:setPresentationVisible(visible)
        self.presentationVisible = visible == true
        if self.frames.bar ~= nil then
            BlzFrameSetVisible(self.frames.bar, self.presentationVisible)
        end
        if self.frames.topicsMenu ~= nil then
            BlzFrameSetVisible(self.frames.topicsMenu,
                self.presentationVisible and self.topicsOpen)
        end
        if self.frames.arrow ~= nil then
            BlzFrameSetVisible(self.frames.arrow,
                self.presentationVisible and self.arrowActive and
                self.arrowVisible and not self.topicsOpen)
        end
        self:renderNarration()
        self:refreshControls()
        self:runStepTrigger(STEPS[self.step])
    end

    function activity:tick()
        if self.locallyPaused or self.topicsOpen then return end
        JTG.UI.TickWelcomeArrow(self,TICK_INTERVAL)
        if self.arrowActive and self.arrowBlinking and self.frames.arrow ~= nil then
            self.arrowElapsed = self.arrowElapsed + TICK_INTERVAL
            self.arrowBlinkElapsed = self.arrowBlinkElapsed + TICK_INTERVAL
            if self.arrowElapsed >= 5.0 then
                self.arrowBlinking = false
                self.arrowVisible = true
                BlzFrameSetVisible(self.frames.arrow, self.presentationVisible)
            elseif self.arrowBlinkElapsed >= 0.35 then
                self.arrowBlinkElapsed = 0
                self.arrowVisible = not self.arrowVisible
                BlzFrameSetVisible(self.frames.arrow,
                    self.presentationVisible and self.arrowVisible)
            end
        end
    end

    function activity:setup(current)
        JTG.BorrowCamera(current.scope, HOTKEY_PLAYER)
        JTG.ResetWorldFog(HOTKEY_PLAYER)
        local oldFood = GetPlayerState(HOTKEY_PLAYER,
            PLAYER_STATE_RESOURCE_FOOD_USED)
        JTG.ScopeBorrow(current.scope, function()
            SetPlayerState(HOTKEY_PLAYER,
                PLAYER_STATE_RESOURCE_FOOD_USED, oldFood)
        end)

        for _, spec in ipairs(UNIT_LAYOUT) do
            local unit = JTG.CreateScopedUnit(current.scope,HOTKEY_PLAYER,FourCC(spec.rawcode),spec.x,spec.y,spec.facing)
            table.insert(self.units, unit)
            if spec.hero then
                self.paladin = unit
                SetHeroLevel(unit, 10, false)
                for _ = 1, 3 do SelectHeroSkill(unit, FourCC("AHhb")) end
                for _ = 1, 3 do SelectHeroSkill(unit, FourCC("AHad")) end
                for _ = 1, 3 do SelectHeroSkill(unit, FourCC("AHds")) end
                SelectHeroSkill(unit, FourCC("AHre"))
                for _, itemId in ipairs({"rde1", "bspd", "ckng",
                        "stwp", "pman", "phea"}) do
                    UnitAddItemById(unit, FourCC(itemId))
                end
            end
        end

        -- Hidden tier-three halls satisfy shop dependencies without adding
        -- more visible buildings to the demonstration line.
        local hidden = {
            {"hcas", 4768, 3392}, {"ofrt", 4832, 3392},
            {"unp2", 4896, 3392}, {"etoe", 4960, 3392},
        }
        for _, spec in ipairs(hidden) do
            local unit = JTG.CreateScopedUnit(current.scope,HOTKEY_PLAYER,FourCC(spec[1]),spec[2],spec[3],0)
            ShowUnit(unit, false)
            SetUnitPathing(unit, false)
            SetUnitInvulnerable(unit, true)
            table.insert(self.units, unit)
        end
        -- The hidden Undead hall is created only to unlock shop buttons.
        -- Clear its blight after Warcraft has applied the building terrain, then
        -- remove the halls before clearing it again during activity cleanup.
        local clearHiddenBlight = JTG.ClearBlightAfterActivity(current,
            HOTKEY_PLAYER, 4896, 3392, 1024)
        clearHiddenBlight()
        JTG.StartScopedTimer(current, current.scope, 0.10, false,
            clearHiddenBlight)
        SetPlayerState(HOTKEY_PLAYER, PLAYER_STATE_RESOURCE_FOOD_USED, 0)
        self:makeTimer(TICK_INTERVAL, true, function() self:tick() end)
    end

    function activity:start()
        if JTG.UI then JTG.UI.HideToolbar() end
        if GetLocalPlayer() == HOTKEY_PLAYER then
            JTG.Tutorial.MoveCamera(HOTKEY_PLAYER, session.scene.centerX, session.scene.centerY)
            ClearSelection()
            if self.paladin ~= nil then SelectUnit(self.paladin, true) end
        end
        self:createPresentation()
        self:showStep(JTG.Tutorial.ResolveStep(STEPS,session.restartData))
    end

    function activity:captureResetState() return JTG.Tutorial.CaptureCheckpoint(self) end

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
    end

    function activity:rebuildPresentation()
        self.frames = {}
        self.actions = {}
        self.clickTrigger = nil
        self:createPresentation()
        self:renderNarration()
        self:runStepTrigger(STEPS[self.step])
    end

    function activity:discardPresentationForLoad()
        self.frames = {}
        self.actions = {}
        self.clickTrigger = nil
    end

    function activity:cleanup()
        JTG.UI.ClearWelcomeArrow(self)
        ClearTextMessages()
        self:clearArrow()
        if GetLocalPlayer() == HOTKEY_PLAYER then ClearSelection() end
        self.frames = {}
        self.actions = {}
    end

    JTG.Tutorial.InstallRunner(activity, session, {id="learn.hotkey_setup", player=HOTKEY_PLAYER, steps=STEPS, requireStableIds=true})
    return activity
end
