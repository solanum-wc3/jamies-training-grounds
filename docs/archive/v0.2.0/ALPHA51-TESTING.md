# Alpha51: focused native checks

Build: `Jamies-Training-Grounds-v0.1.3-alpha51-dev.w3x`. Start a fresh game; loading an older map's save will not test the new object definitions. No automated Hotkey audit is required.

## Mining Micro

1. Check the revised introduction and its blank line before Quest Log. After Human/Orc, hover One Minute, Unlimited and Build Order; check the three supplied tooltips.
2. In either regular mode, check that YOU is bright red, the same size as the other text, and indented with its three following lines. The regular modes still have three bases. Briefly check rotation, Menu/Resume and One Minute's original end card.
3. Start Build Order for Human, then Orc. There should be only two bases, each with five workers initially assigned four to gold and one to lumber. Both start with 500 Gold / 150 Lumber. The five-worker gold reference and its screen text should be absent.
4. Build a Farm/Burrow, Altar and Barracks. Train a worker and send it to lumber so the exercise keeps running. Check that the reference builds/trains corresponding objects at equivalent positions, including commands from a newly constructed building. Test an ordinary research or main-building upgrade too.
5. Repeatedly micro the gold workers. Reference workers must continue ordinary gathering rather than copy these clicks. Change a worker from gold to lumber and back: the reference should copy the job change once. Check building workers resume gathering after their reference construction completes.
6. Try spending faster than the reference can afford and cancel an unfinished building. The reference must wait/retry naturally, without receiving extra money, creating duplicates or continuing a cancelled site. Native queue/cancellation behavior is a particular acceptance risk.
7. Recruit the first hero from the Altar while still at tier one. It should not request a Castle/Fortress. If this still fails, record the exact requirement and whether it also occurs in a fresh game before visiting Heroes/Hotkey Trainer. No tier-three building is supplied as a workaround.
8. Finally send a fifth worker into your mine. Walking near it or merely issuing the order must not end the exercise. Entry should show Total Gold mined, Total Lumber mined, Time Elapsed, and a larger golden Extra Gold mined. Extra Gold is player income minus reference income, independent of spending/refunds.
9. Exit and re-enter; reference buildings, trained units and pending work must not remain. Test one other rotation to check translated building placement and gathering paths.

## Heroes

1. In the Archmage and showcase scenes, hover the targets. They should say Target Dummie, have no hero level badge, and start at zero armor with Heavy armor type.
2. Use the middle-left Change Armor Type button. From Heavy it cycles Building, Hero, Unarmed, Light, Medium, Heavy. The icon should follow the type. Test the same cycle on another dummy and confirm their settings are independent.
3. Middle-right gold + raises armor by one; the gold minus directly below lowers it by one, including below zero. Changing armor type should retain the numeric amount. Neutral/Hostile controls should still work, and damage popups should reflect actual hits. With Hero armor, compare spell damage and a debuff duration against another armor type: the native 30% spell reduction and hero-style Resistant Skin should apply only in Hero mode. Raise Armor must remain visible in that mode.
4. Read the creep-XP narration and Quest. Narration gives the level-five cutoff; the Quest lists 80%, 70%, 60%, 50%, 0% and explains that the reduction applies after sharing.

## Other included changes

- Hotkey Trainer: test Spirit Walker's Ethereal/Corporeal commands when encountered, then a Druid return-form command. Source and destination icons, command names and actual starting forms should agree. Input must wait for setup transformation to finish. Destroyer Form remains one-way.
- Reflex Training: check the added second line in its opening briefing fits without overlapping the mode buttons.

Automated checks cover 42 Lua regression fixtures, native object-table generation, exact icon paths, Lua assembly and both packaging modes. They do not establish native pathing, order acceptance, hero requirements, command-grid redraw or presentation. The source checkpoint is implemented and awaiting the user's in-game acceptance.
