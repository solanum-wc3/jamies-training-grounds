# Alpha 31 native gathering report

Read `CustomMapData/JTG-Economy-Orders.pld` at Economy step 17, active race Orc.

- All five gold Peons had current order 0 and were visible. Four latest Harvest requests returned false; one returned true but had no current order by export.
- All seven lumber Peons also had current order 0 despite accepted Harvest requests.
- Peons retained native Harvest (`Ahar`) and were not marked as constructing.
- Their target was the existing neutral-passive mine at (4160, -5696), unhidden, unpaused, with 12,360 gold remaining.
- Human workers were also idle after their earlier ownership handoff. The Human mine had 12,390 gold remaining.
- Night Elf and Undead workers retained Harvest order 852018. Their occupied mines demonstrate why a false order return alone does not prove failure.

This identifies a handoff/restoration problem affecting both Orc resource tasks, but does not establish which native event cancels or rejects them. Placement or a depleted/paused mine does not explain the recorded failure.

Next revision moves work restoration after all vision changes and adds two bounded idle-worker retries at 0.25 and 0.75 seconds, protected against stale race visits. No ongoing Harvest loop is added. Diagnostics retain a bounded order-event history, handoff samples, worker pause state and mine visibility to identify any remaining failure.
