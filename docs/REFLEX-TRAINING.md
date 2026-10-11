# Reflex Training prototype

Source iteration: v0.1.3-alpha2. The distributed release remains v0.1.2-beta1.

The Skill Training card opens a shared briefing with placeholder Lorem ipsum text and one Start Training choice. That choice enters the south arena directly. The shared toolbar offers Menu, Redo and Pause; live briefing pages retain Resume and Exit. No scoring, targets or round logic is implemented yet.

The prototype uses the shared Human roster's 17 ground entries (70 units). Regular units have six copies, each hero has one, and each summon type shares six copies across its levels: two Water Elementals per level. Any indivisible remainder is distributed in roster order. This includes workers, Militia, normal ground military units, heroes and all three Water Elemental levels. Flying entries are excluded. All are neutral-passive owned, blue, invulnerable and selectable, so clicking cannot interrupt their walking or populate the player's hero bar. Native collision and movement speeds are retained.

The initial arena is 1,800 units wide by 1,000 deep, centered at the south arena's center (4864, 3456). Camera target distance is 1650, rotation 90 and attack angle 304, with the target at the arena center. This is an approximate screen-fitting first layout; actual visible footprint depends on screen aspect ratio, UI and camera perspective and needs native testing.

Spawn slots are shuffled across a 15 × 8 lattice with small random offsets. The separation avoids overlapping initial crowds while shuffled unit types prevent grouping by model. Each unit independently chooses random destinations inside the arena, with staggered initial orders. A quarter-second scoped update chooses another destination on arrival or after 1.5 seconds of no progress; it does not continually overwrite working movement orders. Edge recovery handles collision pushes outside the rectangle. Dense native traffic and visible edge corrections need in-game observation before tuning.

Redo randomizes a fresh crowd. Menu/load frame restoration does not create units or restart timers. The activity scope removes all created units and its timer, restores borrowed camera and time-of-day state, and the controller restores menu/fog state on exit. `tools/test-reflex-training.lua` checks order bounds, independent destinations, stalls, direct navigation and presentation/cleanup contracts; it cannot prove native pathing or camera fit.

## Alpha test focus

- Briefing has the placeholder and Start Training; starting centers the arena.
- Units fill the view without being obscured by the toolbar or lower interface.
- All units are Human ground models and independently wander without becoming permanently stuck.
- Judge density, arena proportions and whether edge recovery causes distracting jumps.
- Menu/Resume and Pause preserve the same crowd; Redo creates a fresh randomized crowd.
- Exit and entering another exercise remove the entire crowd and restore camera/time state.
- Save/load preserves the crowd and resumes movement without duplicate units or timers.

The next design step is tuning the stage, density and movement. Race mixing, unit-type mixtures, target selection and scoring remain undecided.
