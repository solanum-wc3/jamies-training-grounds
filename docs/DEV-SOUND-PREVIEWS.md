# Selected sound previews

Development builds add Sound Previews to Credits. The browser contains only
the user's 52 selections, split across five pages with twelve reusable buttons.
The footer has previous/next arrows and a centered page number. Stop ends the
current preview; Credits returns to the Credits page. Selecting a sound shows
the user's note above the buttons.

Source data: `src/data/dev-sound-previews.json`. Native names, file references
and sound labels were matched against the installed AbilitySounds/AnimSounds
tables. AIamTomes and DoomTarget normalize the supplied spelling. Explicit
numbered variations have separate buttons. RockChunkDeath previews one of its
three native recordings.

Run `tools/prepare-dev-sound-previews.py` after editing the selected list.
The generated catalogue and browser module are included only by the
development build. Release assembly excludes the menu and sound list.

The browser tries the selected recording's FLAC/WAV paths, then uses its
native label for a single sound where a filename is unavailable. A numbered
variant must resolve its exact file; it never silently substitutes a random
recording. The current archive reader did not resolve most older audio paths,
so actual playback still requires in-game checking. Sound-table association
and mocked sound calls do not establish audible playback.

Audio is loaded on click as a non-looping, non-positional interface sound.
The previous handle is stopped and released before another starts. Leaving
the menu, changing pages or rebuilding the UI stops the preview. Standard
button sounds are suppressed on the preview and Stop buttons. No audio is
copied into the map, and none of the suggested menu/exercise assignments is
applied automatically.

`tools/test-sound-preview.lua` checks coverage, page reuse, notes, specific
variants, missing-file feedback, native-label fallback and audio cleanup.
Live acceptance: try a sound on every page, including FanOfKnives hit 1/2,
PeonRepair 1/2/3, CarrionSwarm 1/2/3 and AIamTomes; switch sounds quickly and
leave Credits while a long sound is playing. Repeat after a save/load.
