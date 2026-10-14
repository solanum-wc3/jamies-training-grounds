"""Exclude completed command trials, regardless of outcome, from subsequent audits."""
import argparse
import json
from pathlib import Path

parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('summary',type=Path)
parser.add_argument('--followup',type=Path)
parser.add_argument('--never-activated-only',action='store_true')
parser.add_argument('--include',action='append',default=[],help='Include a previously tested command for regression coverage.')
parser.add_argument('--only-selected',action='store_true',help='Audit only the explicitly included commands.')
args=parser.parse_args()
root=Path(__file__).resolve().parents[1]
data=json.loads(args.summary.read_text(encoding='utf-8'))
followup=json.loads(args.followup.read_text(encoding='utf-8')) if args.followup else None
tested=sorted(data['prompts'])
output=root/'work/hotkey-audit-exclusions.lua'
output.parent.mkdir(exist_ok=True)
catalog=json.loads((root/'src/data/hotkey-catalog.json').read_text(encoding='utf-8'))['entries']
targeted=[]
for entry in ([] if args.only_selected else catalog):
    if followup:
        rows=followup['prompts'].get(entry['id'],[])
        predicate=all if args.never_activated_only else any
        if rows and predicate(row['outcome'] not in ('native-and-trainer','activation-only') for row in rows):
            targeted.append(entry['id'])
        continue
    rows=data['prompts'].get(entry['id'],[])
    failed=rows and all(row['outcome'] not in ('native-and-trainer','activation-only') for row in rows)
    inconsistent=entry['id'] in ('undead.unec.ability.Arai','undead.utom.buy.ritd')
    repaired=entry.get('night') or entry.get('uprooted') or entry.get('heroRecruitment')
    if failed or inconsistent or repaired: targeted.append(entry['id'])
by_id={entry['id']:entry for entry in catalog}
for key in args.include:
    if key not in by_id:
        raise ValueError(f'Unknown regression command: {key}')
    if key not in targeted: targeted.append(key)
output.write_text('-- Completed trials, including failures; generated from the saved audit summary.\n'
    +'JTG.HotkeyAuditTested = {\n'+''.join('    ['+json.dumps(key)+'] = true,\n' for key in tested)+'}\n'
    +'JTG.HotkeyTargetedAuditIds = {\n'+''.join('    ['+json.dumps(key)+'] = true,\n' for key in targeted)+'}\n',encoding='utf-8')
print(f'{len(tested)} command IDs excluded; repeat controls remain only when untested commands exist.')
print(f'{len(targeted)} command IDs selected for repaired/unresolved verification.')
