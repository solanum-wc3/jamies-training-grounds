# Mining Micro modes

After choosing Human or Orc, choose One Minute or Unlimited. Unlimited retains
the existing three-lane practice. One Minute starts a 60-second countdown with
the gathering orders; pausing stops its progression.

The timed result uses gold earned in the same interval:

- Full income: five-worker reference lane.
- Baseline income: ordinary four-worker reference lane.
- Player income: accumulated gold gains in the controlled four-worker lane.
- Expected loss: full income minus baseline income.
- Recovered gold: player income minus baseline income.
- Percentage mitigated: recovered gold divided by expected loss, times 100.

The result also shows the player's accumulated lumber gains. It freezes the
workers at the end. Redo retains the selected mode; rotation retains it too.
If the reference gap is zero or negative, the percentage is shown as N/A.
Results may be negative or above 100%; they are not silently clamped.

Body Blocking shows Runner x/y; Surrounds, Gargoyle Surrounds, Windwalk Pop and
Bat Splitting show Setup x/y in light blue for five seconds. Visits carry through
Redo/Next/Back during a run and reset on a new launch from the briefing. In
Surrounds the index counts army setups, so the second runner for the same army
does not repeat the label.
