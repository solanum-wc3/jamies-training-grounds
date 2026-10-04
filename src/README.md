# Map source

`foundation-test.lua` is the temporary inspection harness used by the accepted `v0.0.1-alpha.5` foundation. It remains available only to reproduce that accepted build.

The successor infrastructure lives in `infrastructure/`. Both build modes assemble the shared modules in an explicit order. Development builds additionally include `diagnostics.lua`; release builds omit that module entirely.

Editable scripts remain authoritative here. `tools/build-infrastructure.cjs` embeds the selected bundle in compiled Lua and the World Editor custom-text trigger. Generated playable maps and validation reports belong in `outputs/`.
