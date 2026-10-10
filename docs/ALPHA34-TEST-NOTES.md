# Alpha 34: gold gathering and native worker icon

- The latest trace shows all five gold Peons idle at export. Four reject Harvest despite a visible, unpaused mine. The fifth enters briefly, runs native resume-harvesting, and later becomes idle. Lumber now works.
- Human/Orc gold tasks now use the contextual Smart order (right-click on the mine), allowing native gather/return handling instead of forcing Harvest. Existing vision-before-work ordering and bounded handoff retries remain. This is a candidate fix requiring native validation, not proof of the carried-resource cause.
- The map-wide `IdlePeon` skin override is removed. Camera retains its scoped Peon icon. Economy no longer changes the player's race preference when switching bases; unit ownership, faction colors and restricted vision still switch.

Test Orc gold gathering, Back/Continue, and a later return to the Orc base. If the miners still stop, run `-economy-orders` again. Check that a Night Elf UI retains its default idle-worker icon outside Camera, including after leaving Camera.
