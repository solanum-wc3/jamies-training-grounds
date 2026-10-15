# Mining Micro modes

After choosing Human or Orc, choose One Minute, Unlimited or Build Order. Unlimited retains
the existing three-lane practice. One Minute starts a 60-second countdown with
the gathering orders; pausing stops its progression.

The timed result uses gold earned in the same interval:

- Full income: five-worker reference lane.
- Baseline income: ordinary four-worker reference lane.
- Player income: the native cumulative gold-gathered total since entering the exercise. Starting resources, purchases and refunds do not count as gathered income.
- Expected loss: full income minus baseline income.
- Recovered gold: player income minus baseline income.
- Percentage mitigated: recovered gold divided by expected loss, times 100.

The result also shows the player's accumulated lumber gains. It freezes the
workers at the end. Redo retains the selected mode; rotation retains it too.
If the reference gap is zero or negative, the percentage is shown as N/A.
Results may be negative or above 100%; they are not silently clamped.

Build Order has no time limit. Both bases start with 500 Gold / 150 Lumber and
can train additional workers. Its five-worker reference is removed entirely;
only the player and a four-worker reference remain. One Minute and Unlimited
retain three lanes, zero starting resources and the original worker limit.

The reference mirrors building, training, research, upgrade and worker resource
assignments using native orders. Placement is translated into its own base.
New buildings and trained units are paired by construction site or producer/
completion sequence. Economic commands wait when their native order is rejected;
later economic commands wait behind them. The reference is never topped up.
Repeated harvest clicks on the same resource do not produce reference orders.
Copied training stays pending until a native training-start (or completion)
event confirms it. An accepted-but-unconfirmed order retries only when its
producer is idle and has no active training. Queued requests are kept distinct,
so repeatedly training the same worker type does not collapse into one request.
The mode selector's rectangular buttons expose their authored hover tooltips.
Workers resume their previous gathering job after a reference build completes.
The mirror is paused with the activity and all actors belong to its scope.
Rally mirroring handles explicit Set Rally Point and building right-click orders.
At player worker completion, native rally getters determine its gathering job,
which is applied when the reference counterpart is available. Ground rallies
are translated into reference-base coordinates. Selection modifiers do not
control mirroring; orders are tracked per actor. Shift-queued worker orders
are not yet faithfully preserved: the mirror does not capture the native
queue flag and its pending list must not be described as equivalent.

Build Order ends when the fifth gold worker actually enters the player's mine,
not when the order is issued. Its end card shows Total Gold mined, Total Lumber
mined, Time Elapsed, and a larger golden Extra Gold mined line. Extra Gold is
player gathered income minus reference gathered income, including negative
results. Both totals use native cumulative gathering counters, so initial money,
spending and refunds do not contaminate the comparison. The earlier per-ten-second
loss breakdown is replaced in this mode; One Minute's calculation is unchanged.

Both Build Order owners receive ordinary melee hero limits (three total,
one per type) and one first-hero token. Changes are restored on exit. No Castle
is spawned and native second-/third-hero tier requirements are retained.

All modes show a bright red **YOU** heading at the same size as the counter
text. The heading and its three counter lines are indented slightly to the
right of the reference-lane text. The player's live gold percentage relative
to the five-worker reference appears above the player's mine.
Each lane now has three trees rotated with its hall/workers. The two additions
are no closer to the hall than the original tree. Presentation rebuilding
recreates the labels without restarting mining, construction or the clock.

Native acceptance: test both races and all four rotations; confirm mirroring,
queued unaffordable actions, first-hero recruitment, cancellation and the labels
fit, resource spending does not alter mining totals, the fifth-worker finish
fires on entry, and trained units/unfinished structures disappear on exit.
The automated fixture covers these orchestration paths with explicit mocks;
actual mine-entry behavior remains a Warcraft check.

Body Blocking shows Runner x/y; Surrounds, Gargoyle Surrounds, Windwalk Pop and
Bat Splitting show Setup x/y in light blue for five seconds. Visits carry through
Redo/Next/Back during a run and reset on a new launch from the briefing. In
Surrounds the index counts army setups, so the second runner for the same army
does not repeat the label.
