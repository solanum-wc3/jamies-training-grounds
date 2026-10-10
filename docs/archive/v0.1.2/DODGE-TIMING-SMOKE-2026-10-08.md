# First native timing smoke test

Read from `Documents/Warcraft III/CustomMapData/JTG-Dodge-Timing.pld`, modified 2026-10-08 at 14:22:53 local time. The original export is preserved in `work/dodge-measurements/smoke-2026-10-08/raw-export.pld`; recovered CSV/summary are beside it. There are 87 observations across five runs.

| Trial | Native evidence |
|---|---|
| Far Seer baseline | First attack start 0.24219 s; first recorded damage 0.89062 s. These occurred before the scheduled request, so this baseline is not a valid controlled-start measurement. |
| Wind Walk | Order accepted at 2.01562 s; enemy-observed invisibility first sampled at 2.61719 s, about 0.602 s later. This is a sampled state transition relative to the order, not a cast-point measurement. |
| Peon construction | Order rejected at 2.01562 s (`false:construction`); no construction-start event. |
| Zeppelin | Load order accepted at 2.01562 s; native loaded event at 2.23438 s, about 0.219 s later. |
| Invisibility Potion | Item order accepted at 2.01562 s; enemy-observed invisibility first sampled at 4.01562 s, 2.000 s later. One observation, not a calibrated general fade-duration claim. |

Warcraft truncated the long original Preload arguments. Leading event/time/detail columns survived, but trailing conditions and unit identities are incomplete. The importer now recovers each legacy line independently and explicitly marks the missing metadata. The full pass remains pending.

Corrections prepared after this run:

- Use `IssueBuildOrderById` with a small Orc Burrow south of the worker. The previous Great Hall placement north overlapped the existing helper Burrow. The export proves rejection, but does not identify which of the command or placement defects caused it.
- Report `construction_not_started` if the isolated build trial has no construction-start event.
- Keep every attacker paused until its scheduled request, including the baseline.
- Export numbered short chunks with a row-count manifest; reject incomplete chunked exports rather than silently importing corrupted metadata.

These corrections pass synthetic checks and development packaging; repeat the native smoke test before running the full batch.
