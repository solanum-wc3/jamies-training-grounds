# Hotkey Setup — editable tutorial script

Snapshot of the current implementation, 13 October 2026.
Edit narration directly and add progression or scene changes under Your edits / notes.
Keep formatting tags such as `{Heading: ...}`, `{Input: ...}` and `{Button: ...}`.
Edits here do not automatically update the map; these are authoring work files.
Each numbered step is one narration stop. Blank lines in narration are intentional.

Implementation reference: `src/activities/hotkey-setup-tutorial.lua`.

## Shared progression

- Continue advances a narration stop; Next appears at section boundaries.
- Back and Topics return to checkpoints using the tutorial restoration procedures.
- Blue heading tags identify narration sub-sections.
- Camera movements use the shared fixed duration (1.5 seconds).

## Step 1 — welcome

### Narration

{Heading: WELCOME}
Welcome to the Hotkeys Tutorial!
This tutorial is going to be a bit different. We are not going to talk about game mechanics, but instead talk about how to best set up your {Term: hotkeys}.
Once you are done reading, press the {Button: Continue} or {Button: Next} button to move on!

### Progression and scene actions

- Checkpoint: `welcome`.
- Advance with Next.

### Your edits / notes



## Step 2 — why

### Narration

{Heading: WHY USE HOTKEYS?}
Should you use {Term: hotkeys}?
The answer is simple: Yes!
If you want to get good at the game, you basically have to.

### Progression and scene actions

- Checkpoint: `why`.
- Advance with Continue.

### Your edits / notes



## Step 3 — why

### Narration

Manually clicking every button for every ability or command slows you down significantly.
For every ability, you have to move the mouse cursor away from the action, to the command grid, click a button, and then move it back to the action.
It takes time away from giving unit commands or moving the camera, and it introduces a lot of room for error.

### Progression and scene actions

- Checkpoint: `why`.
- Advance with Continue.

### Your edits / notes



## Step 4 — why

### Narration

You are effectively playing with one hand tied behind your back - your keyboard hand - and you are doing everything with your mouse hand.

### Progression and scene actions

- Checkpoint: `why`.
- Advance with Continue.

### Your edits / notes



## Step 5 — why

### Narration

When using hotkeys, you distribute the load pretty evenly between your mouse hand and your keyboard hand.
The mouse hand aims, clicks, and adjusts the camera, while the keyboard hand chooses commands and navigates the interface.

### Progression and scene actions

- Checkpoint: `why`.
- Advance with Continue.

### Your edits / notes



## Step 6 — why

### Narration

One measurement of play is "actions per minute", or {Term: APM}.
You can even go to the game options and choose to have the game display them live while you play.
When playing without hotkeys, you limit your {Term: APM} to what you can do with one hand.

### Progression and scene actions

- Checkpoint: `why`.
- Advance with Next.

### Your edits / notes



## Step 7 — which

### Narration

{Heading: LEGACY HOTKEYS}
By default, Warcraft III uses {Term: Legacy} Hotkeys.
These are the ones the game came with back in 2002 and 2003.
They are oriented around the names of abilities, units and buildings, and spread all over the keyboard.

### Progression and scene actions

- Checkpoint: `which`.
- Advance with Continue.

### Your edits / notes



## Step 8 — which

### Narration

You can check out some of the units under your control.
Hover over their buttons in the command grid, to see their {Term: Tooltips}!
Usually one letter will be highlighted in yellow. This is the hotkey for that button.

### Progression and scene actions

- Checkpoint: `which`.
- Advance with Continue.
- Scene action: **command Arrow** (`commandArrow`).

### Your edits / notes



## Step 9 — which

### Narration

These days, nobody will seriously recommend playing with {Term: Legacy} Hotkeys.
This hotkey set requires a lot of acrobatics of your hand.
If you are not a pianist, you will struggle.

### Progression and scene actions

- Checkpoint: `which`.
- Advance with Continue.

### Your edits / notes



## Step 10 — which

### Narration

{Heading: GRID HOTKEYS}
Warcraft III Reforged introduced {Term: Grid} Hotkeys.
These compact all major hotkeys into the 4x3 cluster of QWER, ASDF and ZXCV (or YXCV).
This is the best option, if you want to have a simple solution.
There are better solutions, but they get complicated.
If you want to have it simple for now, it is recommended you simply go with {Term: Grid}.

### Progression and scene actions

- Checkpoint: `which`.
- Advance with Continue.

### Your edits / notes



## Step 11 — which

### Narration

You can change your hotkey setup to Grid by going to {Menu: Input} -> {Menu: Key Bindings} in the game options, and selecting Grid there.
This cannot be done while you are in a map, so {Term: Quicksave} your game with {Input: F6}, leave this map, and check it out!

### Progression and scene actions

- Checkpoint: `which`.
- Advance with Continue.

### Your edits / notes



## Step 12 — which

### Narration

{Heading: CUSTOM HOTKEYS}
From here on out, we are going into the better solutions.
This is where it gets complicated.
If you want to proceed using {Term: Grid}, you can jump to the next {Input: Topic}.

### Progression and scene actions

- Checkpoint: `which`.
- Advance with Continue.

### Your edits / notes



## Step 13 — which

### Narration

When setting your hotkeys to {Term: Grid}, you probably saw that there is a third option: {Term: Custom}.
This allows you to freely assign hotkeys as you see fit.
It also allows you to change the positions of buttons.

### Progression and scene actions

- Checkpoint: `which`.
- Advance with Continue.

### Your edits / notes



## Step 14 — which — HIDDEN / DISABLED

### Narration

This is of course complicated, especially for a newbie.
For this reason, you can use this map to help set you up. (Assuming you use Windows)

### Progression and scene actions

- Checkpoint: `which`.
- Advance with Continue.
- Skipped in the current build; retained here for editing.

### Your edits / notes



## Step 15 — which

### Narration

Again, to change the hotkey setup, you have to {Term: Quicksave} your game with {Input: F6}, leave this map, and go to the game options!

### Progression and scene actions

- Checkpoint: `which`.
- Advance with Continue.

### Your edits / notes



## Step 16 — which

### Narration

Changing custom tooltips also requires you to go to {Menu: \Users\YourUserName\Documents\Warcraft III}, and into the folder {Menu: CustomKeyBindings}.
There you will find a file called {Green Font: CustomKeys.txt}, which contains a list of key bindings.

### Progression and scene actions

- Checkpoint: `which`.
- Advance with Continue.

### Your edits / notes



## Step 17 — which — HIDDEN / DISABLED

### Narration

In the {Menu: Warcraft III} folder, there is also a folder called {Menu: CustomMapData}.
Press the {Input: Export} button! Three files will appear in that folder. One for a {Green Font: QWERTY}, one for a {Green Font: QWERTZ} keyboard layout, and one you do not need yet.
You can now rename the one that fits your layout to {Green Font: "CustomKeys.txt"}, and put it into the {Menu: CustomKeyBindings} folder.
It is recommended you first {Input: rename your old key bindings file}, so it does not get deleted. (Just add a number to the name.)

### Progression and scene actions

- Checkpoint: `which`.
- Advance with Continue.
- Skipped in the current build; retained here for editing.
- Scene action: **highlight Export** (`highlightExport`).

### Your edits / notes



## Step 18 — which — HIDDEN / DISABLED

### Narration

This sets you up with a pretty involved adjustment of the hotkeys.
Notably, the command grid buttons are moved so they fit the key arrangement on the keyboard.
This means that a button with the hotkey {Input: Q} will always be displayed on the top left spot, for example.

### Progression and scene actions

- Checkpoint: `which`.
- Advance with Continue.
- Skipped in the current build; retained here for editing.

### Your edits / notes



## Step 19 — which — HIDDEN / DISABLED

### Narration

It also changes around some of the positions of buttons.
For example, the layout of the build menus of workers, so they are more consistent across races.
Or the item arrangement in shops, so the items better fit the order in which they are unlocked and remain consistent across all shops.

### Progression and scene actions

- Checkpoint: `which`.
- Advance with Continue.
- Skipped in the current build; retained here for editing.

### Your edits / notes



## Step 20 — which — HIDDEN / DISABLED

### Narration

Of course you do not have to keep this hotkey setup.
It is included here as a demonstration of what can be done.

### Progression and scene actions

- Checkpoint: `which`.
- Advance with Continue.
- Skipped in the current build; retained here for editing.

### Your edits / notes



## Step 21 — which

### Narration

Tip: If you want to play the campaign "The Founding of Durotar", or the new campaign of The Forsaken Kingdom, it is recommended you change your hotkey layout to {Term: Grid} again while you do.
The different campaigns have a lot of special units with complicated ability combinations, and a {Term: Custom} setup can cause some confusion here.

### Progression and scene actions

- Checkpoint: `which`.
- Advance with Next.

### Your edits / notes



## Step 22 — resources

### Narration

{Heading: HOTKEY RESOURCES}
If you have looked into the hotkeys file, you will have seen that all the buttons only have a coded description.
Without knowing which code corresponds to which button, you cannot do anything here directly.

### Progression and scene actions

- Checkpoint: `resources`.
- Advance with Continue.

### Your edits / notes



## Step 23 — resources

### Narration

You have probably noticed that there is a part of the options menu called {Hotkeys}.
When setting up custom hotkeys, you can start by using this one.
However, it only allows you to change the keys, not the position of buttons.

### Progression and scene actions

- Checkpoint: `resources`.
- Advance with Continue.

### Your edits / notes



## Step 24 — resources

### Narration

People from the community have created their own interfaces to allow easy editing of all aspects of hotkeys.
One of the simplest can be found by using a search engine and typing in "{Input: warcraft 3 hotkey editor}".
The first result should lead you to a GitHub page belonging to a {Yellow Font: J.C.Fields}, where you can upload your hotkey file, edit it, and download the changed version.
This page allows you to change hotkey positions by simply dragging and dropping the buttons in the displayed command grid.

### Progression and scene actions

- Checkpoint: `resources`.
- Advance with Continue.

### Your edits / notes



## Step 25 — resources

### Narration

Another such resource is the more involved hotkey editor by {Yellow Font: clemenscodes}.
The main problem with setting up custom hotkeys is that abilities are shared between a lot of units, so making a position change can conflict down the line.
This one is very good at showing you where hotkeys or button positions conflict. Warcraft III can show this too, but not nearly as well.
However, this tool will automatically change the button tooltips, so it is only recommended if you don't mind this, or if you know how to change them back.

### Progression and scene actions

- Checkpoint: `resources`.
- Advance with Next.

### Your edits / notes



## Step 26 — inventory

### Narration

{Heading: CHANGING INVENTORY HOTKEYS}
By default, inventory spots are tied to the {Input: Numpad}.
These are far away from the other keys, and some keyboards do not have the buttons at all.
For this reason, many players rebind them.
This can be done in the Warcraft III options.

### Progression and scene actions

- Checkpoint: `inventory`.
- Advance with Continue.

### Your edits / notes



## Step 27 — inventory

### Narration

When using {Term: Grid} or {Term: Custom}, an obvious location to put them in is the 2x3 cluster of TY (or TZ), GH and BN.
However, many people, especially coming from the MOBA scene, prefer using a Modifier key (Alt, Shift, CTRL) and using the cluster of QW, AS and ZX (or YX).
The problem: Warcraft III does not support this.

### Progression and scene actions

- Checkpoint: `inventory`.
- Advance with Continue.

### Your edits / notes



## Step 28 — inventory

### Narration

The only way to do this is to use an extra program just to rebind a key combination onto the relevant {Input: Numpad} keyboard keys.
This little program has to run in the background while Warcraft III is running.

### Progression and scene actions

- Checkpoint: `inventory`.
- Advance with Continue.

### Your edits / notes



## Step 29 — inventory

### Narration

The simplest tool to use for this can be found by using a search engine and typing in "{Input: warcraft inventory hotkeys}".
The first result should be the tool by {Yellow Font: AucT}.
You can use it to customize your inventory buttons in any way you want.

### Progression and scene actions

- Checkpoint: `inventory`.
- Advance with Continue.

### Your edits / notes



## Step 30 — inventory

### Narration

However, be aware that this tool does not work properly if you have rebound the inventory hotkeys away from the {Input: Numpad} in the Warcraft options.
You have to reset them to default before using it.
The tool makes your operating system believe that {Input: Alt+Q} is really {Input: Num1} (for example). If Num1 is not the right key, nothing will happen.

### Progression and scene actions

- Checkpoint: `inventory`.
- Advance with Continue.

### Your edits / notes



## Step 31 — inventory

### Narration

Since you need to have the program running while the game is running, it is easiest to start them at the same time.
Even simpler, you can do this using the same shortcut on your Desktop. (assuming you are using Windows)
Pressing the {Button: Export} button earlier also exported a file called {Green Font: README_ShortcutSetup.txt}, which has instructions on how to do this.

### Progression and scene actions

- Checkpoint: `inventory`.
- Advance with Next.

### Your edits / notes



## Step 32 — inventory

### Narration

{Heading: END OF TUTORIAL}
This concludes the hotkeys tutorial. Press the {Button: Menu} button to choose another tutorial!

### Progression and scene actions

- Checkpoint: `inventory`.
- Final step: return through Menu; no further narration step.
- Scene action: **highlight Menu** (`highlightMenu`).

### Your edits / notes
