# Legacy menu assets

These files were extracted byte-for-byte from the authoritative `Jamie's Training Grounds v0.92.w3x` archive. `manifest.json` records the source archive hash, dimensions, sizes, purposes, and individual SHA-256 hashes.

The set contains all custom graphics referenced by the v0.92 training-path cards, course-card buttons, navigation-card background, hover state, menu wallpaper, and the compact upper control-button frame. Warcraft's built-in command-button icons are not duplicated here. The accompanying TOC and FDF files are included because they define the legacy cards' native tracked hover layer.

To reproduce the extraction:

```text
pnpm run extract:legacy-menu-assets -- <path-to-v0.92.w3x>
```

## Composition findings

- The two large training-path illustrations contain transparency, and `TrainingPathCardBorder.dds` is a separate mostly-transparent yellow border. They can be layered directly over a race-themed panel.
- The course-card textures are fully opaque 512×148 images. Their dark background and yellow border are baked into the same pixels as their character or building artwork.
- `TrainingCourseButtonHover.dds` supplies the shared hover highlight through `TrainingCourseButton.fdf`.
- `TrainingMenuBackground.dds` is a fully opaque 1280×512 black wallpaper.
- `UnitBlockActionButton.dds` is a transparent 512×152 compact reconstruction of the Human console's grey masonry and gold inner rim. The legacy map displays it at `0.088×0.026` behind each upper control icon and label.

For race-themed successor cards, keep these originals as provenance. Rebuild the card as separate layers: a race-specific Warcraft panel, extracted or newly prepared right-side artwork, yellow border, title text, and hover highlight. Applying a vertex-color tint to an original opaque course texture would also recolor its artwork.
