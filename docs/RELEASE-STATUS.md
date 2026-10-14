# Release status: v0.1.2-beta1

Released 10 October 2026. The release map is `outputs/Jamies-Training-Grounds-v0.1.2-beta1.w3x`; it contains no development modules. Patch notes remain headed `v0.1.2` in [CHANGELOG](../CHANGELOG.md).

Current development is tracked separately in [alpha49 status](DEVELOPMENT-STATUS.md). The figures below describe the published beta1, not the current checkout.

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

## Completing an alpha cycle

Standing user instruction, confirmed 11 October 2026: when an alpha cycle finishes and a new non-alpha version is released, update both download routes as part of that release.

1. Attach the validated public release map twice to the new GitHub Release: `Jamies-Training-Grounds.w3x` and `Jamies-Training-Grounds-<version>.w3x` (for example, `Jamies-Training-Grounds-v0.1.2-beta1.w3x`). Both attachments must contain identical bytes. Do not substitute a development build.
2. Publish that release as GitHub's latest non-alpha release. The fixed `/releases/latest/download/Jamies-Training-Grounds.w3x` URL then resolves to the new map without changing the URL.
3. Update the download link at the top of the project README to `/releases/download/<version>/Jamies-Training-Grounds-<version>.w3x`, with the precise version in its visible label. Update the current-release description accordingly and push the documentation change.
4. Verify both public downloads against the validated release artifact and provide both links to the user.

Ordinary alpha outputs do not replace either public download route. Keep previous versioned releases available. This procedure does not independently authorize starting a new release; apply it when the user asks to finish the alpha cycle and release the next version.
