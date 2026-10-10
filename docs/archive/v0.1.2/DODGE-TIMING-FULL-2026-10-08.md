# First complete automatic timing pass — 2026-10-08

Imported the native export modified at 16:52:47 local time. Preserved the original in `work/dodge-measurements/full-2026-10-08/raw-export.pld`; extracted events and per-run summaries are alongside it.

- 595 runs, 51,753 observations; no recorder truncation flags.
- 85 cases ended after damage, 103 after matching observations, 36 after isolated observations, one after construction started, one without construction starting, and 369 without a matching enemy event. These are runner completion statuses, not successful-dodge counts. Cases without matching events cannot establish dodge timing.
- The isolated Wisp building case did not start construction. This needs a focused native check; the isolated Peon construction case did start.
- Baselines without matching events included the staffed Orc Burrow, the first Beastmaster Hawk (which has no native attack), and Carrion Swarm.

## Attack selection correction

The user observed the Chimaera starting at its building attack range. The catalogue selected weapon slot 0, whose native range is 850 and whose targets are structures/debris. Its regular ground attack is slot 1, range 450. The export contains an attack and damage for this baseline, but that does not validate the starting distance: both attacks remained enabled, so it could approach and use a different weapon from the one whose range was read.

The same catalogue audit found Flying Machine ground attack reading its 500-range instant air weapon instead of its 100-range ground missile weapon, and Ancient Protector reading its 128-range melee weapon instead of its 700-range ranged weapon. All three now explicitly select slot 1, which also makes the shared exercise enable only that weapon and read that weapon's range and tooltip data. The Gargoyle note was corrected: its ranged weapon targets ground units; its air attack is melee.

Existing setup, order, lifecycle and automatic batch checks pass after regeneration, including explicit regression checks for these three weapon/range pairs. Native validation of the corrected cases remains pending. Preserve the rest of this run; a full repeat is unnecessary solely for these corrections.

An attack-start event is still not a measured missile-launch event. Damage and sampled state changes must be interpreted individually; absent damage does not prove a dodge.
