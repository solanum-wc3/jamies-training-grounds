# Alpha52: focused native checks

Build: `Jamies-Training-Grounds-v0.1.3-alpha52-dev.w3x`. Start a fresh game.

1. Mining Micro: after choosing Human or Orc, hover One Minute, Unlimited and Build Order. All three should show their supplied tooltips. Return to the race page: no old tooltip should remain.
2. Build Order: train several workers, assigning them to lumber so the exercise stays open. Check that the reference copies each training request exactly once, including several queued copies of the same worker. Repeat for Human and Orc.
3. Spend ahead of the reference: its pending commands should wait for funds, then run without extra clicks or duplicate workers. Check a worker trained from the main building and a combat unit trained from a new Barracks. The reference still receives no income top-ups and must not copy repeated mining-micro clicks.
4. Send the fifth worker into the player's mine and check the usual end card. Exit/re-enter and check that no generated units or pending orders remain.
5. Heroes: XP Numbers should have a blank line before and after “XP from Summons is halved.” The paragraph beginning “These percentages apply...” should immediately follow the percentage list, without a blank line.
6. Hotkey Trainer: on a building prompt, open Build and press an incorrect entry key. The main worker card should return automatically; retry Build followed by the correct building key. Repeat with Hero Abilities. Opening either submenu should not cost points. Also try the full correct sequence quickly without a mistake.

The earlier [alpha51 checks](ALPHA51-TESTING.md) cover dummy armor/resistance, transformation prompts and broader Build Order behavior. Automated tests cover orchestration; native training queue acceptance, tooltip display and command-card reset still require Warcraft testing.
