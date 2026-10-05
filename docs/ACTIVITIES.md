# Implemented activity catalogue

This page describes player-facing content in v0.1.0. Planned catalogue cards without factories are intentionally omitted.

| Activity | Category | Scene | Main variants | Source |
| --- | --- | --- | --- | --- |
| Camera | Learn to Play | Imported Orc base | Player-paced topics, demonstrations and checkpoints | `src/activities/camera-tutorial.lua` |
| Unit Controls | Learn to Play | South arena | Selection, interface and command practice | `src/activities/unit-controls-tutorial.lua` |
| Hotkey Setup | Learn to Play | South arena | QWERTY/QWERTZ comparison and CustomKeys export | `src/activities/hotkey-setup-tutorial.lua` |
| Mining Micro | Skill Training | North arena | Human/Orc; rotated but geometrically identical mine layouts | `src/activities/mining-micro.lua` |
| Body Blocking | Skill Training | South arena | Racial training sequences or custom runner/blocker; Normal/Hard | `src/activities/body-blocking.lua` |
| Surrounds | Skill Training | South arena | Racial training setups or custom army of up to 12 units | `src/activities/surrounds.lua` |
| Windwalk Pop | Skill Training | North arena | Normal, Hard, Timed Training and Counterplay | `src/activities/windwalk-pop.lua` |
| Power Building | Tools & Extras | South arena | Human building selector; 1–10 Peasant comparison | `src/activities/power-building.lua` |

## Shared behavior

Activities register a stable ID, category, scene, capabilities and factory in `src/infrastructure/catalog.lua`. Activities with configuration pages also register a menu function. The controller permits one active session and owns reset, replacement and exit transitions.

Body Blocking, Surrounds and Windwalk Pop use shared result cards and support Replay. Relevant collision exercises expose the Squares control, which cycles obstruction boxes and snap points, then adds the finer navigation grid. Mining Micro exposes rotation; Surrounds exposes setup selection; course activities expose Next and Back where applicable.

## Tutorials

Tutorials use player-paced text and explicit navigation rather than advancing when temporary messages disappear. Quest entries provide durable reference material. Camera uses match-like terrain and fog behavior; the other current tutorials use controlled arena presentation.

The next planned architectural step is to prove a shared tutorial-page system with the Economy tutorial, then migrate existing tutorials incrementally.
