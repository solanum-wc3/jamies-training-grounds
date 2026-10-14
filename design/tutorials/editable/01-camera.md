# Camera — editable tutorial script

Snapshot of the current implementation, 13 October 2026.
Edit narration directly and add progression or scene changes under Your edits / notes.
Keep formatting tags such as `{Heading: ...}`, `{Input: ...}` and `{Button: ...}`.
Edits here do not automatically update the map; these are authoring work files.
Each numbered step is one narration stop. Blank lines in narration are intentional.

Implementation reference: `src/activities/camera-tutorial.lua`.

## Shared progression

- Continue advances a narration stop; Next appears at section boundaries.
- Back and Topics return to checkpoints using the tutorial restoration procedures.
- Blue heading tags identify narration sub-sections.
- Camera movements use the shared fixed duration (1.5 seconds).

## Step 1 — welcome

### Narration

{Heading: WELCOME}
Welcome to the Camera Tutorial!
Let us first take a look at the basic camera controls of Warcraft III.

Once you are done reading and playing around with whatever mechanic you learn, press the {Button: Continue} or {Button: Next} button to move on!

### Progression and scene actions

- Checkpoint: `welcome`.
- Advance with Next.
- Group start: `1`.

### Your edits / notes



## Step 2 — movement

### Narration

{Heading: FREE CAMERA}
There are four ways to freely move the camera.

### Progression and scene actions

- Checkpoint: `movement`.
- Advance with Continue.
- Scene action: **main Base** (`mainBase`).
- Group start: `2`.

### Your edits / notes



## Step 3 — movement

### Narration

Firstly, you can use "edge pan" by {Input: moving the mouse} to the edges of the screen.
Edge pan is the most common way to move the camera. It is quick and intuitive.
The drawback is that your mouse cursor will have to leave the center of the screen, where the action happens. Moving it back may cost you some time.

Try using edge pan!

### Progression and scene actions

- Checkpoint: `movement`.
- Advance with Continue.
- Group start: `3`.

### Your edits / notes



## Step 4 — movement

### Narration

The second way to freely move the camera is to {Input: press and hold the Middle Mouse Button} and drag the screen.
This is slower, but it allows you to make small adjustments quickly, without having to move the cursor away from the action.

Try dragging the camera!

### Progression and scene actions

- Checkpoint: `movement`.
- Advance with Continue.
- Group start: `4`.

### Your edits / notes



## Step 5 — movement

### Narration

The third way to move the camera is using the minimap. It is displayed on the bottom left of the screen.
You can {Input: click on the map} to center the camera on that location, or {Input: click and drag across the map} to move it.

Try moving the camera using the minimap!

### Progression and scene actions

- Checkpoint: `movement`.
- Advance with Continue.
- Group start: `5`.

### Your edits / notes



## Step 6 — movement

### Narration

The last way to freely move the camera is using the keyboard. The default keys for this are the {Input: arrow keys}.
These are a bit out of the way for both your left and your right hand, but some people prefer moving the camera using their keyboard hand.

Try moving the camera using the arrow keys!

### Progression and scene actions

- Checkpoint: `movement`.
- Advance with Next.
- Group start: `6`.

### Your edits / notes



## Step 7 — zooming

### Narration

{Heading: ZOOMING}
The default camera distance is 1650 units. This can be changed in the settings.

Click the Quest button on the top left, or press {Input: F9}, for more details.

### Progression and scene actions

- Checkpoint: `zooming`.
- Advance with Continue.
- Scene action: **zoom Quest** (`zoomQuest`).
- Group start: `7`.

### Your edits / notes



## Step 8 — zooming

### Narration

You can change the camera distance while in-game. The default control for this is rolling the {Input: Mouse Wheel}.
[Progression: Wait for Continue]

A closer camera makes controlling units easier, while having the camera further back can help to keep a clear view of a situation.
It is best to set zoom to a default value that allows you to do both. You can always zoom in or out during play.

Feel free to set the default value to something that feels right for you!

### Progression and scene actions

- Checkpoint: `zooming`.
- Advance with Continue.
- Group start: `8`.

### Your edits / notes



## Step 9 — zooming

### Narration

After zooming in or out using the {Input: Mouse Wheel}, you can reset the current camera distance back to the default value you chose.
The default key to do this is {Input: F5}.

Change the camera zoom, and then reset it!

### Progression and scene actions

- Checkpoint: `zooming`.
- Advance with Next.
- Group start: `9`.

### Your edits / notes



## Step 10 — baseControl

### Narration

{Heading: BASE CAMERA}
Now let us take a look at the camera commands you can use for your bases and units.
In this tutorial, you are in control of three different bases.

### Progression and scene actions

- Checkpoint: `baseControl`.
- Advance with Continue.
- Scene action: **main Base** (`mainBase`).
- Group start: `10`.

### Your edits / notes



## Step 11 — baseControl

### Narration

Each of your bases has a main building at a different tier.
For Orcs, the tier 1 building is called a Great Hall.

### Progression and scene actions

- Checkpoint: `baseControl`.
- Advance with Continue.
- Scene action: **tertiary Base** (`tertiaryBase`).
- Group start: `11`.

### Your edits / notes



## Step 12 — baseControl

### Narration

The tier 2 building is called a Stronghold.

### Progression and scene actions

- Checkpoint: `baseControl`.
- Advance with Continue.
- Scene action: **secondary Base** (`secondaryBase`).
- Group start: `12`.

### Your edits / notes



## Step 13 — baseControl

### Narration

And the tier 3 building is called a Fortress.

### Progression and scene actions

- Checkpoint: `baseControl`.
- Advance with Continue.
- Scene action: **main Base** (`mainBase`).
- Group start: `13`.

### Your edits / notes



## Step 14 — baseControl

### Narration

{Heading: JUMP TO BASE}
You can return to your main buildings, and cycle between them.
The default key for this is {Input: Backspace}.

When doing this, the first main building the camera will jump to is the one with the highest tier. The next will be of the next highest tier.
If several have the same tier, the camera will jump to the oldest ones first.

Try cycling through your main buildings!

### Progression and scene actions

- Checkpoint: `baseControl`.
- Advance with Continue.
- Group start: `14`.

### Your edits / notes



## Step 15 — baseControl

### Narration

{Heading: NOTIFICATIONS}
Throughout the game, you will receive notifications, with associated audio callouts.
Each of the notifications has a location. You can jump to the most recent location, and then cycle through the 8 most recent ones.
The default key for this is {Input: Space}.
These notifications can be for finished units, buildings, or researches.

### Progression and scene actions

- Checkpoint: `baseControl`.
- Advance with Continue.
- Scene action: **notification Production** (`notificationProduction`).
- Group start: `15`.

### Your edits / notes



## Step 16 — baseControl

### Narration

You also get notified when you are being attacked off-screen.
Once you are being attacked, pressing {Input: Space} is the quickest way to get to the action.
This is easier than first checking on the minimap and manually clicking where the enemy units are shown to be.

Try cycling through your notifications!

### Progression and scene actions

- Checkpoint: `baseControl`.
- Advance with Continue.
- Scene action: **notification Attack** (`notificationAttack`).
- Group start: `16`.

### Your edits / notes



## Step 17 — baseControl

### Narration

{Heading: IDLE WORKERS}
You can automatically center the camera on idle worker units, and cycle through them.
The default key for this is {Input: Tilde}.
Its label varies on your keyboard layout. It is between the Tabulator and the Escape keys.

Try cycling through your workers!

### Progression and scene actions

- Checkpoint: `baseControl`.
- Advance with Continue.
- Group start: `17`.

### Your edits / notes



## Step 18 — baseControl

### Narration

If you want to be able to just select idle workers without automatically centering the camera on them, you can set it to require a {Input: double-tap}.
Click the Quest button on the top left, or press {Input: F9}, for more details.

### Progression and scene actions

- Checkpoint: `baseControl`.
- Advance with Next.
- Scene action: **idle Worker Quest** (`idleWorkerQuest`).
- Group start: `18`.

### Your edits / notes



## Step 19 — armyControl

### Narration

{Heading: ARMY CAMERA}
There are two main ways of navigating the camera to your army units.

### Progression and scene actions

- Checkpoint: `armyControl`.
- Advance with Continue.
- Scene action: **army Center** (`armyCenter`).
- Group start: `19`.

### Your edits / notes



## Step 20 — armyControl

### Narration

By pressing {Input: F1}, {Input: F2} or {Input: F3}, you can select your hero units.
{Input: Double-tapping} the key centers the camera on the hero.

### Progression and scene actions

- Checkpoint: `armyControl`.
- Advance with Continue.
- Group start: `20`.

### Your edits / notes

## Step 21 — armyControl

### Narration

Which hero is bound to which key depends on the order you trained them in the current game, with your first hero always being bound to {Input: F1} and so on.
Alternatively, you can {Input: click the hero icons} on the top left of the screen.
These keys cannot be changed in-game.

Try moving the camera to your heroes!

### Progression and scene actions

- Checkpoint: `armyControl`.
- Advance with Continue.
- Group start: `21`.

### Your edits / notes



## Step 22 — armyControl

### Narration

If you want to freely assign units or buildings to keys, you have to use {Term: Control Groups}.
{Input: Click} one of your units, {Input: hold CTRL}, and then {Input: press 1} on your keyboard!
{Input: (CTRL+1)}
This assigns them to Control Group 1.
You can create a control group for every number key.

### Progression and scene actions

- Checkpoint: `armyControl`.
- Advance with Continue.
- Group start: `22`.

### Your edits / notes



## Step 23 — armyControl

### Narration

Control groups can be used to control and divide your army according to type and function.
How to best use control groups will be covered in more detail in a later tutorial.

### Progression and scene actions

- Checkpoint: `armyControl`.
- Advance with Continue.
- Group start: `23`.

### Your edits / notes



## Step 24 — armyControl

### Narration

After forming it, {Input: pressing 1} will select the units of Control Group 1.
{Input: Double-tapping} the key moves the camera to the location of the group's units.

Try to assign and use different control groups!

### Progression and scene actions

- Checkpoint: `armyControl`.
- Advance with Continue.
- Group start: `24`.

### Your edits / notes



## Step 25 — armyControl

### Narration

Instead of locking the camera, you can also center it on the unit by {Input: clicking its portrait} at the bottom of the screen, or follow the unit by {Input: clicking and holding} the portrait.

Try using these commands!

### Progression and scene actions

- Checkpoint: `armyControl`.
- Advance with Next.
- Group start: `25`.

### Your edits / notes



## Step 26 — armyControl

### Narration

{Heading: END OF TUTORIAL}
This concludes the camera tutorial. Press the {Button: Menu} button to choose another tutorial.
There are also some mechanics that are a bit more niche, which you will probably not need for competitive play. If you are interested in those, press the {Button: Optional} button.

### Progression and scene actions

- Checkpoint: `armyControl`.
- Final step: return through Menu; no further narration step.
- Scene action: **highlight Menu And Optional** (`highlightMenuAndOptional`).
- Group start: `26`.

### Your edits / notes



# Optional section: Camera Rotation

Internal section: `rotation`.
At the end of this optional section, Next returns to the main tutorial.

## Optional step 1 — Camera Rotation

### Narration

{Heading: BONUS: CAMERA ROTATION}
You can rotate the camera by 90 degrees left or right.
By default, hold {Input: Insert} to rotate left or {Input: Delete} to rotate right.
Usually there is no reason to do this while playing, but you might get in a situation where clicking something is easier when the camera is rotated.

Try rotating the camera!

### Progression and scene actions

- Checkpoint: `Camera Rotation`.
- Advance with Next.

### Your edits / notes



# Optional section: Lock-On

Internal section: `lockOn`.
At the end of this optional section, Next returns to the main tutorial.

## Optional step 1 — Lock-On

### Narration

{Heading: BONUS: LOCK-ON}
These commands lock the camera to the unit you have currently selected.
The default command for this is {Input: holding CTRL} and {Input: pressing C}.
{Input: (CTRL+C)}

To unlock the camera again, use the same command.

### Progression and scene actions

- Checkpoint: `Lock-On`.
- Advance with Continue.

### Your edits / notes



## Optional step 2 — Lock-On

### Narration

When multiple units are selected, the camera locks onto the one that is displayed on the very left of the selection.

### Progression and scene actions

- Checkpoint: `Lock-On`.
- Advance with Next.

### Your edits / notes
