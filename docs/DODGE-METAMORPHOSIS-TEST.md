# Metamorphosis projectile test — alpha 17 dev

Load `Jamies-Training-Grounds-v0.1.2-alpha17-dev.w3x` and type **`-timing-metamorph`** in chat. Leave the units alone and keep the game running at normal speed. Allow about **eight minutes**.

The 54 automatic trials test Ensnare, Storm Bolt, and a Troll Headhunter/Berserker projectile attack against the Demon Hunter. Each case runs twice at 85% of the native range:

- No Metamorphosis: impact controls on the same hero.
- Metamorphosis 0.25, 0.75, or 1.25 seconds before the enemy order.
- Metamorphosis at 0%, 25%, 50%, 75%, or 90% of estimated projectile flight after launch.

The pawn cannot walk or auto-attack. Evasion is removed from the diagnostic pawn to avoid mistaking a random miss for a Metamorphosis dodge. Each enemy is stopped after its first launch so later attacks cannot obscure the trial. Damage events, native spell events, form changes, invulnerability, and configured buffs are recorded. A zero-damage event is not automatically a hit or a dodge; Ensnare's actual net state must be inspected.

Spell launch anchors are native spell-effect events. Ordinary attack launch is estimated from the attacked event plus the native attack damage point, and the estimated flight fraction is a scheduling aid rather than a directly observed projectile position. Actual event times remain in the export. Missing launches or rejected transformations are reported separately and cannot establish success.

The run exports automatically to **`Documents/Warcraft III/CustomMapData/JTG-Dodge-Timing.pld`** and returns to Skill Training. You can type **`-timing-stop`** to stop early and export the observations collected so far. Tell me when it finishes; no manual table is needed.

This dev alpha also includes the pending tooltip, camera, Spirit Wolf, Chain Lightning, and selection changes. Those changes still need in-game review; this pass primarily investigates Metamorphosis.
