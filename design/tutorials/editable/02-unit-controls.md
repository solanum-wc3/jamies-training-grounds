# Unit Controls — editable tutorial script

Snapshot of the current implementation, 13 October 2026.
Edit narration directly and add progression or scene changes under Your edits / notes.
Keep formatting tags such as `{Heading: ...}`, `{Input: ...}` and `{Button: ...}`.
Edits here do not automatically update the map; these are authoring work files.
Each numbered step is one narration stop. Blank lines in narration are intentional.

Implementation reference: `src/activities/unit-controls-tutorial.lua`.

## Shared progression

- Continue advances a narration stop; Next appears at section boundaries.
- Back and Topics return to checkpoints using the tutorial restoration procedures.
- Blue heading tags identify narration sub-sections.
- Camera movements use the shared fixed duration (1.5 seconds).

## Step 1 — welcome

### Narration

{Heading: WELCOME}
Welcome to the Unit Control Tutorial!
In this tutorial, we are taking a look at units, and how to control them.
Once you are done reading and playing around with whatever mechanic you learn, press the {Button: Continue} or {Button: Next} button to move on!

### Progression and scene actions

- Checkpoint: `welcome`.
- Advance with Continue.
- Scene action: **reset Units** (`resetUnits`).
- Group start: `1`.

### Your edits / notes



## Step 2 — unitselection

### Narration

{Heading: UNIT SELECTION}
To control a unit, you first need to select it.
There are several ways to select a unit. We will look at four right now.

### Progression and scene actions

- Checkpoint: `unitselection`.
- Advance with Continue.
- Scene action: **reset Units** (`resetUnits`).
- Group start: `2`.

### Your edits / notes



## Step 3 — unitselection

### Narration

The first way is to {Input: left click} the unit you want to select.
Clicking another unit will unselect the first one.

Select and unselect some of your units!

### Progression and scene actions

- Checkpoint: `unitselection`.
- Advance with Continue.
- Group start: `3`.

### Your edits / notes



## Step 4 — unitselection

### Narration

The second way to select units is to {Term: box select} them.
You do this by {Input: clicking and dragging} with the mouse cursor.
This forms a selection box. Once you {Input: let go}, all of your units under that box are selected.
You can select up to 24 units at the same time.

Select several of your units in different combinations!

### Progression and scene actions

- Checkpoint: `unitselection`.
- Advance with Continue.
- Group start: `4`.

### Your edits / notes



## Step 5 — unitselection

### Narration

The third way to select units is to {Term: CTRL select} them.
You do this by {Input: holding CTRL and clicking} a unit, or by {Input: double-clicking} it.
This selects all units of that type that you control within a wide radius.

CTRL select your units!

### Progression and scene actions

- Checkpoint: `unitselection`.
- Advance with Continue.
- Group start: `5`.

### Your edits / notes



## Step 6 — unitselection

### Narration

The fourth way to select units is to {Term: shift select} them.
You do this by {Input: holding Shift and clicking} a unit.
This adds that unit to your selection. If you already had units selected, they remain selected.
If you {Input: Shift-click} a single selected unit, it becomes unselected.

Shift select and unselect your units!

### Progression and scene actions

- Checkpoint: `unitselection`.
- Advance with Continue.
- Group start: `6`.

### Your edits / notes



## Step 7 — unitselection

### Narration

You can combine {Term: shift select}, {Term: box select} and {Term: CTRL select}.
But this only works when adding units to the selection, not when taking them away.

Try playing around a bit with different combinations of these selection methods!

### Progression and scene actions

- Checkpoint: `unitselection`.
- Advance with Next.
- Group start: `7`.

### Your edits / notes



## Step 8 — controlgroups

### Narration

{Heading: CONTROL GROUPS}
Having to select units manually is complicated, and can take time.
For this reason, there are {Term: Control Groups}.
They enable you to very quickly jump between specific unit selections you have saved beforehand.

### Progression and scene actions

- Checkpoint: `controlgroups`.
- Advance with Continue.
- Scene action: **reset Units** (`resetUnits`).
- Group start: `8`.

### Your edits / notes



## Step 9 — controlgroups

### Narration

To create a {Term: Control Group}, you have to {Input: select} one or several units, {Input: hold CTRL}, and {Input: press a number}.
For example {Input: CTRL+1}.
You can create a group for every number on your keyboard.

Select some units, and try creating some {Term: Control Groups}!

### Progression and scene actions

- Checkpoint: `controlgroups`.
- Advance with Continue.
- Group start: `9`.

### Your edits / notes



## Step 10 — controlgroups

### Narration

After creating it, {Input: pressing the number} selects the units inside the group.
{Input: Double-tapping} the number centers the camera on the units of the group. Specifically on the unit leftmost in the selection.

### Progression and scene actions

- Checkpoint: `controlgroups`.
- Advance with Continue.
- Group start: `10`.

### Your edits / notes



## Step 11 — controlgroups

### Narration

You can add new units to a {Term: Control Group} by selecting them, {Input: holding Shift, and pressing its number}.
For example {Input: Shift+1}.
[Progression: Wait for Continue]

Alternatively, you can select the group, {Term: Shift-Select} the unit or units you want to add, and then re-create the group.
You can also add units using {Term: Shift-Select} combined with {Term: Box-Select} and {Term: CTRL-Select}.

Try adding units to existing control groups!

### Progression and scene actions

- Checkpoint: `controlgroups`.
- Advance with Continue.
- Group start: `11`.

### Your edits / notes



## Step 12 — controlgroups

### Narration

To remove units from a {Term: Control Group}, you have to {Input: shift-unselect} them and then re-create the group.

Add and remove units from your groups!

### Progression and scene actions

- Checkpoint: `controlgroups`.
- Advance with Continue.
- Group start: `12`.

### Your edits / notes



## Step 13 — controlgroups

### Narration

Every player develops their own preferences when using {Term: Control Groups}.
The first couple groups usually divide the army into melee, ranged and spellcasters, but the details vary.
This allows the player to quickly give precise commands in battle.
The other control groups are often assigned to buildings in the player's base, or worker units.

### Progression and scene actions

- Checkpoint: `controlgroups`.
- Advance with Next.
- Group start: `13`.

### Your edits / notes



## Step 14 — unitinterface

### Narration

{Heading: UNIT INTERFACE}
Let us take a look at your interface.

### Progression and scene actions

- Checkpoint: `unitinterface`.
- Advance with Continue.
- Scene action: **reset Units** (`resetUnits`).
- Group start: `14`.

### Your edits / notes



## Step 15 — unitinterface

### Narration

This is the active unit's {Term: portrait}.
Clicking its portrait centers the camera on the unit.
If several of the same type are selected, you will center on the leftmost in the selection.
Below the portrait, you can see the unit's {Term: health} and {Term: mana}.

### Progression and scene actions

- Checkpoint: `unitinterface`.
- Advance with Continue.
- Scene action: **portrait Arrow** (`portraitArrow`).
- Group start: `15`.

### Your edits / notes



## Step 16 — unitinterface

### Narration

This space has two functions.

### Progression and scene actions

- Checkpoint: `unitinterface`.
- Advance with Continue.
- Scene action: **info Arrow** (`infoArrow`).
- Group start: `16`.

Scene / restoration details:

```json
{
  "preserveArrowOnContinue": true
}
```

### Your edits / notes



## Step 17 — unitinterface

### Narration

When you have selected one unit, it shows you that unit's statistics, such as damage, armor, buffs and debuffs, and so on.

### Progression and scene actions

- Checkpoint: `unitinterface`.
- Advance with Continue.
- Group start: `17`.

Scene / restoration details:

```json
{
  "preserveArrowOnContinue": true
}
```

### Your edits / notes



## Step 18 — unitinterface

### Narration

When you have selected more than one unit, it shows you smaller portraits of your selection.
You can {Input: double-click} these smaller portraits to select or target the individual units without having to look for them on the screen.

### Progression and scene actions

- Checkpoint: `unitinterface`.
- Advance with Continue.
- Group start: `18`.

### Your edits / notes



## Step 19 — unitinterface

### Narration

This space shows a unit's {Term: inventory}.
Not all units have an inventory, and only Hero units can use {Term: items}.
We will talk about items in detail once we talk about Heroes.

### Progression and scene actions

- Checkpoint: `unitinterface`.
- Advance with Continue.
- Scene action: **inventory Arrow** (`inventoryArrow`).
- Group start: `19`.

### Your edits / notes



## Step 20 — unitinterface

### Narration

This part of the interface displays the {Term: actions} a unit can take.
Many of these are generic, meaning almost every unit has some or all of them.
Some of them are unit specific though. These are called unit {Term: abilities}.
You can use these actions and abilities by clicking them, or by using their hotkeys.

### Progression and scene actions

- Checkpoint: `unitinterface`.
- Advance with Continue.
- Scene action: **commands Arrow** (`commandsArrow`).
- Group start: `20`.

### Your edits / notes



## Step 21 — unitinterface

### Narration

{Heading: HOTKEYS}
{Yellow Font: Using hotkeys} takes less time than clicking buttons, so it {Yellow Font: is always recommended!}
You can see a button's hotkey by hovering over it.
If you are new, it is OK to click the buttons during this tutorial.
The next tutorial will instruct you on how to set up Hotkeys.

### Progression and scene actions

- Checkpoint: `unitinterface`.
- Advance with Next.
- Group start: `21`.

### Your edits / notes



## Step 22 — abilities

### Narration

{Heading: ABILITIES}
The units you currently control have a variety of abilities.
The footman has the {Button: Defend} ability, which protects him from the piercing damage type, at the cost of movement speed.
This kind of ability simply activates once you {Input: press the button or use the hotkey}.
When several footmen are selected, all of them will use the ability.

Give it a try!

### Progression and scene actions

- Checkpoint: `abilities`.
- Advance with Continue.
- Scene action: **select Footman** (`selectFootman`).
- Group start: `22`.

### Your edits / notes



## Step 23 — abilities

### Narration

The Rifleman has what is called a {Term: passive ability}. It raises his attack range.
Passive abilities are always in effect.

### Progression and scene actions

- Checkpoint: `abilities`.
- Advance with Continue.
- Scene action: **select Rifleman** (`selectRifleman`).
- Group start: `23`.

### Your edits / notes



## Step 24 — abilities

### Narration

The priest is a spellcaster with a variety of abilities, all of which cost mana.
His {Button: Heal} is a {Term: targeted ability} you can use on friendly units.
You use targeted abilities by {Input: pressing the button or using the hotkey}, and then {Input: clicking the target}.

Try healing your wounded footmen!

### Progression and scene actions

- Checkpoint: `abilities`.
- Advance with Continue.
- Scene action: **heal Exercise** (`healExercise`).
- Group start: `24`.

### Your edits / notes



## Step 25 — abilities

### Narration

{Button: Dispel} is an {Term: area of effect} spell, that removes magical buffs and debuffs, and damages enemy summoned units within an area.
You use area spells in the same way you use other targeted abilities, except that you do not target units.

### Progression and scene actions

- Checkpoint: `abilities`.
- Advance with Continue.
- Scene action: **fill Priest Mana** (`fillPriestMana`).
- Group start: `25`.

### Your edits / notes



## Step 26 — abilities

### Narration

Your units have been magically slowed. Dispel the magic!

### Progression and scene actions

- Checkpoint: `abilities`.
- Advance with Continue.
- Scene action: **slow Exercise** (`slowExercise`).
- Group start: `26`.

### Your edits / notes



## Step 27 — abilities

### Narration

Magically summoned creatures are attacking you! Dispel them!

### Progression and scene actions

- Checkpoint: `abilities`.
- Advance with Continue.
- Scene action: **wolf Exercise** (`wolfExercise`).
- Group start: `27`.

Scene / restoration details:

```json
{
  "afterContinue": "resetUnits"
}
```

### Your edits / notes



## Step 28 — abilities

### Narration

The last Priest spell is another targeted ability.
{Button: Inner Fire} strengthens a friendly unit both offensively and defensively.

Try buffing your footmen with Inner Fire, then select one and check to see the buff!

### Progression and scene actions

- Checkpoint: `abilities`.
- Advance with Continue.
- Scene action: **inner Fire Exercise** (`innerFireExercise`).
- Group start: `28`.

### Your edits / notes



## Step 29 — abilities

### Narration

You have probably noticed that {Button: Inner Fire} and {Button: Heal} have yellow corners.
This means that these are spells that can be {Term: auto-cast}.
You can set a spell to auto-cast by {Button: right-clicking} it.
A spellcaster can only ever auto-cast one spell at a time.

### Progression and scene actions

- Checkpoint: `abilities`.
- Advance with Continue.
- Group start: `29`.

### Your edits / notes



## Step 30 — abilities

### Narration

{Term: Auto-cast} spells usually have conditions.
For example, the priest will only heal units if there are damaged units nearby.
And he will only buff them with Inner Fire if a fight is going on.

### Progression and scene actions

- Checkpoint: `abilities`.
- Advance with Continue.
- Group start: `30`.

### Your edits / notes



## Step 31 — abilities

### Narration

{Heading: SUB-SELECTION}
You may have noticed, that when you have selected all of your units, you can see your Priests' abilities, and their portraits are a bit bigger in the unit selection interface.
This is because when you have selected units of several types, one unit type is selected primarily.

### Progression and scene actions

- Checkpoint: `abilities`.
- Advance with Continue.
- Group start: `31`.

### Your edits / notes



## Step 32 — abilities

### Narration

You can cycle through the different unit types, allowing you to use that type's abilities without changing your selection.
The default hotkey for this is the {Input: Tabulator} key, also known as {Input: Tab}.
Alternatively you can {Input: click} on one of the unit types in the interface.

Try cycling through the unit types in your selection!

### Progression and scene actions

- Checkpoint: `abilities`.
- Advance with Continue.
- Group start: `32`.

### Your edits / notes



## Step 33 — abilities

### Narration

You can also cycle through the unit types in reverse.
This is done by {Input: holding Shift}, and pressing {Input: Tab}.
{Input: (Shift+Tab)}.

### Progression and scene actions

- Checkpoint: `abilities`.
- Advance with Continue.
- Group start: `33`.

### Your edits / notes



## Step 34 — abilities

### Narration

There is an option you can enable, that allows you to give commands only to the primary {Term: sub-group} in your selection.
Go to {Menu: Gameplay} -> {Term: User Interface} in the game options, and check the box for {Term: Subgroup Order Modifier Key}.

### Progression and scene actions

- Checkpoint: `abilities`.
- Advance with Continue.
- Group start: `34`.

### Your edits / notes



## Step 35 — abilities

### Narration

Now you can {Input: press and hold CTRL} and give a {Term: Command}, and only your primary {Term: sub-group} will receive it.
This can be especially useful to move around only your hero in a battle, or have a particular unit type focus fire onto a particular enemy, without having to change selection.

Try giving commands to your primary selection using this command!

### Progression and scene actions

- Checkpoint: `abilities`.
- Advance with Next.
- Group start: `35`.

### Your edits / notes



## Step 36 — movement

### Narration

{Heading: THE MOVEMENT COMMAND}
You can move around your units by using the {Term: Move} command.
You can either do this by {Input: pressing the button} or using the {Input: hotkey}, and then {Input: clicking} somewhere.
Much more simply, you can {Input: right-click}.

### Progression and scene actions

- Checkpoint: `movement`.
- Advance with Continue.
- Scene action: **reset Units** (`resetUnits`).
- Group start: `36`.

### Your edits / notes



## Step 37 — movement

### Narration

If you use a {Term: Move} command on a friendly or neutral unit, your unit will follow that unit.

Have one or several units follow the Siege Engine!

### Progression and scene actions

- Checkpoint: `movement`.
- Advance with Continue.
- Scene action: **start Siege Circle** (`startSiegeCircle`).
- Group start: `37`.

### Your edits / notes



## Step 38 — movement

### Narration

When your units move on a unit that stands still, your units will stand still at a distance.
If you give them another {Term: Move} command on the same unit, they will move closer.
It takes four or more movement commands to get your unit as close to the target as possible.

Have your units move into direct contact with the siege engine!

### Progression and scene actions

- Checkpoint: `movement`.
- Advance with Continue.
- Scene action: **hold Siege** (`holdSiege`).
- Group start: `38`.

### Your edits / notes



## Step 39 — movement

### Narration

{Heading: FORMATION MOVEMENT}
Different units have different movement speeds, sizes, and turn rates.
This means that they move very differently.
Some may get left behind, and your army may become divided across a greater area.

### Progression and scene actions

- Checkpoint: `movement`.
- Advance with Continue.
- Scene action: **give Siege And Peasant** (`giveSiegeAndPeasant`).
- Group start: `39`.

### Your edits / notes



## Step 40 — movement

### Narration

The game has a mechanic for this, called {Term: Formation Movement}.
This can be enabled or disabled by {Input: clicking the button} next to the minimap, or by {Input: holding Alt} and {Input: pressing F}.
{Input: Alt+F}

Try moving around all of your units in one big selection with and without {Term: Formation Movement}!

### Progression and scene actions

- Checkpoint: `movement`.
- Advance with Continue.
- Group start: `40`.

### Your edits / notes



## Step 41 — movement

### Narration

With regular {Term: Movement}, every unit will move individually, as fast as it can.
When reaching the target location, the army will then arrange itself with melee units in front, ranged fighters in the middle, and casters in the back.

### Progression and scene actions

- Checkpoint: `movement`.
- Advance with Continue.
- Group start: `41`.

### Your edits / notes



## Step 42 — movement

### Narration

{Term: Formation Movement} switches this around.
First, the army arranges itself with melee in front, ranged units in the middle, and casters in the back.
Then the army moves as a whole, only as quickly as the slowest unit in the selection, and while trying to hold the arrangement.

### Progression and scene actions

- Checkpoint: `movement`.
- Advance with Continue.
- Group start: `42`.

### Your edits / notes



## Step 43 — movement

### Narration

In competitive play, {Term: Formation Movement} is almost never used, because it slows down your army, and because your army takes a while to get moving in the first place.
Since new players do not know that it exists, and because it is active by default, it is considered an invisible roadblock for new players.
For these reasons, {Yellow Font: it is recommended you deactivate it.}
The game will remember this choice between sessions.

### Progression and scene actions

- Checkpoint: `movement`.
- Advance with Continue.
- Group start: `43`.

### Your edits / notes



## Step 44 — movement

### Narration

{Heading: PATHFINDING}
Since maps are filled with terrain, buildings, and units, movement is often more complicated than in an open field.
When you give your units a {Term: Movement} command, they will navigate around any obstacles they encounter.
This will sometimes cause them to bunch up, slow down, stand still, or change directions.

### Progression and scene actions

- Checkpoint: `movement`.
- Advance with Continue.
- Group start: `44`.

### Your edits / notes



## Step 45 — movement

### Narration

Move your units around and through all of these obstacles!

### Progression and scene actions

- Checkpoint: `movement`.
- Advance with Continue.
- Scene action: **obstacle Course** (`obstacleCourse`).
- Group start: `45`.

Scene / restoration details:

```json
{
  "afterContinue": "removeObstacleCourse"
}
```

### Your edits / notes



## Step 46 — movement

### Narration

{Heading: The SHIFT QUEUE}
If you want to have your unit move along more complicated paths, you can use the {Term: Shift-Queue}.
This is done by {Input: holding Shift}, and then giving the unit several commands.
The unit will then fulfill these commands one by one, allowing you to, for example, plan for a movement to move around hostile units.

Try shift-queueing a movement path for your units!

### Progression and scene actions

- Checkpoint: `movement`.
- Advance with Continue.
- Group start: `46`.

### Your edits / notes



## Step 47 — movement

### Narration

{Term: Shift-Queue} works not only with {Term: Movement} commands, but with basically everything you can tell a unit to do.
This includes all commands, all abilities, and even items.

### Progression and scene actions

- Checkpoint: `movement`.
- Advance with Continue.
- Group start: `47`.

### Your edits / notes



## Step 48 — movement

### Narration

{Heading: THE STOP COMMAND}
If your unit is moving, or doing anything else, you can have it abort what it is currently doing by giving it a {Term: Stop} command.
You can do this by {Input: pressing the button} or by using the {Input: hotkey}.

Have your units move around, and then stop them!

### Progression and scene actions

- Checkpoint: `movement`.
- Advance with Continue.
- Group start: `48`.

### Your edits / notes



## Step 49 — movement

### Narration

{Term: Stop} is a temporary command. It only aborts what the unit currently does.
If the unit wants to start doing something else, like {Term: auto-casting}, it will start again right away.
The same is true for attacking and chasing units that get into range.

### Progression and scene actions

- Checkpoint: `movement`.
- Advance with Next.
- Group start: `49`.

Scene / restoration details:

```json
{
  "afterContinue": "clearMovementProps"
}
```

### Your edits / notes



## Step 50 — combat

### Narration

{Heading: COMBAT}
Like most strategy games, Warcraft III has a basic stance system.
By default, your units start out in an {Term: aggressive stance}, meaning they attack any hostile unit that comes too close.

### Progression and scene actions

- Checkpoint: `combat`.
- Advance with Continue.
- Scene action: **reset Units** (`resetUnits`).
- Group start: `50`.

### Your edits / notes



## Step 51 — combat

### Narration

Once the enemy unit moves away far enough, your units will return to where they were.

### Progression and scene actions

- Checkpoint: `combat`.
- Advance with Continue.
- Scene action: **spawn Passing Grunt** (`spawnPassingGrunt`).
- Group start: `51`.

Scene / restoration details:

```json
{
  "afterContinue": "removeEnemies"
}
```

### Your edits / notes



## Step 52 — combat

### Narration

To change your units' stance, you can use the unit command {Button: Hold Position}, by pressing its button or using its hotkey.
{Button: Hold Position} also cancels any other order they were given, in the same way the {Term: Stop} command does.
However, it also tells the unit to stand still exactly where they are, until they receive another command.

Select all of your units and have them hold position!

### Progression and scene actions

- Checkpoint: `combat`.
- Advance with Continue.
- Scene action: **prepare Hold Position** (`prepareHoldPosition`).
- Group start: `52`.

### Your edits / notes



## Step 53 — combat

### Narration

When holding position, your units will not move, even when an enemy unit is close by.
However, they will attack when in range.

### Progression and scene actions

- Checkpoint: `combat`.
- Advance with Continue.
- Scene action: **spawn Passing Grunt** (`spawnPassingGrunt`).
- Group start: `53`.

Scene / restoration details:

```json
{
  "afterContinue": "removeEnemies"
}
```

### Your edits / notes



## Step 54 — combat

### Narration

{Heading: THE ATTACK COMMAND}
If you want to attack a unit, you use the unit command {Button: Attack}.
You can do this by pressing its {Input: button} or using its {Input: hotkey}, and then {Input: clicking} your target.
You can also {Input: right-click} your target.
{Yellow Font: Select all of your units}, and attack the Grunt to the north!

### Progression and scene actions

- Checkpoint: `combat`.
- Advance with Continue.
- Scene action: **spawn Attack Grunt** (`spawnAttackGrunt`).
- Group start: `54`.

Scene / restoration details:

```json
{
  "afterContinue": "removeEnemies"
}
```

### Your edits / notes



## Step 55 — combat

### Narration

Just like with other commands, you can {Term: shift-queue} attack commands.

{Yellow Font: Select all of your units}, and order them to first attack the Headhunter, then the Grunt, and lastly the Peon.

### Progression and scene actions

- Checkpoint: `combat`.
- Advance with Continue.
- Scene action: **spawn Enemy Trio** (`spawnEnemyTrio`).
- Group start: `55`.

Scene / restoration details:

```json
{
  "afterContinue": "removeEnemies"
}
```

### Your edits / notes



## Step 56 — combat

### Narration

You may have noticed that your footmen were bunching up a bit, and running around each other to reach the target.
This is because the {Term: Attack} command, just like the {Term: Move} command leaves no room for alternatives.
Your units will do everything they can to get into attack range of that unit, and ignore anything else.

### Progression and scene actions

- Checkpoint: `combat`.
- Advance with Continue.
- Group start: `56`.

### Your edits / notes



## Step 57 — combat

### Narration

You may also have noticed that your Priests did not heal your Footmen, despite {Input: Heal} being on {Term: auto-cast}.
This is because a direct attack order supersedes auto-casting.

### Progression and scene actions

- Checkpoint: `combat`.
- Advance with Continue.
- Group start: `57`.

### Your edits / notes



## Step 58 — combat

### Narration

{Heading: THE ATTACK MOVE COMMAND}
The {Yellow Font: most important combat command} is the {Term: Attack Move}!
You perform this by {Input: clicking the Attack button}, or using its {Input: hotkey}, and then {Input: clicking on the ground}.
This makes the selected unit move to that location in aggressive stance, meaning it attacks every enemy it comes across.

### Progression and scene actions

- Checkpoint: `combat`.
- Advance with Continue.
- Scene action: **reset Units** (`resetUnits`).
- Group start: `58`.

### Your edits / notes



## Step 59 — combat

### Narration

There are several advantages to this.
For one, no time is wasted bunching up. Each unit will just find the closest enemy and attack.
For another, this kind of move does not supersede auto-cast.

### Progression and scene actions

- Checkpoint: `combat`.
- Advance with Continue.
- Group start: `59`.

### Your edits / notes



## Step 60 — combat

### Narration

Try attacking the enemy units to the north with an attack move by {Input: clicking it behind them}!

### Progression and scene actions

- Checkpoint: `combat`.
- Advance with Continue.
- Scene action: **spawn Combat Trio** (`spawnCombatTrio`).
- Group start: `60`.

Scene / restoration details:

```json
{
  "afterContinue": "removeEnemies"
}
```

### Your edits / notes



## Step 61 — combat

### Narration

After using an {Term: Attack Move}, you can then manually select units to reposition them or switch their targets.
This is called {Term: Micro}, from micro-management.

Try attacking the enemy units to the north with an attack move, but this time try to micro your units a bit!

### Progression and scene actions

- Checkpoint: `combat`.
- Advance with Continue.
- Scene action: **spawn Combat Trio** (`spawnCombatTrio`).
- Group start: `61`.

Scene / restoration details:

```json
{
  "afterContinue": "removeEnemies"
}
```

### Your edits / notes



## Step 62 — combat

### Narration

As a {Yellow Font: rule of thumb}, it is almost always better to {Yellow Font: move your units with an attack move} compared to a regular move!

### Progression and scene actions

- Checkpoint: `combat`.
- Advance with Continue.
- Scene action: **reset Units** (`resetUnits`).
- Group start: `62`.

### Your edits / notes



## Step 63 — combat

### Narration

The reason for this is that while given a {Term: Move} command, your units will ignore enemies completely.
This makes them vulnerable in two ways.

### Progression and scene actions

- Checkpoint: `combat`.
- Advance with Continue.
- Group start: `63`.

### Your edits / notes



## Step 64 — combat

### Narration

For one, they will receive damage without defending themselves.
For another, weaker units such as Priests and Riflemen will move out of position, making it easier for your enemy to attack them.

### Progression and scene actions

- Checkpoint: `combat`.
- Advance with Continue.
- Group start: `64`.

### Your edits / notes



## Step 65 — combat

### Narration

Another use for attack moves, is to have your units finish off an enemy, and then start moving somewhere else, without you having to give them another command.

### Progression and scene actions

- Checkpoint: `combat`.
- Advance with Continue.
- Group start: `65`.

### Your edits / notes



## Step 66 — combat

### Narration

Your units will win this fight easily.
Give an attack move command to the top right corner of the minimap!
Your units will finish fighting, and then start moving up there.

### Progression and scene actions

- Checkpoint: `combat`.
- Advance with Continue.
- Scene action: **spawn Final Headhunters Attack** (`spawnFinalHeadhuntersAttack`).
- Group start: `66`.

Scene / restoration details:

```json
{
  "afterContinue": "removeEnemies"
}
```

### Your edits / notes



## Step 67 — combat

### Narration

The only downside to the Attack move is that along the way, you may attack things you do not intend to.
This can be annoying, especially when you are not paying attention to your army at the time.
To get around this, you can use {Term: shift-queue} to avoid places where you know there are enemy units.

### Progression and scene actions

- Checkpoint: `combat`.
- Advance with Next.
- Group start: `67`.

### Your edits / notes



## Step 68 — combat

### Narration

{Heading: END OF TUTORIAL}
This concludes the unit control tutorial. Press the {Button: Menu} button to choose another tutorial!
Alternatively, press the {Button: Optional} button to learn about more niche mechanics you may not need in competitive play.

### Progression and scene actions

- Checkpoint: `combat`.
- Final step: return through Menu; no further narration step.
- Scene action: **highlight Menu** (`highlightMenu`).
- Group start: `68`.

### Your edits / notes



# Optional section: Patrol

Internal section: `patrol`.
At the end of this optional section, Next returns to the main tutorial.

## Optional step 1 — Patrol

### Narration

{Heading: BONUS: PATROLLING}
You can have units run back and forth between locations, by using the {Button: Patrol} command.

Try having some of your units patrol around!

### Progression and scene actions

- Checkpoint: `Patrol`.
- Advance with Continue.
- Scene action: **reset Units** (`resetUnits`).

### Your edits / notes



## Optional step 2 — Patrol

### Narration

While patrolling, the unit is in aggressive stance, meaning it works just like an {Term: Attack Move}.
Your unit will attack any hostile unit it comes in range of.

### Progression and scene actions

- Checkpoint: `Patrol`.
- Advance with Continue.

### Your edits / notes



## Optional step 3 — Patrol

### Narration

If you want to set up more complicated movement paths, you can use the {Term: Shift-Queue}.

### Progression and scene actions

- Checkpoint: `Patrol`.
- Advance with Continue.

### Your edits / notes



## Optional step 4 — Patrol

### Narration

{Heading: OPTIONAL TOPIC COMPLETE}
This optional topic is complete.
Press the {Button: Next} button to return to the tutorial section you previously left.

### Progression and scene actions

- Checkpoint: `Patrol`.
- Advance with Next.

### Your edits / notes



# Optional section: Formation

Internal section: `formation`.
At the end of this optional section, Next returns to the main tutorial.

## Optional step 1 — Formation

### Narration

{Heading: BONUS: FORMATION MOVEMENT OPTION}
There is an option that allows the use of {Term: Formation Movement} without having to toggle it on and off between commands.

### Progression and scene actions

- Checkpoint: `Formation`.
- Advance with Continue.
- Scene action: **reset Units** (`resetUnits`).

### Your edits / notes



## Optional step 2 — Formation

### Narration

Go to {Menu: Gameplay} -> {Menu: Interface}, and check the checkbox for {Menu: Enable Formation Movement Toggle}.

### Progression and scene actions

- Checkpoint: `Formation`.
- Advance with Continue.

### Your edits / notes



## Optional step 3 — Formation

### Narration

Now you can give a {Term: Formation Movement} command by {Input: holding Alt} and giving your units a {Term: Movement} command.

Try enabling this option and moving your army using it!

### Progression and scene actions

- Checkpoint: `Formation`.
- Advance with Continue.

### Your edits / notes



## Optional step 4 — Formation

### Narration

{Heading: OPTIONAL TOPIC COMPLETE}
This optional topic is complete.
Press the {Button: Next} button to return to the tutorial section you previously left.

### Progression and scene actions

- Checkpoint: `Formation`.
- Advance with Next.

### Your edits / notes
