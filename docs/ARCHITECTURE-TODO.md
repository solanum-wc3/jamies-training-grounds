# Architecture work list

This is the maintained loose planning list. Completed implementation plans and runtime checklists live in [`archive/`](archive/README.md).

## Completed for v0.1.0

- **Development and release builds:** release maps omit developer tools; development maps include clearly separated diagnostics.
- **Automated lifecycle check:** verifies start, reset, replacement, exit, resource disposal, final cleanup and stale callbacks.
- **Shared activity lifecycle:** common ownership and cleanup cover gameplay and presentation resources, borrowed state and guarded timers.
- **Shared result cards and exercise controls:** common action dispatch, toolbar positions, result layouts and semantic heading colors.
- **Shared briefing and catalogue layouts:** common title, body, artwork, divider, choice and footer positioning; shared General / Race Specific menus.
- **First documentation cleanup:** current guidance was updated; completed plans, old checklists and the implemented Camera draft were archived.

## Next architectural package

### Shared tutorial system

Status: planned alongside the Economy tutorial.

- Share page progression, narration, checkpoints, Topics, Continue, Back, Pause, Menu, save/load presentation rebuilding and cleanup.
- Prove the system with the Economy tutorial.
- Migrate existing tutorials incrementally after the common system is stable.

## Later consolidation candidates

- Review exercise-specific timers for common countdown and elapsed-time helpers.
- Review cleanup code after more activities use the shared lifecycle; extract only patterns that remain genuinely identical.
- Add reusable selectors for future unit, building and hero-selection pages based on the Power Building and Custom Surrounds grids.
- Add a reusable guided camera-tour system if competitive-map lessons are pursued.
- Extend automated lifecycle coverage when new shared resource types appear.

## Deferred

- **Embedded CustomKeys data:** keep the current replaceable generated representation.
- **Long-term player statistics:** keep Player Stats unavailable until a separately versioned persistence design has clear player value and migration rules.
