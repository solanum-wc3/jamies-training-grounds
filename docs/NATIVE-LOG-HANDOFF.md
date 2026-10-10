# Native Log opening behind custom menus

Observed by the user: from the root custom menu, Log opens behind it; after opening and closing F10 once, Log opens in front. This suggests native dialog initialization/stacking or the custom-menu handoff, but does not establish an engine cause.

The existing native Log click handler could queue the custom-menu suspension through a zero-delay game timer. If opening the native dialog pauses first, that timer cannot run until the dialog closes. The custom panel therefore stays visible over it.

Alpha 33 removes all frame-event registrations from the native upper-bar opening buttons. Alpha 31's mouse-down/up hooks were followed by a native regression: buttons depressed visually but played no sound and opened no dialog. Do not hook their frame actions again to hide custom menus.

Native hotkeys hand off synchronously, and the visibility monitor observes dialogs during running simulation. F10 has a key-up fallback for clients that consume key-down. There is no artificial F10 opening/closing or native frame reparenting.

Mouse opening while a custom picker pauses simulation still needs a separate solution: the visibility-monitor timer cannot run while paused. Restoring native button activation takes priority over hiding the custom overlay. The regression test verifies that upper-bar buttons have no custom frame-event hooks; it cannot verify native activation in Warcraft.

The isolated handler test verifies routing, not Warcraft's native frame stacking. In-game acceptance:

1. Fresh launch: click Log directly from the root menu, before opening F10; Log should be unobscured and closing it should restore the root menu.
2. Repeat from a category and an activity briefing. Test F12 too.
3. Repeat after opening/closing F10, and from a paused exercise.
4. Confirm F10 still opens normally, and neither returning from Log nor F10 unpauses an intentionally paused exercise.
