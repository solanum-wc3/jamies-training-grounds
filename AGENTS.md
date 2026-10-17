# Project workflow

## Roles and planning

- The user is the project manager and gameplay designer. They decide intended Warcraft III mechanics, priorities, milestones and gameplay acceptance. The assistant implements those decisions, explains technical tradeoffs and maintains recoverable development history.
- Keep at most three user-chosen topics in active implementation. Work on one concrete task at a time in the user's single working folder; do not introduce parallel worktrees. Other topics are planning/preparation only until the user activates them. Do not start a fourth implementation topic or silently replace an active topic; let the user choose what to finish or park. Use the user's existing milestone planning rather than creating a second management process.
- For tasks beyond small text, timing or position changes, first explain the closest working references, rough implementation mechanics, likely main focus or uncertainty, and automatic versus in-game verification. Wait for the user's feedback before implementation. An already approved approach need not be approved repeatedly; continue authorized routine details.
- Inspect the closest working tutorial/exercise and shared helpers before designing a solution. Consult legacy behavior where relevant. Explain necessary differences before inventing another Warcraft-specific workaround. Investigate related cases when a reported bug suggests a category-wide problem.
- Prefer native Warcraft functionality before adding runtime overrides. Account for packaged object-data changes as well as runtime calls when explaining or diagnosing setup. For placement problems, verify the real foundation's pathing and building footprints before changing timing. Do not retain experimental staggering merely to mask an unexplained hitch.
- Avoid unrelated changes and unnecessary refactoring. Preserve existing gameplay unless a change is requested. Ask about unclear gameplay intent rather than silently substituting another mechanic.

## Existing guidance and project files

Preserve and follow [CONTRIBUTING.md](CONTRIBUTING.md), the [architecture](docs/ARCHITECTURE.md), [activity guide](docs/ADDING-AN-ACTIVITY.md), [tutorial standard](docs/TUTORIAL-STANDARD.md) and [build/test guide](docs/BUILD-AND-TEST.md). This file adds the session workflow; it does not replace those detailed rules. Explicit user instructions take precedence.

- `src/activities/` owns activity behavior; `src/infrastructure/` owns shared systems. Maintained design/data inputs are authoritative for their generated counterparts. Use the documented generators and preserve the user's edited scripts, formatting tags, paragraph breaks and progression boundaries.
- `reference/` contains immutable source maps and historical references. Generated maps/reports belong in ignored `outputs/`; temporary investigations belong in ignored `work/`. A playable alpha is not a substitute for a source checkpoint.
- Update current documentation when behavior changes; preserve dated historical evidence as history. Avoid duplicate documentation and checklists.

## Git and checkpoints

- Treat `main` as the stable, working baseline. Before significant changes, inspect the branch, working tree, recent commits and applicable instructions.
- Never discard, silently alter, stage or commit unrelated uncommitted work. Review the diff and use explicit paths or reviewed hunks when staging.
- Use a feature branch for substantial features, risky experiments or work likely to need rollback. Use the `codex/` prefix unless requested otherwise. Small straightforward fixes do not automatically need another branch.
- If substantial work already exists uncommitted on `main`, explain the state and preserve/checkpoint it before taking on another substantial feature. Do not reset, stash or bundle unrelated work merely to obtain a clean tree.
- Commit coherent progress at meaningful checkpoints with clear messages explaining what changed and why, plus relevant checks or limitations. Avoid trivial-edit commits, but do not leave long or risky sessions without useful checkpoints. WIP commits are acceptable on feature branches; outstanding engine tests must remain explicit.
- Follow session-specific restrictions on commits. Never merge into `main`, rewrite history, force-push or perform destructive Git operations without approval. Commit approval does not authorize a merge, push or public release.

## Testing and acceptance

- Test Warcraft III behavior rather than assuming it. Distinguish code inspection, automated/native-mock checks and actual in-game observations. Explain what still needs Warcraft testing and provide focused steps.
- Run checks appropriate to the change. For substantive Lua changes, normally run `pnpm run check:lua`, `pnpm run test:reliability`, relevant generators/fixtures and packaging validation. Documentation-only changes need content and diff review rather than an unrelated full gameplay test run. See the build guide for prerequisites.
- Check text formatting as well as wording: tags, blank lines, narration boundaries, labels, tooltips and briefing layouts. Identify visual checks that require Warcraft.
- Written code or a passing build is not gameplay acceptance. Report states honestly: implemented, checks passed, awaiting in-game testing, or user accepted. Ask for confirmation before treating a significant milestone as complete or merging it into `main`.
- At a milestone handoff, briefly summarize behavior and affected files, checks passed, remaining in-game tests, branch and relevant commit IDs (or say uncommitted), and known limitations. Small fixes need shorter reports.

## Recovery and binary precautions

- Preserve useful history. Investigate relevant commits and the last accepted build when a regression appears; suggest a safe recovery strategy.
- Prefer a revert commit or a new branch from an earlier checkpoint. Explain the consequences and obtain approval where required. Never silently discard work to resolve a problem.
- Warcraft map files and other binary assets cannot always be merged like source. Avoid parallel edits to the same binary across branches where possible. Never silently choose one side of a binary conflict; discuss what would be retained or lost.
- Prefer rebuilding playable maps from maintained source/assets. Preserve foundation maps, scoped cleanup, ownership, camera, native-menu and save/load behavior.
- Fixed-arena cleanup uses the one-time starting-terrain baseline captured before activities begin. Keep scene ownership and live blight-source protection; do not recapture modified arena terrain as its original state. Outside the cached areas, preserve the existing scoped snapshot behavior.
- Validate maintenance builds in an isolated `work/` output directory. Never overwrite a distributed milestone with different contents under its existing version. When an alpha is requested, use a new version, validate it and identify the exact output/installed map.
- Do not change patch-note versions or release links as an unrelated side effect. Approved non-alpha releases follow the existing procedure for both generic and versioned downloads.
- At every public release, append download-counter snapshots before publication and after public-link verification with `tools/snapshot-downloads.py`. Commit `docs/DOWNLOAD-COUNTS.json` and its generated Markdown table. Preserve prior observations as a timeline, including exact per-version/per-asset counts. Distinguish downloads of versioned files from each version's total across all routes; identify timestamps and never describe link counters as unique players or verified website referrals. When taking a later download update, append a new snapshot instead of replacing the previous observation.

## Keep it lightweight

This is a solo map project. Use judgment: branches, documentation, tests and commits should reduce risk and make continuation easier. Do not create them for procedure's sake. Leave a brief account of the current checkpoint and outstanding engine tests at the end of substantial work so the next session can continue safely.
