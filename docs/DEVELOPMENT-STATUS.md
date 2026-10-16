# Current checkpoint: v0.2.1

Updated 16 October 2026. The user explicitly authorized publishing the fixes-only v0.2.1 as the latest release. Source is promoted from `codex/0.2.1-fixes` into main; Demo is reserved for v0.3.0 and remains recoverable on `codex/demo-mode` at `1f2997f`.

The release contains Heroes scene ownership/early cleanup and level controls, legal custom Surrounds skills/free points and Finish navigation, Body Blocking movement data, countdown-bound stage/round labels, stable empty-tooltip suppression, Build Order's idle start/three-second countdown, and the nil-owner terrain cleanup guard. Demo runtime/catalogue/brush/menu changes are excluded; Heroes shared control is self-contained.

Installed/public map: `Jamies-Training-Grounds-v0.2.1.w3x`, 4,431,795 bytes, SHA256 `a7feab8a9613c82df79fbd3851990bd9f11a1d3f5e895edd0345cce81f6118a3`. Source/data checks, 45 non-Demo fixtures and packaging pass; an isolated rebuild matches exactly. User publication authorization does not imply every [native regression check](0.2.1-TESTING.md) was re-run. The two generic download routes use separate identical attachments for Hive and Warcraft3Gym.

## Source and distribution

- Original release commit/tag: `5a78bc5` / `v0.2.0`.
- Corrected preview source: `7fe7e30`, following the original tag on main. The user explicitly authorized replacing both 0.2.0 downloads without creating 0.2.1; Git history and the original tag were preserved.
- Current public map: `outputs/Jamies-Training-Grounds-v0.2.1.w3x`, SHA256 `a7feab8a9613c82df79fbd3851990bd9f11a1d3f5e895edd0345cce81f6118a3`.
- Generic/latest and versioned downloads were verified against that map. The installed public map matches it. See [release record](RELEASE-STATUS.md) for links, sizes and the original artifact hash.
- Development builds can include local audit bindings from ignored `work/`; clean checkouts use empty defaults. Their hashes need not match another developer's diagnostic build. Ordinary Hotkey practice uses the player's native bindings.

## Accepted implementation and remaining boundaries

Five tutorials and ten exercises/demonstrations are included. Shared tutorial transitions, scoped cleanup, popup layout and result presentation are documented in the [tutorial standard](TUTORIAL-STANDARD.md) and [activity catalogue](ACTIVITIES.md). The Heroes shared-control sound cause and replacement-scene blight cleanup were verified through focused native tests.

Reflex Training remains WIP. Arbitrary Shift-queued worker sequences are not faithfully replayed by Mining Build Order. Native-menu and save/load interactions remain engine-sensitive; release acceptance is not exhaustive proof of every combination. Player-facing clean text export, persistent statistics and multiplayer support remain deferred. See [release boundaries](RELEASE-STATUS.md#content-and-boundaries).

The release passed 45 Lua fixtures, generated-data/build-input checks and release/development packaging validation. The preview correction passed image conversion, archive validation and a direct comparison showing only the two browser preview members changed. Documentation maintenance checks are distinct from new in-game acceptance.

Maintenance, 16 October 2026: completed alpha records were archived and current guides refreshed. Local document links and historical-content preservation checks pass; isolated release/development packaging passes, and the rebuilt release is byte-identical to the published map. No gameplay or authoring inputs changed, so this cleanup needs no additional Warcraft test pass.

## Next work

Demo implementation is paused on its preserved branch for v0.3.0. The user's [roadmap](ARCHITECTURE-TODO.md#next-version-content-direction), [Demo Mode assessment](DEMO-MODE-PORT-REVIEW.md), [Unit Comparison assessment](UNIT-COMPARISON-PORT-REVIEW.md) and [observer/handoff plan](OBSERVER-HOTSEAT-PLAN.md) remain the preparation references for future work. Agree on an approach before implementation; keep the single working folder and at most three user-chosen topics.

## Historical investigations

[0.2.0 archive](archive/v0.2.0/README.md) retains alpha test lists, dated reviews and [the complete pre-cleanup status record](archive/v0.2.0/DEVELOPMENT-HISTORY.md). Their unresolved findings describe their original dates; current conclusions live in the release and activity guides.
