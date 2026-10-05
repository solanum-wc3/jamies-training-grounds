# Decision 0006: Standardize activity ownership and cleanup

- Status: Accepted
- Date: 2026-10-04

## Context

Exercises originally created and removed units, timers, frames and borrowed state through activity-specific paths. Reset, menu browsing, replacement and save/load could interrupt an activity at different moments, making leaks and stale callbacks difficult to prevent consistently.

## Decision

Use one controller session and explicit ownership scopes. Activities perform semantic cleanup while their resources still exist; shared scopes then dispose presentation and gameplay resources in reverse order; finalizers and `afterCleanup` run after disposal. Session-guarded callbacks become inert as soon as reset, replacement or exit invalidates their session.

Borrowed state is restored through registered reversals. Shared tracking covers every resource type currently used by activities. A development-only automated lifecycle test exercises start, reset, replacement, exit, disposal, final cleanup and stale callbacks.

## Consequences

- Activities keep their own rules and timing while sharing interruption safety.
- New resource types need a tracking or restoration strategy before widespread use.
- Cleanup code is divided by when it must run rather than accumulated in one exit function.
- The automated check catches infrastructure regressions but does not replace activity-specific runtime testing.
