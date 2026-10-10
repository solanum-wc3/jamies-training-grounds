# Alpha 35: native gold delivery recovery

The latest export includes manual orders and a successful return visit. Manual Smart orders use 851971, matching scripted Smart. On the second visit, all five scripted Smart requests are accepted; native return (852017) and gathering (852018) cycles continue for all five. A single-Peon export is not needed.

This disproves an incorrect order ID as the explanation. It does not by itself prove carried gold as the cause of the initial rejection.

When a Human/Orc gold worker rejects its mine order, the script now tries native `resumeharvesting` on the nearest living owned building with gold drop-off ability `Argl`. This lets a loaded worker deliver before continuing its native mining cycle. Empty workers and working miners retain their existing routes. No resource values, cargo, abilities or units are reset.

`-economy-orders` now records whether the initial mine order was accepted and distinguishes the intended mine from the actual delivery-order target.

Test a fresh Economy session without manually ordering Peons. Check the first Orc visit, then Back/Continue. If workers remain idle, export once at that point. The mock test verifies the rejected-mine/accepted-return branch and preserves an active delivery order; native cargo behavior still requires this in-game check.
