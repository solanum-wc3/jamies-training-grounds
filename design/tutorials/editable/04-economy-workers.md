# Economy & Workers — editable tutorial script

Snapshot of the current implementation, 13 October 2026.
Edit narration directly and add progression or scene changes under Your edits / notes.
Keep formatting tags such as `{Heading: ...}`, `{Input: ...}` and `{Button: ...}`.
Edits here do not automatically update the map; these are authoring work files.
Each numbered step is one narration stop. Blank lines in narration are intentional.

Implementation reference: `src/activities/economy-tutorial.lua`.

## Shared progression

- Continue advances a narration stop; Next appears at section boundaries.
- Back and Topics return to checkpoints using the tutorial restoration procedures.
- Blue heading tags identify narration sub-sections.
- Camera movements use the shared fixed duration (1.5 seconds).
- Active-race units belong to the player and remain controllable.
- Restore details below specify the state reconstructed when revisiting a step.

## Step 1 — welcome

### Narration

{Heading: WELCOME}
Welcome to the Economy Tutorial!
This time we are taking a look at the different resources you have to manage when playing Warcraft III.
You are also going to learn about the very different worker units of the four races.

Once you are done reading a section and playing around with whichever mechanic you learn, press the {Button: Continue} or {Button: Next} button to move on!

### Progression and scene actions

- Checkpoint: `welcome`.
- Advance with Next.
- Scene action: **welcome** (`welcome`).
- Id: `economy.welcome`.
- Source stop: `1`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 1,
    "buildings": [],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 2 — workers

### Narration

{Heading: WORKERS}
The backbone of your economy is your worker units.
Every race has its own workers, which all function a little differently.

All of them construct {Term: Buildings} and harvest {Term: Gold}, and almost all of them also harvest {Term: Lumber} - The two main resources of Warcraft III.
They are also all produced at the race's main building.

### Progression and scene actions

- Checkpoint: `workers`.
- Advance with Next.
- Scene action: **workers** (`workers`).
- Id: `economy.workers`.
- Source stop: `2`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 1,
    "buildings": [],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 3 — peasants

### Narration

{Heading: PEASANTS}
These are {Term: Peasants}. They are the Human worker unit.
Peasants can gather {Term: Gold} by running back and forth between a {Term: Gold Mine} and the Human player's {Term: Main Building}.

### Progression and scene actions

- Checkpoint: `peasants`.
- Advance with Continue.
- Scene action: **human gold** (`human-gold`).
- Id: `economy.human-gold`.
- Source stop: `3`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 1,
    "buildings": [],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 4 — peasants

### Narration

A mine can be manned by up to five Peasants, and each peasant gathers 10 Gold every five seconds.
So a full gold mine can bring in {Green Font: 10 Gold per second, or 600 Gold per minute}. No more.

### Progression and scene actions

- Checkpoint: `peasants`.
- Advance with Continue.
- Scene action: **text 3** (`text-3`).
- Id: `economy.text-3`.
- Source stop: `3`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 1,
    "buildings": [],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 5 — peasants

### Narration

This is true for all races.
It also means that the only way to raise your gold mining capacity is finding new gold mines and building {Term: Expansions} there.
Expansions are smaller bases you create during play. They will be covered in later tutorials.

### Progression and scene actions

- Checkpoint: `peasants`.
- Advance with Continue.
- Scene action: **this is true for all races** (`this-is-true-for-all-races`).
- Id: `economy.this-is-true-for-all-races`.
- Source stop: `4`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 1,
    "buildings": [],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 6 — peasants

### Narration

Peasants can also gather {Term: Lumber} by hacking at trees and carrying the lumber back to the Human player's {Term: Main Building} or their {Term: Lumber Mill}.
They require 11 seconds to gather 10 Lumber, which they then need to carry back.
Since trees only hold 50 Lumber until they are felled, these trips can vary a lot in length, so a precise rate is not as easy to calculate.

### Progression and scene actions

- Checkpoint: `peasants`.
- Advance with Continue.
- Scene action: **human lumber** (`human-lumber`).
- Id: `economy.human-lumber`.
- Source stop: `5`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 1,
    "buildings": [],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 7 — peasants

### Narration

As a rule of thumb, however, a Human player will eventually want to have {Green Font: 8 Peasants gathering Lumber} in their main base.
Humans can research {Term: Lumber Harvesting}, which raises the Lumber carrying capacity of Peasants to 20 and later 30, cutting down on walking time.

### Progression and scene actions

- Checkpoint: `peasants`.
- Advance with Continue.
- Scene action: **text 5** (`text-5`).
- Id: `economy.text-5`.
- Source stop: `5`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 1,
    "buildings": [],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 8 — peasants

### Narration

Worker units are very vulnerable.
Peasants especially, since they are out in the open when gathering and building.

### Progression and scene actions

- Checkpoint: `peasants`.
- Advance with Continue.
- Scene action: **worker units are very vulnerable** (`worker-units-are-very-vulnerable`).
- Id: `economy.worker-units-are-very-vulnerable`.
- Source stop: `6`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 1,
    "buildings": [],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 9 — peasants

### Narration

To protect themselves and their base, Peasants can be drafted into the {Term: Militia}.
This happens through a {Term: Call to Arms}, either individually, or at the main building. It lasts 42.5 seconds.

While part of the Militia, they are almost as strong as a Human's basic military unit, the {Term: Footman}, and gain a lot of movement speed.

### Progression and scene actions

- Checkpoint: `peasants`.
- Advance with Continue.
- Scene action: **text 6** (`text-6`).
- Id: `economy.text-6`.
- Source stop: `6`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 1,
    "buildings": [],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 10 — peasants

### Narration

Your base is being attacked.
Select your Town Hall and use the {Term: Call to Arms} command to form the {Term: Militia}!

### Progression and scene actions

- Checkpoint: `peasants`.
- Advance with Continue.
- Scene action: **human defense** (`human-defense`).
- Id: `economy.human-defense`.
- Source stop: `7`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 1,
    "buildings": [],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 11 — peasants

### Narration

You can dissolve the {Term: Militia} through the {Term: Back to Work} command.

Since a {Term: Call to Arms} at the main building calls every Peasant in the entire base, this will completely stop your resource production.

For this reason, it is recommended to only ever call Peasants into the Militia by selecting them and giving them the {Term: Call to Arms} command individually.
Usually it is preferable to use the peasants gathering lumber, since gold is generally more important.

### Progression and scene actions

- Checkpoint: `peasants`.
- Advance with Continue.
- Scene action: **human return to work** (`human-return-to-work`).
- Id: `economy.human-return-to-work`.
- Source stop: `8`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 1,
    "buildings": [],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 12 — peasants

### Narration

All worker units can {Term: Repair} buildings and mechanical units.
Repairing damage takes 1.5 times as long as it takes to build that much of the building.
It also costs 35% of the Gold and Lumber it cost to build that part of the building.

### Progression and scene actions

- Checkpoint: `peasants`.
- Advance with Continue.
- Scene action: **human damage hall** (`human-damage-hall`).
- Id: `economy.human-damage-hall`.
- Source stop: `9`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 1,
    "buildings": [],
    "removed": [],
    "shade": false,
    "hallHealth": 0.8
  }
}
```

### Your edits / notes



## Step 13 — peasants

### Narration

Your Town Hall is damaged.
Select some of your Peasants and have them repair it by {Input: right-clicking it}!

### Progression and scene actions

- Checkpoint: `peasants`.
- Advance with Continue.
- Scene action: **human repair** (`human-repair`).
- Id: `economy.human-repair`.
- Source stop: `9`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 1,
    "buildings": [],
    "removed": [],
    "shade": false,
    "hallHealth": 0.8
  }
}
```

### Your edits / notes



## Step 14 — peasants

### Narration

Peasants have another unique feature.
They can help each other in constructing buildings, speeding up the build time for some extra Gold and Lumber.
This is called {Term: Power Building}.

You can see a demonstration of this in {Menu: Tools & Extras}.

### Progression and scene actions

- Checkpoint: `peasants`.
- Advance with Continue.
- Scene action: **peasants have another unique feature** (`peasants-have-another-unique-feature`).
- Id: `economy.peasants-have-another-unique-feature`.
- Source stop: `10`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 1,
    "buildings": [],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 15 — peasants

### Narration

Select a Peasant and tell it to {Input: Build} an {Term: Altar of Kings}!
Then select a few other Peasants (preferably from those gathering Lumber) and {Input: right-click} the construction site!
They will help with the construction.

If you want to make sure they return to what they were doing after they are done, you can {Input: shift-queue} them back onto their gathering duty.

### Progression and scene actions

- Checkpoint: `peasants`.
- Advance with Continue.
- Scene action: **human build** (`human-build`).
- Id: `economy.human-build`.
- Source stop: `10`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 1,
    "buildings": [],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 16 — peasants

### Narration

Canceling a construction returns 75% of the build cost to you.
Having the build site destroyed loses the entire build cost.

### Progression and scene actions

- Checkpoint: `peasants`.
- Advance with Next.
- Scene action: **construction cost** (`construction-cost`).
- Id: `economy.construction-cost`.
- Source stop: `10`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 1,
    "buildings": [
      "halt"
    ],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 17 — peons

### Narration

{Heading: PEONS}
These are {Term: Peons}. They are Orc worker units.
They behave almost the same as Peasants when it comes to Gold and Lumber.

### Progression and scene actions

- Checkpoint: `peons`.
- Advance with Continue.
- Scene action: **orc workers** (`orc-workers`).
- Id: `economy.orc-workers`.
- Source stop: `11`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 2,
    "buildings": [
      "halt"
    ],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 18 — peons

### Narration

The main difference is that an Orc player cannot raise the Lumber carrying capacity of their Peons.
An Orc player will eventually want to have {Green Font: 7 Peons harvesting Lumber} in their base.

### Progression and scene actions

- Checkpoint: `peons`.
- Advance with Continue.
- Scene action: **the main difference is that an orc player cannot raise the lumber** (`the-main-difference-is-that-an-orc-player-cannot-raise-the-lumber`).
- Id: `economy.the-main-difference-is-that-an-orc-player-cannot-raise-the-lumber`.
- Source stop: `12`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 2,
    "buildings": [
      "halt"
    ],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 19 — peons

### Narration

While Peons are building, they vanish into the building site, making them invulnerable.
That is - until the building site is destroyed.

### Progression and scene actions

- Checkpoint: `peons`.
- Advance with Continue.
- Scene action: **while peons are building they vanish into the building site makin** (`while-peons-are-building-they-vanish-into-the-building-site-makin`).
- Id: `economy.while-peons-are-building-they-vanish-into-the-building-site-makin`.
- Source stop: `13`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 2,
    "buildings": [
      "halt"
    ],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 20 — peons

### Narration

Select a Peon (preferably from the ones gathering lumber), and command it to {Term: Build} an {Term: Altar of Storms}.

### Progression and scene actions

- Checkpoint: `peons`.
- Advance with Continue.
- Scene action: **orc build** (`orc-build`).
- Id: `economy.orc-build`.
- Source stop: `13`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 2,
    "buildings": [
      "halt"
    ],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 21 — peons

### Narration

While Peons have a bit more {Term: HP} than other workers, they still die easily.
Their means of protecting themselves is assuming {Term: Battle Stations} in a nearby {Term: Orc Burrow} and throwing spears at the attacker.
Similar to Militia, calling all your Peons into the Burrows will stop your resource production, so you will want to use only as many as are needed.

### Progression and scene actions

- Checkpoint: `peons`.
- Advance with Continue.
- Scene action: **orc select burrow** (`orc-select-burrow`).
- Id: `economy.orc-select-burrow`.
- Source stop: `14`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 2,
    "buildings": [
      "halt",
      "oalt"
    ],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 22 — peons

### Narration

Select a Peon and {Input: right-click} the Orc Burrow.
The Peon will enter it.
You can call it back by {Input: selecting the Burrow and clicking its icon}.

### Progression and scene actions

- Checkpoint: `peons`.
- Advance with Continue.
- Scene action: **orc burrow** (`orc-burrow`).
- Id: `economy.orc-burrow`.
- Source stop: `14`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 2,
    "buildings": [
      "halt",
      "oalt"
    ],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 23 — peons

### Narration

Your base is being attacked.
Call a few Peons to {Term: Battle Stations}!

You can do this by selecting the Burrows and giving the {Term: Battle Stations} command.

### Progression and scene actions

- Checkpoint: `peons`.
- Advance with Continue.
- Scene action: **orc defense** (`orc-defense`).
- Id: `economy.orc-defense`.
- Source stop: `15`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 2,
    "buildings": [
      "halt",
      "oalt"
    ],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 24 — peons

### Narration

Once you are done having them defend your base, you can have them return to work with the {Term: Stand Down} command.

Similar to {Term: Militia}, it is better to assign Peons to {Term: Battle Stations} individually, to disrupt your own economy as little as possible.

### Progression and scene actions

- Checkpoint: `peons`.
- Advance with Next.
- Scene action: **orc end defense** (`orc-end-defense`).
- Id: `economy.orc-end-defense`.
- Source stop: `16`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 2,
    "buildings": [
      "halt",
      "oalt"
    ],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 25 — wisps

### Narration

{Heading: WISPS}
Night Elf workers are called {Term: Wisps}.
They behave very differently compared to Peasants and Peons.

### Progression and scene actions

- Checkpoint: `wisps`.
- Advance with Continue.
- Scene action: **nightelf workers** (`nightelf-workers`).
- Id: `economy.nightelf-workers`.
- Source stop: `17`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 3,
    "buildings": [
      "halt",
      "oalt"
    ],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 26 — wisps

### Narration

The Night Elf main building entangles the nearby gold mine.
Wisps gather Gold in this {Term: Entangled Gold Mine}.
They do not have to walk back and forth, and while inside, are completely safe from harm.

### Progression and scene actions

- Checkpoint: `wisps`.
- Advance with Continue.
- Scene action: **nightelf mine tour** (`nightelf-mine-tour`).
- Id: `economy.nightelf-mine-tour`.
- Source stop: `18`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 3,
    "buildings": [
      "halt",
      "oalt"
    ],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 27 — wisps

### Narration

Wisps gather Lumber at a rate of 5 per 7.5 seconds, and they do not destroy the trees when doing so.
Because of the lower gathering rate, a Night Elf player will want to have {Green Font: around 8 Wisps gathering Lumber}.
This may fluctuate up and down a bit during the game.

### Progression and scene actions

- Checkpoint: `wisps`.
- Advance with Continue.
- Scene action: **nightelf lumber** (`nightelf-lumber`).
- Id: `economy.nightelf-lumber`.
- Source stop: `19`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 3,
    "buildings": [
      "halt",
      "oalt"
    ],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 28 — wisps

### Narration

Like Peons, Wisps disappear into the building when they are {Term: Constructing}.
Additionally, when they finish building one of the living trees that make up many of the Night Elf buildings, they do not come out at all.

### Progression and scene actions

- Checkpoint: `wisps`.
- Advance with Continue.
- Scene action: **like peons wisps disappear into the building when they are constr** (`like-peons-wisps-disappear-into-the-building-when-they-are-constr`).
- Id: `economy.like-peons-wisps-disappear-into-the-building-when-they-are-constr`.
- Source stop: `20`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 3,
    "buildings": [
      "halt",
      "oalt"
    ],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 29 — wisps

### Narration

Select a Wisp and {Input: Build an Altar of Elders}!
Then select another and {Input: Build an Ancient of Wonders}!

The first Wisp will return from the construction site.
The second will not, and will have to be replaced.

### Progression and scene actions

- Checkpoint: `wisps`.
- Advance with Continue.
- Scene action: **nightelf build** (`nightelf-build`).
- Id: `economy.nightelf-build`.
- Source stop: `20`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 3,
    "buildings": [
      "halt",
      "oalt"
    ],
    "removed": [],
    "shade": false
  }
}
```

### Your edits / notes



## Step 30 — wisps

### Narration

Aside from the ones in the {Term: Entangled Gold Mine}, Wisps are among the most vulnerable worker units.
Except for fleeing into the gold mine or into a construction site, Wisps have no great ways of dealing with attacks, even being unable to attack units themselves.

Their only option is often to run or simply {Term: Detonate}.

### Progression and scene actions

- Checkpoint: `wisps`.
- Advance with Continue.
- Scene action: **aside from the ones in the entangled gold mine wisps are among th** (`aside-from-the-ones-in-the-entangled-gold-mine-wisps-are-among-th`).
- Id: `economy.aside-from-the-ones-in-the-entangled-gold-mine-wisps-are-among-th`.
- Source stop: `21`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 3,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden"
    ],
    "removed": [
      "ewsp"
    ],
    "shade": false
  }
}
```

### Your edits / notes



## Step 31 — wisps

### Narration

{Term: Detonate} burns 40 mana from enemy units, and deals 225 damage to enemy summons.
This also denies the enemy the {Term: XP} they would otherwise get for killing the Wisp.

### Progression and scene actions

- Checkpoint: `wisps`.
- Advance with Continue.
- Scene action: **detonate burns 40 mana from enemy units and deals 225 damage to e** (`detonate-burns-40-mana-from-enemy-units-and-deals-225-damage-to-e`).
- Id: `economy.detonate-burns-40-mana-from-enemy-units-and-deals-225-damage-to-e`.
- Source stop: `22`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 3,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden"
    ],
    "removed": [
      "ewsp"
    ],
    "shade": false
  }
}
```

### Your edits / notes



## Step 32 — wisps

### Narration

Your Wisps are being harassed by magically summoned units.
{Term: Detonate} a Wisp to protect the others!

### Progression and scene actions

- Checkpoint: `wisps`.
- Advance with Next.
- Scene action: **nightelf defense** (`nightelf-defense`).
- Id: `economy.nightelf-defense`.
- Source stop: `23`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 3,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden"
    ],
    "removed": [
      "ewsp"
    ],
    "shade": false
  }
}
```

### Your edits / notes



## Step 33 — acolytes

### Narration

{Heading: ACOLYTES}
Undead workers are called {Term: Acolytes}.
They function in a very unique way compared to other worker units.

### Progression and scene actions

- Checkpoint: `acolytes`.
- Advance with Continue.
- Scene action: **undead workers** (`undead-workers`).
- Id: `economy.undead-workers`.
- Source stop: `24`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden"
    ],
    "removed": [
      "ewsp"
    ],
    "shade": false
  }
}
```

### Your edits / notes



## Step 34 — acolytes

### Narration

Acolytes gather {Term: Gold} in the {Term: Haunted Gold Mine}.
This is a separate building that has nothing to do with the Undead main building.

Different from any other worker, Acolytes stand in the open while gathering gold, completely vulnerable.

### Progression and scene actions

- Checkpoint: `acolytes`.
- Advance with Continue.
- Scene action: **undead mine** (`undead-mine`).
- Id: `economy.undead-mine`.
- Source stop: `25`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden"
    ],
    "removed": [
      "ewsp"
    ],
    "shade": false
  }
}
```

### Your edits / notes



## Step 35 — acolytes

### Narration

Acolytes are also the only worker unit that does not gather {Term: Lumber} at all.
Instead this is done by the basic Undead military unit, the {Term: Ghoul}.

Ghouls can harvest 20 {Term: Lumber} in 13.5 seconds, and an Undead player will want to have {Green Font: 3 Ghouls harvesting Lumber}.
Their gather rate can be slightly improved by the {Term: Ghoul Frenzy} research, which raises their movement speed.

### Progression and scene actions

- Checkpoint: `acolytes`.
- Advance with Continue.
- Scene action: **undead lumber** (`undead-lumber`).
- Id: `economy.undead-lumber`.
- Source stop: `26`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden"
    ],
    "removed": [
      "ewsp"
    ],
    "shade": false
  }
}
```

### Your edits / notes



## Step 36 — acolytes

### Narration

Acolytes stand in the open, with no way to defend themselves like Peasants or Peons, and no safe haven like the Entangled Gold Mine for Wisps.

While Acolytes deal slightly more damage than Peons or non-Militia Peasants, they are not great at defending themselves.
Ghouls take care of this, as well as the Undead buildings' superb defensive capabilities.

### Progression and scene actions

- Checkpoint: `acolytes`.
- Advance with Continue.
- Scene action: **acolytes have no way of defending themselves** (`acolytes-have-no-way-of-defending-themselves`).
- Id: `economy.acolytes-have-no-way-of-defending-themselves`.
- Source stop: `27`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden"
    ],
    "removed": [
      "ewsp"
    ],
    "shade": false
  }
}
```

### Your edits / notes



## Step 37 — acolytes

### Narration

When {Term: Summoning} buildings, an Acolyte needs only to be present once to initiate the summoning.
This way, an Undead base only ever needs the five Acolytes in the Gold Mine.

### Progression and scene actions

- Checkpoint: `acolytes`.
- Advance with Continue.
- Scene action: **text 27** (`text-27`).
- Id: `economy.text-27`.
- Source stop: `27`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden"
    ],
    "removed": [
      "ewsp"
    ],
    "shade": false
  }
}
```

### Your edits / notes



## Step 38 — acolytes

### Narration

Select an Acolyte and command it to {Input: Build an Altar of Darkness}!
Then immediately order it to {Input: Move} back into the Gold Mine.

### Progression and scene actions

- Checkpoint: `acolytes`.
- Advance with Continue.
- Scene action: **undead build** (`undead-build`).
- Id: `economy.undead-build`.
- Source stop: `27`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden"
    ],
    "removed": [
      "ewsp"
    ],
    "shade": false
  }
}
```

### Your edits / notes



## Step 39 — acolytes

### Narration

Undead are the only race that can deconstruct their own buildings.
This is done through the Acolyte's {Term: Unsummon Building} command.
It nets the Undead player 50% of the building's original resource cost.

{Input: Select an Acolyte and unsummon your Crypt}!

### Progression and scene actions

- Checkpoint: `acolytes`.
- Advance with Continue.
- Scene action: **undead unsummon** (`undead-unsummon`).
- Id: `economy.undead-unsummon`.
- Source stop: `28`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden",
      "uaod"
    ],
    "removed": [
      "ewsp"
    ],
    "shade": false
  }
}
```

### Your edits / notes



## Step 40 — acolytes

### Narration

Another unique feature of Acolytes is that they can be sacrificed at a {Term: Sacrificial Pit}, turning them into a {Term: Shade}.
A Shade is an invisible scout unit that reveals other invisible units.

Select an Acolyte and {Input: right-click the Sacrificial Pit}!

Since the sacrifice can be cancelled, this is a way to safely hide an Acolyte for a few seconds.

### Progression and scene actions

- Checkpoint: `acolytes`.
- Advance with Next.
- Scene action: **undead sacrifice** (`undead-sacrifice`).
- Id: `economy.undead-sacrifice`.
- Source stop: `29`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden",
      "uaod"
    ],
    "removed": [
      "ewsp",
      "usep"
    ],
    "shade": false
  }
}
```

### Your edits / notes



## Step 41 — food

### Narration

{Heading: FOOD PRODUCTION}
Aside from {Term: Gold} and {Term: Lumber}, which can be gathered directly, there is a third Resource in Warcraft III, called {Term: Food}.
Food is produced by building specific buildings.

### Progression and scene actions

- Checkpoint: `food`.
- Advance with Continue.
- Scene action: **food display** (`food-display`).
- Id: `economy.food-display`.
- Source stop: `30`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden",
      "uaod"
    ],
    "removed": [
      "ewsp",
      "usep",
      "uaco"
    ],
    "shade": true
  }
}
```

### Your edits / notes



## Step 42 — food

### Narration

At first, this is the {Term: Main Building}.
Since the player always starts with this, it provides their starting {Term: Food Production}.
The amount of Food a Main Building produces is different by race.

### Progression and scene actions

- Checkpoint: `food`.
- Advance with Continue.
- Scene action: **at first this is the main building** (`at-first-this-is-the-main-building`).
- Id: `economy.at-first-this-is-the-main-building`.
- Source stop: `31`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden",
      "uaod"
    ],
    "removed": [
      "ewsp",
      "usep",
      "uaco"
    ],
    "shade": true
  }
}
```

### Your edits / notes



## Step 43 — food

### Narration

For Night Elves and the Undead, their Main Buildings, the {Term: Tree of Life} and the {Term: Necropolis}, produce 10 Food.

### Progression and scene actions

- Checkpoint: `food`.
- Advance with Continue.
- Scene action: **racial food tour** (`racial-food-tour`).
- Id: `economy.racial-food-tour`.
- Source stop: `32`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden",
      "uaod"
    ],
    "removed": [
      "ewsp",
      "usep",
      "uaco"
    ],
    "shade": true
  }
}
```

### Your edits / notes



## Step 44 — food

### Narration

For Orcs, their Main Building, the {Term: Great Hall}, produces 11 Food.

### Progression and scene actions

- Checkpoint: `food`.
- Advance with Continue.
- Scene action: **orc food** (`orc-food`).
- Id: `economy.orc-food`.
- Source stop: `33`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 2,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden",
      "uaod"
    ],
    "removed": [
      "ewsp",
      "usep",
      "uaco"
    ],
    "shade": true
  }
}
```

### Your edits / notes



## Step 45 — food

### Narration

The Main Building of the Humans produces different amounts of Food depending on its tier.
The {Term: Town Hall} produces 12, the {Term: Keep} produces 14, and the {Term: Castle} produces 16.

### Progression and scene actions

- Checkpoint: `food`.
- Advance with Continue.
- Scene action: **human hall tour** (`human-hall-tour`).
- Id: `economy.human-hall-tour`.
- Source stop: `34`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 1,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden",
      "uaod"
    ],
    "removed": [
      "ewsp",
      "usep",
      "uaco"
    ],
    "shade": true
  }
}
```

### Your edits / notes



## Step 46 — food

### Narration

Aside from their main building, each race has a Food building.
For Humans it is {Term: Farms}, for Orcs it is {Term: Orc Burrows}, for Night Elves it is {Term: Moon Wells}, and for Undead it is {Term: Ziggurats}.

Each of these produces 10 Food.

### Progression and scene actions

- Checkpoint: `food`.
- Advance with Continue.
- Scene action: **food building tour** (`food-building-tour`).
- Id: `economy.food-building-tour`.
- Source stop: `35`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden",
      "uaod"
    ],
    "removed": [
      "ewsp",
      "usep",
      "uaco"
    ],
    "shade": true
  }
}
```

### Your edits / notes



## Step 47 — food

### Narration

Now, the question is: {Gold Font: What does Food do?}

The answer: Nothing by itself.
Instead, {Gold Font: it limits how many units you can have} - the size of your army.

### Progression and scene actions

- Checkpoint: `food`.
- Advance with Continue.
- Scene action: **now the question is what does food do** (`now-the-question-is-what-does-food-do`).
- Id: `economy.now-the-question-is-what-does-food-do`.
- Source stop: `36`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden",
      "uaod"
    ],
    "removed": [
      "ewsp",
      "usep",
      "uaco"
    ],
    "shade": true
  }
}
```

### Your edits / notes



## Step 48 — food

### Narration

Workers require 1 Food, other small units require 2 or 3.
Heroes require 5, and larger units require up to 7.
All of these add up, and the total {Gold Font: cannot exceed your food production}.

### Progression and scene actions

- Checkpoint: `food`.
- Advance with Continue.
- Scene action: **workers require 1 food other small units require 2 or 3** (`workers-require-1-food-other-small-units-require-2-or-3`).
- Id: `economy.workers-require-1-food-other-small-units-require-2-or-3`.
- Source stop: `38`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden",
      "uaod"
    ],
    "removed": [
      "ewsp",
      "usep",
      "uaco"
    ],
    "shade": true
  }
}
```

### Your edits / notes



## Step 49 — food

### Narration

When you are consuming as much food as you produce, you cannot produce more units.
This means you have {Term: Supply Blocked} yourself.

To be able to build new units, you now have to build more food production buildings.
This takes time, and slows down your game, so it is better to {Gold Font: plan ahead!}

### Progression and scene actions

- Checkpoint: `food`.
- Advance with Next.
- Scene action: **food limit demonstration** (`food-limit-demonstration`).
- Id: `economy.food-limit-demonstration`.
- Source stop: `39`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden",
      "uaod"
    ],
    "removed": [
      "ewsp",
      "usep",
      "uaco"
    ],
    "shade": true
  }
}
```

### Your edits / notes



## Step 50 — upkeep

### Narration

{Heading: UPKEEP}
Food governs the last mechanic relevant to Warcraft III's economy: {Term: Upkeep}.
This mechanic limits your army size, not by not allowing you to build units, but by making you pay extra for having them.

### Progression and scene actions

- Checkpoint: `upkeep`.
- Advance with Continue.
- Scene action: **upkeep display** (`upkeep-display`).
- Id: `economy.upkeep-display`.
- Source stop: `40`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden",
      "uaod"
    ],
    "removed": [
      "ewsp",
      "usep",
      "uaco"
    ],
    "shade": true
  }
}
```

### Your edits / notes



## Step 51 — upkeep

### Narration

This is done through a {Gold Font: tax on all Gold income}.
Once your {Term: Food Consumption}, not production, goes past 50, you hear a notification sound, and see {Yellow Font: Low Upkeep} pop up on your screen.

### Progression and scene actions

- Checkpoint: `upkeep`.
- Advance with Continue.
- Scene action: **low upkeep** (`low-upkeep`).
- Id: `economy.low-upkeep`.
- Source stop: `41`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden",
      "uaod"
    ],
    "removed": [
      "ewsp",
      "usep",
      "uaco"
    ],
    "shade": true
  }
}
```

### Your edits / notes



## Step 52 — upkeep

### Narration

While you consume this much food, {Gold Font: you pay a 30% tax}.
This means each of your workers only produces 7 {Term: Gold} every 5 seconds.

It also affects Gold you get for selling items, killing neutral enemies, and so on.
Basically it affects all ways you can receive Gold in the game, except for Unsummon, or cancelling build sites.
Lumber is not affected.

### Progression and scene actions

- Checkpoint: `upkeep`.
- Advance with Continue.
- Scene action: **low upkeep focus** (`low-upkeep-focus`).
- Id: `economy.low-upkeep-focus`.
- Source stop: `42`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden",
      "uaod"
    ],
    "removed": [
      "ewsp",
      "usep",
      "uaco"
    ],
    "shade": true,
    "foodUsed": 51
  }
}
```

### Your edits / notes



## Step 53 — upkeep

### Narration

Once you fall back under 51 {Term: Food Consumption}, you no longer have to pay {Term: Upkeep}.
You hear the notification sound again, and {Green Font: No Upkeep} pops up on your screen.

### Progression and scene actions

- Checkpoint: `upkeep`.
- Advance with Continue.
- Scene action: **no upkeep** (`no-upkeep`).
- Id: `economy.no-upkeep`.
- Source stop: `43`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden",
      "uaod"
    ],
    "removed": [
      "ewsp",
      "usep",
      "uaco"
    ],
    "shade": true,
    "foodUsed": 51
  }
}
```

### Your edits / notes



## Step 54 — upkeep

### Narration

Once your {Term: Food Consumption} goes past 80, you go to {Red Font: High Upkeep}.
You now {Gold Font: pay a 60% tax}.

### Progression and scene actions

- Checkpoint: `upkeep`.
- Advance with Continue.
- Scene action: **high upkeep** (`high-upkeep`).
- Id: `economy.high-upkeep`.
- Source stop: `44`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden",
      "uaod"
    ],
    "removed": [
      "ewsp",
      "usep",
      "uaco"
    ],
    "shade": true
  }
}
```

### Your edits / notes



## Step 55 — upkeep

### Narration

This mechanic makes it so {Yellow Font: you do not want to just grow your army as quickly as you can}.

Growing it to 50 Food Consumption is great, and you should do it quickly, to be as strong as possible as soon as you can.
But both {Yellow Font: crossing the threshold to 51 and to 81 are serious decisions} you should only make with a goal in mind.

### Progression and scene actions

- Checkpoint: `upkeep`.
- Advance with Continue.
- Scene action: **this mechanic makes it so you do not want to just grow your army ** (`this-mechanic-makes-it-so-you-do-not-want-to-just-grow-your-army-`).
- Id: `economy.this-mechanic-makes-it-so-you-do-not-want-to-just-grow-your-army-`.
- Source stop: `45`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden",
      "uaod"
    ],
    "removed": [
      "ewsp",
      "usep",
      "uaco"
    ],
    "shade": true,
    "foodUsed": 81
  }
}
```

### Your edits / notes



## Step 56 — upkeep

### Narration

For example, you can raise your army size past 50 in anticipation of a battle.
Since you will lose some units, it will likely drop you back to below 51.

And of course it makes sense to cross the threshold into Low or High Upkeep to attain the advantage to end the game.

### Progression and scene actions

- Checkpoint: `upkeep`.
- Advance with Continue.
- Scene action: **for example you can raise your army size past 50 in anticipation ** (`for-example-you-can-raise-your-army-size-past-50-in-anticipation-`).
- Id: `economy.for-example-you-can-raise-your-army-size-past-50-in-anticipation-`.
- Source stop: `46`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden",
      "uaod"
    ],
    "removed": [
      "ewsp",
      "usep",
      "uaco"
    ],
    "shade": true,
    "foodUsed": 81
  }
}
```

### Your edits / notes



## Step 57 — upkeep

### Narration

{Yellow Font: What you do not ever want to do is go to 51 Food Consumption and stay there for no reason.}
That is just wasting money.

Especially because your Gold Mines still lose 10 Gold for every trip a worker unit makes, whether or not you lose some of that gold to Upkeep.
Gold mines run empty eventually.

### Progression and scene actions

- Checkpoint: `upkeep`.
- Advance with Next.
- Scene action: **what you do not ever want to do is go to 51 food consumption and ** (`what-you-do-not-ever-want-to-do-is-go-to-51-food-consumption-and-`).
- Id: `economy.what-you-do-not-ever-want-to-do-is-go-to-51-food-consumption-and-`.
- Source stop: `48`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden",
      "uaod"
    ],
    "removed": [
      "ewsp",
      "usep",
      "uaco"
    ],
    "shade": true,
    "foodUsed": 81
  }
}
```

### Your edits / notes



## Step 58 — upkeep

### Narration

{Heading: END OF TUTORIAL}
This concludes the economy tutorial. Press the {Button: Menu} button to choose another tutorial!

### Progression and scene actions

- Checkpoint: `upkeep`.
- Final step: return through Menu; no further narration step.
- Scene action: **outro** (`outro`).
- Id: `economy.outro`.
- Source stop: `49`.

Scene / restoration details:

```json
{
  "restore": {
    "race": 4,
    "buildings": [
      "halt",
      "oalt",
      "eate",
      "eden",
      "uaod"
    ],
    "removed": [
      "ewsp",
      "usep",
      "uaco"
    ],
    "shade": true,
    "foodUsed": 81
  }
}
```

### Your edits / notes
