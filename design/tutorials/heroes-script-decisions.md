# Heroes tutorial draft decisions

Confirmed by the user:

- Arena1 (south) contains the altar/hero showcase; Arena2 (north) contains the demonstrations.
- Optional XP Numbers racial lists exclude heroes.
- The Hero XP display uses ten regular Paladins at levels 1–10. Level 1 uses the Arthas-with-hammer model; level 10 uses Arthas with Frostmourne. Intermediate levels use the regular Paladin model.
- Ground items appear once per distinct item, grouped by the smallest Twisted Meadows camp/drop group that can drop them.
- The XP circle marks the actual range: 1200-unit radius, 2400-unit diameter.
- Updated after alpha48: spawn the first Gnoll-task army together with its directions; no empty setup stop.
- Updated after alpha48: remove the first Mountain King level-5 trial. Subsequent revision: in the retained second trial, the level-5 King starts outside with the army; ask the player to attack with the entire army and bring both heroes inside the circle. The final trial leaves the King outside XP range.

`heroes-script.json` is the authoritative narration and scene plan; the build generates Lua from it. The corrected readable draft remains `heroes-script-draft.txt`; the original attachment is preserved.

The author subsequently requested the original 20%-per-level creep XP explanation in narration. The data snapshot retains native creep factors 80/70/60/50/0 percent; hero spell damage reduction is 30 percent; attribute growth is fractional and not exactly six points at every level. Actual XP distribution, skins, stock and UI behavior need the in-game acceptance pass in `docs/HEROES-TUTORIAL.md`.
