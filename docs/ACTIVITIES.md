# Implemented activity catalogue

This page describes player-facing content in v0.1.2-beta1. Planned catalogue cards without factories are intentionally omitted.

| Activity | Category | Scene | Main variants | Source |
| --- | --- | --- | --- | --- |
| Camera | Learn to Play | Imported Orc base | Player-paced topics, demonstrations and checkpoints | `src/activities/camera-tutorial.lua` |
| Unit Controls | Learn to Play | South arena | Selection, interface and command practice | `src/activities/unit-controls-tutorial.lua` |
| Hotkey Setup | Learn to Play | South arena | QWERTY/QWERTZ comparison and setup guidance; file export disabled | `src/activities/hotkey-setup-tutorial.lua` |
| Economy & Workers | Learn to Play | Four racial bases | Worker mechanics, resource gathering, defense practice, food and upkeep | `src/activities/economy-tutorial.lua` |
| Mining Micro | Skill Training | North arena | Human/Orc; rotated but geometrically identical mine layouts | `src/activities/mining-micro.lua` |
| Body Blocking | Skill Training | South arena | Racial training sequences or custom runner/blocker; Normal/Hard | `src/activities/body-blocking.lua` |
| Surrounds | Skill Training | South arena | Racial training setups or custom army of up to 12 units | `src/activities/surrounds.lua` |
| Gargoyle Surrounds | Skill Training | South arena | Gargoyles form ground surrounds by entering Stone Form; Undead and neutral-hero setups | `src/activities/surrounds.lua` |
| Windwalk Pop | Skill Training | North arena | Normal, Hard, Timed Training and Counterplay | `src/activities/windwalk-pop.lua` |
| Power Building | Tools & Extras | South arena | Human building selector; 1–10 Peasant comparison | `src/activities/power-building.lua` |
| Bat Splitting | Skill Training | Arena 1 northern boundary | 6/8/10 Gryphons versus fixed-target bats; direct/splash results | `src/activities/bat-splitting.lua` |
| Dodging | Skill Training | South arena | Disjoining Abilities/Attacks; Avoiding Area/Devour; grouped dodge abilities and racial movement selection | `src/activities/missile-dodging.lua` |

Four tutorials and eight exercises are implemented. Planned cards are not playable. Dodging modes and diagnostic limitations are described in [Dodge test bench](DODGE-TEST-BENCH.md).

## Shared behavior

Activities register a stable ID, category, scene, capabilities and factory in `src/infrastructure/catalog.lua`. Activities with configuration pages also register a menu function. The controller permits one active session and owns reset, replacement and exit transitions.

Body Blocking, Surrounds, Gargoyle Surround and Windwalk Pop use shared result cards and support Replay. Relevant collision exercises expose the Squares control, which cycles obstruction boxes and snap points, then adds the finer navigation grid. Gargoyle Surround hides the obstruction box while a Gargoyle is flying and shows its current box after Stone Form turns it into a ground unit. Mining Micro exposes rotation; Surrounds and Gargoyle Surround expose setup selection; course activities expose Next and Back where applicable.

## Tutorials

Tutorials use player-paced text and explicit navigation rather than advancing when temporary messages disappear. Quest entries provide durable reference material. Camera uses match-like terrain and fog behavior; Unit Controls and Hotkey Setup use controlled arenas; Economy uses four racial bases with active-race vision.

All four tutorials use the shared presentation helpers in `JTG.Tutorial`. See [TUTORIAL-STANDARD.md](TUTORIAL-STANDARD.md) for confirmed ownership, checkpoint, camera and lifecycle rules.
