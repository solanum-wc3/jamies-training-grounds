-- Hotkey Setup tutorial. This tutorial presents Warcraft's hotkey options and
-- exports two ready-to-edit CustomKeys examples and their shortcut-setup
-- instructions into CustomMapData.
JTG = JTG or {}

local HOTKEY_PLAYER = Player(0)
local TICK_INTERVAL = 0.05
local NARRATION_DURATION = 3600.0

local STEPS = {
    {
        checkpoint = "welcome", wait = true, sectionEnd = true,
        lines = {
            "{Heading: WELCOME}",
            "Welcome to the Hotkeys Tutorial!",
            "This tutorial is going to be a bit different. We are not going to talk about game mechanics, but instead talk about how to best set up your {Term: hotkeys}.",
            "Once you are done reading, press the {Button: Continue} or {Button: Next} button to move on!",
        },
    },
    {
        checkpoint = "why", wait = true,
        lines = {
            "{Heading: WHY USE HOTKEYS?}",
            "Should you use {Term: hotkeys}?",
            "The answer is simple: Yes!",
            "If you want to get good at the game, you basically have to.",
        },
    },
    {
        wait = true,
        lines = {
            "Manually clicking every button for every ability or command, it slows you down significantly.",
            "For every ability, you have to move the mouse cursor away from the action, to the command grid, click a button it, and then move it back to the action.",
            "It takes time away from giving unit commands or moving the camera, and it introduces a lot of opportunity for error.",
        },
    },
    {
        wait = true,
        lines = {
            "You are effectively playing with one hand tied behind your back - your keyboard hand - and you are doing everything with your mouse hand.",
        },
    },
    {
        wait = true,
        lines = {
            "When using hotkeys, you distribute the load pretty evenly between your mouse hand and your keyboard hand.",
            "The mouse hand aims, clicks, and adjusts the camera, while the keyboard hand chooses commands and navigates the interface.",
        },
    },
    {
        wait = true, sectionEnd = true,
        lines = {
            "One measurement of play is \"actions per minute\", or {Term: APM}.",
            "You can even go to the game options and choose to have the game display them live while you play.",
            "When playing without hotkeys, you limit your {Term: APM} to what you can do with one hand.",
        },
    },
    {
        checkpoint = "which", wait = true,
        lines = {
            "{Heading: LEGACY HOTKEYS}",
            "By default, Warcraft III uses {Term: Legacy} Hotkeys.",
            "These are the ones the game came with back in 2002 and 2003.",
            "They are oriented around the names of abilities, units and buildings, and spread all over the keyboard.",
        },
    },
    {
        wait = true, trigger = "commandArrow",
        lines = {
            "You can check out some of the units under your control.",
            "Hover over their buttons in the command grid, to see their {Term: Tool Tips}!",
            "Usually one letter will be highlighted in yellow. This is the hotkey for that button.",
        },
    },
    {
        wait = true,
        lines = {
            "These days, nobody will seriously recommend playing with {Term: Legacy} Hotkeys.",
            "This hotkey set requires a lot of acrobatics of your hand.",
            "If you are not a pianist, you will struggle.",
        },
    },
    {
        wait = true,
        lines = {
            "{Heading: GRID HOTKEYS}",
            "For this reason, Warcraft III Reforged introduced {Term: Grid} Hotkeys.",
            "These compact all major hotkeys into the 4x3 cluster of QWER, ASDF and ZXCV (or YXCV).",
            "This is the best option, if you want to have a simple solution.",
            "There are better solutions, but they get complicated.",
            "If you want to have it simple for now, it is recommended you simply go with {Term: Grid}.",
        },
    },
    {
        wait = true,
        lines = {
            "You can change your hotkey setup to Grid by going to {Menu: Input} -> {Menu: Key Bindings} in the game options, and selecting Grid there.",
            "This cannot be done while you are in a map, so {Term: Quicksave} your game with {Input: F6}, leave this map, and check it out!",
        },
    },
    {
        wait = true,
        lines = {
            "{Heading: CUSTOM HOTKEYS}",
            "From here on out, we are going into the better solutions.",
            "This is where it gets complicated.",
            "If you want to proceed using {Term: Grid}, you can jump the the next {Input: Topic}.",
        },
    },
    {
        wait = true,
        lines = {
            "When setting your hotkeys to {Term: Grid}, you probably saw that there is a third option: {Term: Custom}.",
            "This allows you to freely assign hotkeys as you see fit.",
            "It also allows you to change the positions of buttons.",
        },
    },
    {
        wait = true,
        lines = {
            "This is of course complicated, especially for a newbie.",
            "For this reason, you can use this map to help set you up. (Assuming you use Windows)",
        },
    },
    {
        wait = true,
        lines = {
            "Again, to change the hotkey setup, you have to {Term: Quicksave} your game with {Input: F6}, leave this map, and go to the game options!",
        },
    },
    {
        wait = true,
        lines = {
            "Changing custom tooltips also requires you go to {Menu: \\Users\\YourUserName\\Documents\\Warcraft III}, and into the folder {Menu: CustomKeyBindings}.",
            "There you will find a file called {Green Font: CustomKeys.txt}, which contains a list of key bindings.",
        },
    },
    {
        wait = true, trigger = "highlightExport",
        lines = {
            "In the {Menu: Warcraft III} folder, there is also a folder called {Menu: CustomMapData}.",
            "Press the {Input: Export} button! Three files will appear in that folder. One for a {Green Font: QWERTY}, one for a {Green Font: QWERTZ} keyboard layout, and one you do not need yet.",
            "You can now rename the one that fits your layout to {Green Font: \"CustomKeys.txt\"}, and put it into the {Menu: CustomKeyBindings} folder.",
            "It is recommended you first {Input: rename your old key bindings file}, so it does not get deleted. (Just add a number to the name.)",
        },
    },
    {
        wait = true,
        lines = {
            "This sets you up with a pretty involved adjustment of the hotkeys.",
            "Notably, unit the command grid buttons are moved so they fit the key arrangement on the keyboard.",
            "This means that a button with the hotkey {Input: Q} will be on the top left spot, for example.",
        },
    },
    {
        wait = true,
        lines = {
            "It also changes around some of the positions of buttons.",
            "For example, the layout of the build menus of workers, so they are more consistent across races.",
            "Or the item arrangement in shops, so those better fit the when they are unlocked, and are consistent across shops.",
        },
    },
    {
        wait = true, sectionEnd = true,
        lines = {
            "Of course you do not have to keep this hotkey setup.",
            "It included here as a demonstration of what can be done.",
            "Tip: If you want to play the campaign, it is recommended you change your hotkey layout to {Term: Grid} again while you do. The different campaigns have a lot of special units that, and a {Term: Custom} setup can cause some bugs with the buttons and hotkeys.",
        },
    },
    {
        checkpoint = "resources", wait = true,
        lines = {
            "{Heading: HOTKEY RESOURCES}",
            "If you have looked into the hotkeys file, you will have seen that all the buttons only have a coded description.",
            "Without knowing which code corresponds to which button, you cannot do anything here directly.",
        },
    },
    {
        wait = true,
        lines = {
            "You have probably noticed that there is a part of the options menu called {Hotkeys}.",
            "When setting up custom hotkeys, you can start by using this one.",
            "However, it only allows you to change the keys, not the position of buttons.",
        },
    },
    {
        wait = true,
        lines = {
            "People from the community have created their own interfaces to allow easy editing of all aspects of hotkeys.",
            "One of the simplest can be found by using a search engine and typing in \"{Input: warcraft 3 hotkey editor}\".",
            "The first result should lead you to a GitHub page belonging to a {Yellow Font: J.C.Fields}, where you can upload your hotkey file, edit it, and download the changed version.",
            "This page allows you to change hotkey positions, by simple dragging and dropping the buttons in the displayed command grid.",
        },
    },
    {
        wait = true, sectionEnd = true,
        lines = {
            "Another such resource is the more involved hotkey editor by {Yellow Font: clemenscodes}.",
            "The main problem with setting up custom hotkeys is that abilities are shared between a lot of units, so making a position change can conflict down the line.",
            "This one is very good in showing you where hotkeys or button positions conflict. Warcraft III can show this too, but not as well by far.",
            "However, this tool will automatically change the button tooltips, so it is only recommended if you don't mind this, or if you know how to change them back.",
        },
    },
    {
        checkpoint = "inventory", wait = true,
        lines = {
            "{Heading: CHANGING INVENTORY HOTKEYS}",
            "By default, inventory spots are tied to the {Input: Numpad}.",
            "These are far away from the other keys, and since some keyboards do not have the buttons at all.",
            "For this reason, many players rebind them.",
            "This can be done in the Warcraft III options.",
        },
    },
    {
        wait = true,
        lines = {
            "When using {Term: Grid} or {Term: Custom}, an obvious location to put them in is the 2x3 cluster of TY (or TZ), GH and BN..",
            "However, many people, especially coming from the MOBA scene, prefer using a Modifier key (Alt, Shift, CTRL) and using the cluister of  QW, AS and ZX (or YX).",
            "The problem: Warcraft III does not support this.",
        },
    },
    {
        wait = true,
        lines = {
            "The only way to do this, is use an extra program just to rebind a key combination onto the relevant {Input: Numpad} keyboard keys.",
            "This little program has to run in the background while Warcraft III is running.",
        },
    },
    {
        wait = true,
        lines = {
            "The simplest tool to use for this can be found by using a search engine and typing in \"{Input: warcraft inventory hotkeys}\".",
            "The first result should be the tool by {Yellow Font: J.C.Fields}.",
            "You can use it to customize your inventory buttons in any way you want.",
        },
    },
    {
        wait = true,
        lines = {
            "However, be aware that this tool does not work properly if you have rebound the inventory hotkeys away from the {Input: Numpad} in the Warcraft options.",
            "You have to reset them to default before using it.",
            "The tool makes your operating system believe that {Input: Alt+Q} is really {Input: Num1} (for example). If Num1 is not the right key, nothing will happen.",
        },
    },
    {
        wait = true, sectionEnd = true,
        lines = {
            "Since you need to have the program running while the game is running, it is easiest to start them at the same time.",
            "Even simpler, you can do this using the same shortcut on your Desktop. (assuming you are using Windows)",
            "Pressing the {Button: Export} button earlier also exported a .txt file with instructions on how to do this.",
        },
    },
    {
        terminal = true, trigger = "highlightMenu",
        lines = {
            "{Heading: END OF TUTORIAL}",
            "This concludes the hotkeys tutorial. Press the {Button: Menu} button to choose another tutorial!",
        },
    },
}

local TOPICS = {
    {label = "Welcome", step = 1},
    {label = "Why Use Hotkeys", step = 2},
    {label = "Which Hotkeys?", step = 7},
    {label = "Hotkey Resources", step = 21},
    {label = "The Inventory", step = 25},
}

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

local function FormatNarration(text)
    local formatted = text
    formatted = string.gsub(formatted, "{Heading:%s*(.-)}", "|cff00ccff%1|r")
    formatted = string.gsub(formatted, "{Button:%s*(.-)}", "|cffffcc00%1|r")
    formatted = string.gsub(formatted, "{Input:%s*(.-)}", "|cffffcc00%1|r")
    formatted = string.gsub(formatted, "{Menu:%s*(.-)}", "|cffcc66ff%1|r")
    formatted = string.gsub(formatted, "{Term:%s*(.-)}", "|cffff9933%1|r")
    formatted = string.gsub(formatted, "{Yellow Font:%s*(.-)}", "|cffffcc00%1|r")
    formatted = string.gsub(formatted, "{Green Font:%s*(.-)}", "|cff00ff00%1|r")
    formatted = string.gsub(formatted, "{Hotkeys}", "|cffcc66ffHotkeys|r")
    return formatted
end

local function CreateTutorialButton(name, parent, label, width)
    local button = BlzCreateFrameByType("GLUETEXTBUTTON", name, parent,
        "ScriptDialogButton", 0)
    BlzFrameSetSize(button, width, 0.024)
    BlzFrameSetText(button, label)
    return button
end

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

    function activity:makeTimer(period, repeating, callback)
        return JTG.StartScopedTimer(session, session.scope, period, repeating,
            callback)
    end

    function activity:registerClick(button, action, soundKind)
        self.actions[GetHandleId(button)] = {action = action, sound = soundKind}
        BlzTriggerRegisterFrameEvent(self.clickTrigger, button,
            FRAMEEVENT_CONTROL_CLICK)
    end

    function activity:setButtonEnabled(button, enabled)
        if button == nil then return end
        self.buttonEnabled[GetHandleId(button)] = enabled == true
        BlzFrameSetEnable(button, enabled == true)
        BlzFrameSetAlpha(button, enabled and 255 or 145)
        BlzFrameSetTextColor(button, enabled and
            BlzConvertColor(255, 255, 204, 0) or
            BlzConvertColor(255, 145, 145, 145))
    end

    function activity:refreshControls()
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

    function activity:clearNarration()
        self:clearArrow()
        if self.frames.exportHighlight ~= nil then
            BlzFrameSetVisible(self.frames.exportHighlight, false)
        end
        if self.frames.menuHighlight ~= nil then
            BlzFrameSetVisible(self.frames.menuHighlight, false)
        end
        ClearTextMessages()
        self.narrationBlocks = {}
    end

    function activity:renderNarration()
        ClearTextMessages()
        if not self.presentationVisible or self.topicsOpen then return end
        for _, text in ipairs(self.narrationBlocks) do
            DisplayTimedTextToPlayer(HOTKEY_PLAYER, 0, 0,
                NARRATION_DURATION, text)
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
        elseif trigger == "highlightExport" then
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

    function activity:showStep(index)
        local spec = STEPS[index]
        if spec == nil then return end
        self.step = index
        self.checkpoint = spec.checkpoint or self.checkpoint
        self.complete = spec.terminal == true
        self.waitingForContinue = spec.wait == true and not self.complete
        self:clearNarration()
        local text = FormatNarration(table.concat(spec.lines or {}, "\n"))
        table.insert(self.narrationBlocks, text)
        if self.presentationVisible and not self.topicsOpen then
            DisplayTimedTextToPlayer(HOTKEY_PLAYER, 0, 0,
                NARRATION_DURATION, text)
        end
        self:runStepTrigger(spec)
        self:refreshControls()
    end

    function activity:continueTutorial()
        if not self.waitingForContinue or self.complete then return end
        self:showStep(math.min(#STEPS, self.step + 1))
    end

    function activity:goBack()
        if self.step <= 1 and not self.complete then return end
        self:setTopicsVisible(false)
        self:showStep(math.max(1, self.step - 1))
    end

    function activity:restoreTopic(index)
        self:setTopicsVisible(false)
        self:showStep(index)
    end

    function activity:openMenu()
        if JTG.UI == nil then return end
        self:setPresentationVisible(false)
        JTG.UI.SetGameplayMenuPaused(true)
        JTG.UI.ShowActivityMenu("learn")
    end

    function activity:togglePause()
        if JTG.UI ~= nil then
            JTG.UI.SetExercisePaused(not JTG.UI.exercisePaused)
        end
        self:refreshControls()
    end

    function activity:exportCustomKeys()
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

        local layout = (JTG.UI and JTG.UI.ToolbarLayout) or {
            buttonWidth = 0.087, gap = 0.001, rowStep = 0.025,
            left = 0.446, top = 0.575,
        }
        local bar = JTG.ScopeTrackFrame(scope, BlzCreateFrameByType("FRAME",
            "JTGHotkeyTutorialBar" .. suffix, root, "", 0))
        BlzFrameSetSize(bar, 0.351, 0.060)
        BlzFrameSetAbsPoint(bar, FRAMEPOINT_TOPLEFT, layout.left, layout.top)
        self.frames.bar = bar
        local labels = {
            {"menu", "Menu", 1}, {"back", "Back", 2},
            {"topics", "Topics", 3}, {"continue", "Continue", 5},
            {"pause", "Pause", 7}, {"export", "Export", 8},
        }
        for _, spec in ipairs(labels) do
            local button = JTG.ScopeTrackFrame(scope, CreateTutorialButton(
                "JTGHotkeyTutorial" .. spec[1] .. suffix, bar, spec[2],
                layout.buttonWidth))
            local slot = spec[3] - 1
            BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, bar,
                FRAMEPOINT_TOPLEFT,
                (slot % 4) * (layout.buttonWidth + layout.gap),
                -math.floor(slot / 4) * layout.rowStep)
            self.frames[spec[1]] = button
            local label = BlzFrameGetChild(button, 4)
            if label ~= nil then BlzFrameSetScale(label, 0.72) end
        end

        local function createHighlight(key)
            local highlight = JTG.ScopeTrackFrame(scope, BlzCreateFrameByType("SPRITE",
                "JTGHotkey" .. key .. "Highlight" .. suffix, bar, "", 0))
            BlzFrameSetSize(highlight, 0.058, 0.024)
            BlzFrameSetPoint(highlight, FRAMEPOINT_CENTER, self.frames[key],
                FRAMEPOINT_CENTER, -0.0125, 0)
            BlzFrameSetModel(highlight,
                "UI\\Feedback\\QuestButton\\UI-QuestButtonOn.mdl", 0)
            BlzFrameSetLevel(highlight, 3)
            BlzFrameSetEnable(highlight, false)
            BlzFrameSetVisible(highlight, false)
            BlzFrameSetLevel(self.frames[key], 2)
            return highlight
        end
        self.frames.continueHighlight = createHighlight("continue")
        self.frames.exportHighlight = createHighlight("export")
        self.frames.menuHighlight = createHighlight("menu")
        local pauseHighlight = createHighlight("pause")
        if JTG.UI and JTG.UI.RegisterPauseHighlight then
            JTG.ScopeBorrow(scope, JTG.UI.RegisterPauseHighlight(pauseHighlight))
        end

        local arrow = JTG.ScopeTrackFrame(scope, BlzCreateFrameByType("BACKDROP",
            "JTGHotkeyCommandArrow" .. suffix, root, "", 0))
        BlzFrameSetSize(arrow, 0.078, 0.078)
        BlzFrameSetTexture(arrow, "JTGMenu\\TutorialArrowDown.dds", 0, true)
        BlzFrameSetEnable(arrow, false)
        BlzFrameSetLevel(arrow, 30)
        BlzFrameSetVisible(arrow, false)
        self.frames.arrow = arrow

        local topics = JTG.ScopeTrackFrame(scope, BlzCreateFrameByType("FRAME",
            "JTGHotkeyTopics" .. suffix, root, "", 0))
        BlzFrameSetSize(topics, 0.185, JTG.TutorialMenuHeight(#TOPICS))
        BlzFrameSetAbsPoint(topics, FRAMEPOINT_TOPRIGHT, 0.795, 0.500)
        local skin = JTG.ScopeTrackFrame(scope, BlzCreateFrame("EscMenuBackdrop",
            topics, 0, 980 + session.generation))
        BlzFrameSetPoint(skin, FRAMEPOINT_TOPLEFT, topics,
            FRAMEPOINT_TOPLEFT, 0, 0)
        BlzFrameSetPoint(skin, FRAMEPOINT_BOTTOMRIGHT, topics,
            FRAMEPOINT_BOTTOMRIGHT, 0, 0)
        BlzFrameSetEnable(skin, false)
        self.frames.topicsMenu = topics

        local topicButtons = {}
        local previous = nil
        for index, topic in ipairs(TOPICS) do
            local button = JTG.ScopeTrackFrame(scope, CreateTutorialButton(
                "JTGHotkeyTopic" .. index .. suffix, topics,
                topic.label, 0.125))
            BlzFrameSetSize(button, 0.125, 0.026)
            if previous == nil then
                BlzFrameSetPoint(button, FRAMEPOINT_TOP, topics,
                    FRAMEPOINT_TOP, 0, -0.041)
            else
                BlzFrameSetPoint(button, FRAMEPOINT_TOP, previous,
                    FRAMEPOINT_BOTTOM, 0, -0.003)
            end
            topicButtons[index] = button
            previous = button
        end
        local close = JTG.ScopeTrackFrame(scope, CreateTutorialButton(
            "JTGHotkeyTopicsClose" .. suffix, topics, "Close", 0.10))
        BlzFrameSetSize(close, 0.10, 0.026)
        BlzFrameSetPoint(close, FRAMEPOINT_BOTTOM, topics,
            FRAMEPOINT_BOTTOM, 0, 0.025)

        self.clickTrigger = JTG.ScopeTrackTrigger(scope, CreateTrigger())
        TriggerAddAction(self.clickTrigger, function()
            local clicked = BlzGetTriggerFrame()
            local entry = self.actions[GetHandleId(clicked)]
            if entry == nil or self.buttonEnabled[GetHandleId(clicked)] == false then
                return
            end
            if JTG.UI and JTG.UI.PlayButtonSound then
                local soundKind = entry.sound
                if type(soundKind) == "function" then soundKind = soundKind() end
                JTG.UI.PlayButtonSound(soundKind)
            end
            if JTG.UI and JTG.UI.ReleaseFrameFocus then
                JTG.UI.ReleaseFrameFocus(clicked)
            end
            entry.action()
            if JTG.UI and JTG.UI.ReleaseKeyboardFocusAfterClick then
                JTG.UI.ReleaseKeyboardFocusAfterClick()
            end
        end)
        self:registerClick(self.frames.continue,
            function() self:continueTutorial() end)
        self:registerClick(self.frames.back, function() self:goBack() end, "return")
        self:registerClick(self.frames.menu, function() self:openMenu() end)
        self:registerClick(self.frames.pause, function() self:togglePause() end,
            function() return JTG.UI.exercisePaused and "return" or "normal" end)
        self:registerClick(self.frames.export,
            function() self:exportCustomKeys() end)
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
            local unit = JTG.ScopeTrackUnit(current.scope,
                CreateUnit(HOTKEY_PLAYER, FourCC(spec.rawcode),
                    spec.x, spec.y, spec.facing))
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
            local unit = JTG.ScopeTrackUnit(current.scope,
                CreateUnit(HOTKEY_PLAYER, FourCC(spec[1]),
                    spec[2], spec[3], 0))
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
            SetCameraPosition(session.scene.centerX, session.scene.centerY)
            ClearSelection()
            if self.paladin ~= nil then SelectUnit(self.paladin, true) end
        end
        self:createPresentation()
        self:showStep(1)
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
        ClearTextMessages()
        self:clearArrow()
        if GetLocalPlayer() == HOTKEY_PLAYER then ClearSelection() end
        self.frames = {}
        self.actions = {}
    end

    return activity
end
