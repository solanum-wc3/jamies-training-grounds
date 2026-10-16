# Current checkpoint: v0.2.0

Updated 16 October 2026. Public release remains v0.2.0. The user requested a separate fixes-only v0.2.1 package, with Demo deferred to v0.3.0. The single working folder is on `codex/0.2.1-fixes`, based on `main`; complete Demo work remains recoverable on `codex/demo-mode` at `1f2997f`. No merge into main or publication of v0.2.1 has occurred.

The candidate contains Heroes scene ownership/early cleanup and level controls, legal custom Surrounds skills/free points and Finish navigation, Body Blocking movement data, countdown-bound stage/round labels, stable empty-tooltip suppression, Build Order's idle start/three-second countdown, and the nil-owner terrain cleanup guard. Its native-test checklist is [0.2.1 testing](0.2.1-TESTING.md). Demo runtime/catalogue/brush/menu changes are excluded. The Heroes shared-control initialization is self-contained in its existing presentation configuration helper.

The release candidate is installed as `Maps/Onboarding Project/Jamies-Training-Grounds-v0.2.1.w3x`, 4,431,795 bytes, SHA256 `a7feab8a9613c82df79fbd3851990bd9f11a1d3f5e895edd0345cce81f6118a3`. Lua assembly (32 release/49 development modules), data/build checks, 45 non-Demo fixtures and both packaging modes pass. Both archives were inspected for absence of Demo factory, catalogue, brush and briefing assets. Native acceptance remains pending. The separate Hive generic link is live on the existing public v0.2.0; future releases must include its dedicated attachment.

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
