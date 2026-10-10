# Economy & Workers — script work file

Implementation note: These edits are incorporated into alpha27 as 58 narration stops. The numbered headings below retain your original review numbers; the setup and reconstruction tables below describe the earlier snapshot. Current behavior is documented in [ECONOMY-TUTORIAL-LAYOUT.md](ECONOMY-TUTORIAL-LAYOUT.md), with narration in `design/tutorials/economy-script.json`. Player practice prompts no longer issue automatic repair, build, Burrow, Unsummon or Sacrifice orders.

Current implementation snapshot: 10 October 2026. Edit this file section by section; edits here do not automatically change the map. Narration is copied verbatim, including formatting tags and existing wording. Trigger descriptions describe what the current map actually attempts, rather than proposed behavior.

## Shared setup and rules

- Create all initial buildings before mobile units, using the exported coordinates and orientations. There are 65 initial placements and 8 reserved later placements.
- Remove nearby neutral creeps from the tutorial scene temporarily; restore them on exit. Start with healthy trees and no researches enabled.
- Give each faction 10,000 Gold and Lumber. Start five gold workers per race, plus eight lumber Peasants, seven lumber Peons, eight lumber Wisps, and three lumber Ghouls. Harvest assignments were inferred from placement clusters: the original export contains positions and orientations, not orders.
- The active race belongs to the player, with full control and only that race's vision. The other bases remain separately owned and provide no shared sight. Preserve faction resource balances when switching races.
- Colors: Human Blue; Orc Red; Night Elf Teal; Undead Purple.
- All camera moves take 1.5 seconds. “Focus/select” below includes a camera move and unit selection. Timed callbacks run only while their narration stop is still active; advancing early cancels their effect.
- Every stop waits for a button press. There are currently no completion conditions that gate progress on fighting, construction, or other player actions.
- Continue advances one stop. At section boundaries the button reads Next. Back and Topics reconstruct the scene at the selected stop. Ordinary progression, narration clearing, and menu resume do not reconstruct the scene.
- On each stop, clear the previous narration arrow. Resource arrows blink 10 times and then remain until narration is cleared.
- The trigger-created Town Hall receives native militia conversion (Amic).

### Main buildings and mines

| Race | Main building coordinates | Gold mine coordinates |
|---|---|---|
| Human | Town Hall (-2368, -6400) | (-2944, -6912) |
| Orc | Great Hall (3648, -5120) | (4160, -5696) |
| Night Elf | Tree of Life (-4928, -3904) | Entangled Mine (-5248, -4352) |
| Undead | Necropolis (-6336, 1920) | Haunted Mine (-6528, 2432) |

The racial mines exist at tutorial start. Their underlying neutral mine foundations are hidden; they are not extra visible mines. The full placement list remains in `design/tutorials/economy-layout.json`.

### Engine event commands

- Construction start/finish and unit training finish: track the new structure or unit for ownership and cleanup.
- Construction finish: return the assigned builder and repairing assistants to their harvesting orders, if still present.
- Altar of Darkness construction start: return its Acolyte to Gold after 0.05 seconds.
- Shade training finish: track it and order patrol toward (0, 0).
- Enemy wolf summon during stop 23: track it, set half health, and order an attack against a Wisp. During that encounter, retarget surviving Wisps as needed.

## Narration and trigger commands

Formatting tags are editable player-facing markup. Blank lines inside each narration block are preserved.

### 01 — Welcome

**Narration**

```text
{Heading: WELCOME}
Welcome to the Economy Tutorial!
This time we are taking a look at the different resources you have to manage when playing Warcraft III.

Once you are done reading a section and playing around with whichever mechanic you learn, press the {Button: Continue} or {Button: Next} button to move on!
```

**Trigger commands on entry**

Activate Human ownership and vision. Move the camera to the Town Hall. Point the welcome arrow upward at the progression button; blink 10 times, then keep it visible until narration is cleared.

**Progression:** Next. No automatic completion check.

**Your changes / notes:**
Problem: Lumber Peasants have no collision.

### 02 — Workers

**Narration**

```text
{Heading: WORKERS}
The backbone of your economy are your worker units.
Every race has their own workers, which all function a little differently.

All of them construct {Term: Buildings} and harvest {Term: Gold}, and almost of them also harvest {Term: Lumber} - The two main resources of Warcraft III.
They are also all produced at the race's main building.
```

**Trigger commands on entry**

No additional scene command. Existing harvesting, construction, combat, ownership, and resource state continue.

**Progression:** Next. No automatic completion check.

**Your changes / notes:**


### 03 — Peasants

**Narration**

```text
{Heading: PEASANTS}
These are {Term: Peasants}. They are the Human worker unit.
Peasants can gather {Term: Gold} by running back and forth between a {Term: Gold Mine} and the Human player's {Term: Main Building}.

A mine can be manned by up to five Peasants, and each peasant gathers 10 Gold every five seconds.
So a full gold mine can bring in {Green Font: 10 Gold per second, or 600 Gold per minute}. No more.
```

**Trigger commands on entry**

Focus/select a gold-harvesting Peasant. Point the blinking resource arrow at Gold.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**
Break up progression between the first two lines and the last two lines. I have divided them by an extra line. This should require a Continue button click.

### 04 — Peasants

**Narration**

```text
This is true for all races.
It also means that the only way to raise your gold mining capacity, is finding new gold mines and building {Term: Expansions} there.
Expansions are smaller bases you create during play. They will be covered in later tutorials.
```

**Trigger commands on entry**

No additional scene command. Existing harvesting, construction, combat, ownership, and resource state continue.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 05 — Peasants

**Narration**

```text
Peasants can also gather {Term: Lumber} by hacking at trees and carrying the lumber back to the Human player's {Term: Main Building} or their {Term: Lumber Mill}.
They require 11 seconds to gather 10 Lumber, which they then need to carry back.
Since trees only hold 50 Lumber until they are felled, these trips can vary a lot in length, so a precise rate is not as easy to calculate.

As a rule of thumb however, a Human player will eventually want to have {Green Font: 8 Peasants gathering Lumber} in their main base.
Humans can research {Term: Lumber Harvesting}, which raises the Lumber carrying capacity of Peasants to 20 and later 30, cutting down on walking time.
```

**Trigger commands on entry**

Focus/select a lumber-harvesting Peasant. Point the blinking resource arrow at Lumber.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**
Break up progression between the first three lines and the last two lines. I have divided them by an extra line. This should require a Continue button click.


### 06 — Peasants

**Narration**

```text
Worker units are very vulnerable.
Peasants especially, since they are out in the open when gathering and building.


To protect themselves and their base, Peasants can be drafted into the {Term: Militia}.
This happens through a {Term: Call to Arms}, either individually, or at the main building. It lasts 42.5 seconds.

While part of the Militia, they are almost as strong as a Human's basic worker unit, the {Term: Footman}, and gain a lot of movement speed.
```

**Trigger commands on entry**

No additional scene command. Existing harvesting, construction, combat, ownership, and resource state continue.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**
Break up progression between the first two lines and the last three lines. I have divided them by an extra line. This should require a Continue button click.
The last line should have an extra line break above it, but should be displayed with the two before it.

### 07 — Peasants

**Narration**

```text
Your base is being attacked.
Select your Town Hall and use the {Term: Call fo Arms} command to form the {Term: Militia}!
```

**Trigger commands on entry**

Spawn two enemy Ghouls at (-2368, -5900) and (-2272, -5900), facing 270 degrees. Give each a direct attack order against the first gold-harvesting Peasant. The player can call Militia and fight. Progression does not wait for either Ghoul to die.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**
The Ghouls should belong to the (purple) Undead Neutral faction.
On Progression, the Ghouls should die automatically.

### 08 — Peasants

**Narration**

```text
You can dissolve the {Term: Militia} through the {Term: Back to Work} command.

Since a {Term: Call to Arms} at the main building calls every Peasant in the entire base, this will completely stop your resource production.

For this reason, it is recommended to only ever call Peasants into the Militia by selecting them and giving them the {Term: Call to Arms} command individually.
```

**Trigger commands on entry**

Kill the attackers. Resume harvesting for workers not assigned to construction. Repeat the harvesting pass after 0.25 seconds.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 09 — Peasants

**Narration**

```text
All worker units can {Term: Repair} buildings and mechanical units.
Repairing damage takes 1.5 times as long as it takes to build that much of the building.
It also costs 35% of the Gold and Lumber it cost to build that part of the building.
```

**Trigger commands on entry**

Set the Town Hall to 80% health. 

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**
Add in an extra narration set after this with the following text:
"Your Town Hall is damaged.
Select some of your Peasants and have them repair it by {Input: right-clicking it}!"
Progression should be handled regularly.

### 10 — Peasants

**Narration**

```text
Peasants have another unique feature.
They can help each other in constructing buildings, speeding up the build time for some extra Gold and Lumber.
This is called {Term: Power Building}.

You can see a demonstration of this in {Menu: Tools & Extras}.
```

**Trigger commands on entry**


**Progression:** Next. No automatic completion check.

**Your changes / notes:**
Insert an extra narration set:
"Select a Peasant and tell it to {Input: Build} an {Term: Altar of Kings}!
Then select a few other Peasants (preferrably from those gathering Lumber) and {Input: right-click} the construction site!
They will help with the construction.

If you want to make sure they continue to what they were doing after they are done, you can {Input: shift-queue} them back onto their gathering duty."

Make this narration an extra narration set:
"Canceling a construction costs you 25% of its build cost.
Having the build site destroyed loses the entire build cost."

### 11 — Peons

**Narration**

```text
{Heading: PEONS}
These are {Term: Peons}. They are Orc worker units.
They behave almost the same as Peasants when it comes to Gold and Lumber.
```

**Trigger commands on entry**

Activate Orc ownership and vision. Focus the Great Hall, then focus/select a lumber Peon.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 12 — Peons

**Narration**

```text
The main difference is that an Orc player cannot raise the Lumber carrying capacity of their Peons.
An Orc player will eventually want to have {Green Font: 7 Peons harvesting Lumber} in their base.
```

**Trigger commands on entry**

No additional scene command. Existing harvesting, construction, combat, ownership, and resource state continue.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**
Problem: Gold Peons are not harvesting. Lumber Peons start inside the forest. Workers should probably start at their respective main building when the exercise loads, and be commanded to their duty.

### 13 — Peons

**Narration**

```text
While Peons are building, they vanish into the building site, making them invulnerable.
That is - until the building site is destroyed.
```

**Trigger commands on entry**


**Progression:** Continue. No automatic completion check.

**Your changes / notes:**
Insert a narration set after this one:
"Select a Peon (preferrably from the ones gathering lumber), and command it to {Term: Build} an {Term: Altar of Storms}.

### 14 — Peons

**Narration**

```text
While Peons have a bit more {Term: HP} than other workers, they still die easily.
Their means of protecting themselves is assuming {Term: Battle Stations} in a nearby {Term: Orc Burrow} and throwing spears at the attacker.
Similar to Militia, calling all your Peons into the Burrows will stop your resource production, so you will want to only use as few as are needed.
```

**Trigger commands on entry**

Focus/select the Orc Burrow. 

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**
Insert a Narration set after this:
"Select a Peon and {Input: right-click} the Orc Burrow.
The Peon will enter it.
You can call it back by {Input: selecting the Burrow and clicking its icon}." 

### 15 — Peons

**Narration**

```text
Your base is being attacked.
Call a few Peons to {Term: Battle Stations}!

You can do this by selecting the Burrows and giving the {Term: Battle Stations} command.```

**Trigger commands on entry**

Spawn three enemy Ghouls at (3648, -4620), (3744, -4620), and (3840, -4620), facing 270 degrees. Give each a direct attack order against the first gold-harvesting Peon. Progression is manual.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 16 — Peons

**Narration**

```text
Once you are done having them defend your base, you can have them return to work with the {Term: Stand Down} command.
```
Similar to {Term: Militia}, it is better to assign Peons to {Term: Battle Stations} individually, to disrupt your own economy as little as possible.

**Trigger commands on entry**

Remove the attackers. The player can use Stand Down; this stop does not automatically resume harvesting.

**Progression:** Next. No automatic completion check.

**Your changes / notes:**


### 17 — Wisps

**Narration**

```text
{Heading: WISPS}
Night Elf workers are called {Term: Wisps}.
They behave very differently compared to Peasants and Peons.
```

**Trigger commands on entry**

Restore workers and kill any attackers as at stop 8. Activate Night Elf ownership and vision. Focus/select a lumber Wisp.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 18 — Wisps

**Narration**

```text
The Night Elf main building entangles the nearby gold mine.
Wisps gather Gold in this {Term: Entangled Gold Mine}.
They do not have to walk back and forth, and while inside, are completely safe from harm.
```

**Trigger commands on entry**

Focus/select the Tree of Life. After 5 seconds, focus/select the existing Entangled Gold Mine. No new mine is created here.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 19 — Wisps

**Narration**

```text
Wisps gather Lumber at a rate of 5 per 7.5 seconds, and they do not destroy the trees when doing so.
Because of the lower gathering rate, a Night Elf player will want to have {Green Font: around 8 Wisps gathering Lumber}.
This may fluctuate up and down a bit during the game.
```

**Trigger commands on entry**

Focus/select a lumber Wisp.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 20 — Wisps

**Narration**

```text
Like Peons, Wisps disappear into the building when they are {Term: Constructing}.
Additionally, when they finish building one of the living trees that make up many of the Night Elf buildings, they do not come out at all.
```

**Trigger commands on entry**

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**
Add in a narration pass after this:
"Select a Wisp and {Input: Build an Altar of Elders}!
Then select another and {Input: Build an Ancient of Wonders}!

The first Wisp will return from the construction site.
The second will not, and will have to be replaced."

### 21 — Wisps

**Narration**

```text
Aside from the ones in the {Term: Entangled Gold Mine}, Wisps are among the most vulnerable worker units.
Except for fleeing into the gold mine or into a construction site, Wisps have no great ways of dealing with attacks.

Their only option is often run or to simply {Term: Detonate}.
```

**Trigger commands on entry**

No additional scene command. Existing harvesting, construction, combat, ownership, and resource state continue.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 22 — Wisps

**Narration**

```text
{Term: Detonate} burns 40 mana from enemy units, and deals 225 damage to enemy summons.
This also denies the enemy the {Term: XP} they would otherwise get for killing the Wisp.
```

**Trigger commands on entry**

No additional scene command. Existing harvesting, construction, combat, ownership, and resource state continue.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 23 — Wisps

**Narration**

```text
Your Wisps are being harassed by magically summoned units.
{Term: Detonate} a Wisp to protect the others!
```

**Trigger commands on entry**

Spawn an enemy Far Seer at (-3400, -2400), facing 225 degrees. Learn Feral Spirit (AOsf), then immediately order spiritwolf. Newly summoned wolves start at half health and receive direct attack orders against a lumber Wisp; retarget a surviving lumber Wisp when needed. After 1 second, order the Far Seer to move toward the tavern at (0, 0). The player detonates manually; progression does not check for a successful Detonate.

**Progression:** Next. No automatic completion check.

**Your changes / notes:**


### 24 — Acolytes

**Narration**

```text
{Heading: ACOLYTES}
Undead workers are called {Term: Acolytes}.
They function in a very unique way compared to other worker units..
```

**Trigger commands on entry**

Restore workers and remove attackers. Activate Undead ownership and vision. Focus/select a gold-harvesting Acolyte.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 25 — Acolytes

**Narration**

```text
Acolytes gather {Term: Gold} in the {Term: Haunted Gold Mine}.
This is a separate building that has nothing to do with the Undead main building.

Different from any other worker, Acolytes stand in the open while gathering gold, completely vulnerable.
```

**Trigger commands on entry**

Focus/select the existing Haunted Gold Mine. No new mine is created here.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 26 — Acolytes

**Narration**

```text
Acolytes are also the only worker unit that does not gather {Term: Lumber} at all.
Instead this is done by the basic Undead military unit, the {Term: Ghoul}.

Ghouls can harvest 20 {Term: Lumber} in 13.5 seconds, and an Undead player will want to have {Green Font: 3 Ghouls harvesting Lumber}.
Their gather rate can be slightly improved by the {Term: Ghoul Frenzy} research, which raises their movement speed.
```

**Trigger commands on entry**

Focus/select a lumber-harvesting Ghoul.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 27 — Acolytes

**Narration**

```text
Acolytes have no way of defending themselves.
Ghouls take care of this, as well as the Undead buildings' superb defensive capabilities.

When {Term: Summoning} buildings, an Acolyte needs only to be present once to initiate the summoning.
This way, an Undead base only ever needs the five Acolytes in the Gold Mine.
```

**Trigger commands on entry**

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**
Make the first two and the last two lines two separate narration sets.

Then add this as a separate narration set:
"Select an Acolyte and command it to {Input: Build an Altar of Darkness}!
Then immediately order it to {Input: Move} back into the Goldmine.

### 28 — Acolytes

**Narration**

```text
Undead are the only race that can deconstruct their own buildings.
This is done through the Acolyte's {Term: Unsummon Building} command.
It nets the Undead player 50% of the building's original resource cost.

{Input: Select an Acolyte and unsummon your Crypt}!
```

**Trigger commands on entry**


**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 29 — Acolytes

**Narration**

```text
Another unique feature of Acolytes is that they can be sacrificed at a {Term: Sacrificial Pit}, turning them into a {Term: Shade}.
A Shade is an invisible scout unit that reveals other invisible units.

Select an Acolyte and {Input: right-click the Sacrificial Pit}!

Since the sacrifice can be cancelled, this is a way to safely hide an Acolyte for a few seconds.
```

**Trigger commands on entry**


**Progression:** Next. No automatic completion check.

**Your changes / notes:**


### 30 — Food

**Narration**

```text
{Heading: FOOD PRODUCTION}
Aside from {Term: Gold} and {Term: Lumber}, which can be gathered directly, there is a third Resource in Warcraft III, called {Term: Food}.
Food is produced by building specific buildings.
```

**Trigger commands on entry**

Focus/select the active main building. Point the blinking resource arrow at Food.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 31 — Food

**Narration**

```text
At first, this is the {Term: Main Building}.
Since the player always starts with this, it provides their starting {Term: Food Production}.
The amount of Food a Main Building produces is different by race.
```

**Trigger commands on entry**

No additional scene command. Existing harvesting, construction, combat, ownership, and resource state continue.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 32 — Food

**Narration**

```text
For Night Elves and the Undead, their Main Buildings, the {Term: Tree of Life} and the {Term: Necropolis}, produce 10 Food.
```

**Trigger commands on entry**

Activate Night Elf ownership and vision; focus/select the Tree of Life. After 5 seconds, activate Undead ownership and vision; focus/select the Necropolis.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 33 — Food

**Narration**

```text
For Orcs, their Main Building, the {Term: Great Hall}, produces 11 Food.
```

**Trigger commands on entry**

Activate Orc ownership and vision; focus/select the Great Hall.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 34 — Food

**Narration**

```text
The Main Building of the Humans produces different amounts of Food depending on its tier.
The {Term: Town Hall} produces 12, the {Term: Keep} produces 14, and the {Term: Castle} produces 16.
```

**Trigger commands on entry**

Activate Human ownership and vision; focus/select the Town Hall. Instantly create the demonstration Keep at (-1856, -6400) and Castle at (-1344, -6400), if absent. After 5 seconds, focus/select the Keep. After 10 seconds, focus/select the Castle.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 35 — Food

**Narration**

```text
Aside from their main building, each race has a Food building.
For Humans it is {Term: Farms}, for Orcs it is {Term: Orc Burrows}, for Night Elves it is {Term: Moon Wells}, and for Undead it is {Term: Ziggurats}.

Each of these produce 10 Food.
```

**Trigger commands on entry**

Remove the demonstration Keep and Castle. Activate Human ownership/vision and focus/select a Farm. After 5 seconds, switch to Orc and focus/select a Burrow; after 10 seconds, switch to Night Elf and focus/select a Moon Well; after 15 seconds, switch to Undead and focus/select a Ziggurat.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 36 — Food

**Narration**

```text
Now, the question is: {Gold Font: What does Food do?}

The answer: Nothing by itself.
Instead, {Gold Font: it limits how many units you can have} - the size of your army.
```

**Trigger commands on entry**

No additional scene command. Existing harvesting, construction, combat, ownership, and resource state continue.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 38 — Food

**Narration**

```text
Workers require 1 Food, other small units require 2 or 3.
Heroes require 5, and larger units require up to 7.
All of these add up, and the total {Gold Font: cannot exceed your food production}.
```

**Trigger commands on entry**

No additional scene command. Existing harvesting, construction, combat, ownership, and resource state continue.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 39 — Food

**Narration**

```text
When you are consuming as much food as you produce, you cannot produce more units.
This means you have {Term: Supply Blocked} yourself.

To be able to build new units, you now have to build more food production buildings.
This takes time, and slows down your game, so it is better to {Gold Font: plan ahead!}
```

**Trigger commands on entry**

Activate Undead ownership and vision. Focus/select the Necropolis. Set player Food Used equal to Food Cap, then issue an Acolyte training order to demonstrate the native supply-block notification. This changes the food counter; it does not spawn an army.

**Progression:** Next. No automatic completion check.

**Your changes / notes:**


### 40 — Upkeep

**Narration**

```text
{Heading: UPKEEP}
Food governs the last mechanic relevant to Warcraft III's economy: {Term: Upkeep}.
This mechanic limits your army size, not by not allowing you to build units, but by making you pay extra for having them.
```

**Trigger commands on entry**

Focus/select the active main building. Point the blinking resource arrow at Upkeep.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 41 — Upkeep

**Narration**

```text
This is done through a {Gold Font: tax on all Gold income}.
Once your {Term: Food Consumption}, not production, goes past 50, you hear a notification sound, and see {Yellow Font: Low Upkeep} pop up on your screen.
```

**Trigger commands on entry**

Set player Food Used to 51 to demonstrate Low Upkeep. This is a scripted counter change, not an army spawn.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 42 — Upkeep

**Narration**

```text
While you consume this much food, {Gold Font: you pay a 30% tax}.
This means each of your workers only produce 7 {Term: Gold} every 5 seconds.

It also affects Gold you get for selling items, killing neutral enemies, and so on.
Basically it affects all ways you can receive Gold in the game. (Lumber is not affected.)
```

**Trigger commands on entry**

Focus/select the active main building. The scripted Food Used value remains 51.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 43 — Upkeep

**Narration**

```text
Once you fall back under 51 {Term: Food Consumption}, you no longer have to pay {Term: Upkeep}.
Your hear the notification sound again, and {Green Font: No Upkeep} pops up on your screen.
```

**Trigger commands on entry**

Set player Food Used to 50 to demonstrate No Upkeep.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 44 — Upkeep

**Narration**

```text
Once your {Term: Food Consumption} goes past 80, you go to {Red Font: High Upkeep}.
You now {Gold Font: pay a 60% tax}.
```

**Trigger commands on entry**

Set player Food Used to 81 to demonstrate High Upkeep. Focus/select the active main building.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 45 — Upkeep

**Narration**

```text
This mechanic makes it so {Yellow Font: you do not want to just grow your army as quickly as you can}.

Growing it to 50 Food Consumption is great, and you should do it quickly, to be as strong as possible as soon as you can.
But both {Yellow Font: crossing the threshold to 51 and to 81 are serious decisions} you should only make with a goal in mind.
```

**Trigger commands on entry**

No additional scene command. Existing harvesting, construction, combat, ownership, and resource state continue.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**


### 46 — Upkeep

**Narration**

```text
For example, you can raise your army size past 50 in anticipation for a battle.
Since you will lose some units, it will likely drop you back to below 51.

And of course it makes sense to cross the threshold into Low or High Upkeep to attain the advantage to end the game.

```

**Trigger commands on entry**

No additional scene command. Existing harvesting, construction, combat, ownership, and resource state continue.

**Progression:** Continue. No automatic completion check.

**Your changes / notes:**



### 48 — Upkeep

**Narration**

```text
{Yellow Font: What you do not ever want to do is go to 51 Food Consumption and stay there for no reason.}

That is just wasting money.
Especially because your Gold Mines still lose 10 Gold, and will run empty eventually.
```

**Trigger commands on entry**

No additional scene command. Existing harvesting, construction, combat, ownership, and resource state continue.

**Progression:** Next. No automatic completion check.

**Your changes / notes:**


### 49 — Outro

**Narration**

```text
{Heading: END OF TUTORIAL}
This concludes the economy tutorial. Press the {Button: Menu} button to choose another tutorial!
```

**Trigger commands on entry**

Highlight the Menu button. Disable further progression; the player leaves through Menu.

**Progression:** Menu (end of tutorial). No automatic completion check.

**Your changes / notes:**


## Back / Topics reconstruction

Re-entering a stop through Back or Topics starts a fresh scene and reconstructs earlier demonstrations:

| Selected stop | Reconstructed state before its entry commands |
|---|---|
| After 10 | Finished Altar of Kings |
| After 13 | Finished Watch Tower |
| After 20 | Finished Ancient of Wonders; one lumber Wisp removed |
| After 27 | Finished Altar of Darkness |
| After 28 | Crypt removed |
| After 29 | One gold Acolyte removed; Shade created at (-5728, 1920), patrolling toward (0, 0) |
| 42–43 | Food Used initially 51; stop 43 then sets it to 50 |
| 45 onward | Food Used 81 |

Default active race before entry commands: Human at 1–10; Orc at 11–16; Night Elf at 17–23; Undead at 24–32; Orc at 33; Human at 34; Undead from 35 onward. Stop-specific commands and timed race switches then apply.

Topics jump to: Welcome 1, Workers 2, Peasants 3, Peons 11, Wisps 17, Acolytes 24, Food 30, Upkeep 40. The Outro is part of Upkeep and has no separate Topics entry.

## Exit / cleanup commands

Remove tutorial units, construction sites, trained units, summons, attackers, timers, event triggers, arrows, and tutorial interface. Restore borrowed world units, hidden creeps, mine foundations, tree state, player state, and camera state. Clear tutorial blight after tutorial structures are removed.

## Existing wording to review separately

These phrases are preserved above and have not been corrected without your approval:

- Stop 2: “almost of them”.
- Stop 6: “basic worker unit, the Footman”.
- Stop 8: “only every call individual Peasants”.
- Stop 24: “other worker units..”.
- Stop 43: “Your hear the notification sound”.

## Source references

- Narration: `design/tutorials/economy-script.json`.
- Entry commands and checkpoint reconstruction: `src/activities/economy-tutorial.lua`.
- Scene and harvesting setup: `src/infrastructure/economy-layout.lua`.
- Placements: `design/tutorials/economy-layout.json`.
- Shared tutorial procedures: `src/infrastructure/tutorial.lua` and `docs/TUTORIAL-STANDARD.md`.
