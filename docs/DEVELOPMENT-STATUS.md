# Current checkpoint: v0.2.0

Updated 16 October 2026. The release is accepted and published; source is on `main`. The user confirmed alpha60's final blight correction, then authorized release, merge and the subsequent map-preview replacement. No gameplay implementation is active as part of this documentation cleanup.

## Source and distribution

- Original release commit/tag: `5a78bc5` / `v0.2.0`.
- Corrected preview source: `7fe7e30`, following the original tag on main. The user explicitly authorized replacing both 0.2.0 downloads without creating 0.2.1; Git history and the original tag were preserved.
- Current public map: `outputs/Jamies-Training-Grounds-v0.2.0.w3x`, SHA256 `24c6f9ef71d6983b15ec6626e9e945d41d9649032b7c274827f8cfc38f2617ef`.
- Generic/latest and versioned downloads were verified against that map. The installed public map matches it. See [release record](RELEASE-STATUS.md) for links, sizes and the original artifact hash.
- Development builds can include local audit bindings from ignored `work/`; clean checkouts use empty defaults. Their hashes need not match another developer's diagnostic build. Ordinary Hotkey practice uses the player's native bindings.

## Accepted implementation and remaining boundaries

Five tutorials and ten exercises/demonstrations are included. Shared tutorial transitions, scoped cleanup, popup layout and result presentation are documented in the [tutorial standard](TUTORIAL-STANDARD.md) and [activity catalogue](ACTIVITIES.md). The Heroes shared-control sound cause and replacement-scene blight cleanup were verified through focused native tests.

Reflex Training remains WIP. Arbitrary Shift-queued worker sequences are not faithfully replayed by Mining Build Order. Native-menu and save/load interactions remain engine-sensitive; release acceptance is not exhaustive proof of every combination. Player-facing clean text export, persistent statistics and multiplayer support remain deferred. See [release boundaries](RELEASE-STATUS.md#content-and-boundaries).

The release passed 45 Lua fixtures, generated-data/build-input checks and release/development packaging validation. The preview correction passed image conversion, archive validation and a direct comparison showing only the two browser preview members changed. Documentation maintenance checks are distinct from new in-game acceptance.

Maintenance, 16 October 2026: completed alpha records were archived and current guides refreshed. Local document links and historical-content preservation checks pass; isolated release/development packaging passes, and the rebuilt release is byte-identical to the published map. No gameplay or authoring inputs changed, so this cleanup needs no additional Warcraft test pass.

## Next work

The user's [roadmap](ARCHITECTURE-TODO.md#next-version-content-direction), [Demo Mode assessment](DEMO-MODE-PORT-REVIEW.md), [Unit Comparison assessment](UNIT-COMPARISON-PORT-REVIEW.md) and [observer/handoff plan](OBSERVER-HOTSEAT-PLAN.md) are preparation, not activated features. Agree on an approach before implementation; keep the single working folder and at most three user-chosen topics.

## Historical investigations

[0.2.0 archive](archive/v0.2.0/README.md) retains alpha test lists, dated reviews and [the complete pre-cleanup status record](archive/v0.2.0/DEVELOPMENT-HISTORY.md). Their unresolved findings describe their original dates; current conclusions live in the release and activity guides.
