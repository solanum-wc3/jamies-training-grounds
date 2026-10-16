# Documentation guide

Published baseline and current source: **v0.2.0** (16 October 2026). See [release status](RELEASE-STATUS.md) for validation and [development status](DEVELOPMENT-STATUS.md) for the accepted checkpoint. Archived reports describe earlier builds and are not current specifications.

## Current guidance

- [0.3.1 fixes-only testing](0.3.1-TESTING.md) — candidate without Demo; native acceptance outstanding

- [Development workflow](../AGENTS.md) and [contribution rules](../CONTRIBUTING.md)
- [Development status](DEVELOPMENT-STATUS.md) — current checkpoint, build and outstanding tests
- [Release status](RELEASE-STATUS.md) — validation, limitations and distribution
- [Activity catalogue](ACTIVITIES.md) — playable content and placeholders
- [Build and test](BUILD-AND-TEST.md) — dependencies, packaging and native acceptance
- [Architecture](ARCHITECTURE.md) and [backlog](ARCHITECTURE-TODO.md)
- [Adding an activity](ADDING-AN-ACTIVITY.md) — reference-first implementation workflow
- [Tutorial standard](TUTORIAL-STANDARD.md) — progression, checkpoints, ownership and scene setup
- [Economy layout](ECONOMY-TUTORIAL-LAYOUT.md) — current construction, gathering and ownership rules
- [Dodging test bench](DODGE-TEST-BENCH.md) — current modes and diagnostic tools
- [Native menu handoff](NATIVE-LOG-HANDOFF.md) — implementation and engine-sensitive behavior
- [Project files](PROJECT-FILES.md) — source/generated/reference boundaries
- [Collision research](COLLISION-OBSTRUCTION-RESEARCH.md)
- [Foundation acceptance](FOUNDATION-ACCEPTANCE.md) and [decisions](decisions)

## Current development

The [next-version roadmap](ARCHITECTURE-TODO.md#next-version-content-direction) records the user's deferred content plans. [Unit Comparison review](UNIT-COMPARISON-PORT-REVIEW.md) and [Demo Mode review](DEMO-MODE-PORT-REVIEW.md) assess the legacy modules; neither port is underway.

[Observer/control-handoff plan](OBSERVER-HOTSEAT-PLAN.md) records the proposed future multiplayer proof and rollout. It is deferred, not implemented.

[Release status](RELEASE-STATUS.md) records the accepted checkpoint. [The 0.2.0 archive](archive/v0.2.0/README.md) preserves completed consolidation reviews and alpha test handoffs.

[Reflex Training (WIP)](REFLEX-TRAINING.md) describes crowd layouts, race selection, identification stages and buff/debuff recognition. [Hotkey Trainer](HOTKEY-TRAINING.md) describes current-layout command recognition, practice stages, prompt preparation and the audited command catalogue. [Heroes](HEROES-TUTORIAL.md) describes the authored lesson and optional displays. All three are included in v0.2.0; their guides retain native testing details.

## Editable work and inventories

[Economy script work file](ECONOMY-TUTORIAL-SCRIPT-WORK.md) remains available for author edits. [Tutorial text review](TUTORIAL-TEXT-REVIEW.md), [Bat Splitting text review](BAT-SPLITTING-TEXT-REVIEW.md), [Gargoyle Surround text review](GARGOYLE-SURROUND-TEXT-REVIEW.md), [Dodging tooltip review](DODGING-TOOLTIP-REVIEW.md), [Surrounds ability audit](SURROUNDS-ABILITY-AUDIT.md) and [timing inventory](DODGE-TIMING-INVENTORY.md) are working or generated snapshots. Editing them does not automatically update the map; maintained JSON/Lua remains authoritative.

## Historical evidence

[archive](archive/README.md) retains completed implementation plans, candidate checklists and measurement results. The [0.1.2 archive](archive/v0.1.2/README.md) includes the standardization audits, alpha reports and native timing measurements. The [0.2.0 archive](archive/v0.2.0/README.md) contains the subsequent alpha51–60 handoffs, investigations and pre-cleanup guide snapshots. Keep dated findings and limitations intact; current conclusions belong in current guidance.

[Melee prerequisites](MELEE-PREREQUISITES.md) inventories the four racial tech trees used to prepare individual Hotkey Trainer prompts.

The shared scene transition/reset contract and position-check hooks are documented in [TUTORIAL-STANDARD.md](TUTORIAL-STANDARD.md). The authored Heroes tutorial, optional demonstrations and acceptance checks are described in [HEROES-TUTORIAL.md](HEROES-TUTORIAL.md).
