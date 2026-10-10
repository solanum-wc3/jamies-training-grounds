# Menu artwork sources

The PNG files here are editable source artwork. `tools/prepare-menu-art.py` converts them to textures under `src/assets/menu/`; the build's asset list determines which textures are packaged. Button backgrounds, art, titles and hover treatment are separate UI layers.

Each card has its own crop or containment recipe. Full-composition briefing images are generated separately from cropped button cards. Sizes and placement are controlled jointly by the preparation recipe and UI frames; do not apply a universal 2:1 crop to every source. Menu panels use native racial frame resources.

The obsolete Camera settings screenshot sources and textures were removed when those quests switched to native Reveal and Peon icons. Generated hover and older tooltip textures retained for review are listed in [Project files](../../docs/PROJECT-FILES.md); their existence does not mean they are included in the map.
