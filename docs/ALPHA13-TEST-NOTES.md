# 0.1.2 alpha 13

## Dodging

The briefing now branches into Disjoining (Abilities, Attacks) and Avoiding (Area, Devour). Artillery is no longer a top-level choice; its catalogue and diagnostics remain available for research.

Selection tooltips separate cast point or attack wind-up from projectile speed, fade duration, known protection duration and native area values. AbilityData's Cast1 field is no longer universally added to cast point; Blizzard and Rain of Fire list their wave interval separately. Unmeasured transformation delays are identified as such. Death Coil and area target restrictions explain disabled choices, including air/ground and organic-target restrictions. Existing orb/Ensnare matchup restrictions remain. Timing alone does not disable a method.

Enemy tint: yellow waiting, red wind-up, green fired. Dodger tint: green ready, red casting, yellow activating/fading, green active. Native spell events drive casting phases; actual invisibility drives completion of a fade. The on-screen phase labels distinguish ready from active. Attack wind-up colours use estimated base animation timing, not a measured native projectile-launch timestamp. Green is not a universal immunity indicator.

Test Back/Resume/Exit and Redo from both branches; check disabled tooltips for flying units against Shockwave versus Carrion Swarm and Undead against Death Coil; compare Wind Walk and potion fade colours; check normal ranged attacks and helper-based dodges. Existing scoring remains unchanged.

## Development-only base workspace

Choose Learn to Play → 4. The Economy. One Peasant, Peon, Acolyte and Wisp spawn beside the existing Tavern. The workspace provides resources, food capacity, researched upgrades and map vision. All author-created units/buildings are cleaned up on exit/restart while original map units are preserved; borrowed resources and research restore on cleanup.

Type `-export-layout` before leaving to write `Documents/Warcraft III/CustomMapData/JTG-Economy-Layout.pld`. It contains short CSV records for the workspace's player-owned units and buildings: rawcode, x, y, facing and player. The exporter only writes data; never execute the preload file to import it. Preserve an export when building work should be retained.

The regular alpha does not include the workspace or measurement tools. Both builds passed module/compiled Lua syntax, archive roundtrip, unchanged-member/foundation checks, development boundary and shared lifecycle/result/menu checks. Synthetic tests additionally cover phase changes, native-handle event matching, navigation restoration and workspace placement/export/ownership; visual behaviour and native building placement need in-game testing.
