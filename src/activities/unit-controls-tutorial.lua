-- Unit Controls tutorial. This first implementation covers selection, the
-- unit interface and the basic ability types from the current script draft.
JTG = JTG or {}

local UNIT_PLAYER = Player(0)
local HOSTILE_PLAYER = Player(PLAYER_NEUTRAL_AGGRESSIVE)
local TICK_INTERVAL = 0.05
local NARRATION_DURATION = 3600.0

local UNIT_LAYOUT = {
    {kind = "footmen", rawcode = "hfoo", x = 4560.0, y = 3730.0, facing = 90.0},
    {kind = "footmen", rawcode = "hfoo", x = 4760.0, y = 3730.0, facing = 90.0},
    {kind = "footmen", rawcode = "hfoo", x = 4960.0, y = 3730.0, facing = 90.0},
    {kind = "footmen", rawcode = "hfoo", x = 5160.0, y = 3730.0, facing = 90.0},
    {kind = "riflemen", rawcode = "hrif", x = 4710.0, y = 3530.0, facing = 90.0},
    {kind = "riflemen", rawcode = "hrif", x = 5010.0, y = 3530.0, facing = 90.0},
    {kind = "priests", rawcode = "hmpr", x = 4710.0, y = 3330.0, facing = 90.0},
    {kind = "priests", rawcode = "hmpr", x = 5010.0, y = 3330.0, facing = 90.0},
}

local STEPS = {
    {
        groupStart = 1, checkpoint = "welcome", wait = true, trigger = "resetUnits",
        lines = {
            "{Heading: WELCOME}",
            "Welcome to the Unit Control Tutorial!",
            "In this tutorial, we are taking a look at units, and how to control them.",
            "Once you are done reading and playing around with whatever mechanic you learn, press the {Button: Continue} or {Button: Next} button to move on!",
        },
    },
    {
        groupStart = 2, checkpoint = "unitselection", wait = true, trigger = "resetUnits",
        lines = {
            "{Heading: UNIT SELECTION}",
            "To control a unit, you first need to select it.",
            "There are several ways to select a unit. We will look at four right now.",
        },
    },
    {
        groupStart = 3, wait = true,
        lines = {
            "The first way is to {Input: left click} the unit you want to select.",
            "Clicking another unit will unselect the first one.",
            "Select and unselect some of your units!",
        },
    },
    {
        groupStart = 4, wait = true,
        lines = {
            "The second way to select units is to {Term: box select} them.",
            "You do this by {Input: clicking and dragging} with the mouse cursor.",
            "This forms a selection box. Once you {Input: let go}, all of your units under that box are selected.",
            "You can select up to 24 units at the same time.",
            "Select several of your units in different combinations!",
        },
    },
    {
        groupStart = 5, wait = true,
        lines = {
            "The third way to select units is to {Term: CTRL select} them.",
            "You do this by {Input: holding CTRL and clicking} a unit, or by {Input: double-clicking} it.",
            "This selects all units of that type that you control within a wide radius.",
            "CTRL select your units!",
        },
    },
    {
        groupStart = 6, wait = true,
        lines = {
            "The fourth way to select units is to {Term: shift select} them.",
            "You do this by {Input: holding Shift and clicking} a unit.",
            "This adds that unit to your selection. If you already had units selected, they remain selected.",
            "If you {Input: Shift-click} a single selected unit, it becomes unselected.",
            "Shift select and unselect your units!",
        },
    },
    {
        groupStart = 7, wait = true, sectionEnd = true,
        lines = {
            "You can combine {Term: shift select}, {Term: box select} and {Term: CTRL select}.",
            "But this only works when adding units to the selection, not when taking them away.",
            "Try playing around a bit with different combinations of these selection methods!",
        },
    },
    {
        groupStart = 8, checkpoint = "controlgroups", wait = true, trigger = "resetUnits",
        lines = {
            "{Heading: CONTROL GROUPS}",
            "Having to select units manually is complicated, and can take time.",
            "For this reason, there are {Term: Control Groups}.",
            "They enable you to very quickly jump between specific unit selections you have saved beforehand.",
        },
    },
    {
        groupStart = 9, wait = true,
        lines = {
            "To create a {Term: Control Group}, you have to {Input: select} one or several units, {Input: hold CTRL}, and {Input: press a number}.",
            "For example {Input: CTRL+1}.",
            "You can create a group for every number on your keyboard.",
            "Select some units, and try creating some {Term: Control Groups}!",
        },
    },
    {
        groupStart = 10, wait = true,
        lines = {
            "After creating it, {Input: pressing the number} selects the units inside the group.",
            "{Input: Double-tapping} the number centers the camera on the units of the group. Specifically on the unit leftmost in the selection.",
        },
    },
    {
        groupStart = 11, wait = true,
        lines = {
            "If you already have a {Term: Control Group}, you can add new units to it by selecting hem, {Input: holding Shift}, and {Input: pressing its number}.",
            "For example {Input: Shift+1}.",
            "Alternatively, you can select the group, {Term: Shift-Select} the unit or units you want to add, and then re-create the group.",
            "You can also add units using {Term: Shift-Select} combined with {Term: Box-Select} and {Term: CTRL-Select}.",
            "Try adding units to existing control groups!",
        },
    },
    {
        groupStart = 12, wait = true, sectionEnd = true,
        lines = {
            "To remove units from a {Term: Control Group}, you have to {Input: shift-unselect} them and then re-create the group.",
            "Add and remove units from your groups!",
            "Every player develops their own preferences when using {Term: Control Groups}.",
            "The first couple groups usually divide the army into melee, ranged and spellcasters, but the details vary.",
            "This allows the player to quickly give precise commands in battle.",
            "The other control groups are often assigned to buildings in the player's base, or worker units.",
        },
    },
    {
        groupStart = 13, checkpoint = "unitinterface", wait = true, trigger = "resetUnits",
        lines = {
            "{Heading: UNIT INTERFACE}",
            "Let us take a look at your interface.",
        },
    },
    {
        groupStart = 14, wait = true, trigger = "portraitArrow",
        lines = {
            "This is the active unit's {Term: portrait}.",
            "Clicking it portrait centers the camera on the unit.",
            "If several of the same type are selected, you will center on the leftmost in the selection.",
            "Below the portrait, you can see the unit's {Term: health} and {Term: mana}.",
        },
    },
    {
        groupStart = 15, wait = true, trigger = "infoArrow", preserveArrowOnContinue = true,
        lines = {
            "This space has two functions.",
        },
    },
    {
        groupStart = 16, wait = true, preserveArrowOnContinue = true,
        lines = {
            "When you have selected one unit, it shows you that unit's statistics, such as damage, armor, buffs and debuffs, and so on..",
        },
    },
    {
        groupStart = 17, wait = true,
        lines = {
            "When you have selected more than one unit, it shows you smaller portraits of your selection.",
            "You can {Input: double-click} these smaller portraits to select or target the individual units without having to look for them on the screen.",
        },
    },
    {
        groupStart = 18, wait = true, trigger = "inventoryArrow",
        lines = {
            "This space shows a units {Term: inventory}.",
            "Not all units have an inventory, and only Hero units can use {Term: items}.",
            "We will talk about items in detail once we talk about Heroes.",
        },
    },
    {
        groupStart = 19, wait = true, trigger = "commandsArrow",
        lines = {
            "This part of the interface displays the {Term: actions} a unit can take.",
            "Many of these are generic, meaning almost every unit has some or all of them.",
            "Some of them are unit specific though. These are called unit {Term: abilities}.",
            "You can use these actions and abilities by clicking them, or by using their hotkeys.",
        },
    },
    {
        groupStart = 20, wait = true, sectionEnd = true,
        lines = {
            "{Heading: HOTKEYS}",
            "{Yellow Font: Using hotkeys} takes less time than clicking buttons, so it {Yellow Font: is always recommended!}",
            "If you are new, it is OK to click the buttons during this tutorial.",
            "There will be tips on how to best set up Hotkeys in the next tutorial.",
        },
    },
    {
        groupStart = 21, checkpoint = "abilities", wait = true, trigger = "selectFootman",
        lines = {
            "{Heading: ABILITIES}",
            "The units you currently control have a variety of abilities.",
            "The footman has the {Button: Defend} ability, which protects him from the piercing damage type, at the cost of movement speed.",
            "This kind of ability simply activates once you {Input: press the button} or {Input: use the hotkey}.",
            "When several footmen are selected, all of them will use the ability.",
            "Give it a try!",
        },
    },
    {
        groupStart = 22, wait = true, trigger = "selectRifleman",
        lines = {
            "The Rifleman has what is called a {Term: passive ability}. It raises his attack range.",
            "Passive abilities are always in effect.",
        },
    },
    {
        groupStart = 23, wait = true, trigger = "healExercise",
        lines = {
            "The priest is a spellcaster with a variety of abilities, all of which cost mana.",
            "His {Button: Heal} is a {Term: targeted ability} you can use on friendly units.",
            "You use targeted abilities by {Input: pressing the button} or {Input: using the hotkey}, and then {Input: clicking the target}.",
            "Try healing your wounded footmen!",
        },
    },
    {
        groupStart = 24, wait = true, trigger = "fillPriestMana",
        lines = {
            "{Button: Dispel} is an {Term: area of effect} spell, that removes magical buffs debuffs, and damages enemy summoned units within an area.",
            "You use area spells in the same way you user other targeted abilities, except that you do not target units.",
        },
    },
    {
        groupStart = 25, wait = true, trigger = "slowExercise",
        lines = {
            "Your units have been magically slowed. Dispel the magic!",
        },
    },
    {
        groupStart = 26, wait = true, trigger = "wolfExercise", afterContinue = "resetUnits",
        lines = {
            "Magically summoned creatures are attacking you! Dispel them!",
        },
    },
    {
        groupStart = 27, wait = true, trigger = "innerFireExercise",
        lines = {
            "The last Priest spell is another targeted ability.",
            "{Button: Inner Fire} strengthens a friendly unit both offensively and defensively.",
            "Try buffing your footmen with Inner Fire, then select one and check to see the buff!",
        },
    },
    {
        groupStart = 28, wait = true,
        lines = {
            "You have probably noticed that {Button: Inner Fire} and {Button: Heal} have yellow corners.",
            "This means that these are spells that can be {Term: auto-cast}",
            "You can set a spell to auto-cast by {Button: right-clicking} it.",
            "A spellcaster can only ever auto-cast one spell at a time.",
        },
    },
    {
        groupStart = 29, wait = true,
        lines = {
            "{Term: Auto-cast} spells usually have conditions.",
            "For example, the priest will only heal units if there are damaged units nearby.",
            "And he will only buff them with Inner Fire if a fight is going on.",
        },
    },
    {
        groupStart = 30, wait = true,
        lines = {
            "{Heading: SUB-SELECTION}",
            "You may have noticed, that when you have selected all of your units, you can see your Priests' abilities, and their portraits are a bit bigger in the unit selection interface.",
            "This is because when you have selected units of several types, one is type is selected primarily.",
        },
    },
    {
        groupStart = 31, wait = true,
        lines = {
            "You can cycle through the different unit types, allowing you to use that type's abilities without changing your selection.",
            "The default hotkey for this is the {Input: Tabulator} key, or {Input: Tab}.",
            "Alternatively you can {Input: click} on one of the unit types in the interface.",
            "Try cycling through the unit types in your selection!",
        },
    },
    {
        groupStart = 32, wait = true, sectionEnd = true,
        lines = {
            "You can cycle through the unit types in reverse.",
            "This is done by {Input: holding Shift}, and pressing {Input: Tab}.",
            "{Input: (Shift+Tab)}.",
        },
    },
    {
        groupStart = 33, checkpoint = "movement", wait = true, trigger = "resetUnits",
        lines = {
            "{Heading: THE MOVEMENT COMMAND}",
            "You can move around your units by using the {Term: Move} command.",
            "You can either do this by {Input: pressing the button} or using the {Input: hotkey}, and then {Input: clicking} somewhere.",
            "Much more simply, you can {Input: right-click}.",
        },
    },
    {
        groupStart = 34, wait = true, trigger = "startSiegeCircle",
        lines = {
            "If you use a {Term: Move} command on a friendly or neutral unit, your unit will follow that unit.",
            "Have one or several units follow the Siege Engine!",
        },
    },
    {
        groupStart = 35, wait = true, trigger = "holdSiege",
        lines = {
            "When your units move on a unit that stands still, your units will stand still at a distance.",
            "If you give them another {Term: Move} command on the same unit, they will move closer.",
            "It takes four or more movement commands to get your unit as close to the target as possible.",
            "Have your units move into direct contact with the siege engine!",
        },
    },
    {
        groupStart = 36, wait = true, trigger = "giveSiegeAndPeasant",
        lines = {
            "{Heading: FORMATION MOVEMENT}",
            "Different units have different movement speeds, sizes, and turn rates.",
            "This means that they move very differently.",
            "Some may get left behind, and your army may become divided across a greater area.",
        },
    },
    {
        groupStart = 37, wait = true,
        lines = {
            "The game has a mechanic for this, called {Term: Formation Movement}.",
            "This can be enabled or disabled by {Input: clicking the button} next to the minimap, or, per default by {Input: holding Alt} and {Input: pressing F}.",
            "{Input: Alt+F}",
            "Try moving around all of your units in one big selection with and without {Term: Formation Movement}!",
        },
    },
    {
        groupStart = 38, wait = true,
        lines = {
            "With regular {Term: Movement}, every unit will move individually, as fast as it can.",
            "When reaching the target location, the army will then arrange itself with melee units in front, ranged fighters in the middle, and casters in the back.",
        },
    },
    {
        groupStart = 39, wait = true,
        lines = {
            "{Term: Formation Movement} switches this around.",
            "First, the army arranges itself with melee in front and casters in the back.",
            "Then the army moves as a whole, only as quickly as the slowest unit in the selection.",
        },
    },
    {
        groupStart = 40, wait = true,
        lines = {
            "In competitive play, {Term: Formation Movement} is almost never, because it slows down your army, and because your army takes a while to get moving in the first place.",
            "Since new players do not know that it exists, and because it is active by default, it is considered an invisible roadblock for new players.",
            "For these reasons, {Yellow Font: it is recommended you deactivate it.}",
            "The game will remember this choice between sessions.",
        },
    },
    {
        groupStart = 41, wait = true,
        lines = {
            "{Heading: PATHFINDING}",
            "Since maps are filled with terrain, buildings, and units, movement is often more complicated than in an open field.",
            "When you give your units a {Term: Movement} command, they will navigate around any obstacles they encounter.",
            "This will sometimes cause them to bunch up, slow down, stand still, or change directions.",
        },
    },
    {
        groupStart = 42, wait = true, trigger = "obstacleCourse", afterContinue = "removeObstacleCourse",
        lines = {
            "Move your units around and through all of these obstacles!",
        },
    },
    {
        groupStart = 43, wait = true,
        lines = {
            "{Heading: The SHIFT QUEUE}",
            "If you want to have your unit move along more complicated paths, you can use the {Term: Shift-Queue}.",
            "This is done by {Input: holding Shift}, and then giving the unit several commands.",
            "The unit will then fulfill these commands one by one, allowing you to, for example, plan for a movement to move around hostile units.",
            "Try shift-queueing a movement path for your units!",
        },
    },
    {
        groupStart = 44, wait = true,
        lines = {
            "{Term: Shift-Queue} works not only with {Term: Movement} commands, but with basically everything you can tell a unit to do.",
            "This includes all commands, all abilities, and even items.",
        },
    },
    {
        groupStart = 45, wait = true,
        lines = {
            "{Heading: THE STOP COMMAND}",
            "If your unit is moving, or doing anything else, you can have it abort what it is currently doing by giving it a {Term: Stop} command.",
            "You can do this by {Input: pressing the button} or by using the {Input: hotkey}.",
            "Have your units move around, and then stop them!",
        },
    },
    {
        groupStart = 46, wait = true, sectionEnd = true, afterContinue = "clearMovementProps",
        lines = {
            "{Term: Stop} is a temporary command. It only aborts what the unit currently does.",
            "If the unit wants to start doing something else, like {Term: auto-casting}, it will start again right away.",
            "The same is true for attacking and chasing units that get into range.",
        },
    },
    {
        groupStart = 47, checkpoint = "combat", wait = true, trigger = "resetUnits",
        lines = {
            "{Heading: COMBAT}",
            "Like most strategy games, Warcraft III has a basic stance system.",
            "By default, your units start out in an {Term: aggressive stance}, meaning they attack any hostile unit that comes too close.",
        },
    },
    {
        groupStart = 48, wait = true, trigger = "spawnPassingGrunt", afterContinue = "removeEnemies",
        lines = {
            "Once the enemy unit moves away far enough, your units will return to where they were.",
        },
    },
    {
        groupStart = 49, wait = true, trigger = "prepareHoldPosition",
        lines = {
            "To change your units' stance, you can use the unit command {Button: Hold Position}, by pressing its button or using its hotkey.",
            "{Button: Hold Position} also cancels any other order they were given, in the same way the {Term: Stop} command does.",
            "However, it also tells the unit to stand still exactly where they are, until they receive another command.",
            "Select all of your units and have them hold position!",
        },
    },
    {
        groupStart = 50, wait = true, trigger = "spawnPassingGrunt", afterContinue = "removeEnemies",
        lines = {
            "When holding position, your units will not move, even when an enemy unit is close by.",
            "However, they will attack when in range.",
        },
    },
    {
        groupStart = 51, wait = true, trigger = "spawnAttackGrunt", afterContinue = "removeEnemies",
        lines = {
            "{Heading: THE ATTACK COMMAND}",
            "If you want to attack a unit, you use the unit command {Button: Attack}.",
            "You can do this by pressing its {Input: button} or using its {Input: hotkey}, and then clicking your target.",
            "You can also {Input: right-click} your target.",
            "{Yellow Font: Select all of your units}, and attack the Grunt to the north!",
        },
    },
    {
        groupStart = 52, wait = true, trigger = "spawnEnemyTrio", afterContinue = "removeEnemies",
        lines = {
            "Just like with other commands, you can {Term: shift-queue} attack commands.",
            "{Yellow Font: Select all of your units}, and order them to first attack the Headhunter, then the Grunt, and lastly the Peon.",
        },
    },
    {
        groupStart = 53, wait = true,
        lines = {
            "You may have noticed that your footmen were bunching up a lot, and running around each other to reach the target.",
            "This is because the Attack command leaves no room for alternatives.",
            "Your units will do everything they can to get into attack range of that unit, and ignore anything else.",
        },
    },
    {
        groupStart = 54, wait = true,
        lines = {
            "You may also have noticed that your Priests did not heal your Footmen, despite Heal being on auto-cast.",
            "This is because a direct attack order supersedes auto-casting.",
        },
    },
    {
        groupStart = 55, wait = true, trigger = "resetUnits",
        lines = {
            "{Heading: THE ATTACK MOVE COMMAND}",
            "The {Yellow Font: most important combat command} is the {Term: Attack Move}!",
            "You perform this by {Input: clicking the Attack button}, or using its {Input: hotkey}, and then {Input: clicking on the ground}.",
            "This essentially makes the selected unit move to that location in aggressive stance, meaning it attacks every enemy it comes across.",
        },
    },
    {
        groupStart = 56, wait = true,
        lines = {
            "There is several advantages to this.",
            "For one, no time is wasted bunching up. Each unit will just find the closest enemy and attack.",
            "For another, this kind of move does not supersede auto-cast.",
        },
    },
    {
        groupStart = 57, wait = true, trigger = "spawnCombatTrio", afterContinue = "removeEnemies",
        lines = {
            "Try attacking the enemy units to the north with an attack move by {Input: clicking it behind them}!",
        },
    },
    {
        groupStart = 58, wait = true, trigger = "spawnCombatTrio", afterContinue = "removeEnemies",
        lines = {
            "After using an {Term: Attack Move}, you can then manually select units to reposition them or switch their targets.",
            "This is called {Term: Micro}, from micro-management.",
            "Try attacking the enemy units to the north with an attack move, but this time try to micro your units a bit!",
        },
    },
    {
        groupStart = 59, wait = true, trigger = "resetUnits",
        lines = {
            "As a {Yellow Font: rule of thumb}, it is almost always better to {Yellow Font: move your units with an attack move} compared to a regular move!",
        },
    },
    {
        groupStart = 60, wait = true,
        lines = {
            "The reason for this is that while given a {Term: Move} command, your units will ignore enemies completely.",
            "This makes them vulnerable in two ways.",
        },
    },
    {
        groupStart = 61, wait = true,
        lines = {
            "For one, they will receive damage without defending themselves.",
            "For another, weaker units such as Priests and Riflemen will move out of position, making it easier for your enemy to attack them.",
        },
    },
    {
        groupStart = 62, wait = true,
        lines = {
            "Another use for attack moves, is to have your units finish off an enemy, and then start moving somewhere else, without you having to give them another command.",
        },
    },
    {
        groupStart = 63, wait = true, trigger = "spawnFinalHeadhuntersAttack", afterContinue = "removeEnemies",
        lines = {
            "Your units will win this fight easily.",
            "Give an attack move command to the top right corner of the minimap!",
            "Your units will finish fighting, and then starting moving up there.",
        },
    },
    {
        groupStart = 64, wait = true, sectionEnd = true,
        lines = {
            "The only downside to the Attack move is that along the way, you may attack things you do not intend to.",
            "This can be annoying, especially when you are not paying attention to your army at the time.",
            "To get around this, you can use {Term: shift-queue} to avoid places where you know there are enemy units.",
        },
    },
    {
        groupStart = 65, terminal = true, trigger = "highlightMenu",
        lines = {
            "{Heading: END OF TUTORIAL}",
            "This concludes the unit control tutorial. Press the {Button: Menu} button to choose another tutorial!",
            "Alternatively, press the {Button: Optional} button to learn about more niche mechanics you may not need in competitive play.",
        },
    },
}

local TOPICS = {
    {label = "Welcome", step = 1},
    {label = "Unit Selection", step = 2},
    {label = "Control Groups", step = 8},
    {label = "Unit Interface", step = 13},
    {label = "Abilities", step = 21},
    {label = "Movement", step = 33},
    {label = "Combat", step = 47},
}




local OPTIONAL_SECTIONS = {
    {
        id = "patrol", label = "Patrol",
        steps = {
            {wait = true, trigger = "resetUnits", lines = {
                "{Heading: BONUS: PATROLLING}",
                "You can have units run back and forth between locations, by using the {Button: Patrol} command.",
                "Try having some of your units patrol around!",
            }},
            {wait = true, lines = {
                "While patrolling, the unit is in aggressive stance, meaning it works just like an {Term: Attack Move}.",
                "Your unit will attack any hostile unit it comes in range of.",
            }},
            {wait = true, lines = {
                "If you want to set up more complicated movement paths, you can use the {Term: Shift-Queue}.",
            }},
            {wait = true, sectionEnd = true, lines = {
                "{Heading: OPTIONAL TOPIC COMPLETE}",
                "This optional topic is complete.",
                "Press the {Button: Next} button to return to the tutorial section you previously left.",
            }},
        },
    },
    {
        id = "formation", label = "Formation",
        steps = {
            {wait = true, trigger = "resetUnits", lines = {
                "{Heading: BONUS: FORMATION MOVEMENT OPTION}",
                "There is an option that allow the use of {Term: Formation Movement} without having to toggle it on and off between commands.",
            }},
            {wait = true, lines = {
                "Go to {Menu: Gameplay} -> {Menu: Interface}, and check the checkbox for {Menu: Enable Formation Movement Toggle}.",
            }},
            {wait = true, lines = {
                "Now you can give a {Term: Formation Movement} command by {Input: holding Alt} and giving your units a {Term: Movement} command.",
                "Try enabling this option and moving your army with and without {Term: Formation Movement} using it!",
            }},
            {wait = true, sectionEnd = true, lines = {
                "{Heading: OPTIONAL TOPIC COMPLETE}",
                "This optional topic is complete.",
                "Press the {Button: Next} button to return to the tutorial section you previously left.",
            }},
        },
    },
}


local function FormatNarration(text)
    local formatted = text
    formatted = string.gsub(formatted, "{Small Heading:%s*(.-)}", "|cff00ccff%1|r")
    formatted = string.gsub(formatted, "{Heading:%s*(.-)}", "|cff00ccff%1|r")
    formatted = string.gsub(formatted, "{Button:%s*(.-)}", "|cffffcc00%1|r")
    formatted = string.gsub(formatted, "{Input:%s*(.-)}", "|cffffcc00%1|r")
    formatted = string.gsub(formatted, "{Menu:%s*(.-)}", "|cffcc66ff%1|r")
    formatted = string.gsub(formatted, "{Term:%s*(.-)}", "|cffff9933%1|r")
    formatted = string.gsub(formatted, "{Yellow Font:%s*(.-)}", "|cffffcc00%1|r")
    return formatted
end

local function StepText(step)
    return table.concat(step.lines or {}, "\n")
end

local function CreateTutorialButton(name, parent, label, width)
    local button = BlzCreateFrameByType("GLUETEXTBUTTON", name, parent,
        "ScriptDialogButton", 0)
    BlzFrameSetSize(button, width, 0.024)
    BlzFrameSetText(button, label)
    return button
end

function JTG.CreateUnitControlsTutorialActivity(session)
    local activity = {
        step = 1,
        checkpoint = "welcome",
        waitingForContinue = true,
        complete = false,
        locallyPaused = false,
        topicsOpen = false,
        optionalOpen = false,
        optionalActive = false,
        optionalSection = nil,
        optionalStep = 0,
        optionalReturnStep = 1,
        presentationVisible = true,
        narrationBlocks = {},
        units = {},
        unitGroups = {footmen = {}, riflemen = {}, priests = {}},
        wolves = {},
        wolfSummoners = {},
        enemies = {},
        movementUnits = {},
        obstacleUnits = {},
        obstacleDestructables = {},
        siegeEngine = nil,
        siegeCircleActive = false,
        frames = {},
        actions = {},
        buttonEnabled = {},
        arrowActive = false,
        arrowElapsed = 0.0,
        arrowVisible = false,
        combatAutocast = false,
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
        local optionalSteps = self.optionalSection and
            self.optionalSection.steps or nil
        local current = self.optionalActive and optionalSteps and
            optionalSteps[self.optionalStep] or STEPS[self.step]
        local canContinue = self.waitingForContinue and not self.complete
        BlzFrameSetText(self.frames.continue,
            current ~= nil and current.sectionEnd and "Next" or "Continue")
        self:setButtonEnabled(self.frames.continue, canContinue)
        self:setButtonEnabled(self.frames.back,
            self.optionalActive or self.step > 1 or self.complete)
        local paused = JTG.UI and JTG.UI.exercisePaused == true
        BlzFrameSetText(self.frames.pause, paused and
            "|cffffffffUnpause|r" or "|cffffcc00Pause|r")
        local closed = not self.topicsOpen and not self.optionalOpen
        if self.frames.continueHighlight ~= nil then
            BlzFrameSetVisible(self.frames.continueHighlight,
                canContinue and self.presentationVisible and closed)
        end
    end

    function activity:clearArrow()
        self.arrowActive = false
        self.arrowElapsed = 0.0
        self.arrowVisible = false
        if self.frames.arrow ~= nil then
            BlzFrameSetVisible(self.frames.arrow, false)
        end
    end

    function activity:clearNarration(preserveArrow)
        if not preserveArrow then self:clearArrow() end
        ClearTextMessages()
        self.narrationBlocks = {}
    end

    function activity:renderNarration()
        ClearTextMessages()
        if not self.presentationVisible or self.topicsOpen or
                self.optionalOpen then return end
        for _, text in ipairs(self.narrationBlocks) do
            DisplayTimedTextToPlayer(UNIT_PLAYER, 0, 0,
                NARRATION_DURATION, text)
        end
    end

    function activity:appendNarration(text)
        local formatted = FormatNarration(text or "")
        table.insert(self.narrationBlocks, formatted)
        if self.presentationVisible and not self.topicsOpen and
                not self.optionalOpen then
            DisplayTimedTextToPlayer(UNIT_PLAYER, 0, 0,
                NARRATION_DURATION, formatted)
        end
    end

    function activity:setArrow(target, targetPoint, offsetX, offsetY)
        local arrow = self.frames.arrow
        if arrow == nil or target == nil then return end
        BlzFrameClearAllPoints(arrow)
        BlzFrameSetPoint(arrow, FRAMEPOINT_BOTTOM, target,
            targetPoint or FRAMEPOINT_TOP, offsetX or 0, offsetY or 0.003)
        self.arrowActive = true
        self.arrowElapsed = 0.0
        self.arrowVisible = true
        BlzFrameSetVisible(arrow, self.presentationVisible and
            not self.topicsOpen and not self.optionalOpen)
    end

    function activity:showInterfaceArrow(kind)
        local target = nil
        local targetPoint = FRAMEPOINT_TOP
        local offsetX = 0
        if kind == "portrait" then
            target = BlzGetOriginFrame(ORIGIN_FRAME_PORTRAIT, 0)
            targetPoint = FRAMEPOINT_TOPLEFT
            offsetX = 0.010
        elseif kind == "info" then
            target = BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)
            if target == nil then
                target = BlzGetOriginFrame(ORIGIN_FRAME_SIMPLE_UI_PARENT, 0)
            end
        elseif kind == "inventory" then
            target = BlzGetOriginFrame(ORIGIN_FRAME_ITEM_BUTTON, 0)
            targetPoint = FRAMEPOINT_TOP
            offsetX = 0.017
        elseif kind == "commands" then
            target = BlzGetOriginFrame(ORIGIN_FRAME_COMMAND_BUTTON, 0)
            targetPoint = FRAMEPOINT_TOP
            offsetX = 0.048
        end
        if self.frames.arrow ~= nil then
            local size = kind == "portrait" and 0.068 or 0.052
            BlzFrameSetSize(self.frames.arrow, size, size)
        end
        self:setArrow(target, targetPoint, offsetX, 0.004)
    end

    function activity:removeWolves()
        for _, unit in ipairs(self.wolves) do
            if unit ~= nil then RemoveUnit(unit) end
        end
        self.wolves = {}
        for _, unit in ipairs(self.wolfSummoners) do
            if unit ~= nil and GetUnitTypeId(unit) ~= 0 then RemoveUnit(unit) end
        end
        self.wolfSummoners = {}
    end

    function activity:disablePriestAutocast(priest)
        IssueImmediateOrder(priest, "healoff")
        IssueImmediateOrder(priest, "innerfireoff")
    end

    function activity:removeEnemies()
        for _, unit in ipairs(self.enemies) do
            if unit ~= nil and GetUnitTypeId(unit) ~= 0 then RemoveUnit(unit) end
        end
        self.enemies = {}
    end

    function activity:createEnemy(rawcode, x, y, facing)
        local unit = JTG.ScopeTrackUnit(session.scope,
            CreateUnit(HOSTILE_PLAYER, FourCC(rawcode), x, y, facing or 270.0))
        table.insert(self.enemies, unit)
        return unit
    end

    function activity:resetUnits()
        self:removeWolves()
        self:removeEnemies()
        for index, unit in ipairs(self.units) do
            local spec = UNIT_LAYOUT[index]
            if unit ~= nil and GetUnitTypeId(unit) ~= 0 then
                SetUnitPosition(unit, spec.x, spec.y)
                SetUnitFacing(unit, spec.facing)
                SetUnitState(unit, UNIT_STATE_LIFE, BlzGetUnitMaxHP(unit))
                SetUnitState(unit, UNIT_STATE_MANA, BlzGetUnitMaxMana(unit))
                UnitRemoveBuffs(unit, true, true)
                IssueImmediateOrder(unit, "stop")
                if spec.kind == "footmen" then
                    IssueImmediateOrder(unit, "undefend")
                elseif spec.kind == "priests" then
                    self:disablePriestAutocast(unit)
                    if self.combatAutocast then IssueImmediateOrder(unit, "healon") end
                end
            end
        end
        if GetLocalPlayer() == UNIT_PLAYER then
            PanCameraToTimed(session.scene.centerX, session.scene.centerY, 0.5)
        end
    end

    function activity:topFootmanReference()
        local topY = -100000.0
        local sumX = 0.0
        local count = 0
        for _, footman in ipairs(self.unitGroups.footmen) do
            local y = GetUnitY(footman)
            if y > topY + 1.0 then
                topY = y
                sumX = GetUnitX(footman)
                count = 1
            elseif math.abs(y - topY) <= 1.0 then
                sumX = sumX + GetUnitX(footman)
                count = count + 1
            end
        end
        return count > 0 and sumX / count or session.scene.centerX, topY
    end

    function activity:spawnPassingGrunt()
        self:removeEnemies()
        local anchor = self.unitGroups.footmen[#self.unitGroups.footmen]
        local grunt = self:createEnemy("ogru", GetUnitX(anchor) + 600.0,
            GetUnitY(anchor) + 100.0, 180.0)
        RemoveGuardPosition(grunt)
        local leftX = session.scene.minX + 64.0
        local leftY = GetUnitY(grunt)
        local north = JTG.Scenes["arena.north"]
        local northX = north.minX + 96.0
        local northY = north.maxY - 96.0
        IssuePointOrder(grunt, "move", leftX, GetUnitY(grunt))
        local routed = false
        local routeTimer = nil
        routeTimer = self:makeTimer(0.10, true, function()
            if grunt == nil or GetUnitTypeId(grunt) == 0 then
                PauseTimer(routeTimer)
                return
            end
            if not routed and GetUnitX(grunt) <= leftX + 72.0 then
                routed = true
                IssuePointOrder(grunt, "move", northX, northY)
            elseif not routed then
                -- Neutral hostile units otherwise sometimes resume their
                -- guard position before reaching the arena boundary.
                IssuePointOrder(grunt, "move", leftX, leftY)
            elseif GetUnitY(grunt) < northY - 72.0 then
                IssuePointOrder(grunt, "move", northX, northY)
            else
                PauseTimer(routeTimer)
            end
        end)
    end

    function activity:spawnNorthernEnemies(distance, attackMove, combatSet)
        self:resetUnits()
        local centerX, topY = self:topFootmanReference()
        local specs = combatSet and {
            {"ogru", -170.0}, {"ogru", 0.0}, {"ohun", 170.0},
        } or {
            {"ogru", -170.0}, {"ohun", 0.0}, {"opeo", 170.0},
        }
        for _, spec in ipairs(specs) do
            local unit = self:createEnemy(spec[1], centerX + spec[2],
                topY + distance, 270.0)
            RemoveGuardPosition(unit)
            if attackMove then
                IssuePointOrder(unit, "attack", session.scene.centerX,
                    session.scene.centerY)
            end
        end
    end

    function activity:spawnFinalHeadhuntersAttack()
        self:resetUnits()
        local centerX, topY = self:topFootmanReference()
        for _, offsetX in ipairs({-110.0, 110.0}) do
            local unit = self:createEnemy("ohun", centerX + offsetX,
                topY + 800.0, 270.0)
            RemoveGuardPosition(unit)
            IssuePointOrder(unit, "attack", session.scene.centerX,
                session.scene.centerY)
        end
    end

    function activity:spawnAttackGrunt()
        self:resetUnits()
        local centerX, topY = self:topFootmanReference()
        local grunt = self:createEnemy("ogru", centerX,
            topY + 800.0, 270.0)
        RemoveGuardPosition(grunt)
        IssueImmediateOrder(grunt, "holdposition")
    end

    function activity:selectUnit(unit)
        if unit == nil then return end
        if GetLocalPlayer() == UNIT_PLAYER then
            ClearSelection()
            SelectUnit(unit, true)
            PanCameraToTimed(GetUnitX(unit), GetUnitY(unit), 0.5)
        end
    end

    function activity:fillPriestMana()
        for _, priest in ipairs(self.unitGroups.priests) do
            SetUnitState(priest, UNIT_STATE_MANA, BlzGetUnitMaxMana(priest))
        end
    end

    function activity:applySlow()
        self:fillPriestMana()
        local dummies = {}
        for index, target in ipairs(self.units) do
            local dummy = JTG.ScopeTrackUnit(session.scope,
                CreateUnit(HOSTILE_PLAYER, FourCC("hsor"),
                    GetUnitX(target), GetUnitY(target) + 350.0, 270.0))
            table.insert(dummies, dummy)
            SetUnitVertexColor(dummy, 255, 255, 255, 0)
            SetUnitInvulnerable(dummy, true)
            SetUnitState(dummy, UNIT_STATE_MANA, BlzGetUnitMaxMana(dummy))
            IssueTargetOrder(dummy, "slow", target)
        end
        self:makeTimer(1.5, false, function()
            for _, dummy in ipairs(dummies) do RemoveUnit(dummy) end
        end)
    end

    function activity:spawnWolves()
        self:resetUnits()
        self:fillPriestMana()
        local centerX, topY = self:topFootmanReference()
        local spawnY = topY + 800.0
        local upperArena = JTG.Scenes["arena.north"]
        local exitY = upperArena.maxY - 96.0
        local abilityId = FourCC("AOsf")
        for index = 1, 2 do
            local caster = JTG.ScopeTrackUnit(session.scope,
                CreateUnit(HOSTILE_PLAYER, FourCC("Ofar"),
                    centerX - 150.0 + (index - 1) * 300.0,
                    spawnY, 90.0))
            table.insert(self.wolfSummoners, caster)
            SetUnitInvulnerable(caster, true)
            RemoveGuardPosition(caster)
            -- The summoners only create and sustain the Spirit Wolves; they
            -- must never acquire or attack the tutorial army themselves.
            SetUnitAcquireRange(caster, 0.0)
            UnitRemoveAbility(caster, FourCC("Aatk"))
            UnitAddAbility(caster, abilityId)
            SetUnitAbilityLevel(caster, abilityId, 1)
            SetUnitState(caster, UNIT_STATE_MANA, BlzGetUnitMaxMana(caster))
            if index == 2 then BlzSetUnitSkin(caster, FourCC("Othr")) end
            IssueImmediateOrder(caster, "spiritwolf")
        end
        -- Let Warcraft create the actual level-one Feral Spirit summons. This
        -- preserves their summoned classification, model and Dispel response.
        self:makeTimer(0.40, false, function()
            local group = CreateGroup()
            GroupEnumUnitsInRange(group, centerX, spawnY, 520.0, nil)
            while true do
                local unit = FirstOfGroup(group)
                if unit == nil then break end
                GroupRemoveUnit(group, unit)
                if GetOwningPlayer(unit) == HOSTILE_PLAYER and
                        IsUnitType(unit, UNIT_TYPE_SUMMONED) then
                    JTG.ScopeTrackUnit(session.scope, unit)
                    table.insert(self.wolves, unit)
                    IssuePointOrder(unit, "attack", session.scene.centerX,
                        session.scene.centerY)
                end
            end
            DestroyGroup(group)
            for _, caster in ipairs(self.wolfSummoners) do
                if caster ~= nil and GetUnitTypeId(caster) ~= 0 then
                    IssuePointOrder(caster, "move", GetUnitX(caster), exitY)
                end
            end
        end)
        -- Keep the summoners alive at the arena's northern edge. Removing a
        -- Farseer also removes his timed summons, so both the Farseers and
        -- wolves are now cleared together with this narration group.
    end

    function activity:selectBothPriestsAtArenaCenter()
        if GetLocalPlayer() ~= UNIT_PLAYER then return end
        ClearSelection()
        for _, priest in ipairs(self.unitGroups.priests) do
            SelectUnit(priest, true)
        end
        PanCameraToTimed(session.scene.centerX, session.scene.centerY, 0.5)
    end

    function activity:removeObstacleCourse()
        for _, unit in ipairs(self.obstacleUnits) do
            if unit ~= nil and GetUnitTypeId(unit) ~= 0 then RemoveUnit(unit) end
        end
        self.obstacleUnits = {}
        for _, destructable in ipairs(self.obstacleDestructables) do
            if destructable ~= nil then RemoveDestructable(destructable) end
        end
        self.obstacleDestructables = {}
    end

    function activity:clearMovementProps()
        self:removeObstacleCourse()
        self.siegeCircleActive = false
        for _, unit in ipairs(self.movementUnits) do
            if unit ~= nil and GetUnitTypeId(unit) ~= 0 then RemoveUnit(unit) end
        end
        self.movementUnits = {}
        self.siegeEngine = nil
    end

    function activity:startSiegeCircle()
        self:clearMovementProps()
        local engine = JTG.ScopeTrackUnit(session.scope,
            CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), FourCC("hmtt"),
                session.scene.centerX + 800.0, session.scene.centerY, 180.0))
        self.siegeEngine = engine
        table.insert(self.movementUnits, engine)
        SetUnitInvulnerable(engine, true)
        RemoveGuardPosition(engine)
        self.siegeCircleActive = true
        local waypoint = 1
        local points = {}
        for index = 1, 12 do
            local angle = (index - 1) * 2.0 * bj_PI / 12.0
            points[index] = {
                session.scene.centerX + 800.0 * Cos(angle),
                session.scene.centerY + 800.0 * Sin(angle),
            }
        end
        IssuePointOrder(engine, "move", points[waypoint][1], points[waypoint][2])
        local circleTimer = nil
        circleTimer = self:makeTimer(0.10, true, function()
            if not self.siegeCircleActive or engine == nil or
                    GetUnitTypeId(engine) == 0 then
                PauseTimer(circleTimer)
                return
            end
            local dx = GetUnitX(engine) - points[waypoint][1]
            local dy = GetUnitY(engine) - points[waypoint][2]
            if dx * dx + dy * dy < 90.0 * 90.0 then
                waypoint = waypoint % #points + 1
            end
            IssuePointOrder(engine, "move", points[waypoint][1],
                points[waypoint][2])
        end)
    end

    function activity:holdSiege()
        self.siegeCircleActive = false
        if self.siegeEngine ~= nil and GetUnitTypeId(self.siegeEngine) ~= 0 then
            IssueImmediateOrder(self.siegeEngine, "holdposition")
        end
    end

    function activity:giveSiegeAndPeasant()
        self:holdSiege()
        if self.siegeEngine ~= nil and GetUnitTypeId(self.siegeEngine) ~= 0 then
            SetUnitOwner(self.siegeEngine, UNIT_PLAYER, true)
        end
        local peasant = JTG.ScopeTrackUnit(session.scope,
            CreateUnit(UNIT_PLAYER, FourCC("hpea"),
                session.scene.centerX + 125.0,
                session.scene.centerY - 50.0, 90.0))
        table.insert(self.movementUnits, peasant)
    end

    function activity:startObstacleCourse()
        self:removeObstacleCourse()
        local owner = Player(PLAYER_NEUTRAL_PASSIVE)
        local cx, cy = session.scene.centerX, session.scene.centerY
        local buildingSpecs = {
            {"htow", -760, 650}, {"hbar", -420, 700}, {"hbar", 420, 700},
            {"halt", 760, 630}, {"hgra", -760, -630},
            {"harm", -390, -700}, {"harm", 390, -700},
            {"hvlt", 760, -620}, {"hvlt", 760, 0},
        }
        for index = 1, 4 do
            buildingSpecs[#buildingSpecs + 1] = {"hgtw", -860 + index * 345, 420}
        end
        for index = 1, 12 do
            local column = (index - 1) % 6
            local row = math.floor((index - 1) / 6)
            buildingSpecs[#buildingSpecs + 1] = {
                "hhou", -720 + column * 290, -380 + row * 190,
            }
        end
        for _, spec in ipairs(buildingSpecs) do
            local unit = JTG.ScopeTrackUnit(session.scope,
                CreateUnit(owner, FourCC(spec[1]), cx + spec[2], cy + spec[3], 270.0))
            table.insert(self.obstacleUnits, unit)
            SetUnitInvulnerable(unit, true)
        end
        for patch = 1, 3 do
            local baseX = cx - 650 + (patch - 1) * 650
            local baseY = cy + (patch == 2 and 120 or -80)
            for tree = 1, 5 do
                local destructable = CreateDestructable(FourCC("LTlt"),
                    baseX + ((tree - 1) % 3) * 80.0,
                    baseY + math.floor((tree - 1) / 3) * 90.0,
                    0.0, 1.0, 0)
                table.insert(self.obstacleDestructables, destructable)
            end
        end
        for index = 1, 20 do
            local angle = (index - 1) * 2.0 * bj_PI / 20.0
            local radius = 250.0 + (index % 4) * 125.0
            local unit = JTG.ScopeTrackUnit(session.scope,
                CreateUnit(owner, FourCC("hmtt"),
                    cx + Cos(angle) * radius, cy + Sin(angle) * radius,
                    angle * bj_RADTODEG))
            table.insert(self.obstacleUnits, unit)
            SetUnitInvulnerable(unit, true)
            RemoveGuardPosition(unit)
            IssuePointOrder(unit, "patrol",
                cx - Cos(angle) * radius, cy - Sin(angle) * radius)
        end
    end

    function activity:runStepTrigger(step)
        local trigger = step and step.trigger
        if trigger == "resetUnits" then
            self:resetUnits()
        elseif trigger == "portraitArrow" then
            self:showInterfaceArrow("portrait")
        elseif trigger == "infoArrow" then
            self:showInterfaceArrow("info")
        elseif trigger == "inventoryArrow" then
            self:showInterfaceArrow("inventory")
        elseif trigger == "commandsArrow" then
            self:showInterfaceArrow("commands")
        elseif trigger == "selectFootman" then
            self:resetUnits()
            self:selectUnit(self.unitGroups.footmen[1])
        elseif trigger == "selectRifleman" then
            self:selectUnit(self.unitGroups.riflemen[1])
        elseif trigger == "healExercise" then
            self:fillPriestMana()
            for index = 1, 2 do
                local footman = self.unitGroups.footmen[index]
                SetUnitState(footman, UNIT_STATE_LIFE,
                    BlzGetUnitMaxHP(footman) * 0.5)
            end
            self:selectUnit(self.unitGroups.priests[1])
        elseif trigger == "fillPriestMana" then
            self:fillPriestMana()
        elseif trigger == "slowExercise" then
            self:resetUnits()
            self:fillPriestMana()
            self:selectBothPriestsAtArenaCenter()
            self:applySlow()
        elseif trigger == "wolfExercise" then
            self:spawnWolves()
            self:selectBothPriestsAtArenaCenter()
        elseif trigger == "innerFireExercise" then
            self:resetUnits()
            self:fillPriestMana()
            self:selectUnit(self.unitGroups.priests[1])
        elseif trigger == "startSiegeCircle" then
            self:startSiegeCircle()
        elseif trigger == "holdSiege" then
            self:holdSiege()
        elseif trigger == "giveSiegeAndPeasant" then
            self:giveSiegeAndPeasant()
        elseif trigger == "obstacleCourse" then
            self:resetUnits()
            self:startObstacleCourse()
        elseif trigger == "spawnPassingGrunt" then
            self:spawnPassingGrunt()
        elseif trigger == "prepareHoldPosition" then
            self.combatAutocast = true
            self:resetUnits()
        elseif trigger == "spawnAttackGrunt" then
            self:spawnAttackGrunt()
        elseif trigger == "spawnEnemyTrio" then
            self:spawnNorthernEnemies(800.0, false, false)
        elseif trigger == "spawnCombatTrio" then
            self:spawnNorthernEnemies(800.0, false, true)
        elseif trigger == "spawnCombatTrioAttack" then
            self:spawnNorthernEnemies(800.0, true, true)
        elseif trigger == "spawnFinalHeadhuntersAttack" then
            self:spawnFinalHeadhuntersAttack()
        elseif trigger == "highlightMenu" then
            if self.frames.menuHighlight ~= nil then
                BlzFrameSetVisible(self.frames.menuHighlight, true)
            end
        end
    end

    function activity:showStep(index, preserveArrow)
        self.optionalActive = false
        self.optionalSection = nil
        local spec = STEPS[index]
        if spec == nil then
            self.complete = true
            self.waitingForContinue = false
            self:refreshControls()
            return
        end
        self.step = index
        self.checkpoint = spec.checkpoint or self.checkpoint
        self.complete = false
        self.waitingForContinue = spec.wait == true
        if index < 49 then
            self.combatAutocast = false
            for _, priest in ipairs(self.unitGroups.priests) do
                self:disablePriestAutocast(priest)
            end
        else
            self.combatAutocast = true
        end
        if self.frames.menuHighlight ~= nil then
            BlzFrameSetVisible(self.frames.menuHighlight, false)
        end
        self:clearNarration(preserveArrow)
        self:appendNarration(StepText(spec))
        self:runStepTrigger(spec)
        self:refreshControls()
    end

    function activity:showOptionalStep(index)
        local steps = self.optionalSection and self.optionalSection.steps
        local spec = steps and steps[index]
        if spec == nil then return end
        if self.frames.menuHighlight ~= nil then
            BlzFrameSetVisible(self.frames.menuHighlight, false)
        end
        self.optionalActive = true
        self.optionalStep = index
        self.complete = false
        self.waitingForContinue = true
        self:setTopicsVisible(false)
        self:setOptionalVisible(false)
        self:clearNarration(false)
        self:appendNarration(StepText(spec))
        self:runStepTrigger(spec)
        if self.frames.menuHighlight ~= nil then
            BlzFrameSetVisible(self.frames.menuHighlight,
                spec.sectionEnd == true and self.presentationVisible and
                not self.topicsOpen and not self.optionalOpen)
        end
        self:refreshControls()
    end

    function activity:beginOptionalSection(section)
        self.optionalReturnStep = self.step
        self.optionalSection = section
        if self.step >= 33 and self.step <= 46 then
            self:clearMovementProps()
        end
        self:removeEnemies()
        self:showOptionalStep(1)
    end

    function activity:continueTutorial()
        if not self.waitingForContinue or self.complete then return end
        if self.optionalActive then
            local steps = self.optionalSection.steps
            if self.optionalStep < #steps then
                self:showOptionalStep(self.optionalStep + 1)
            else
                local returnStep = self.optionalReturnStep
                self.optionalActive = false
                self.optionalSection = nil
                self:showStep(returnStep)
            end
            return
        end
        local current = STEPS[self.step]
        if current ~= nil then
            if current.afterContinue == "resetUnits" then
                self:resetUnits()
            elseif current.afterContinue == "removeEnemies" then
                self:removeEnemies()
            elseif current.afterContinue == "removeObstacleCourse" then
                self:removeObstacleCourse()
            elseif current.afterContinue == "clearMovementProps" then
                self:clearMovementProps()
            end
        end
        if self.step >= #STEPS then
            self.complete = true
            self.waitingForContinue = false
            self:refreshControls()
            return
        end
        self:showStep(self.step + 1,
            current ~= nil and current.preserveArrowOnContinue == true)
    end

    function activity:goBack()
        if self.optionalActive then
            if self.optionalStep > 1 then
                self:showOptionalStep(self.optionalStep - 1)
            else
                local returnStep = self.optionalReturnStep
                self.optionalActive = false
                self.optionalSection = nil
                self:showStep(returnStep)
            end
            return
        end
        if self.step <= 1 and not self.complete then return end
        self:showStep(math.max(1, self.complete and self.step or self.step - 1))
    end

    function activity:restoreTopic(stepIndex)
        if self.step >= 33 and self.step <= 46 and
                (stepIndex < 33 or stepIndex > 46) then
            self:clearMovementProps()
        end
        self:removeEnemies()
        self:setTopicsVisible(false)
        self:setOptionalVisible(false)
        self:showStep(stepIndex)
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

    function activity:setTopicsVisible(visible)
        self.topicsOpen = visible == true
        if self.topicsOpen then
            self.optionalOpen = false
            if self.frames.optionalMenu ~= nil then
                BlzFrameSetVisible(self.frames.optionalMenu, false)
            end
        end
        if self.frames.topicsMenu ~= nil then
            BlzFrameSetVisible(self.frames.topicsMenu,
                self.presentationVisible and self.topicsOpen)
        end
        self:renderNarration()
        self:refreshControls()
    end

    function activity:setOptionalVisible(visible)
        self.optionalOpen = visible == true
        if self.optionalOpen then
            self.topicsOpen = false
            if self.frames.topicsMenu ~= nil then
                BlzFrameSetVisible(self.frames.topicsMenu, false)
            end
        end
        if self.frames.optionalMenu ~= nil then
            BlzFrameSetVisible(self.frames.optionalMenu,
                self.presentationVisible and self.optionalOpen)
        end
        self:renderNarration()
        self:refreshControls()
    end

    function activity:createMenuPanel(name, suffix, buttonCount)
        local root = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        local panel = JTG.ScopeTrackFrame(session.presentationScope,
            BlzCreateFrameByType("FRAME", name .. suffix, root, "", 0))
        BlzFrameSetSize(panel, 0.185,
            JTG.TutorialMenuHeight(buttonCount))
        BlzFrameSetAbsPoint(panel, FRAMEPOINT_TOPRIGHT, 0.795, 0.500)
        local skin = JTG.ScopeTrackFrame(session.presentationScope,
            BlzCreateFrame("EscMenuBackdrop", panel, 0,
                800 + session.generation + string.len(name)))
        BlzFrameSetPoint(skin, FRAMEPOINT_TOPLEFT, panel,
            FRAMEPOINT_TOPLEFT, 0, 0)
        BlzFrameSetPoint(skin, FRAMEPOINT_BOTTOMRIGHT, panel,
            FRAMEPOINT_BOTTOMRIGHT, 0, 0)
        BlzFrameSetEnable(skin, false)
        return panel
    end

    function activity:createPresentation()
        local root = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        local scope = session.presentationScope
        local suffix = tostring(session.generation) .. "x" ..
            tostring((JTG.UI and JTG.UI.epoch) or 0)
        self.frames = {}
        self.actions = {}
        self.buttonEnabled = {}

        local toolbarLayout = (JTG.UI and JTG.UI.ToolbarLayout) or {
            buttonWidth = 0.087, buttonHeight = 0.024,
            gap = 0.001, rowStep = 0.025, left = 0.446, top = 0.575,
        }
        local bar = JTG.ScopeTrackFrame(scope, BlzCreateFrameByType("FRAME",
            "JTGUnitControlsTutorialBar" .. suffix, root, "", 0))
        BlzFrameSetSize(bar, 0.351, 0.060)
        BlzFrameSetAbsPoint(bar, FRAMEPOINT_TOPLEFT,
            toolbarLayout.left, toolbarLayout.top)
        self.frames.bar = bar
        local labels = {
            {"menu", "Menu", 1}, {"back", "Back", 2},
            {"topicsButton", "Topics", 3},
            {"optionalButton", "Optional", 4},
            {"continue", "Continue", 5}, {"pause", "Pause", 7},
        }
        for _, spec in ipairs(labels) do
            local button = JTG.ScopeTrackFrame(scope, CreateTutorialButton(
                "JTGUnitControlsTutorial" .. spec[1] .. suffix,
                bar, spec[2], toolbarLayout.buttonWidth))
            local slot = spec[3] - 1
            BlzFrameSetPoint(button, FRAMEPOINT_TOPLEFT, bar,
                FRAMEPOINT_TOPLEFT,
                (slot % 4) * (toolbarLayout.buttonWidth + toolbarLayout.gap),
                -math.floor(slot / 4) * toolbarLayout.rowStep)
            self.frames[spec[1]] = button
            local label = BlzFrameGetChild(button, 4)
            if label ~= nil then BlzFrameSetScale(label, 0.72) end
        end

        local highlight = JTG.ScopeTrackFrame(scope, BlzCreateFrameByType("SPRITE",
            "JTGUnitControlsContinueHighlight" .. suffix, bar, "", 0))
        BlzFrameSetSize(highlight, 0.058, 0.024)
        BlzFrameSetPoint(highlight, FRAMEPOINT_CENTER, self.frames.continue,
            FRAMEPOINT_CENTER, -0.0125, 0)
        BlzFrameSetModel(highlight,
            "UI\\Feedback\\QuestButton\\UI-QuestButtonOn.mdl", 0)
        BlzFrameSetLevel(highlight, 3)
        BlzFrameSetEnable(highlight, false)
        BlzFrameSetVisible(highlight, false)
        BlzFrameSetLevel(self.frames.continue, 2)
        self.frames.continueHighlight = highlight

        local pauseHighlight = JTG.ScopeTrackFrame(scope, BlzCreateFrameByType("SPRITE",
            "JTGUnitControlsPauseHighlight" .. suffix, bar, "", 0))
        BlzFrameSetSize(pauseHighlight, 0.058, 0.024)
        BlzFrameSetPoint(pauseHighlight, FRAMEPOINT_CENTER, self.frames.pause,
            FRAMEPOINT_CENTER, -0.0125, 0)
        BlzFrameSetModel(pauseHighlight,
            "UI\\Feedback\\QuestButton\\UI-QuestButtonOn.mdl", 0)
        BlzFrameSetLevel(pauseHighlight, 3)
        BlzFrameSetEnable(pauseHighlight, false)
        BlzFrameSetVisible(pauseHighlight, false)
        BlzFrameSetLevel(self.frames.pause, 2)
        if JTG.UI and JTG.UI.RegisterPauseHighlight then
            local unregister = JTG.UI.RegisterPauseHighlight(pauseHighlight)
            JTG.ScopeAdd(scope, unregister)
        end

        local menuHighlight = JTG.ScopeTrackFrame(scope, BlzCreateFrameByType("SPRITE",
            "JTGUnitControlsMenuHighlight" .. suffix, bar, "", 0))
        BlzFrameSetSize(menuHighlight, 0.058, 0.024)
        BlzFrameSetPoint(menuHighlight, FRAMEPOINT_CENTER, self.frames.menu,
            FRAMEPOINT_CENTER, -0.0125, 0)
        BlzFrameSetModel(menuHighlight,
            "UI\\Feedback\\QuestButton\\UI-QuestButtonOn.mdl", 0)
        BlzFrameSetLevel(menuHighlight, 3)
        BlzFrameSetEnable(menuHighlight, false)
        BlzFrameSetVisible(menuHighlight, false)
        BlzFrameSetLevel(self.frames.menu, 2)
        self.frames.menuHighlight = menuHighlight

        local arrow = JTG.ScopeTrackFrame(scope, BlzCreateFrameByType("BACKDROP",
            "JTGUnitControlsInterfaceArrow" .. suffix, root, "", 0))
        BlzFrameSetSize(arrow, 0.052, 0.052)
        BlzFrameSetTexture(arrow, "JTGMenu\\TutorialArrowDown.dds", 0, true)
        BlzFrameSetEnable(arrow, false)
        BlzFrameSetLevel(arrow, 30)
        BlzFrameSetVisible(arrow, false)
        self.frames.arrow = arrow

        local topics = self:createMenuPanel("JTGUnitControlsTopics", suffix,
            #TOPICS)
        self.frames.topicsMenu = topics
        local previous = nil
        local topicButtons = {}
        for index, topic in ipairs(TOPICS) do
            local button = JTG.ScopeTrackFrame(scope, CreateTutorialButton(
                "JTGUnitControlsTopic" .. index .. suffix,
                topics, topic.label, 0.115))
            BlzFrameSetSize(button, 0.115, 0.026)
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
        local topicsClose = JTG.ScopeTrackFrame(scope, CreateTutorialButton(
            "JTGUnitControlsTopicsClose" .. suffix, topics, "Close", 0.10))
        BlzFrameSetSize(topicsClose, 0.10, 0.026)
        BlzFrameSetPoint(topicsClose, FRAMEPOINT_BOTTOM, topics,
            FRAMEPOINT_BOTTOM, 0, 0.025)

        local optional = self:createMenuPanel(
            "JTGUnitControlsOptional", suffix, #OPTIONAL_SECTIONS)
        self.frames.optionalMenu = optional
        local optionalButtons = {}
        previous = nil
        for index, section in ipairs(OPTIONAL_SECTIONS) do
            local button = JTG.ScopeTrackFrame(scope, CreateTutorialButton(
                "JTGUnitControlsOptional" .. index .. suffix,
                optional, section.label, 0.115))
            BlzFrameSetSize(button, 0.115, 0.026)
            if previous == nil then
                BlzFrameSetPoint(button, FRAMEPOINT_TOP, optional,
                    FRAMEPOINT_TOP, 0, -0.041)
            else
                BlzFrameSetPoint(button, FRAMEPOINT_TOP, previous,
                    FRAMEPOINT_BOTTOM, 0, -0.003)
            end
            optionalButtons[index] = button
            previous = button
        end
        local optionalClose = JTG.ScopeTrackFrame(scope, CreateTutorialButton(
            "JTGUnitControlsOptionalClose" .. suffix,
            optional, "Close", 0.10))
        BlzFrameSetSize(optionalClose, 0.10, 0.026)
        BlzFrameSetPoint(optionalClose, FRAMEPOINT_BOTTOM, optional,
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
        self:registerClick(self.frames.topicsButton,
            function() self:setTopicsVisible(not self.topicsOpen) end)
        self:registerClick(self.frames.optionalButton,
            function() self:setOptionalVisible(not self.optionalOpen) end)
        for index, topic in ipairs(TOPICS) do
            self:registerClick(topicButtons[index],
                function() self:restoreTopic(topic.step) end)
        end
        self:registerClick(topicsClose,
            function() self:setTopicsVisible(false) end, "return")
        self:registerClick(optionalClose,
            function() self:setOptionalVisible(false) end, "return")
        for index, section in ipairs(OPTIONAL_SECTIONS) do
            self:registerClick(optionalButtons[index],
                function() self:beginOptionalSection(section) end)
        end

        self:setTopicsVisible(self.topicsOpen)
        self:setOptionalVisible(self.optionalOpen)
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
        if self.frames.optionalMenu ~= nil then
            BlzFrameSetVisible(self.frames.optionalMenu,
                self.presentationVisible and self.optionalOpen)
        end
        if self.frames.arrow ~= nil then
            BlzFrameSetVisible(self.frames.arrow,
                self.presentationVisible and self.arrowActive and
                self.arrowVisible and not self.topicsOpen and
                not self.optionalOpen)
        end
        self:renderNarration()
        self:refreshControls()
    end

    function activity:tick()
        if self.locallyPaused or self.topicsOpen or self.optionalOpen then return end
        if self.arrowActive and self.frames.arrow ~= nil then
            self.arrowElapsed = self.arrowElapsed + TICK_INTERVAL
            if self.arrowElapsed >= 0.35 then
                self.arrowElapsed = 0.0
                self.arrowVisible = not self.arrowVisible
                BlzFrameSetVisible(self.frames.arrow,
                    self.presentationVisible and self.arrowVisible)
            end
        end
    end

    function activity:setup(current)
        JTG.BorrowCamera(current.scope, UNIT_PLAYER)
        JTG.ResetWorldFog(UNIT_PLAYER)
        local playerHostile = GetPlayerAlliance(UNIT_PLAYER, HOSTILE_PLAYER,
            ALLIANCE_PASSIVE)
        local hostilePlayer = GetPlayerAlliance(HOSTILE_PLAYER, UNIT_PLAYER,
            ALLIANCE_PASSIVE)
        SetPlayerAlliance(UNIT_PLAYER, HOSTILE_PLAYER, ALLIANCE_PASSIVE, false)
        SetPlayerAlliance(HOSTILE_PLAYER, UNIT_PLAYER, ALLIANCE_PASSIVE, false)
        JTG.ScopeAdd(current.scope, function()
            SetPlayerAlliance(UNIT_PLAYER, HOSTILE_PLAYER, ALLIANCE_PASSIVE,
                playerHostile)
            SetPlayerAlliance(HOSTILE_PLAYER, UNIT_PLAYER, ALLIANCE_PASSIVE,
                hostilePlayer)
        end)
        for _, sceneId in ipairs({"arena.south", "arena.north"}) do
            local scene = JTG.Scenes[sceneId]
            local area = Rect(scene.minX, scene.minY, scene.maxX, scene.maxY)
            SetFogStateRect(UNIT_PLAYER, FOG_OF_WAR_FOGGED, area, true)
            RemoveRect(area)
        end

        local upgrades = {
            {FourCC("Rhde"), 1}, {FourCC("Rhri"), 1},
            {FourCC("Rhpt"), 2},
        }
        for _, upgrade in ipairs(upgrades) do
            local techId = upgrade[1]
            local targetLevel = upgrade[2]
            local oldLevel = GetPlayerTechCount(UNIT_PLAYER, techId, true)
            SetPlayerTechResearched(UNIT_PLAYER, techId, targetLevel)
            JTG.ScopeAdd(current.scope, function()
                SetPlayerTechResearched(UNIT_PLAYER, techId, oldLevel)
            end)
        end

        -- The tutorial army is instructional scenery rather than a trained
        -- army. Keep it from producing an upkeep transition on entry.
        local oldFoodUsed = GetPlayerState(UNIT_PLAYER,
            PLAYER_STATE_RESOURCE_FOOD_USED)
        JTG.ScopeAdd(current.scope, function()
            SetPlayerState(UNIT_PLAYER, PLAYER_STATE_RESOURCE_FOOD_USED,
                oldFoodUsed)
        end)

        for _, spec in ipairs(UNIT_LAYOUT) do
            local unit = JTG.ScopeTrackUnit(current.scope,
                CreateUnit(UNIT_PLAYER, FourCC(spec.rawcode),
                    spec.x, spec.y, spec.facing))
            table.insert(self.units, unit)
            table.insert(self.unitGroups[spec.kind], unit)
            if spec.kind == "priests" then self:disablePriestAutocast(unit) end
        end
        SetPlayerState(UNIT_PLAYER, PLAYER_STATE_RESOURCE_FOOD_USED, 0)
        self:makeTimer(TICK_INTERVAL, true, function() self:tick() end)
    end

    function activity:start()
        if JTG.UI then JTG.UI.HideToolbar() end
        if GetLocalPlayer() == UNIT_PLAYER then
            SetCameraPosition(session.scene.centerX, session.scene.centerY)
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
        local trigger = STEPS[self.step] and STEPS[self.step].trigger
        if trigger == "portraitArrow" then self:showInterfaceArrow("portrait")
        elseif trigger == "infoArrow" then self:showInterfaceArrow("info")
        elseif trigger == "inventoryArrow" then self:showInterfaceArrow("inventory")
        elseif trigger == "commandsArrow" then self:showInterfaceArrow("commands") end
    end

    function activity:discardPresentationForLoad()
        self.frames = {}
        self.actions = {}
        self.clickTrigger = nil
    end

    function activity:cleanup()
        ClearTextMessages()
        self:clearArrow()
        self:removeWolves()
        self:removeEnemies()
        self:clearMovementProps()
        if GetLocalPlayer() == UNIT_PLAYER then ClearSelection() end
        self.frames = {}
        self.actions = {}
    end

    return activity
end


