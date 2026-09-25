# Map source

`foundation-test.lua` is the temporary inspection harness used by the accepted `v0.0.1-alpha.5` foundation. It remains available only to reproduce that accepted build.

The successor infrastructure lives in `infrastructure/`. The build assembles its modules in this explicit order: core, catalogue, interface, diagnostics, and bootstrap. The hidden diagnostic activity is development support rather than playable project content.

Editable scripts remain authoritative here. `tools/build-infrastructure.cjs` embeds the same assembled bundle in compiled Lua and the World Editor custom-text trigger. Generated playable maps and validation reports belong in `outputs/`.
