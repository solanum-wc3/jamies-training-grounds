# Alpha 33: native menu activation

Native upper-bar mouse hooks were removed after the report that clicks animated the buttons but neither sounded nor opened dialogs. Keyboard handoff and visibility monitoring remain.

Test Menu and Log with the mouse from the main custom menu, a tutorial, and active Dodging. Confirm the native sound and dialog opening, then Return/OK and reopening. Check F10/F12 too. Quests should remain intentionally disabled where no quest is available.

Also test from Dodging's paused custom picker. Native activation should take priority; overlay hiding while paused remains an engine acceptance check, not a confirmed fix.
