# Release status: v0.2.2

Publication and a fixes-only merge into main were explicitly authorized on 17 October 2026. The preceding [0.2.1 record](archive/v0.2.1/RELEASE-STATUS.md) is preserved. Demo remains on `codex/demo-mode` for 0.3.0 and is excluded from this release.

## Release artifact

- Map: `outputs/Jamies-Training-Grounds-v0.2.2.w3x`
- Size: 4,443,665 bytes
- SHA256: `0689d72bd6c8daa906445ce4cf4254d6d474c04e7db5e02e389b67c5bdd971fb`
- Maintenance candidate: `work/maintenance/022/Jamies-Training-Grounds-v0.2.2.w3x`; independent final build matches exactly.
- Source: fixes selected onto the stable 0.2.1 baseline on `codex/0.2.2-fixes`; the full Demo branch is preserved.

## Changes and validation

Repairs Heroes section-transition crashes and scope ownership, bought/dropped item cleanup, Items prerequisite placement and loading, Quest description layout, Hotkey neutral hiring/readiness/retry recovery and command labels/aliases, and Mining starting worker formation. Fixed arenas capture starting terrain once before menus; scene leases and blight-source guards remain. Items returns to synchronous native setup, with no standard-shop stock override or building invulnerability. Economy clarifies Human Farms provide 6 Food. The in-map patch note is dated 17 October 2026.

Passed: 46 non-Demo Lua fixture files, 33 release/50 development module assemblies, maintained/generated data, briefing/data/build-input checks, actual foundation pathing, download-history tests and release/development packaging. Both archives exclude Demo; final release bytes match the isolated candidate. The user accepted alpha31's remaining Items delay and declared the repair work complete. Existing native observations and reusable checks are recorded in [0.2.2 testing](0.2.2-TESTING.md); extraction is not a claim that every native combination was rerun.

## Known limits

A brief cursor flash on button release and remembered blight under fog remain parked visual issues. An accepted small Items stutter may remain. Reflex is WIP with further design parked. Five tutorials and ten exercises/demonstrations remain available; Demo is a placeholder in this release. Arbitrary queued Build Order sequences, observers/hotseating and Unit Comparison remain outside it.

## Downloads

Only the versioned map is promoted on GitHub. The generic Warcraft3Gym and Hive routes will advance through identical attachments when this release is published as latest.

- [Versioned v0.2.2 map](https://github.com/solanum-wc3/jamies-training-grounds/releases/download/v0.2.2/Jamies-Training-Grounds-v0.2.2.w3x)
- [Release page](https://github.com/solanum-wc3/jamies-training-grounds/releases/tag/v0.2.2)
- [Download timeline](DOWNLOAD-COUNTS.md): timestamped cumulative route totals and exact per-version asset counts; [JSON evidence](DOWNLOAD-COUNTS.json) retains every observation.

Publication and public-link hash verification are pending; record their result after upload.

## Public download convention

Each non-alpha release attaches `Jamies-Training-Grounds.w3x` for Warcraft3Gym, `Jamies-Training-Grounds-Hive.w3x` for Hive, and the versioned filename. All three contain identical map bytes. Separate asset counters distinguish downloads through the two generic routes; totals across releases require summing each filename's counters. Alpha builds never replace these routes. Release-mode packaging alone does not publish anything.

Only the versioned map link is promoted in GitHub's README, current download list and release description. Generic links are for their external sites. GitHub still automatically displays all uploaded assets on a release; this cannot be hidden per asset while retaining the existing generic download routes.

## Completing an alpha cycle

1. Attach the validated release map under all three filenames. Never substitute a development build.
2. Publish the release as GitHub's latest non-alpha release. Both generic links then advance without changing their URLs.
3. Update the README's versioned map and release-note links and current-release description; commit and push the release source/documentation.
4. Download all three public routes and verify their hashes against the validated release artifact. Provide all links to the user.

5. Append download snapshots with `python tools/snapshot-downloads.py --release vX.Y.Z --phase before-publication` before publishing and `--phase after-verification` after checking the links. Commit both `docs/DOWNLOAD-COUNTS.json` and `docs/DOWNLOAD-COUNTS.md`. Totals sum asset counters across all public releases; they describe routes, not unique people or confirmed referrers. Never overwrite historical snapshots or fabricate past release-time totals.

Preserve previous versioned releases and source history. This procedure requires the user's release authorization; it does not independently authorize publishing a new version.
