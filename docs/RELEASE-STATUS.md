# Release status: v0.1.2-beta1

Released 10 October 2026. The release map is `outputs/Jamies-Training-Grounds-v0.1.2-beta1.w3x`; it contains no development modules. Patch notes remain headed `v0.1.2` in [CHANGELOG](../CHANGELOG.md).

## Validation

- 21 Lua regression files passed before packaging.
- Release and development Lua assemblies passed syntax checks (23 and 31 modules).
- All nine release checks passed: module syntax, compiled syntax, archive roundtrip, unchanged member identity, foundation hash, development boundary, shared lifecycle, result cards and menu layouts.
- The user confirmed the alpha36 gathering fix in Warcraft and reported the earlier regression acceptance checks passing before beta1 packaging. Beta1 changes the version label from that tested release candidate.

Synthetic checks establish command routing and lifecycle contracts. They do not prove native pathfinding, frame stacking or every possible Dodging matchup.

## Current boundaries

- Four tutorials and eight exercises are playable; future tutorial/training cards remain placeholders.
- Hotkey Setup’s player-facing file export button and export narration are disabled. Native Preload output wraps and can alter arbitrary text. Development `.pld` exports are diagnostic records parsed as text, not clean user documents.
- Save/load reconstructs presentation without replaying world actions. Long-term player statistics are deferred.
- Native upper-bar buttons have no custom opening frame-event hooks. The paused custom-picker/native-menu interaction remains engine-sensitive; see [native menu handoff](NATIVE-LOG-HANDOFF.md). Overall user acceptance is recorded above, not a guarantee about every mouse/hotkey route.
- Timing measurements and exceptions are retained in the [0.1.2 archive](archive/v0.1.2/README.md). Projectile outcomes use native events and bounded inference; Warcraft exposes no general projectile enumeration.

## Distribution and later changes

Generated maps and reports are ignored by Git. Preserve the distributed beta1 artifact; documentation cleanup does not replace it. Build a new version for subsequent player-visible or packaging changes. Current source may include maintenance changes made after beta1.

For future releases, test only changed behavior and relevant interruption paths after automated checks pass. Repeat broad acceptance when shared lifecycle, navigation or persistence changes justify it.

Maintenance verification on 10 October 2026: obsolete Camera quest textures and their preparation/package entries were removed. All remaining packaged assets have runtime references. Isolated release/development builds passed all nine checks, all 21 regression files passed, and artwork preparation passed its DXT5 decode check. The distributed beta1 map hash was unchanged.

## Public download convention

The repository is public and `v0.1.2-beta1` is published as a GitHub Release. Its attached `Jamies-Training-Grounds.w3x` is the preserved release artifact, verified against the public download.

The fixed link is [Download the latest non-alpha map](https://github.com/solanum-wc3/jamies-training-grounds/releases/latest/download/Jamies-Training-Grounds.w3x). Each future non-alpha release must attach the public map under that exact filename and become GitHub's latest release. Beta versions qualify for this link and are published as ordinary GitHub Releases while retaining their beta version names. Alpha versions must be marked as pre-releases, which GitHub excludes from `/releases/latest`. Upload the map before publishing a release so the fixed link has its asset available.
