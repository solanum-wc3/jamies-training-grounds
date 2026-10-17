# Download snapshots

Release-time snapshots of cumulative GitHub asset download counters across all public releases, including prereleases. Drafts are excluded. Historical releases continue to contribute to later totals.

These are downloads through attachment routes, not unique players or proven referring sites. The generic route is used by Warcraft3Gym; before the separate Hive attachment existed it may also have been shared elsewhere. Versioned links likewise cannot identify the referring site. Verification/test downloads also count, and GitHub counter updates may lag.

No earlier release-time totals have been reconstructed. The JSON retains every asset ID, release, URL and count observed at each timestamp.

| Release checkpoint | Captured UTC | Hive | Generic / Warcraft3Gym | Versioned | Other | Total |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| v0.2.2 (before-publication) | 2026-10-17T02:11:16+00:00 | 43 | 246 | 216 | 0 | 505 |
| v0.2.2 (after-verification) | 2026-10-17T02:20:29+00:00 | 43 | 246 | 216 | 0 | 505 |

## Counts for each version at every snapshot

The Versioned column counts only the explicitly versioned file. Total includes that version's Hive and generic attachments too. Rows from different snapshots must not be added together.

| Captured UTC | Version | Hive | Generic / Warcraft3Gym | Versioned | Other | Total |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 2026-10-17T02:11:16+00:00 | v0.2.1 | 37 | 7 | 1 | 0 | 45 |
| 2026-10-17T02:11:16+00:00 | v0.2.0 | 6 | 26 | 32 | 0 | 64 |
| 2026-10-17T02:11:16+00:00 | v0.1.2-beta1 | 0 | 213 | 183 | 0 | 396 |
| 2026-10-17T02:20:29+00:00 | v0.2.2 | 0 | 0 | 0 | 0 | 0 |
| 2026-10-17T02:20:29+00:00 | v0.2.1 | 37 | 7 | 1 | 0 | 45 |
| 2026-10-17T02:20:29+00:00 | v0.2.0 | 6 | 26 | 32 | 0 | 64 |
| 2026-10-17T02:20:29+00:00 | v0.1.2-beta1 | 0 | 213 | 183 | 0 | 396 |

Detailed source: [DOWNLOAD-COUNTS.json](DOWNLOAD-COUNTS.json).

At each public release, run `python tools/snapshot-downloads.py --release vX.Y.Z --phase before-publication`, then repeat with `--phase after-verification` after all public links are checked. Commit both records; never replace old snapshots. For current live numbers, take a new snapshot rather than presenting these historical values as current.
