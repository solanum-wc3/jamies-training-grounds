# Gargoyle Surround — text review

Current player-facing text. Formatting markers are preserved as written in the
source. Edit the text blocks directly. Bracketed placeholders describe changing
values, rather than words displayed literally. No new progression points are
implied by the sections in this review document.

## Skill Training menu

Button: **Gargoyle Surrounds**

Tooltip:

```text
Turn flying Gargoyles into a ground surround with Stone Form.
```

## Briefing

Title: **Gargoyle Surrounds**

```text
Since Gargoyles are flying units, they do not obstruct the movement of ground units. Their {Button: Stone Form} changes this: once they land as statues, they occupy space like ordinary ground units.

In this, you can practice surrounding units using Stone Form.

Check the {Button: Quest Log} for precise instructions!
```

Buttons: **Start Training**, **Back**. When opened during an exercise:
**Resume**, **Exit** also appear. Start Training has no tooltip.

## Main quest

Title: **Gargoyle Surrounds**

Icon: Stone Form

```text
Flying Gargoyles can overlap ground units because they have no ground obstruction. This changes immediately when they use {Button: Stone Form}.

Use your hero or casters to stop or slow the target, move the Gargoyles into position around all four sides, and then turn them into statues. The target must be blocked in all four cardinal directions.

Tip: If you have selected only Gargoyles and give them a {Term: Move} command on the ground, they will bunch up. If you then give them smaller {Term: Move} commands nearby, four of them will form a diamond formation, perfect for establishing a surround.

Press the {Button: Squares} button to compare the flying and Stone Form states. A tiny box appears immediately once you activate Stone Form, and becomes larger once the Gargoyle hits the ground. The tiny one alone can be enough to box in a target, by blocking snapping points on the navigation grid.
```

## Setup selection and progression

Setup names, in order:

1. Dread Lord
2. Crypt Lord
3. Necromancers
4. Lich
5. Frost Wyrm
6. 6 Gargoyles
7. 4 Gargoyles
8. Naga Sea Witch
9. Pandaren Brewmaster
10. Forsaken Paladin

Each setup runs against **Grunt**, then **Demon Hunter**.
The setup panel also has a **Close** button.

## In-exercise display

There is no opening instruction message.

Countdown: **3**, **2**, **1** (gold).

World labels: **START** (green), **FINISH** (red).

Status line (setup name in gold):

```text
[Setup name]  vs [Runner name]   Still [0–100]%
```

Toolbar: **Menu**, **Setups**, **Next**, **Redo**, **Pause** / **Unpause**,
**Squares** / **Squares: On**. Squares cycles through off, boxes and dots,
then boxes, dots and the finer grid.

## End cards

Success title (green):

```text
SURROUND COMPLETE
```

After surrounding the Grunt:

```text
The Grunt stayed fully surrounded.
Next: Demon Hunter.
```

After surrounding the Demon Hunter, with another setup remaining:

```text
The Grunt and Demon Hunter were surrounded with this setup.
```

After the final setup:

```text
You completed every Gargoyle setup.
```

Failure title (red):

```text
RUNNER ESCAPED
```

Failure detail, depending on the cause:

```text
The runner crossed the finish line.
```

```text
The runner was killed before it was surrounded.
```

Fallback failure detail:

```text
The runner reached the finish line.
```

End-card buttons: **Redo**, **Menu**, plus a progression button on success.
Progression button:
**Next Round**, **Next Setup**, or **Finish**. Failure repeats the current round.
