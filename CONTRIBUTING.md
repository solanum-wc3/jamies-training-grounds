# Contributing

The lightweight session workflow, including the user's pre-implementation review for nontrivial mechanics, is defined in [AGENTS.md](AGENTS.md). Current development and outstanding acceptance checks are summarized in [development status](docs/DEVELOPMENT-STATUS.md).

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

## Reference-first changes

Before adding tutorial or exercise behavior, read the closest working activity and the shared lifecycle helpers. Follow [Tutorial standard](docs/TUTORIAL-STANDARD.md) and [Adding an activity](docs/ADDING-AN-ACTIVITY.md). Compare differences before introducing engine workarounds, especially for native gathering orders, ownership, camera moves, menu handoff and cleanup.

Keep generated data consistent with its maintained input. Run the relevant scripted checks and packaging validation, then report separately what still needs native Warcraft III testing. A mocked native call passing is not evidence that the engine accepts its target or order.

Do not overwrite a distributed milestone during maintenance validation. Use the builder's `--output-dir=work/maintenance-build` option for isolated checks. Do not silently change release or patch-note versions as part of a documentation cleanup.

## Release download links

When completing an alpha cycle and publishing the next non-alpha version, update both the generic latest-map attachment and the precisely versioned attachment, then point the README's top download link to the versioned file. Follow [the release procedure](docs/RELEASE-STATUS.md#completing-an-alpha-cycle), including verification of both downloads. Alpha outputs do not advance these links.
