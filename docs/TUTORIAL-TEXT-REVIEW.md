# Tutorial Text Review

This file collects the player-facing instructional text from every currently implemented tutorial. It is arranged by progression point and keeps the authoring markers used by the map. Trigger logic and scene implementation details are omitted.

## Formatting markers

- `{Heading: ...}` — cyan section heading
- `{Small Heading: ...}` — cyan subheading where supported
- `{Button: ...}` — yellow interface button
- `{Input: ...}` — yellow player input or key
- `{Menu: ...}` — purple menu path or menu item
- `{Term: ...}` — orange game term
- `{Yellow Font: ...}` — yellow emphasis
- `{Green Font: ...}` — green emphasis
- `{Hotkeys}` — purple “Hotkeys” label

Blank lines below separate review paragraphs. In game, the lines within one progression point are displayed together.

# Camera tutorial

**Learn to Play entry:** 1. Camera

**Tooltip:** Learn how to move, zoom and quickly reposition the camera.

## Main progression

### Progression point 1 — WELCOME

{Heading: WELCOME}
Welcome to the Camera Tutorial!
Let us first take a look at the basic camera controls of Warcraft III.
Once you are done reading and playing around with whatever mechanic you learn, press the {Button: Continue} or {Button: Next} button to move on!

### Progression point 2 — FREE CAMERA

{Heading: FREE CAMERA}
There are four ways to freely move the camera.

### Progression point 3

Firstly, you can use "edge pan" by {Input: moving the mouse} to the edges of the screen.
Edge pan is the most common way to move the camera. It is quick and intuitive.
The drawback is that your mouse cursor will have to leave the center of the screen, where the action happens. Moving it back may cost you some time.
Try using edge pan!

### Progression point 4

The second way to freely move the camera is to {Input: press and hold the Middle Mouse Button} and drag the screen.
This is slower, but it allows you to make small adjustments quickly, without having to move the cursor away from the action.
Try dragging the camera!

### Progression point 5

The third way to move the camera is using the minimap. It is displayed on the bottom left of the screen.
You can {Input: click on the map} to center the camera on that location, or {Input: click and drag across the map} to move it.
Try moving the camera using the minimap!

### Progression point 6

The last way to freely move the camera is using the keyboard. The default keys for this are the {Input: arrow keys}.
These are a bit out of the way for both your left and your right hand, but some people prefer moving the camera using their keyboard hand.
Try moving the camera using the arrow keys!

### Progression point 7 — ZOOMING

{Heading: ZOOMING}
The default camera distance is 1650 units. This can be changed in the settings.
Click the Quest button on the top left, or press {Input: F9}, for more details.

### Progression point 8

You can change the camera distance while in-game. The default control for this is rolling the {Input: Mouse Wheel}.
A closer camera makes controlling units easier, while having the camera further back can help to keep a clear view of a situation.
It is best to set zoom to a default value that allows you to do both. You can always zoom in or out during play.
Feel free to set the default value to something that feels right for you!

### Progression point 9

After zooming in or out using the {Input: Mouse Wheel}, you can reset the current camera distance back to the default value you chose.
The default key to do this is {Input: F5}.
Change the camera zoom, and then reset it!

### Progression point 10 — BASE CAMERA

{Heading: BASE CAMERA}
Now let us take a look at the camera commands you can use for your bases and units.
In this tutorial, you are in control of three different bases.

### Progression point 11

Each of your bases has a main building at a different tier.
For Orcs, the tier 1 building is called a Great Hall.

### Progression point 12

The tier 2 building is called a Stronghold.

### Progression point 13

And the tier 3 building is called a Fortress.

### Progression point 14 — JUMP TO BASE

{Heading: JUMP TO BASE}
You can return to your main buildings, and cycle between them.
The default key for this is {Input: Backspace}.
When doing this, the first main building the camera will jump to is the one with the highest tier. The next will be of the next highest tier.
If several have the same tier, the camera will jump to the oldest ones first.
Try cycling through your main buildings!

### Progression point 15 — NOTIFICATIONS

{Heading: NOTIFICATIONS}
Throughout the game, you will receive notifications, with associated audio callouts.
Each of the notifications has a location. You can jump to the most recent location, and then cycle through the 8 most recent ones.
The default key for this is {Input: Space}.
These notifications can be for finished units, buildings, or researches.

### Progression point 16

You also get notified when you are being attacked.
Once you are being attacked, pressing {Input: Space} is the quickest way to get to the action.
This is easier than first checking on the minimap and manually clicking where the enemy units are shown to be.
Try cycling through your notifications!

### Progression point 17 — IDLE WORKERS

{Heading: IDLE WORKERS}
You can automatically center the camera on idle worker units, and cycle through them.
The default key for this is {Input: Tilde}.
Its label varies on your keyboard layout. It is between the Tabulator and the Escape keys.
Try cycling through your workers!

### Progression point 18

If you want to be able to just select idle workers without automatically centering the camera on them, you can set it to require a {Input: double-tap}.
Click the Quest button on the top left, or press {Input: F9}, for more details.

### Progression point 19 — ARMY CAMERA

{Heading: ARMY CAMERA}
There are two main ways of navigating the camera to your army units.

### Progression point 20

By pressing {Input: F1}, {Input: F2} or {Input: F3}, you can select your hero units.
{Input: Double-tapping} the key centers the camera on the hero.
Which hero is bound to which key depends on the order you trained them in the current game, with your first hero always being bound to {Input: F1} and so on.
Alternatively, you can {Input: click the hero icons} on the top left of the screen.
These keys cannot be changed in-game.
Try moving the camera to your heroes!

### Progression point 21

If you want to freely assign units or buildings to keys, you have to use {Term: Control Groups}.
{Input: Click} one of your units, {Input: hold CTRL}, and then {Input: press 1} on your keyboard!
{Input: (CTRL+1)}
This assigns them to Control Group 1.
You can create a control group for every number key.

### Progression point 22

Control groups can be used to control and divide your army according to type and function.
How to best use control groups will be covered in more detail in a later tutorial.

### Progression point 23

After forming it, {Input: pressing 1} will select the units of Control Group 1.
{Input: Double-tapping} the key moves the camera to the location of the group's units.
Try to assign and use different control groups!

### Progression point 24

Instead of locking the camera, you can also center it on the unit by {Input: clicking its portrait} at the bottom of the screen, or follow the unit by {Input: clicking and holding} the portrait.
Try using these commands!

### Progression point 25 — END OF TUTORIAL

{Heading: END OF TUTORIAL}
This concludes the camera tutorial. Press the {Button: Menu} button to choose another tutorial.
There are also some mechanics that are a bit more niche, which you will probably not need for competitive play. If you are interested in those, press the {Button: Optional} button.

## Optional topics

### Progression point 1 — BONUS: CAMERA ROTATION

{Heading: BONUS: CAMERA ROTATION}
You can rotate the camera by 90 degrees left or right.
By default, hold {Input: Insert} to rotate left or {Input: Delete} to rotate right.
Usually there is no reason to do this while playing, but you might get in a situation where clicking something is easier when the camera is rotated.
Try rotating the camera!

### Progression point 2 — BONUS: LOCK-ON

{Heading: BONUS: LOCK-ON}
These commands lock the camera to the unit you have currently selected.
The default command for this is {Input: holding CTRL} and {Input: pressing C}.
{Input: (CTRL+C)}
To unlock the camera again, use the same command.

### Progression point 3

When multiple units are selected, the camera locks onto the one that is displayed on the very left of the selection.

## Camera tutorial — Quest Log entries

### Changing Default Camera Distance

To change the default camera distance, go to {Menu: Gameplay -> Camera Settings}, enable {Menu: Improved Zoom}, and enter your preferred value.

To do this, you need to leave this map temporarily. Before you do, you should make a {Term: Quicksave}. The default key for this is {Input: F6}.

### Idle Worker Double-Tap

To make centering the camera on an idle worker require a double-tap, go to {Menu: Gameplay -> Game Behavior}, and enable {Menu: Snap Camera to Worker on Double Click}.

# Unit Controls tutorial

**Learn to Play entry:** 2. Unit Controls

**Tooltip:** Learn how to select units, read their interface and use their abilities.

**Topic menu:** Welcome · Unit Selection · Control Groups · Unit Interface · Abilities · Movement · Combat

## Main progression

### Progression point 1 — WELCOME

{Heading: WELCOME}
Welcome to the Unit Control Tutorial!
In this tutorial, we are taking a look at units, and how to control them.
Once you are done reading and playing around with whatever mechanic you learn, press the {Button: Continue} or {Button: Next} button to move on!

### Progression point 2 — UNIT SELECTION

{Heading: UNIT SELECTION}
To control a unit, you first need to select it.
There are several ways to select a unit. We will look at four right now.

### Progression point 3

The first way is to {Input: left click} the unit you want to select.
Clicking another unit will unselect the first one.
Select and unselect some of your units!

### Progression point 4

The second way to select units is to {Term: box select} them.
You do this by {Input: clicking and dragging} with the mouse cursor.
This forms a selection box. Once you {Input: let go}, all of your units under that box are selected.
You can select up to 24 units at the same time.
Select several of your units in different combinations!

### Progression point 5

The third way to select units is to {Term: CTRL select} them.
You do this by {Input: holding CTRL and clicking} a unit, or by {Input: double-clicking} it.
This selects all units of that type that you control within a wide radius.
CTRL select your units!

### Progression point 6

The fourth way to select units is to {Term: shift select} them.
You do this by {Input: holding Shift and clicking} a unit.
This adds that unit to your selection. If you already had units selected, they remain selected.
If you {Input: Shift-click} a single selected unit, it becomes unselected.
Shift select and unselect your units!

### Progression point 7

You can combine {Term: shift select}, {Term: box select} and {Term: CTRL select}.
But this only works when adding units to the selection, not when taking them away.
Try playing around a bit with different combinations of these selection methods!

### Progression point 8 — CONTROL GROUPS

{Heading: CONTROL GROUPS}
Having to select units manually is complicated, and can take time.
For this reason, there are {Term: Control Groups}.
They enable you to very quickly jump between specific unit selections you have saved beforehand.

### Progression point 9

To create a {Term: Control Group}, you have to {Input: select} one or several units, {Input: hold CTRL}, and {Input: press a number}.
For example {Input: CTRL+1}.
You can create a group for every number on your keyboard.
Select some units, and try creating some {Term: Control Groups}!

### Progression point 10

After creating it, {Input: pressing the number} selects the units inside the group.
{Input: Double-tapping} the number centers the camera on the units of the group. Specifically on the unit leftmost in the selection.

### Progression point 11

If you already have a {Term: Control Group}, you can add new units to it by selecting them, {Input: holding Shift}, and {Input: pressing its number}.
For example {Input: Shift+1}.
Alternatively, you can select the group, {Term: Shift-Select} the unit or units you want to add, and then re-create the group.
You can also add units using {Term: Shift-Select} combined with {Term: Box-Select} and {Term: CTRL-Select}.
Try adding units to existing control groups!

### Progression point 12

To remove units from a {Term: Control Group}, you have to {Input: shift-unselect} them and then re-create the group.
Add and remove units from your groups!

### Progression point 13

Every player develops their own preferences when using {Term: Control Groups}.
The first couple groups usually divide the army into melee, ranged and spellcasters, but the details vary.
This allows the player to quickly give precise commands in battle.
The other control groups are often assigned to buildings in the player's base, or worker units.

### Progression point 14 — UNIT INTERFACE

{Heading: UNIT INTERFACE}
Let us take a look at your interface.

### Progression point 15

This is the active unit's {Term: portrait}.
Clicking its portrait centers the camera on the unit.
If several of the same type are selected, you will center on the leftmost in the selection.
Below the portrait, you can see the unit's {Term: health} and {Term: mana}.

### Progression point 16

This space has two functions.

### Progression point 17

When you have selected one unit, it shows you that unit's statistics, such as damage, armor, buffs and debuffs, and so on.

### Progression point 18

When you have selected more than one unit, it shows you smaller portraits of your selection.
You can {Input: double-click} these smaller portraits to select or target the individual units without having to look for them on the screen.

### Progression point 19

This space shows a unit's {Term: inventory}.
Not all units have an inventory, and only Hero units can use {Term: items}.
We will talk about items in detail once we talk about Heroes.

### Progression point 20

This part of the interface displays the {Term: actions} a unit can take.
Many of these are generic, meaning almost every unit has some or all of them.
Some of them are unit specific though. These are called unit {Term: abilities}.
You can use these actions and abilities by clicking them, or by using their hotkeys.

### Progression point 21 — HOTKEYS

{Heading: HOTKEYS}
{Yellow Font: Using hotkeys} takes less time than clicking buttons, so it {Yellow Font: is always recommended!}
You can see a button's hotkey by hovering over it.
If you are new, it is OK to click the buttons during this tutorial.
The next tutorial will instruct you on how to set up Hotkeys.

### Progression point 22 — ABILITIES

{Heading: ABILITIES}
The units you currently control have a variety of abilities.
The footman has the {Button: Defend} ability, which protects him from the piercing damage type, at the cost of movement speed.
This kind of ability simply activates once you {Input: press the button or use the hotkey}.
When several footmen are selected, all of them will use the ability.
Give it a try!

### Progression point 23

The Rifleman has what is called a {Term: passive ability}. It raises his attack range.
Passive abilities are always in effect.

### Progression point 24

The priest is a spellcaster with a variety of abilities, all of which cost mana.
His {Button: Heal} is a {Term: targeted ability} you can use on friendly units.
You use targeted abilities by {Input: pressing the button or using the hotkey}, and then {Input: clicking the target}.
Try healing your wounded footmen!

### Progression point 25

{Button: Dispel} is an {Term: area of effect} spell, that removes magical buffs and debuffs, and damages enemy summoned units within an area.
You use area spells in the same way you use other targeted abilities, except that you do not target units.

### Progression point 26

Your units have been magically slowed. Dispel the magic!

### Progression point 27

Magically summoned creatures are attacking you! Dispel them!

### Progression point 28

The last Priest spell is another targeted ability.
{Button: Inner Fire} strengthens a friendly unit both offensively and defensively.
Try buffing your footmen with Inner Fire, then select one and check to see the buff!

### Progression point 29

You have probably noticed that {Button: Inner Fire} and {Button: Heal} have yellow corners.
This means that these are spells that can be {Term: auto-cast}.
You can set a spell to auto-cast by {Button: right-clicking} it.
A spellcaster can only ever auto-cast one spell at a time.

### Progression point 30

{Term: Auto-cast} spells usually have conditions.
For example, the priest will only heal units if there are damaged units nearby.
And he will only buff them with Inner Fire if a fight is going on.

### Progression point 31 — SUB-SELECTION

{Heading: SUB-SELECTION}
You may have noticed, that when you have selected all of your units, you can see your Priests' abilities, and their portraits are a bit bigger in the unit selection interface.
This is because when you have selected units of several types, one unit type is selected primarily.

### Progression point 32

You can cycle through the different unit types, allowing you to use that type's abilities without changing your selection.
The default hotkey for this is the {Input: Tabulator} key, also known as {Input: Tab}.
Alternatively you can {Input: click} on one of the unit types in the interface.
Try cycling through the unit types in your selection!

### Progression point 33

You can also cycle through the unit types in reverse.
This is done by {Input: holding Shift}, and pressing {Input: Tab}.
{Input: (Shift+Tab)}.

### Progression point 34

There is an option you can enable, that allows you to give commands only to the primary {Term: sub-group} in your selection.
Go to {Menu: Gameplay} -> {Term: User Interface} in the game options, and check the box for {Term: Subgroup Order Modifier Key}.

### Progression point 35

Now you can {Input: press and hold CTRL} and give a {Term: Command}, and only your primary {Term: sub-group} will receive it.
This can be especially useful to move around only your hero in a battle, or have a particular unit type focus fire onto a particular enemy, without having to change selection.
Try giving commands to your primary selection using this command!

### Progression point 36 — THE MOVEMENT COMMAND

{Heading: THE MOVEMENT COMMAND}
You can move around your units by using the {Term: Move} command.
You can either do this by {Input: pressing the button} or using the {Input: hotkey}, and then {Input: clicking} somewhere.
Much more simply, you can {Input: right-click}.

### Progression point 37

If you use a {Term: Move} command on a friendly or neutral unit, your unit will follow that unit.
Have one or several units follow the Siege Engine!

### Progression point 38

When your units move on a unit that stands still, your units will stand still at a distance.
If you give them another {Term: Move} command on the same unit, they will move closer.
It takes four or more movement commands to get your unit as close to the target as possible.
Have your units move into direct contact with the siege engine!

### Progression point 39 — FORMATION MOVEMENT

{Heading: FORMATION MOVEMENT}
Different units have different movement speeds, sizes, and turn rates.
This means that they move very differently.
Some may get left behind, and your army may become divided across a greater area.

### Progression point 40

The game has a mechanic for this, called {Term: Formation Movement}.
This can be enabled or disabled by {Input: clicking the button} next to the minimap, or by {Input: holding Alt} and {Input: pressing F}.
{Input: Alt+F}
Try moving around all of your units in one big selection with and without {Term: Formation Movement}!

### Progression point 41

With regular {Term: Movement}, every unit will move individually, as fast as it can.
When reaching the target location, the army will then arrange itself with melee units in front, ranged fighters in the middle, and casters in the back.

### Progression point 42

{Term: Formation Movement} switches this around.
First, the army arranges itself with melee in front, ranged units in the middle, and casters in the back.
Then the army moves as a whole, only as quickly as the slowest unit in the selection, and while trying to hold the arrangement.

### Progression point 43

In competitive play, {Term: Formation Movement} is almost never used, because it slows down your army, and because your army takes a while to get moving in the first place.
Since new players do not know that it exists, and because it is active by default, it is considered an invisible roadblock for new players.
For these reasons, {Yellow Font: it is recommended you deactivate it.}
The game will remember this choice between sessions.

### Progression point 44 — PATHFINDING

{Heading: PATHFINDING}
Since maps are filled with terrain, buildings, and units, movement is often more complicated than in an open field.
When you give your units a {Term: Movement} command, they will navigate around any obstacles they encounter.
This will sometimes cause them to bunch up, slow down, stand still, or change directions.

### Progression point 45

Move your units around and through all of these obstacles!

### Progression point 46 — The SHIFT QUEUE

{Heading: The SHIFT QUEUE}
If you want to have your unit move along more complicated paths, you can use the {Term: Shift-Queue}.
This is done by {Input: holding Shift}, and then giving the unit several commands.
The unit will then fulfill these commands one by one, allowing you to, for example, plan for a movement to move around hostile units.
Try shift-queueing a movement path for your units!

### Progression point 47

{Term: Shift-Queue} works not only with {Term: Movement} commands, but with basically everything you can tell a unit to do.
This includes all commands, all abilities, and even items.

### Progression point 48 — THE STOP COMMAND

{Heading: THE STOP COMMAND}
If your unit is moving, or doing anything else, you can have it abort what it is currently doing by giving it a {Term: Stop} command.
You can do this by {Input: pressing the button} or by using the {Input: hotkey}.
Have your units move around, and then stop them!

### Progression point 49

{Term: Stop} is a temporary command. It only aborts what the unit currently does.
If the unit wants to start doing something else, like {Term: auto-casting}, it will start again right away.
The same is true for attacking and chasing units that get into range.

### Progression point 50 — COMBAT

{Heading: COMBAT}
Like most strategy games, Warcraft III has a basic stance system.
By default, your units start out in an {Term: aggressive stance}, meaning they attack any hostile unit that comes too close.

### Progression point 51

Once the enemy unit moves away far enough, your units will return to where they were.

### Progression point 52

To change your units' stance, you can use the unit command {Button: Hold Position}, by pressing its button or using its hotkey.
{Button: Hold Position} also cancels any other order they were given, in the same way the {Term: Stop} command does.
However, it also tells the unit to stand still exactly where they are, until they receive another command.
Select all of your units and have them hold position!

### Progression point 53

When holding position, your units will not move, even when an enemy unit is close by.
However, they will attack when in range.

### Progression point 54 — THE ATTACK COMMAND

{Heading: THE ATTACK COMMAND}
If you want to attack a unit, you use the unit command {Button: Attack}.
You can do this by pressing its {Input: button} or using its {Input: hotkey}, and then {Input: clicking} your target.
You can also {Input: right-click} your target.
{Yellow Font: Select all of your units}, and attack the Grunt to the north!

### Progression point 55

Just like with other commands, you can {Term: shift-queue} attack commands.
{Yellow Font: Select all of your units}, and order them to first attack the Headhunter, then the Grunt, and lastly the Peon.

### Progression point 56

You may have noticed that your footmen were bunching up a bit, and running around each other to reach the target.
This is because the {Term: Attack} command, just like the {Term: Move} command leaves no room for alternatives.
Your units will do everything they can to get into attack range of that unit, and ignore anything else.

### Progression point 57

You may also have noticed that your Priests did not heal your Footmen, despite {Input: Heal} being on {Term: auto-cast}.
This is because a direct attack order supersedes auto-casting.

### Progression point 58 — THE ATTACK MOVE COMMAND

{Heading: THE ATTACK MOVE COMMAND}
The {Yellow Font: most important combat command} is the {Term: Attack Move}!
You perform this by {Input: clicking the Attack button}, or using its {Input: hotkey}, and then {Input: clicking on the ground}.
This essentially makes the selected unit move to that location in aggressive stance, meaning it attacks every enemy it comes across.

### Progression point 59

There are several advantages to this.
For one, no time is wasted bunching up. Each unit will just find the closest enemy and attack.
For another, this kind of move does not supersede auto-cast.

### Progression point 60

Try attacking the enemy units to the north with an attack move by {Input: clicking it behind them}!

### Progression point 61

After using an {Term: Attack Move}, you can then manually select units to reposition them or switch their targets.
This is called {Term: Micro}, from micro-management.
Try attacking the enemy units to the north with an attack move, but this time try to micro your units a bit!

### Progression point 62

As a {Yellow Font: rule of thumb}, it is almost always better to {Yellow Font: move your units with an attack move} compared to a regular move!

### Progression point 63

The reason for this is that while given a {Term: Move} command, your units will ignore enemies completely.
This makes them vulnerable in two ways.

### Progression point 64

For one, they will receive damage without defending themselves.
For another, weaker units such as Priests and Riflemen will move out of position, making it easier for your enemy to attack them.

### Progression point 65

Another use for attack moves, is to have your units finish off an enemy, and then start moving somewhere else, without you having to give them another command.

### Progression point 66

Your units will win this fight easily.
Give an attack move command to the top right corner of the minimap!
Your units will finish fighting, and then start moving up there.

### Progression point 67

The only downside to the Attack move is that along the way, you may attack things you do not intend to.
This can be annoying, especially when you are not paying attention to your army at the time.
To get around this, you can use {Term: shift-queue} to avoid places where you know there are enemy units.

### Progression point 68 — END OF TUTORIAL

{Heading: END OF TUTORIAL}
This concludes the unit control tutorial. Press the {Button: Menu} button to choose another tutorial!
Alternatively, press the {Button: Optional} button to learn about more niche mechanics you may not need in competitive play.

## Optional topics

### Progression point 1 — BONUS: PATROLLING

{Heading: BONUS: PATROLLING}
You can have units run back and forth between locations, by using the {Button: Patrol} command.
Try having some of your units patrol around!

### Progression point 2

While patrolling, the unit is in aggressive stance, meaning it works just like an {Term: Attack Move}.
Your unit will attack any hostile unit it comes in range of.

### Progression point 3

If you want to set up more complicated movement paths, you can use the {Term: Shift-Queue}.

### Progression point 4 — OPTIONAL TOPIC COMPLETE

{Heading: OPTIONAL TOPIC COMPLETE}
This optional topic is complete.
Press the {Button: Next} button to return to the tutorial section you previously left.

### Progression point 5 — BONUS: FORMATION MOVEMENT OPTION

{Heading: BONUS: FORMATION MOVEMENT OPTION}
There is an option that allows the use of {Term: Formation Movement} without having to toggle it on and off between commands.

### Progression point 6

Go to {Menu: Gameplay} -> {Menu: Interface}, and check the checkbox for {Menu: Enable Formation Movement Toggle}.

### Progression point 7

Now you can give a {Term: Formation Movement} command by {Input: holding Alt} and giving your units a {Term: Movement} command.
Try enabling this option and moving your army using it!

### Progression point 8 — OPTIONAL TOPIC COMPLETE

{Heading: OPTIONAL TOPIC COMPLETE}
This optional topic is complete.
Press the {Button: Next} button to return to the tutorial section you previously left.

# Hotkey Setup tutorial

**Learn to Play entry:** 3. Hotkey Setup

**Tooltip:** Learn how to use and customize your hotkey layout.

**Topic menu:** Welcome · Why Use Hotkeys · Which Hotkeys? · Hotkey Resources · The Inventory

## Main progression

### Progression point 1 — WELCOME

{Heading: WELCOME}
Welcome to the Hotkeys Tutorial!
This tutorial is going to be a bit different. We are not going to talk about game mechanics, but instead talk about how to best set up your {Term: hotkeys}.
Once you are done reading, press the {Button: Continue} or {Button: Next} button to move on!

### Progression point 2 — WHY USE HOTKEYS?

{Heading: WHY USE HOTKEYS?}
Should you use {Term: hotkeys}?
The answer is simple: Yes!
If you want to get good at the game, you basically have to.

### Progression point 3

Manually clicking every button for every ability or command slows you down significantly.
For every ability, you have to move the mouse cursor away from the action, to the command grid, click a button, and then move it back to the action.
It takes time away from giving unit commands or moving the camera, and it introduces a lot of room for error.

### Progression point 4

You are effectively playing with one hand tied behind your back - your keyboard hand - and you are doing everything with your mouse hand.

### Progression point 5

When using hotkeys, you distribute the load pretty evenly between your mouse hand and your keyboard hand.
The mouse hand aims, clicks, and adjusts the camera, while the keyboard hand chooses commands and navigates the interface.

### Progression point 6

One measurement of play is "actions per minute", or {Term: APM}.
You can even go to the game options and choose to have the game display them live while you play.
When playing without hotkeys, you limit your {Term: APM} to what you can do with one hand.

### Progression point 7 — LEGACY HOTKEYS

{Heading: LEGACY HOTKEYS}
By default, Warcraft III uses {Term: Legacy} Hotkeys.
These are the ones the game came with back in 2002 and 2003.
They are oriented around the names of abilities, units and buildings, and spread all over the keyboard.

### Progression point 8

You can check out some of the units under your control.
Hover over their buttons in the command grid, to see their {Term: Tooltips}!
Usually one letter will be highlighted in yellow. This is the hotkey for that button.

### Progression point 9

These days, nobody will seriously recommend playing with {Term: Legacy} Hotkeys.
This hotkey set requires a lot of acrobatics of your hand.
If you are not a pianist, you will struggle.

### Progression point 10 — GRID HOTKEYS

{Heading: GRID HOTKEYS}
Warcraft III Reforged introduced {Term: Grid} Hotkeys.
These compact all major hotkeys into the 4x3 cluster of QWER, ASDF and ZXCV (or YXCV).
This is the best option, if you want to have a simple solution.
There are better solutions, but they get complicated.
If you want to have it simple for now, it is recommended you simply go with {Term: Grid}.

### Progression point 11

You can change your hotkey setup to Grid by going to {Menu: Input} -> {Menu: Key Bindings} in the game options, and selecting Grid there.
This cannot be done while you are in a map, so {Term: Quicksave} your game with {Input: F6}, leave this map, and check it out!

### Progression point 12 — CUSTOM HOTKEYS

{Heading: CUSTOM HOTKEYS}
From here on out, we are going into the better solutions.
This is where it gets complicated.
If you want to proceed using {Term: Grid}, you can jump to the next {Input: Topic}.

### Progression point 13

When setting your hotkeys to {Term: Grid}, you probably saw that there is a third option: {Term: Custom}.
This allows you to freely assign hotkeys as you see fit.
It also allows you to change the positions of buttons.

### Progression point 14

Again, to change the hotkey setup, you have to {Term: Quicksave} your game with {Input: F6}, leave this map, and go to the game options!

### Progression point 15

Changing custom tooltips also requires you to go to {Menu: \Users\YourUserName\Documents\Warcraft III}, and into the folder {Menu: CustomKeyBindings}.
There you will find a file called {Green Font: CustomKeys.txt}, which contains a list of key bindings.

### Progression point 16

Tip: If you want to play the campaign "The Founding of Durotar", or the new campaign of The Forsaken Kingdom, it is recommended you change your hotkey layout to {Term: Grid} again while you do.
The different campaigns have a lot of special units with complicated ability combinations, and a {Term: Custom} setup can cause some confusion here.

### Progression point 17 — HOTKEY RESOURCES

{Heading: HOTKEY RESOURCES}
If you have looked into the hotkeys file, you will have seen that all the buttons only have a coded description.
Without knowing which code corresponds to which button, you cannot do anything here directly.

### Progression point 18

You have probably noticed that there is a part of the options menu called {Hotkeys}.
When setting up custom hotkeys, you can start by using this one.
However, it only allows you to change the keys, not the position of buttons.

### Progression point 19

People from the community have created their own interfaces to allow easy editing of all aspects of hotkeys.
One of the simplest can be found by using a search engine and typing in "{Input: warcraft 3 hotkey editor}".
The first result should lead you to a GitHub page belonging to a {Yellow Font: J.C.Fields}, where you can upload your hotkey file, edit it, and download the changed version.
This page allows you to change hotkey positions by simply dragging and dropping the buttons in the displayed command grid.

### Progression point 20

Another such resource is the more involved hotkey editor by {Yellow Font: clemenscodes}.
The main problem with setting up custom hotkeys is that abilities are shared between a lot of units, so making a position change can conflict down the line.
This one is very good at showing you where hotkeys or button positions conflict. Warcraft III can show this too, but not nearly as well.
However, this tool will automatically change the button tooltips, so it is only recommended if you don't mind this, or if you know how to change them back.

### Progression point 21 — CHANGING INVENTORY HOTKEYS

{Heading: CHANGING INVENTORY HOTKEYS}
By default, inventory spots are tied to the {Input: Numpad}.
These are far away from the other keys, and some keyboards do not have the buttons at all.
For this reason, many players rebind them.
This can be done in the Warcraft III options.

### Progression point 22

When using {Term: Grid} or {Term: Custom}, an obvious location to put them in is the 2x3 cluster of TY (or TZ), GH and BN.
However, many people, especially coming from the MOBA scene, prefer using a Modifier key (Alt, Shift, CTRL) and using the cluster of QW, AS and ZX (or YX).
The problem: Warcraft III does not support this.

### Progression point 23

The only way to do this is to use an extra program just to rebind a key combination onto the relevant {Input: Numpad} keyboard keys.
This little program has to run in the background while Warcraft III is running.

### Progression point 24

The simplest tool to use for this can be found by using a search engine and typing in "{Input: warcraft inventory hotkeys}".
The first result should be the tool by {Yellow Font: AucT}.
You can use it to customize your inventory buttons in any way you want.

### Progression point 25

However, be aware that this tool does not work properly if you have rebound the inventory hotkeys away from the {Input: Numpad} in the Warcraft options.
You have to reset them to default before using it.
The tool makes your operating system believe that {Input: Alt+Q} is really {Input: Num1} (for example). If Num1 is not the right key, nothing will happen.

### Progression point 26

Since you need to have the program running while the game is running, it is easiest to start them at the same time.
Even simpler, you can do this using the same shortcut on your Desktop. (assuming you are using Windows)

### Progression point 27 — END OF TUTORIAL

{Heading: END OF TUTORIAL}
This concludes the hotkeys tutorial. Press the {Button: Menu} button to choose another tutorial!

# Economy & Workers tutorial

**Learn to Play entry:** 4. Economy & Workers

## Main progression

### Progression point 1 — WELCOME

{Heading: WELCOME}
Welcome to the Economy Tutorial!
This time we are taking a look at the different resources you have to manage when playing Warcraft III.

Once you are done reading a section and playing around with whichever mechanic you learn, press the {Button: Continue} or {Button: Next} button to move on!

### Progression point 2 — WORKERS

{Heading: WORKERS}
The backbone of your economy are your worker units.
Every race has their own workers, which all function a little differently.

All of them construct {Term: Buildings} and harvest {Term: Gold}, and almost of them also harvest {Term: Lumber} - The two main resources of Warcraft III.
They are also all produced at the race's main building.

### Progression point 3 — PEASANTS

{Heading: PEASANTS}
These are {Term: Peasants}. They are the Human worker unit.
Peasants can gather {Term: Gold} by running back and forth between a {Term: Gold Mine} and the Human player's {Term: Main Building}.

### Progression point 4

A mine can be manned by up to five Peasants, and each peasant gathers 10 Gold every five seconds.
So a full gold mine can bring in {Green Font: 10 Gold per second, or 600 Gold per minute}. No more.

### Progression point 5

This is true for all races.
It also means that the only way to raise your gold mining capacity, is finding new gold mines and building {Term: Expansions} there.
Expansions are smaller bases you create during play. They will be covered in later tutorials.

### Progression point 6

Peasants can also gather {Term: Lumber} by hacking at trees and carrying the lumber back to the Human player's {Term: Main Building} or their {Term: Lumber Mill}.
They require 11 seconds to gather 10 Lumber, which they then need to carry back.
Since trees only hold 50 Lumber until they are felled, these trips can vary a lot in length, so a precise rate is not as easy to calculate.

### Progression point 7

As a rule of thumb however, a Human player will eventually want to have {Green Font: 8 Peasants gathering Lumber} in their main base.
Humans can research {Term: Lumber Harvesting}, which raises the Lumber carrying capacity of Peasants to 20 and later 30, cutting down on walking time.

### Progression point 8

Worker units are very vulnerable.
Peasants especially, since they are out in the open when gathering and building.

### Progression point 9

To protect themselves and their base, Peasants can be drafted into the {Term: Militia}.
This happens through a {Term: Call to Arms}, either individually, or at the main building. It lasts 42.5 seconds.

While part of the Militia, they are almost as strong as a Human's basic worker unit, the {Term: Footman}, and gain a lot of movement speed.

### Progression point 10

Your base is being attacked.
Select your Town Hall and use the {Term: Call fo Arms} command to form the {Term: Militia}!

### Progression point 11

You can dissolve the {Term: Militia} through the {Term: Back to Work} command.

Since a {Term: Call to Arms} at the main building calls every Peasant in the entire base, this will completely stop your resource production.

For this reason, it is recommended to only ever call Peasants into the Militia by selecting them and giving them the {Term: Call to Arms} command individually.

### Progression point 12

All worker units can {Term: Repair} buildings and mechanical units.
Repairing damage takes 1.5 times as long as it takes to build that much of the building.
It also costs 35% of the Gold and Lumber it cost to build that part of the building.

### Progression point 13

Your Town Hall is damaged.
Select some of your Peasants and have them repair it by {Input: right-clicking it}!

### Progression point 14

Peasants have another unique feature.
They can help each other in constructing buildings, speeding up the build time for some extra Gold and Lumber.
This is called {Term: Power Building}.

You can see a demonstration of this in {Menu: Tools & Extras}.

### Progression point 15

Select a Peasant and tell it to {Input: Build} an {Term: Altar of Kings}!
Then select a few other Peasants (preferrably from those gathering Lumber) and {Input: right-click} the construction site!
They will help with the construction.

If you want to make sure they continue to what they were doing after they are done, you can {Input: shift-queue} them back onto their gathering duty.

### Progression point 16

Canceling a construction costs you 25% of its build cost.
Having the build site destroyed loses the entire build cost.

### Progression point 17 — PEONS

{Heading: PEONS}
These are {Term: Peons}. They are Orc worker units.
They behave almost the same as Peasants when it comes to Gold and Lumber.

### Progression point 18

The main difference is that an Orc player cannot raise the Lumber carrying capacity of their Peons.
An Orc player will eventually want to have {Green Font: 7 Peons harvesting Lumber} in their base.

### Progression point 19

While Peons are building, they vanish into the building site, making them invulnerable.
That is - until the building site is destroyed.

### Progression point 20

Select a Peon (preferrably from the ones gathering lumber), and command it to {Term: Build} an {Term: Altar of Storms}.

### Progression point 21

While Peons have a bit more {Term: HP} than other workers, they still die easily.
Their means of protecting themselves is assuming {Term: Battle Stations} in a nearby {Term: Orc Burrow} and throwing spears at the attacker.
Similar to Militia, calling all your Peons into the Burrows will stop your resource production, so you will want to only use as few as are needed.

### Progression point 22

Select a Peon and {Input: right-click} the Orc Burrow.
The Peon will enter it.
You can call it back by {Input: selecting the Burrow and clicking its icon}.

### Progression point 23

Your base is being attacked.
Call a few Peons to {Term: Battle Stations}!

You can do this by selecting the Burrows and giving the {Term: Battle Stations} command.

### Progression point 24

Once you are done having them defend your base, you can have them return to work with the {Term: Stand Down} command.

Similar to {Term: Militia}, it is better to assign Peons to {Term: Battle Stations} individually, to disrupt your own economy as little as possible.

### Progression point 25 — WISPS

{Heading: WISPS}
Night Elf workers are called {Term: Wisps}.
They behave very differently compared to Peasants and Peons.

### Progression point 26

The Night Elf main building entangles the nearby gold mine.
Wisps gather Gold in this {Term: Entangled Gold Mine}.
They do not have to walk back and forth, and while inside, are completely safe from harm.

### Progression point 27

Wisps gather Lumber at a rate of 5 per 7.5 seconds, and they do not destroy the trees when doing so.
Because of the lower gathering rate, a Night Elf player will want to have {Green Font: around 8 Wisps gathering Lumber}.
This may fluctuate up and down a bit during the game.

### Progression point 28

Like Peons, Wisps disappear into the building when they are {Term: Constructing}.
Additionally, when they finish building one of the living trees that make up many of the Night Elf buildings, they do not come out at all.

### Progression point 29

Select a Wisp and {Input: Build an Altar of Elders}!
Then select another and {Input: Build an Ancient of Wonders}!

The first Wisp will return from the construction site.
The second will not, and will have to be replaced.

### Progression point 30

Aside from the ones in the {Term: Entangled Gold Mine}, Wisps are among the most vulnerable worker units.
Except for fleeing into the gold mine or into a construction site, Wisps have no great ways of dealing with attacks.

Their only option is often run or to simply {Term: Detonate}.

### Progression point 31

{Term: Detonate} burns 40 mana from enemy units, and deals 225 damage to enemy summons.
This also denies the enemy the {Term: XP} they would otherwise get for killing the Wisp.

### Progression point 32

Your Wisps are being harassed by magically summoned units.
{Term: Detonate} a Wisp to protect the others!

### Progression point 33 — ACOLYTES

{Heading: ACOLYTES}
Undead workers are called {Term: Acolytes}.
They function in a very unique way compared to other worker units..

### Progression point 34

Acolytes gather {Term: Gold} in the {Term: Haunted Gold Mine}.
This is a separate building that has nothing to do with the Undead main building.

Different from any other worker, Acolytes stand in the open while gathering gold, completely vulnerable.

### Progression point 35

Acolytes are also the only worker unit that does not gather {Term: Lumber} at all.
Instead this is done by the basic Undead military unit, the {Term: Ghoul}.

Ghouls can harvest 20 {Term: Lumber} in 13.5 seconds, and an Undead player will want to have {Green Font: 3 Ghouls harvesting Lumber}.
Their gather rate can be slightly improved by the {Term: Ghoul Frenzy} research, which raises their movement speed.

### Progression point 36

Acolytes have no way of defending themselves.
Ghouls take care of this, as well as the Undead buildings' superb defensive capabilities.

### Progression point 37

When {Term: Summoning} buildings, an Acolyte needs only to be present once to initiate the summoning.
This way, an Undead base only ever needs the five Acolytes in the Gold Mine.

### Progression point 38

Select an Acolyte and command it to {Input: Build an Altar of Darkness}!
Then immediately order it to {Input: Move} back into the Goldmine.

### Progression point 39

Undead are the only race that can deconstruct their own buildings.
This is done through the Acolyte's {Term: Unsummon Building} command.
It nets the Undead player 50% of the building's original resource cost.

{Input: Select an Acolyte and unsummon your Crypt}!

### Progression point 40

Another unique feature of Acolytes is that they can be sacrificed at a {Term: Sacrificial Pit}, turning them into a {Term: Shade}.
A Shade is an invisible scout unit that reveals other invisible units.

Select an Acolyte and {Input: right-click the Sacrificial Pit}!

Since the sacrifice can be cancelled, this is a way to safely hide an Acolyte for a few seconds.

### Progression point 41 — FOOD PRODUCTION

{Heading: FOOD PRODUCTION}
Aside from {Term: Gold} and {Term: Lumber}, which can be gathered directly, there is a third Resource in Warcraft III, called {Term: Food}.
Food is produced by building specific buildings.

### Progression point 42

At first, this is the {Term: Main Building}.
Since the player always starts with this, it provides their starting {Term: Food Production}.
The amount of Food a Main Building produces is different by race.

### Progression point 43

For Night Elves and the Undead, their Main Buildings, the {Term: Tree of Life} and the {Term: Necropolis}, produce 10 Food.

### Progression point 44

For Orcs, their Main Building, the {Term: Great Hall}, produces 11 Food.

### Progression point 45

The Main Building of the Humans produces different amounts of Food depending on its tier.
The {Term: Town Hall} produces 12, the {Term: Keep} produces 14, and the {Term: Castle} produces 16.

### Progression point 46

Aside from their main building, each race has a Food building.
For Humans it is {Term: Farms}, for Orcs it is {Term: Orc Burrows}, for Night Elves it is {Term: Moon Wells}, and for Undead it is {Term: Ziggurats}.

Each of these produce 10 Food.

### Progression point 47

Now, the question is: {Gold Font: What does Food do?}

The answer: Nothing by itself.
Instead, {Gold Font: it limits how many units you can have} - the size of your army.

### Progression point 48

Workers require 1 Food, other small units require 2 or 3.
Heroes require 5, and larger units require up to 7.
All of these add up, and the total {Gold Font: cannot exceed your food production}.

### Progression point 49

When you are consuming as much food as you produce, you cannot produce more units.
This means you have {Term: Supply Blocked} yourself.

To be able to build new units, you now have to build more food production buildings.
This takes time, and slows down your game, so it is better to {Gold Font: plan ahead!}

### Progression point 50 — UPKEEP

{Heading: UPKEEP}
Food governs the last mechanic relevant to Warcraft III's economy: {Term: Upkeep}.
This mechanic limits your army size, not by not allowing you to build units, but by making you pay extra for having them.

### Progression point 51

This is done through a {Gold Font: tax on all Gold income}.
Once your {Term: Food Consumption}, not production, goes past 50, you hear a notification sound, and see {Yellow Font: Low Upkeep} pop up on your screen.

### Progression point 52

While you consume this much food, {Gold Font: you pay a 30% tax}.
This means each of your workers only produce 7 {Term: Gold} every 5 seconds.

It also affects Gold you get for selling items, killing neutral enemies, and so on.
Basically it affects all ways you can receive Gold in the game. (Lumber is not affected.)

### Progression point 53

Once you fall back under 51 {Term: Food Consumption}, you no longer have to pay {Term: Upkeep}.
Your hear the notification sound again, and {Green Font: No Upkeep} pops up on your screen.

### Progression point 54

Once your {Term: Food Consumption} goes past 80, you go to {Red Font: High Upkeep}.
You now {Gold Font: pay a 60% tax}.

### Progression point 55

This mechanic makes it so {Yellow Font: you do not want to just grow your army as quickly as you can}.

Growing it to 50 Food Consumption is great, and you should do it quickly, to be as strong as possible as soon as you can.
But both {Yellow Font: crossing the threshold to 51 and to 81 are serious decisions} you should only make with a goal in mind.

### Progression point 56

For example, you can raise your army size past 50 in anticipation for a battle.
Since you will lose some units, it will likely drop you back to below 51.

And of course it makes sense to cross the threshold into Low or High Upkeep to attain the advantage to end the game.

### Progression point 57

{Yellow Font: What you do not ever want to do is go to 51 Food Consumption and stay there for no reason.}

That is just wasting money.
Especially because your Gold Mines still lose 10 Gold, and will run empty eventually.

### Progression point 58 — END OF TUTORIAL

{Heading: END OF TUTORIAL}
This concludes the economy tutorial. Press the {Button: Menu} button to choose another tutorial!

