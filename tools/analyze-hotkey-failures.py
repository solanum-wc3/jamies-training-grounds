"""Report command-level audit failures and distinguish binding gaps from setup evidence."""
import json
from collections import defaultdict
from pathlib import Path
root=Path(__file__).resolve().parents[1]
data=json.loads((root/'work/hotkey-full-alpha28-summary.json').read_text())
catalog={entry['id']:entry for entry in json.loads((root/'src/data/hotkey-catalog.json').read_text())['entries']}
context={'Alam','Amed','Amel','Aco3','Ambt','Aabs','Astd','AUcb','Adro'}
groups=defaultdict(list)
for key,rows in data['prompts'].items():
    if any(row['outcome'] in ('native-and-trainer','activation-only') for row in rows): continue
    entry=catalog[key]
    if rows[0]['outcome']=='unsupported-binding': group='Unsupported automated binding — not a failed game input'
    elif entry['kind'] in ('buy','hire'): group='Neutral shop purchases and hires — shared cause unconfirmed'
    elif entry['raw']=='ANeg': group='Confirmed catalogue error — passive ability listed as active'
    elif entry['source']=='ubsp' and entry['raw']=='Aave': group='Wrong transformation state — Destroyer already transformed'
    elif entry['raw'] in context: group='Context-dependent commands — missing preparation to investigate'
    else: group='Other commands requiring focused investigation'
    groups[group].append((entry,rows))
lines=['# Hotkey audit failure analysis — alpha28','',
    'All 652 command IDs completed at least one trial. 583 produced activation evidence; '
    '57 never produced activation evidence and 12 lacked a supported automation binding.',
    'All 42 Stop controls produced both native and trainer confirmations. No command had '
    'a recorded native action that the trainer missed. This does not prove every targeted '
    'ability can complete its effect: activation-only confirms a button, not a target or placement.',
    '', '## Findings','',
    '- Neutral buildings account for 32 failures: 24 hires and eight purchases. '
    'The native stock call is already shared and supplies current stock=1. '
    'Stock timers alone are not established as the cause. Check neutral ownership, '
    'patron selection, displayed availability and actual button identity together.',
    '- Engineering Upgrade uses PASBTNEngineeringUpgrade and is passive. It belongs '
    'in Ability Choice, not the active ability rotation.',
    '- Destroyer Form must be tested from an Obsidian Statue, not an already transformed Destroyer.',
    '- Corpse handling, unloading, replenishing, coupling and garrison commands need '
    'prepared context. The current generic source/mana preparation is insufficient to prove these.',
    '- Tinker learns Engineering Upgrade level 3, which changes its other abilities. '
    'The test registers the base ability IDs; upgraded identities need checking.',
    '- Raise Dead failed once and worked once. Ritual Dagger worked once and failed once. '
    'These are additional inconsistent cases even though each activated at least once.',
    '- Other native-versus-activation-only differences are not hotkey failures.',
    '', '## Next targeted verification','',
    'First correct the passive/morph/context data. Then inspect one neutral purchase and '
    'one hire with the native button visible; apply the verified shared fix to the group. '
    'Only the repaired cases and unresolved commands need another audit. '
    'Missing CustomKeys entries require a separately verified key or a physical test.', '']
for group,items in groups.items():
    lines+=['## '+group+f' ({len(items)})','', '| Source | Command | ID | Trials |','|---|---|---|---|']
    for entry,rows in sorted(items,key=lambda item:item[0]['id']):
        lines.append(f"| {entry['sourceName']} | {entry['name']} | `{entry['id']}` | {len(rows)} |")
    lines+=['']
(root/'work/HOTKEY-FAILURE-ANALYSIS-ALPHA28.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('Wrote failure analysis for 69 commands plus two inconsistent cases.')
