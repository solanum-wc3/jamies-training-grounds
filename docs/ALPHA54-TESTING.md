# Alpha54: focused native checks

Build: `Jamies-Training-Grounds-v0.1.3-alpha54-dev.w3x`. Start a fresh game.

1. Mining Micro: choose Human, return with Back, then choose Orc. Hover each mode button. Neither transition should crash and all supplied tooltips should appear.
2. Build Order: right-click the player's mine to set the main building's rally point, then train a worker. The reference counterpart should gather at its own mine. Repeat with a lumber rally, a rally changed during training, and a ground rally. Delay the fifth player worker's actual mine entry until ready to finish the exercise.
3. Queue several workers and assign them to lumber. Check each reference worker is trained exactly once, including after the reference temporarily lacks funds. Verify the end card's Extra Gold value and exit/re-entry cleanup. Shift-queued worker jobs are a known limitation and are not claimed to mirror faithfully.
4. Heroes: the Archmage dummy is Hostile during the attack-speed comparison, then becomes Neutral on Continue to Attributes. Back should restore the attacking comparison. Other dummies default to Neutral.
5. Each dummy has one Change Mode button: Stop depicts Neutral; Attack depicts Hostile. Clicking toggles it. Check that changing one dummy does not change another.
6. Cycle all six armor types: artwork should fill the command cell without a number box. Tooltip titles should not repeat in the body; the body should say Current: followed by the current mode, armor type, or numeric armor. Test Raise/Lower through positive and negative values, then another dummy to check independence. Native live tooltip refresh remains unverified automatically.
7. Hotkey Trainer: wrong Build/Ability Choice entry keys close the submenu. Reopen it and answer correctly; opening keys must remain unpenalized.
8. Patch Notes: the approved 0.2.0 entry is marked Upcoming. XP Numbers retains the requested paragraph spacing.

Earlier [alpha51 checks](ALPHA51-TESTING.md) cover armor resistance, transformations and broader Build Order behavior. The public release remains v0.1.2-beta1; no release links were changed.
