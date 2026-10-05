# Map source

`foundation-test.lua` is the temporary inspection harness used by the accepted `v0.0.1-alpha.5` foundation. It remains available only to reproduce that accepted build.

The successor infrastructure lives in `infrastructure/`. Both build modes assemble the shared modules in an explicit order. Development builds additionally include lifecycle and collision diagnostic modules; release builds omit them entirely.

Player-facing activity rules live in `activities/`. `assets/` contains packaged menu and overlay resources, `data/` contains replaceable source data, and `generated/` contains representations produced from that data.

Editable scripts remain authoritative here. `tools/build-infrastructure.cjs` embeds the selected bundle in compiled Lua and the World Editor custom-text trigger. Generated playable maps and validation reports belong in `outputs/`.
