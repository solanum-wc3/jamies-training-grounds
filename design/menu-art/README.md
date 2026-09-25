# Successor menu artwork

The PNG files in this directory are the editable source artwork supplied for successor menu cards and the full-size menu frame. Card art remains separate from button backgrounds, titles, status text and hover treatment so those layers can be changed independently.

`tools/prepare-menu-art.py` crops each composition to a readable 2:1 card image without distorting it, creates a matching white alpha-mask hover layer, and writes DXT5 textures under `src/assets/menu/`. It combines `menu-frame-source.png` with a near-opaque black field for the full menu backdrop.

Cropping choices prioritize the recognizable subject on the right half of each card.
