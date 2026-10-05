# Contributing

## Change history

Keep each commit focused on one coherent change. A useful commit message explains:

- what behavior changed;
- why the change was needed;
- any Warcraft III limitation or workaround involved;
- how the result was checked.

Do not mix unrelated interface, terrain, exercise, and tooling changes in one commit.

## Code documentation

Names and structure should make ordinary behavior understandable. Comments should explain design intent, engine constraints, cleanup requirements, synchronization rules, or surprising workarounds. Avoid comments that merely repeat a line of code.

Shared systems and activities should document their ownership and lifecycle. Every activity is expected to define setup, start, reset, cleanup, and exit behavior where applicable.

## Playable builds

Generated `.w3x` files and validation reports belong in `outputs/` and are not committed during ordinary development. Temporary extraction and investigation material belongs in `work/`. Historical reference maps may be stored under `reference/`. Tested public milestones should be attached to a tagged GitHub release.

## Documentation

Current guidance belongs in the documents listed by `docs/README.md`. Completed plans and superseded candidate checklists should be moved to `docs/archive/` rather than left beside authoritative documents or silently rewritten as current behavior.
