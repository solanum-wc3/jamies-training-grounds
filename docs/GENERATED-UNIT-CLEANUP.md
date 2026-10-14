# Generated unit cleanup

The shared controller snapshots the world's original unit handles before an
activity starts. `ScopeTrackUnit` records each activity unit's owning resource
scope. Native summoned units inherit their summoner's scope, including summons
that themselves summon other units.

Native mount/dismount, Mirror Image and transformation abilities can produce
new handles without returning them to activity code. Their effect callbacks
schedule two bounded collection passes (next update and 0.1 seconds later).
New, untracked units of the caster's owner within 600 units inherit its scope.
Products discovered after that scope was disposed are removed immediately.
Ordinary spell casts do not trigger world enumeration.

On activity exit, the controller removes remaining untracked handles that were
absent from the original snapshot. This runs before scope finalizers restore
borrowed map units, so restored originals are preserved. Explicitly tracked
units remain the responsibility of their scope. This assumes the map's existing
single active activity model; unrelated background unit creation would need
explicit ownership rather than relying on the final orphan sweep.

Activity authors must track temporary actors through `ScopeTrackUnit`, using
an attempt scope when generated units must disappear on an in-session retry.
Custom replacement abilities need to be added to the replacement registry;
the exit sweep still covers unregistered products.

`tools/test-generated-unit-cleanup.lua` exercises summon inheritance, split
products, delayed products, stale callbacks and preservation of originals.
Live checks should include Hippogryph mount/dismount and summoned units across
Redo, Menu/Exit and switching exercises. Native replacement timing remains a
game-side acceptance check.
