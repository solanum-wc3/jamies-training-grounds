# Architecture work list

This is a loose planning list. Each package should receive its own playable
build and commit so Warcraft-specific regressions remain easy to isolate.

## 1. Development and release builds

Status: implemented and verified in game.

- Release builds omit development tools and diagnostic commands entirely.
- Development builds include the diagnostic module and are clearly marked.
- The development-only automated lifecycle check covers start, reset,
  replacement, exit, resource disposal and stale callbacks.

## 2. Shared activity lifecycle

Status: implemented and verified in game with the development-build automated
lifecycle check.

- The controller now runs semantic cleanup, disposes presentation and gameplay
  resources, and then runs a guaranteed final cleanup stage.
- Shared ownership helpers cover units, timers, triggers, frames, images,
  markers, quests, destructables, fog and borrowed state.
- Shared timers automatically stop stale callbacks while retaining every
  exercise's existing timing values.
- Hotkey Setup uses final cleanup to remove blight after its hidden dependency
  buildings have been removed.

## 3. Shared result cards and exercise controls

Status: planned.

- Standardize result-card layout and sizing.
- Share Replay, Retry, Next, Back and Menu behavior.
- Migrate exercises individually and validate each playable result.

## 4. Shared tutorial system

Status: planned alongside the Economy tutorial.

- Share page progression, narration, checkpoints, Topics, Continue, Back,
  Pause, Menu, save/load presentation rebuilding and cleanup.
- Migrate existing tutorials incrementally after the common system is proven
  by the Economy tutorial.

## 5. Project documentation and file cleanup

Status: planned as a collaborative review.

- Inventory design documents, generated files, obsolete scripts and historical
  implementation material.
- Agree which documents are authoritative before resolving contradictions or
  consolidating overlapping outlines.
- Archive useful history and remove only files that are confirmed obsolete or
  reproducible from the maintained source.
- Review old tutorial drafts such as `CameraTutorialScript_Current` against the
  implemented tutorial before deciding whether to merge, archive or remove
  them.

## Deferred: embedded CustomKeys data

Keep the current generated representation. Its files are easy to replace, and
reducing its embedded size offers too little benefit to justify complicating
that workflow.
