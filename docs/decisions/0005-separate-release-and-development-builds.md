# Decision 0005: Separate release and development builds

- Status: Accepted
- Date: 2026-10-04

## Context

Lifecycle checks, collision experiments and export commands are valuable while developing the map, but they add code, commands and failure paths that players should never encounter. Hiding diagnostic buttons would leave the underlying tools packaged and callable.

## Decision

Build two variants from the same maintained source. The release build excludes diagnostic modules and developer commands entirely. The development build appends those modules and identifies itself with a `-dev` suffix in both its filename and map-selection title.

The builder owns the explicit module boundary and validates that release output contains no development-only markers. Both variants use the same accepted foundation and player-facing activity modules.

## Consequences

- Public maps contain no dormant diagnostic interface or command path.
- Development tools remain easy to include without maintaining a separate map project.
- A feature is not considered release-safe merely because its button is hidden.
- Changes to shared source must still be tested in both variants.
