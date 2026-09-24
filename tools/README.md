# Project tools

`build-foundation.cjs` creates the current playable foundation from the preserved Twisted Meadows reference map. It changes only the designated northeastern practice district, map metadata, the temporary test harness, and the files required for the lobby preview. It fails if the reference-map hash or expected binary layouts change.

`foundation-minimap.py` updates the matching region of the minimap and preserves the remaining pixels. Run it after the build script's `--prepare` step and before the final build.

Temporary investigation files remain in `work/` and are excluded from version control. Generated maps and validation reports remain in `outputs/`.
