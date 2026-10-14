# Quest explanation hint

The hint appears only once during an exercise session. The shared help state is
carried through Redo/Next/Back, and discarded when starting a new exercise from
the briefing.

- Body Blocking: five consecutive Redo presses on the same runner. Advancing
  to another runner resets this count.
- Surrounds and Gargoyle Surrounds: failure and Redo each add one to the streak.
  Success resets it. Advancing through Next does not count as Redo.

At the threshold, light-blue text at scale 1.85 (slightly translucent at alpha 230) appears at the bottom for ten seconds:

> You seem to be having some trouble. Try reading the Quest Log for an explanation of what to do!

At the same time as the text appears, an arrow anchors directly to the native `UpperButtonBarQuestsButton` and points upward to it. It
blinks three times (0.3 seconds on/off), then remains visible for twenty seconds.
Frames and timers belong to the active exercise scopes. Redo carries the
remaining hint timing into the replacement run. Opening an exercise menu hides
the hint; leaving the exercise disposes it. Presentation is rebuilt after load.
