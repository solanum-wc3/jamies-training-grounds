# Release status: v0.2.1

Released 16 October 2026 on the user's explicit publication instruction. This is a fixes-only release; Demo Mode is reserved for v0.3.0. The previous release record is preserved in [the v0.2.0 archive](archive/v0.2.0/RELEASE-STATUS.md).

## Release artifact

- Map: `outputs/Jamies-Training-Grounds-v0.2.1.w3x`
- Size: 4,431,795 bytes
- SHA256: `a7feab8a9613c82df79fbd3851990bd9f11a1d3f5e895edd0345cce81f6118a3`
- Gameplay/source checkpoint before publication documentation: `6e92091`
- Source tag: `v0.2.1` at `188658b295606722cab3e130fd19bab87abf9bc7`, published from main; Demo's feature commits are not ancestors.

## Changes and validation

Heroes uses directly created presentation heroes with preconfigured shared control and removes its scenes before borrowed-state restoration. Grey level controls consume clicks; custom Surrounds heroes follow legal skill requirements and keep spare points. Surrounds Finish returns to its briefing. Body Blocking adds pawn movement data. Yellow stage/round labels accompany countdowns and repeat on Redo. Build Order starts with a three-second countdown and idle workers on both sides. Empty tooltip visuals are suppressed without detaching native frames; terrain cleanup tolerates removed-unit owners.

Source assembly (32 release/49 development modules), authored/generated data, clean build inputs, 45 non-Demo Lua fixture files and both packaging modes pass. A fresh isolated release build exactly matches the installed candidate. Both archives exclude Demo's factory, catalogue, brush and briefing asset. All three public downloads are verified against the release SHA256 before handoff.

Publication is authorized; it is not a claim that the assistant manually retested every engine behavior. Native hero initialization, input routing, cleanup/crash reproduction and countdown/menu/save-load interactions remain covered by [the regression checklist](0.2.1-TESTING.md).

## Content and boundaries

Five tutorials and ten exercises/demonstrations remain available, as listed in [the activity catalogue](ACTIVITIES.md). Demo remains a placeholder. Reflex Training remains WIP. Arbitrary Shift-queued Build Order sequences, persistent statistics and observers/hotseat remain outside this release. Development preload exports are diagnostic text, never executable scripts.

## Downloads

All three attachments contain identical release bytes, without development tools:

- [Versioned v0.2.1 map](https://github.com/solanum-wc3/jamies-training-grounds/releases/download/v0.2.1/Jamies-Training-Grounds-v0.2.1.w3x)
- [Release page](https://github.com/solanum-wc3/jamies-training-grounds/releases/tag/v0.2.1)

Publication verified 16 October 2026: release ID `415015638` is GitHub's latest non-prerelease. Public downloads through all three routes match the release SHA256 above. Asset IDs are `647481658` (versioned), `647481779` (Warcraft3Gym) and `647481873` (Hive). Main and the release tag were pushed; the previous release/assets and the deferred Demo branch remain intact.

## Public download convention

Each non-alpha release attaches `Jamies-Training-Grounds.w3x` for Warcraft3Gym, `Jamies-Training-Grounds-Hive.w3x` for Hive, and the versioned filename. All three contain identical map bytes. Separate asset counters distinguish downloads through the two generic routes; totals across releases require summing each filename's counters. Alpha builds never replace these routes. Release-mode packaging alone does not publish anything.

Only the versioned map link is promoted in GitHub's README, current download list and release description. Generic links are for their external sites. GitHub still automatically displays all uploaded assets on a release; this cannot be hidden per asset while retaining the existing generic download routes.

## Completing an alpha cycle

1. Attach the validated release map under all three filenames. Never substitute a development build.
2. Publish the release as GitHub's latest non-alpha release. Both generic links then advance without changing their URLs.
3. Update the README's versioned map and release-note links and current-release description; commit and push the release source/documentation.
4. Download all three public routes and verify their hashes against the validated release artifact. Provide all links to the user.

Preserve previous versioned releases and source history. This procedure requires the user's release authorization; it does not independently authorize publishing a new version.
