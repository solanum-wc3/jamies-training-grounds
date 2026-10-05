# Changelog

This file records player-visible changes in tested project versions. Development reasoning belongs in commit messages and `docs/decisions/`.

## v0.1.0 — Training and shared-system milestone (2026-10-05)

- Added Surrounds Skill Training with standard and custom unit compositions.
- Expanded Windwalk Pop with racial Hard Mode and Counterplay courses.
- Added obstruction-square, snap-point and navigation-grid visualization to relevant exercises.
- Standardized exercise controls, result cards, briefing pages and race-specific catalogues.
- Separated public release builds from development builds and added automated lifecycle and collision diagnostics.
- Standardized Mining Micro arena geometry and expanded the Power Building selector.

## v0.0.11 — Surrounds (2026-10-04)

- Added Surrounds Skill Training.
- Improved map script structure.

## v0.0.10 — Hotkey Setup (2026-10-02)

- Added the Hotkey Setup tutorial and CustomKeys exports.

## v0.0.9 — Windwalk Pop (2026-10-02)

- Added Windwalk Pop training, Hard Mode and Counterplay.

## v0.0.8 — Unit Controls (2026-10-01)

- Added the Unit Controls tutorial and optional tutorial topics.

## v0.0.7 — Mining Micro (2026-09-29)

- Added Mining Micro training for Human and Orc workers.

## v0.0.6 — Camera tutorial (2026-09-29)

- Added the Camera tutorial, covering essential camera controls and navigation.
- Added guided demonstrations, checkpoints, Topics and supporting Quest information.

## v0.0.2-alpha.31 — Menu and shared infrastructure (2026-09-25)

- Established the successor-project repository structure.
- Recorded the initial modular-map and text-first tutorial direction.
- Added the four-category Training Grounds menu with Patch Notes, Credits, and visible planned-content placeholders.
- Added independent activity sessions, reverse-order resource cleanup, stale-callback protection, shared Restart and Training Menu controls, and an in-memory result boundary.
- Deferred Player Stats and legacy profile persistence; the existing v0.92 profile path is never read or written.
- Added a hidden lifecycle diagnostic for reset, exit, callback, resource, and camera-restoration testing.
- Corrected diagnostic camera-angle restoration, scene fog reset, and shared button-event routing after the first runtime test.
- Replaced the diagnostic Footman's temporary yellow tint with a status-only timer counter.
- Added native hover tooltips to active menu controls with compact translucent-grey text fields; planned entries without artwork and disabled entries remain tooltip-free.
- Preserved the complete v0.92 custom menu-button artwork set and its hover-frame definitions for the successor menu redesign.
- Added illustrated standard-button card prototypes for Body Blocking, Bat Splitter, Gold Mine Micro, AoW Creeping, Demo Mode and Unit Comparison.
- Enabled illustrated prototype cards and their descriptive hover tooltips for visual testing without starting an activity.
- Corrected mouse routing so decorative card and tooltip layers no longer interrupt the underlying button hover state.
- Enlarged and inset illustrated-card labels, raised submenu Back buttons, and refined the root-menu title and lower-button spacing.
- Isolated illustrated-card input in transparent hit targets and returned delayed display to Warcraft's native tooltip mechanism to remove hover feedback loops.
- Increased illustrated-card label size again and raised the root-menu title and instruction line.
- Replaced the failed alpha-zero hit targets with visual-free button frames, restored immediate native tooltips, and corrected illustrated-card draw order.
- Removed custom artwork hover and press effects after runtime testing showed that their frame events destabilized card input; cards now rely on the regular Warcraft button alone.
- Replaced illustrated-card experiments with the legacy native tracked-hover control and its `IGNORETRACKEVENTS` highlight layer.
- Made that native control the sole interactive card layer so its display-only background, artwork, text, and border cannot intercept hover.
- Removed tooltips from category and information-panel Back buttons; native tooltips remain immediate on supported controls.
- Restored illustrated cards to ordinary Warcraft buttons with non-interactive artwork and labels layered above them.
- Moved native tooltips to a fixed position above the bottom-right interface and added a gold border.
- Replaced merely disabled card overlays with FDF visual children marked `IGNORETRACKEVENTS`, leaving the regular button as the sole mouse target.
- Made tooltip height follow the amount of descriptive text while retaining a fixed width and bottom-right anchor.
- Corrected illustrated-card FDF inheritance so the complete regular-button child structure is retained.
- Replaced the reconstructed tooltip textures and edges with Warcraft's active tooltip background, border, and standard information-text template while retaining the elevated menu-safe layer.
- Removed the runtime-failing custom FDF dependency; illustrated cards now use ordinary script-created buttons, direct backdrop artwork, and each button's built-in text frame.
- Restored the proven elevated tooltip implementation with Warcraft's tooltip background and a thinner muted border.
- Left-aligned and reduced illustrated-card labels by targeting the regular button's known built-in text child when its name is unavailable.
- Repositioned tooltips to the native lower-right area and restored a translucent near-black field with a softer border.
- Cleared button focus directly after clicks instead of disabling and re-enabling controls, avoiding the observed release-time cursor jump.
- Inset illustrated-card labels and replaced the tooltip field with a compact rounded blue-black panel based on the native Lumber-tooltip reference.
- Removed post-click focus clearing so a visible tooltip remains continuous when its button is released.
- Rebuilt the tooltip field from nine pieces to preserve its rounded corners, with a brighter translucent interior and stronger gold outline.
- Restored post-click focus clearing for a stable cursor and moved tooltip visibility to explicit button enter/leave events so click release no longer controls it.
- Removed the custom enter/leave event path after runtime testing showed that it reintroduced cursor jumps; native hover now resumes immediately after release-time focus clearing.
- Reduced tooltip corner rounding, doubled the brighter gold border, and made the interior slightly brighter and less transparent.
- Removed the explicit post-release tooltip visibility override and returned to the earlier cursor-stable native button path.
- Reduced the tooltip border from six pixels to five and restored visible background transparency.
- Slightly darkened the tooltip's gold border and raised its background transparency without changing button interaction behavior.
- Deferred scripted button actions until the next timer callback so Warcraft can complete its mouse-release transition before panels or activity state change.
- Removed explicit release-time focus clearing and slightly increased tooltip background transparency.
- Added temporary top-level A/B buttons that differ only by whether `FRAMEEVENT_CONTROL_CLICK` is registered, isolating the reported Warcraft cursor bug from all callback logic.
- Increased tooltip background transparency slightly and shifted its border toward a warmer, more orange gold.
- Confirmed in runtime testing that the no-event `GLUETEXTBUTTON` remains stable while registering an empty click event reproduces the cursor flicker.
- Added a temporary `SIMPLEBUTTON` event comparator and increased tooltip background transparency by five alpha points.
- Removed the runtime-created `SIMPLEBUTTON` comparator after its unconstrained hit area blocked custom and native interface input; retained the confirmed A/B event diagnostic and tooltip transparency.
- Removed the completed A/B diagnostic controls after confirming Warcraft's registered `GLUETEXTBUTTON` event bug.
- Added the legacy-proven hidden edit-box focus sink after real menu actions so Enter chat and native/gameplay hotkeys resume immediately.
- Delayed the hidden focus sink slightly so buttons that remain visible cannot reclaim focus after the sink runs.
- Corrected the supplied illustrated asset from Body Blocking to Surrounds, renamed its source and generated texture, and shortened the button title from Surround Training to Surrounds.
- Replaced the iterative in-game development log with two concise, dated milestone entries in a scrollable Patch Notes panel.
- Changed Training Menu into a reversible browsing state that preserves the active activity and exposes Return to Training.
- Changed restart and explicit activity exit to remask the entire playable map rather than only the registered arena.
- Replaced the unsupported green menu backdrops with a near-black translucent field and a supplied full-size Human masonry frame.
- Removed the surrounding backdrop from the in-activity Restart and Training Menu controls.
- Kept the native Quest window and F9 path available. No exercise or tutorial is included in this infrastructure candidate.

## v0.0.1-alpha.5 — Preview and loading-screen test

- Removed the menu-minimap marker layer so gold mines, buildings, and player starts no longer cover the browser artwork.
- Added the legacy map's loading-screen model and original fullscreen texture as the temporary loading screen.
- Preserved the separate real terrain minimap used during loading and play.

## v0.0.1-alpha.4 — Foundation completion test

- Set the map author metadata to `Jamie & Solanum`.
- Replaced the Reforged browser minimap with the Arthas and Jaina thumbnail and restored the real terrain minimap at runtime.
- Made unexplored terrain fully black by default.
- Replaced generated arena texture patches with Twisted Meadows' original hand-authored ground-painting pattern while retaining the flattened district and raised boundary.

## v0.0.1-alpha.3 — Metadata and preview test

- Put the version number in the map-browser title and restored `Solo` as the suggested-player value.
- Removed lobby-panel author text and moved foundation credits into the Quest window.
- Restored race selection so the training map is not tied to Orc.
- Replaced the incorrect shield preview asset with the Arthas and Jaina artwork from the legacy training interface.
- Matched the legacy map's preview-flag behavior for thumbnail testing.
- Recorded that visibility, music, and race-specific presentation belong to individual activities.

## v0.0.1-alpha.2 — Foundation and lobby test

- Converted the custom-game lobby to one fixed Orc player slot.
- Added the permanent map name, description, credits, and a separate version/test line.
- Added the initial custom preview asset.
- Restored normal fog of war and unexplored-map masking.
- Reworked the northeastern practice district with varied grass and earth patches.
- Retained both empty arenas, the blocking perimeter, test units, chat commands, and native Quest window.

## Foundation test 01

- Created two empty practice spaces in the northeastern district of Twisted Meadows.
- Removed terrain objects and units only from the designated district.
- Disabled melee starting armies and victory conditions.
- Added a temporary movement, camera, and Quest-window test harness.
