# Native command-card selection comparison

Historical diagnostic record. Preserve the findings below; its alpha-specific setup is not the current exercise specification. See [Hotkey Trainer](HOTKEY-TRAINING.md) for current behavior and [development status](DEVELOPMENT-STATUS.md) before scheduling another audit.

Development alpha26 provides `-hotkey-selection-audit` during Hotkey Training.
Close chat after entering it. The sequence runs automatically for about four
minutes (alpha26: about two) and saves `JTG-Hotkey-Selection-Audit.pld` plus numbered batches in
Warcraft III's CustomMapData directory. It does not overwrite full-audit reports.

Alpha25 ran eight commands with both transition sequences, repeated three times:
Stop, War Stomp, Shockwave, Grunt, Steel Weapons, Healing Salve, Altar,
and Reincarnation ability choice. The baseline disposes the old context before
cancelling its command UI. The comparison cancels and clears selection while
the old source still exists, waits 0.5 seconds, then creates the next context.
Both use the same subsequent selection delay and key dispatch rules.

Alpha25 completed all 48 trials. In the last two repetitions, the original
sequence failed all eight entries; the new sequence activated all eight.
The first repetition was mixed. Alpha26 therefore runs only the new sequence
for three repetitions (24 trials), to verify it independently from the failing
baseline. Source selection was reported true throughout alpha25, while all
observed frame opacities remained 255. Selection alone was insufficient.

The report records the transition method, native action evidence, trainer
recognition, selected-source state, and each command button's opacity,
visibility and enabled state at dispatch. These frame properties alone do not
prove a command is available. A submenu entry is never dispatched unless its
opening event was received.

Keep the game foreground and do not click or double-click units during the
comparison, since that changes the selection state under investigation.
The existing `-hotkey-full-audit-end` command also ends this comparison.

Mock checks verify cancellation precedes disposal and both methods have equal
coverage. Native behavior remains unverified until the in-game reports return.
The normal trainer and full audit retain their current transition behavior
until this comparison provides evidence for changing it.

Alpha26 verification completed 24/24 activations (eight commands, three
repetitions). Six commands per repetition produced native execution events;
Shockwave and Altar produced activation events without a world target or
placement click. Alpha27 applies close-before-dispose to the full audit.
Normal play timing still needs a separate shorter-delay test: the diagnostic
0.5-second cancellation delay is a reliability baseline, not a final speed.
