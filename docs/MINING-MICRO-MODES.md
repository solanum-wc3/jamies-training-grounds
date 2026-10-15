# Mining Micro modes

After choosing Human or Orc, choose One Minute, Unlimited or Base Build. Unlimited retains
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

Base Build has no time limit. It gives the player 500 Gold / 150 Lumber and
removes the five-worker training limit, allowing base construction and extra
workers. The two reference lanes retain their original setup. One Minute and
Unlimited still start at zero resources with the original worker limit.

Base Build ends when a fifth currently assigned gold worker actually enters the
player's mine, not when the mining order is issued. Assigned workers retain
their role during ordinary gold drop-offs; movement, construction and other
tasks clear it. The entry check uses the native hidden-worker state near that
mine. The end card freezes the run and shows elapsed time, gold/lumber gathered,
expected loss, recovered gold and percentage mitigated. Gold loss and recovered
gold per ten seconds are the measured totals multiplied by `10 / elapsed`;
the percentage uses the same expected-loss denominator as One Minute.

All modes show an enlarged purple **YOU** heading and the player's live gold
percentage relative to the five-worker reference above the player's mine.
Each lane now has three trees rotated with its hall/workers. The two additions
are no closer to the hall than the original tree. Presentation rebuilding
recreates the labels without restarting mining, construction or the clock.

Native acceptance: test both races and all four rotations; confirm the labels
fit, resource spending does not alter mining totals, the fifth-worker finish
fires on entry, and trained units/unfinished structures disappear on exit.
The automated fixture covers these orchestration paths with explicit mocks;
actual mine-entry behavior remains a Warcraft check.

Body Blocking shows Runner x/y; Surrounds, Gargoyle Surrounds, Windwalk Pop and
Bat Splitting show Setup x/y in light blue for five seconds. Visits carry through
Redo/Next/Back during a run and reset on a new launch from the briefing. In
Surrounds the index counts army setups, so the second runner for the same army
does not repeat the label.
