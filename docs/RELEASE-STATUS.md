# Release status: v0.2.0

Released 16 October 2026 after the user accepted alpha60 and authorized release and merge into main. The approved in-map patch note and CHANGELOG carry the same date. Gameplay matches the accepted alpha60 source; release packaging changes the version/date and excludes development tools.

## Release artifact

- Map: `outputs/Jamies-Training-Grounds-v0.2.0.w3x`
- Size: 4,427,781 bytes
- SHA256: `24c6f9ef71d6983b15ec6626e9e945d41d9649032b7c274827f8cfc38f2617ef`
- Accepted source checkpoint before version/date changes: `73fcbcd` (alpha60)
- Source milestone/tag: `v0.2.0` on `main`

## Validation and acceptance

Preview correction, 16 October 2026: the user explicitly requested overwriting both published 0.2.0 map attachments rather than creating 0.2.1. Only `war3mapMap.blp` and `war3mapPreview.tga` differ from the original release; gameplay, metadata and the in-game terrain minimap are byte-identical. The authored PNG and generated assets are maintained separately from the immutable foundation. BLP mip/decode, TGA roundtrip and map packaging checks passed. The original release artifact was 4,207,717 bytes, SHA256 `c1b9fea3590313e707bd401d2b3d7c577a2ea469011175eb540b8fe2cffb3aca`; its original tag/source history is retained, with the artwork correction following on main.

- All 45 Lua regression fixtures passed, including late native blight writes, overlapping source/non-source scenes and replacement guards.
- Release/development Lua source assemblies passed syntax checks (32 and 49 modules).
- Maintained briefing, Heroes data and clean-checkout build-input checks passed.
- Release packaging passed all nine archive, foundation, syntax, lifecycle, result/menu and development-boundary checks.
- Native acceptance: the user confirmed alpha59's sound/control and presentation-building changes, then confirmed alpha60's blight correction works. The user authorized this release after those checks. Earlier native tests and limitations are retained in [development history](archive/v0.2.0/DEVELOPMENT-HISTORY.md).

Mock checks establish orchestration, not exhaustive Warcraft rendering, pathing or save/load coverage. The release does not claim every possible interaction was manually retested.

## Content and boundaries

- Five tutorials and ten playable exercises/demonstrations; other cards remain placeholders. See [activity catalogue](ACTIVITIES.md).
- Reflex Training remains explicitly WIP.
- Mining Build Order mirrors economic commands and worker job changes; faithful replay of arbitrary Shift-queued worker sequences remains a known limitation.
- Player-facing text-file exports remain disabled; development preload exports are diagnostic text, never executable scripts.
- Save/load restores presentation without replaying world actions. Long-term player statistics and observers/hotseat are not part of this release.

## Downloads

All three release attachments contain the identical public map, without development tools:

- [Versioned v0.2.0 map](https://github.com/solanum-wc3/jamies-training-grounds/releases/download/v0.2.0/Jamies-Training-Grounds-v0.2.0.w3x)
- [Latest non-alpha map](https://github.com/solanum-wc3/jamies-training-grounds/releases/latest/download/Jamies-Training-Grounds.w3x)
- [Hive-specific latest map](https://github.com/solanum-wc3/jamies-training-grounds/releases/latest/download/Jamies-Training-Grounds-Hive.w3x)
- [Release page](https://github.com/solanum-wc3/jamies-training-grounds/releases/tag/v0.2.0)

Published and verified 16 October 2026: both public downloads match the SHA256 above, GitHub's latest release is `v0.2.0`, and the release tag points to `5a78bc5b026286f0ac54e89f165fd44e362a92cb`. The source branch was fast-forwarded into `main` and pushed. Previous versioned assets remain available; the generic latest route advances with this release. Generated maps and reports remain ignored by Git. The immutable foundation is not modified.

The previous beta1 validation record is preserved in [the archive](archive/v0.1.2/RELEASE-STATUS.md).

## Public download convention

Each non-alpha release attaches `Jamies-Training-Grounds.w3x` for Warcraft3Gym, `Jamies-Training-Grounds-Hive.w3x` for Hive, and the versioned filename. All three contain identical map bytes. Separate asset counters distinguish downloads through the two generic routes; totals across releases require summing each filename's counters. The release becomes GitHub's latest and the README's precise versioned link advances. Alpha builds never replace these routes. Release-mode packaging alone does not publish anything.

The user requested the separate Hive route on 16 October 2026. It was added to the existing v0.2.0 release as asset 647421103, checksum-identical to the public map; the original attachments were preserved. Future public releases must carry this filename too.

## Completing an alpha cycle

Standing user instruction, confirmed 11 October 2026: when an alpha cycle finishes and a new non-alpha version is released, update both download routes as part of that release.

1. Attach the validated public release map three times to the new GitHub Release: `Jamies-Training-Grounds.w3x`, `Jamies-Training-Grounds-Hive.w3x` and `Jamies-Training-Grounds-<version>.w3x`. All attachments must contain identical bytes. Do not substitute a development build.
2. Publish that release as GitHub's latest non-alpha release. The fixed `/releases/latest/download/Jamies-Training-Grounds.w3x` URL then resolves to the new map without changing the URL.
3. Update the download link at the top of the project README to `/releases/download/<version>/Jamies-Training-Grounds-<version>.w3x`, with the precise version in its visible label. Update the current-release description accordingly and push the documentation change.
4. Verify all three public downloads against the validated release artifact and provide the versioned and both generic links to the user.

Ordinary alpha outputs do not replace either public download route. Keep previous versioned releases available. This procedure does not independently authorize starting a new release; apply it when the user asks to finish the alpha cycle and release the next version.
