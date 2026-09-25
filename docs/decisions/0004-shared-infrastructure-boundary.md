# Decision 0004: Port shared infrastructure before activities

- Status: Accepted
- Date: 2026-09-24

## Context

The v0.92 map combines shared navigation with large exercise-specific dispatch chains, custom Info/Quest replacement behavior, and a persistent profile. Porting those pieces together would couple the successor menu to unfinished activities and preserve the main source of customization and cleanup difficulty.

The accepted alpha.5 map already provides the terrain, lobby, loading screen, preview/minimap behavior, native interface, and fog defaults required for the next stage.

## Decision

Build a shared successor layer on the exact accepted alpha.5 archive before migrating any exercise or tutorial.

The permanent layer owns the four-category menu, Patch Notes, Credits, the disabled Player Stats placeholder, the activity registry, one-session controller, shared toolbar, and in-memory result boundary. Every activity receives a fresh ownership scope and may advertise its own capabilities. Reset disposes the complete run and creates a new instance. Exit disposes it and restores the catalogue that launched it.

Planned activities appear as disabled catalogue entries. A hidden diagnostic activity proves lifecycle behavior but is not project content. The native Quest window and F9 remain available. The legacy profile, custom Info button, exercises, and camera tutorial are outside this port.

## Consequences

- Activities can share controls and services while keeping their own rules and interface choices.
- Cleanup can invalidate stale callbacks and dispose registered resources in reverse order.
- The existing v0.92 profile is neither loaded nor overwritten.
- The first playable candidate can validate navigation and lifecycle behavior without confusing a diagnostic with a migrated exercise.
- Body Blocking or Reflexes remains a separate next migration, followed later by the camera tutorial.
