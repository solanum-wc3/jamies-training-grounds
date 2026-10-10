# Dodging tooltip review

Current wording. Headings are the golden headline; code blocks are the grey tooltip body. Circular areas specify radius. Disabled choices show their restriction reason only. Hawk 1 is disabled without a tooltip.

## Dodge abilities and items

### Blademaster

```text
Wind Walk
Instant
Fade duration: 0.602s

Mirror Image
Cast Point: 0.3s
Hidden: 0.305s after command
Invulnerable: 0.305s after command
```

### Spirit Wolf: re-summon

```text
Cast Point: 0.3s
Old summon replaced: 0.297s after command
```

### Peon: Build, Burrow

```text
Instant
```

### Shadow Hunter: Big Bad Voodoo

```text
Cast Point: 0.3s
Target invulnerable: 0.555s after command
```

### Mountain King: Avatar

```text
Instant
```

### Paladin: Divine Shield

```text
Instant
```

### Sorceress: Invisibility

```text
Cast Point: 0.45s
Fade duration: 0.008s
```

### Staff of Sanctuary

```text
Instant
```

### Gargoyle: Stone Form

```text
Instant
Stone form: 1.01s after command
```

### Crypt Fiend: Burrow

```text
Instant
Burrowed / invisible: 1.46s after command
```

### Obsidian Statue: Destroyer Form

```text
Instant
```

### Carrion Beetle: Burrow

```text
Instant
Burrowed / invisible: 1.46s after command
```

### Banshee: Anti-Magic Shell

```text
Cast Point: 0.5s
Target protection buff: 0.508s after command
```

### Shadowmeld

```text
Cast Point: 0.5s
Fade duration: 1.51s
```

### Warden: Blink

```text
Cast Point: 0.34s
Position changes: 0.344s after command
```

### Faerie Dragon: Phase Shift

```text
Cast Point: 0.3s
Phase Shift active: 0.312s after command
```

### Demon Hunter: Metamorphosis

```text
Instant
```

### Druid of the Claw: Bear Form

```text
Instant
```

### Druid of the Talon: Crow Form

```text
Instant
```

### Archer: mount Hippogryph

```text
Instant
```

### Hippogryph: pick up Archer

```text
Instant
```

### Hippogryph Rider: dismount

```text
Instant
```

### Wisp: Build, Goldmine, Detonate

```text
Instant
```

### Staff of Preservation

```text
Instant
```

### Anti-Magic Potion

```text
Instant
```

### Forsaken Paladin: Righteous Fury

```text
Instant
```

### Pandaren Brewmaster: Storm, Earth and Fire

```text
Cast Point: 0.4s
Hidden: 0.406s after command
Invulnerable: 0.406s after command
```

### Tinker: Robo-Goblin

```text
Instant
Robo-Goblin form: 1.5s after command
```

### Goblin Zeppelin: load unit

```text
Instant
```

### Scroll of Town Portal

```text
Instant
```

### Cloak of Shadows

```text
Instant
Fade duration: 1.47s
```

### Potion of Invisibility

```text
Instant
Fade duration: 1.95s
```

### Potion of Invulnerability

```text
Instant
```

## Additional notes on enabled choices

Example: Blademaster against Far Seer

```text
Wind Walk must finish fading before the projectile hits.
```

Example: Blademaster against Raider: Ensnare

```text
Ensnare reveals invisible units
```

Example: Druid of the Talon: Crow Form against Priestess of the Moon: Searing Arrows

```text
After transforming, Druids of the Talon benefit from higher armor, but they do not dodge attacks.
```

## Disabled-choice variants

Example: Mountain King: Avatar against Siege Engine Barrage

```text
This attack only targets flying units.
```

Example: Mountain King: Avatar against Kodo Beast: Devour

```text
This unit cannot be devoured.
```

Example: Shadow Hunter: Big Bad Voodoo against Kodo Beast: Devour

```text
This method does not disjoin the selected projectile.
```

Example: Mountain King: Avatar against Raider: Ensnare

```text
Only blocks magical abilities.
```

Example: Paladin: Divine Shield against Raider: Ensnare

```text
The net still hits if it was thrown before Divine Shield.
```

Example: Sorceress: Invisibility against Raider: Ensnare

```text
Ensnare reveals invisible units.
```

Example: Potion of Invulnerability against Raider: Ensnare

```text
The net still hits if it was thrown before invulnerability.
```

Example: Gargoyle: Stone Form against Tauren Chieftain: Shockwave

```text
This ability cannot hit flying units.
```

Example: Obsidian Statue: Destroyer Form against Tauren Chieftain: War Stomp

```text
This ability only affects organic units.
```

Example: Gargoyle: Stone Form against Death Knight: Death Coil

```text
Death Coil cannot damage Undead units.
```

Example: Mountain King: Avatar against Batrider: Unstable Concoction

```text
Choose a Hippogryph, Hippogryph Rider, Crow Form Druid of the Talon, or Gargoyle.
```

Ranged attacker restrictions:

```text
This attack has no projectile to disjoin.
```

```text
This unit has no selectable ranged attack.
```

## Incoming abilities and attacks

### Homing

#### Raider: Ensnare

```text
Cast Point: 0.6s
Projectile Speed: 1500.0 units/s
```

#### Mountain King: Storm Bolt

```text
Cast Point: 0.4s
Projectile Speed: 1000.0 units/s
```

#### Death Knight: Death Coil

```text
Cast Point: 0.452s
Projectile Speed: 1100.0 units/s
```

#### Priestess of the Moon: Searing Arrows

```text
Base attack wind-up: 0.3s
Projectile Speed: 1500.0 units/s
```

#### Warden: Shadow Strike

```text
Cast Point: 0.5s
Projectile Speed: 1200.0 units/s
```

#### Naga Sea Witch: Frost Arrows

```text
Base attack wind-up: 0.73s
Projectile Speed: 1500.0 units/s
```

#### Pandaren Brewmaster: Drunken Haze

```text
Cast Point: 0.4s
Projectile Speed: 1500.0 units/s
```

#### Dark Ranger: Black Arrow

```text
Base attack wind-up: 0.7s
Projectile Speed: 1050.0 units/s
```

#### Firelord: Incinerate

```text
Base attack wind-up: 0.5s
Projectile Speed: 1000.0 units/s
```

#### Crypt Lord: Impale (unit target)

```text
Cast Point: 0.5s
Projectile Speed: Instant
```

### Area

#### Tauren Chieftain: Shockwave

```text
Cast Point: 0.47s
Projectile Speed: 1050.0 units/s
Area: 125 units wide
```

#### Tauren Chieftain: War Stomp

```text
Cast Point: 0.47s
Projectile Speed: Instant
Area: 250 units radius
```

#### Mountain King: Thunder Clap

```text
Cast Point: 0.4s
Projectile Speed: Instant
Area: 300 units radius
```

#### Archmage: Blizzard

```text
Cast Point: 0.3s
Projectile Speed: Instant
Area: 200 units radius
Wave interval: 1.0s
```

#### Crypt Lord: Impale

```text
Cast Point: 0.5s
Projectile Speed: Instant
Area: Line-shaped
```

#### Dread Lord: Carrion Swarm

```text
Cast Point: 0.3s
Projectile Speed: 1100.0 units/s
Area: Expanding cone; 100 units initial width; 300 units final radius
```

#### Warden: Fan of Knives

```text
Cast Point: 0.5s
Projectile Speed: 700.0 units/s
Area: 400 units radius
```

#### Pandaren Brewmaster: Breath of Fire

```text
Cast Point: 0.4s
Projectile Speed: 1050.0 units/s
Area: Expanding cone; 90 units initial width; 175 units final radius
```

#### Pit Lord: Rain of Fire

```text
Cast Point: 0.75s
Projectile Speed: Instant
Area: 200 units radius
Wave interval: 1.0s
```

#### Tinker: Cluster Rockets

```text
Cast Point: 0.53s
Projectile Speed: 700.0 units/s
Area: 200 units radius on lvl 1
```

#### Alchemist: Acid Bomb

```text
Cast Point: 0.4s
Projectile Speed: 700.0 units/s
Area: 200 units radius
```

#### Far Seer: Chain Lightning

```text
Cast Point: 0.3s
Projectile Speed: 1500.0 units/s
Area: 500 units bounce range
```

#### Batrider: Unstable Concoction

```text
Instant
Projectile Speed: Instant
Area: 200 units radius
```

### Ranged

#### Far Seer

```text
Base attack wind-up: 0.3s
Projectile Speed: 1200.0 units/s
Attack range: 600.0 units
```

#### Shadow Hunter

```text
Base attack wind-up: 0.3s
Projectile Speed: 900.0 units/s
Attack range: 600.0 units
```

#### Troll Headhunter

```text
Base attack wind-up: 0.31s
Projectile Speed: 1200.0 units/s
Attack range: 550.0 units
```

#### Troll Berserker

```text
Base attack wind-up: 0.31s
Projectile Speed: 1200.0 units/s
Attack range: 550.0 units
```

#### Troll Batrider

```text
Base attack wind-up: 0.6s
Projectile Speed: 900.0 units/s
Attack range: 300.0 units
```

#### Wind Rider

```text
Base attack wind-up: 0.6s
Projectile Speed: 1200.0 units/s
Attack range: 450.0 units
```

#### Kodo Beast

```text
Base attack wind-up: 0.85s
Projectile Speed: 1200.0 units/s
Attack range: 500.0 units
```

#### Shaman

```text
Base attack wind-up: 0.43s
Projectile Speed: 1200.0 units/s
Attack range: 600.0 units
```

#### Witch Doctor

```text
Base attack wind-up: 0.73s
Projectile Speed: 900.0 units/s
Attack range: 600.0 units
```

#### Spirit Walker

```text
Base attack wind-up: 0.5s
Projectile Speed: 900.0 units/s
Attack range: 400.0 units
```

#### Orc Burrow

```text
Base attack wind-up: 0.3s
Projectile Speed: 1200.0 units/s
Attack range: 700.0 units
```

#### Watch Tower

```text
Base attack wind-up: 0.3s
Projectile Speed: 1800.0 units/s
Attack range: 800.0 units
```

#### Serpent Ward 1

```text
Base attack wind-up: 0.3s
Projectile Speed: 900.0 units/s
Attack range: 600.0 units
```

#### Serpent Ward 2

```text
Base attack wind-up: 0.3s
Projectile Speed: 900.0 units/s
Attack range: 600.0 units
```

#### Serpent Ward 3

```text
Base attack wind-up: 0.3s
Projectile Speed: 900.0 units/s
Attack range: 600.0 units
```

#### Rifleman

```text
Base attack wind-up: 0.17s
Projectile Speed: Instant
Attack range: 400.0 units
```

#### Spell Breaker

```text
Base attack wind-up: 0.5s
Projectile Speed: 900.0 units/s
Attack range: 250.0 units
```

#### Priest

```text
Base attack wind-up: 0.59s
Projectile Speed: 900.0 units/s
Attack range: 600.0 units
```

#### Sorceress

```text
Base attack wind-up: 0.75s
Projectile Speed: 900.0 units/s
Attack range: 600.0 units
```

#### Gryphon Rider

```text
Base attack wind-up: 0.8s
Projectile Speed: 1100.0 units/s
Attack range: 450.0 units
```

#### Water Elemental Level 1

```text
Base attack wind-up: 0.4s
Projectile Speed: 1300.0 units/s
Attack range: 300.0 units
```

#### Water Elemental Level 2

```text
Base attack wind-up: 0.4s
Projectile Speed: 1300.0 units/s
Attack range: 300.0 units
```

#### Water Elemental Level 3

```text
Base attack wind-up: 0.4s
Projectile Speed: 1300.0 units/s
Attack range: 300.0 units
```

#### Dragonhawk Rider

```text
Base attack wind-up: 0.43s
Projectile Speed: 1100.0 units/s
Attack range: 300.0 units
```

#### Phoenix

```text
Base attack wind-up: 0.43s
Projectile Speed: 1800.0 units/s
Attack range: 600.0 units
```

#### Archmage

```text
Base attack wind-up: 0.55s
Projectile Speed: 900.0 units/s
Attack range: 600.0 units
```

#### Blood Mage

```text
Base attack wind-up: 0.55s
Projectile Speed: 900.0 units/s
Attack range: 600.0 units
```

#### Guard Tower

```text
Base attack wind-up: 0.3s
Projectile Speed: 1800.0 units/s
Attack range: 700.0 units
```

#### Arcane Tower

```text
Base attack wind-up: 0.3s
Projectile Speed: 1500.0 units/s
Attack range: 800.0 units
```

#### Cannon Tower

```text
Base attack wind-up: 0.3s
Projectile Speed: 700.0 units/s
Attack range: 800.0 units
```

#### Flying Machine ground attack

```text
Base attack wind-up: 0.633s
Projectile Speed: Instant
Attack range: 100.0 units
```

#### Siege Engine Barrage

```text
Base attack wind-up: 0.125s
Projectile Speed: Instant
Attack range: 500.0 units
```

#### Gargoyle

```text
Base attack wind-up: 0.633s
Projectile Speed: 900.0 units/s
Attack range: 300.0 units
```

#### Destroyer

```text
Base attack wind-up: 0.633s
Projectile Speed: 900.0 units/s
Attack range: 450.0 units
```

#### Crypt Fiend

```text
Base attack wind-up: 0.64s
Projectile Speed: 500.0 units/s
Attack range: 550.0 units
```

#### Necromancer

```text
Base attack wind-up: 0.53s
Projectile Speed: 900.0 units/s
Attack range: 600.0 units
```

#### Banshee

```text
Base attack wind-up: 0.56s
Projectile Speed: 900.0 units/s
Attack range: 600.0 units
```

#### Frost Wyrm

```text
Base attack wind-up: 0.5s
Projectile Speed: 800.0 units/s
Attack range: 375.0 units
```

#### Skeleton Mage

```text
Base attack wind-up: 0.5s
Projectile Speed: 900.0 units/s
Attack range: 500.0 units
```

#### Spirit Tower

```text
Base attack wind-up: 0.5s
Projectile Speed: 900.0 units/s
Attack range: 700.0 units
```

#### Nerubian Tower

```text
Base attack wind-up: 0.5s
Projectile Speed: 1200.0 units/s
Attack range: 700.0 units
```

#### Black Citadel

```text
Base attack wind-up: 0.3s
Projectile Speed: 1200.0 units/s
Attack range: 800.0 units
```

#### Halls of the Dead

```text
Base attack wind-up: 0.3s
Projectile Speed: 1200.0 units/s
Attack range: 800.0 units
```

#### Lich

```text
Base attack wind-up: 0.46s
Projectile Speed: 900.0 units/s
Attack range: 600.0 units
```

#### Obsidian Statue

```text
Base attack wind-up: 0.53s
Projectile Speed: 1200.0 units/s
Attack range: 575.0 units
```

#### Keeper of the Grove

```text
Base attack wind-up: 0.4s
Projectile Speed: 900.0 units/s
Attack range: 600.0 units
```

#### Priestess of the Moon

```text
Base attack wind-up: 0.3s
Projectile Speed: 900.0 units/s
Attack range: 600.0 units
```

#### Demon Hunter demon form

```text
Base attack wind-up: 0.26s
Projectile Speed: 900.0 units/s
Attack range: 600.0 units
```

#### Archer

```text
Base attack wind-up: 0.72s
Projectile Speed: 900.0 units/s
Attack range: 500.0 units
```

#### Huntress

```text
Base attack wind-up: 0.46s
Projectile Speed: 900.0 units/s
Attack range: 225.0 units
```

#### Dryad

```text
Base attack wind-up: 0.3s
Projectile Speed: 1000.0 units/s
Attack range: 500.0 units
```

#### Faerie Dragon

```text
Base attack wind-up: 0.5s
Projectile Speed: 900.0 units/s
Attack range: 300.0 units
```

#### Chimaera

```text
Base attack wind-up: 0.5s
Projectile Speed: Instant
Attack range: 450.0 units
```

#### Druid of the Talon caster form

```text
Base attack wind-up: 0.5s
Projectile Speed: 900.0 units/s
Attack range: 600.0 units
```

#### Druid of the Talon crow form

```text
Base attack wind-up: 0.6s
Projectile Speed: 900.0 units/s
Attack range: 600.0 units
```

#### Hippogryph Rider

```text
Base attack wind-up: 0.633s
Projectile Speed: 1500.0 units/s
Attack range: 400.0 units
```

#### Ancient Protector

```text
Base attack wind-up: 0.6s
Projectile Speed: 750.0 units/s
Attack range: 700.0 units
```

#### Avatar of Vengeance

```text
Base attack wind-up: 0.33s
Projectile Speed: 1200.0 units/s
Attack range: 450.0 units
```

#### Spirit of Vengeance

```text
Base attack wind-up: 0.33s
Projectile Speed: 1200.0 units/s
Attack range: 450.0 units
```

#### Firelord

```text
Base attack wind-up: 0.5s
Projectile Speed: 1200.0 units/s
Attack range: 550.0 units
```

#### Lava Spawn 1

```text
Base attack wind-up: 0.4s
Projectile Speed: 1000.0 units/s
Attack range: 300.0 units
```

#### Lava Spawn 2

```text
Base attack wind-up: 0.4s
Projectile Speed: 1000.0 units/s
Attack range: 300.0 units
```

#### Lava Spawn 3

```text
Base attack wind-up: 0.4s
Projectile Speed: 1000.0 units/s
Attack range: 300.0 units
```

#### Dark Ranger

```text
Base attack wind-up: 0.7s
Projectile Speed: 900.0 units/s
Attack range: 600.0 units
```

#### Naga Sea Witch

```text
Base attack wind-up: 0.73s
Projectile Speed: 1200.0 units/s
Attack range: 600.0 units
```

#### Storm Spirit

```text
Base attack wind-up: 0.4s
Projectile Speed: 1200.0 units/s
Attack range: 500.0 units
```

#### Beastmaster Quillbeast 1

```text
Base attack wind-up: 0.5s
Projectile Speed: 1500.0 units/s
Attack range: 550.0 units
```

#### Beastmaster Quillbeast 2

```text
Base attack wind-up: 0.5s
Projectile Speed: 1500.0 units/s
Attack range: 550.0 units
```

#### Beastmaster Quillbeast 3

```text
Base attack wind-up: 0.633s
Projectile Speed: 1500.0 units/s
Attack range: 550.0 units
```

#### Beastmaster Quillbeast 4

```text
Base attack wind-up: 0.633s
Projectile Speed: Instant
Attack range: 550.0 units
```

#### Beastmaster Hawk 2

```text
Base attack wind-up: 0.5s
Projectile Speed: 1500.0 units/s
Attack range: 300.0 units
```

#### Beastmaster Hawk 3

```text
Base attack wind-up: 0.5s
Projectile Speed: 1500.0 units/s
Attack range: 300.0 units
```

#### Demolisher: targeted attack

```text
Base attack wind-up: 0.1s
Projectile Speed: 900.0 units/s
Attack range: 1150.0 units
```

#### Mortar Team: targeted attack

```text
Base attack wind-up: 1s
Projectile Speed: 900.0 units/s
Attack range: 1150.0 units
```

#### Meat Wagon: targeted attack

```text
Base attack wind-up: 0.7s
Projectile Speed: 900.0 units/s
Attack range: 1150.0 units
```

#### Glaive Thrower: targeted attack

```text
Base attack wind-up: 0.1s
Projectile Speed: Instant
Attack range: 1150.0 units
```
