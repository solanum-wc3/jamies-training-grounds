# Alpha 36: Economy initial gathering setup

The alpha35 report has seven working lumber Peons, one cycling gold Peon and four idle gold Peons. The return-and-resume fallback was rejected by the four idle miners. Initial Smart requests were accepted, but later native Stop events occurred before the first Orc ownership handoff. This does not establish ownership transfer as the original cause.

Comparison with Camera found that Economy spawned workers in a ring around the hall instead of using the exported working positions. Its startup also reissued gathering orders, and used contextual Smart for gold instead of Camera's explicit Harvest order.

Economy now creates its workers at the exported positions, after all initial buildings; uses direct Harvest for both resources; and preserves gathering orders through the start/welcome sequence. Back/Topics still leave actual gatherers in place and restore idle/missing workers near the hall. The native delivery fallback remains available when a gold Harvest request is rejected.

Diagnostics now include worker positions in the order trace and sample all races at 0.25, 1, 3 and 5 seconds after startup. These samples are scoped to the activity and only present in development builds. They do not issue commands. The trace retains up to 1024 rows.

Validation: Lua fixtures check initial authored worker positions, buildings before workers, no replacement of an established Human gathering order during start/welcome, ownership restoration and native delivery fallback. Fixtures cannot verify engine pathfinding or mining.

In-game: start a fresh Economy tutorial, wait at least five seconds, then visit Orc without manually commanding Peons. Check five gold miners and lumber workers. If any are idle, use `-economy-orders` before manual intervention. Then test Back/Continue while gathering.
