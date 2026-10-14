"""Prepare dev-only comparison bindings from an explicitly supplied CustomKeys file.

No user paths or names are embedded in the map. Missing bindings stay unsupported.
"""
import argparse
import csv
import hashlib
import json
from pathlib import Path

CASES = [('common.hfoo.common.stop','CmdStop','Hotkey',None),
         ('orc.Otch.ability.AOws','AOws','Hotkey',None),
         ('orc.Otch.ability.AOsh','AOsh','Hotkey',None),
         ('orc.obar.train.ogru','ogru','Hotkey',None),
         ('orc.ofor.research.Rome','Rome','Hotkey',None),
         ('orc.ovln.buy.hslv','hslv','Hotkey',None),
         ('orc.opeo.build.oalt','oalt','Hotkey','CmdBuildOrc'),
         ('orc.Otch.learn.AOre','AOre','Researchhotkey','CmdSelectSkill')]


def prepare(text, cases=CASES, native=None):
    sections, current = {}, None
    for line in text.splitlines():
        line = line.strip()
        if line.startswith('[') and line.endswith(']'):
            current = line[1:-1]
        elif current and '=' in line and not line.startswith('//'):
            key, value = line.split('=', 1)
            sections.setdefault(current, {})[key.lower()] = value.strip()
    def key(raw, field, level=1):
        fields=sections.get(raw)
        if fields is None: fields=next((v for k,v in sections.items() if k.casefold()==raw.casefold()),{})
        defaults=(native or {}).get(raw,{})
        value=fields[field.lower()] if field.lower() in fields else defaults.get(field.lower(),'')
        parts = next(csv.reader([value])) if value else []
        index = 0 if len(parts)==1 else level-1
        value = parts[index].strip().upper() if index<len(parts) else ''
        return value if len(value) == 1 and 'A' <= value <= 'Z' else None
    rows = []
    for case in cases:
        prompt, raw, field, prefix = case[:4]
        level = case[4] if len(case)>4 else 1
        sequence = ([key(prefix, 'Hotkey')] if prefix else []) + [key(raw, field, level)]
        rows.append((prompt, sequence if all(sequence) else []))
    return rows


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('custom_keys', type=Path)
    args = parser.parse_args()
    data = args.custom_keys.read_bytes()
    rows = prepare(data.decode('utf-8-sig'))
    root = Path(__file__).resolve().parent.parent
    native={}
    for path in sorted((root/'work/hotkey-native').glob('*.txt')):
        current=None
        for line in path.read_text(encoding='utf-8-sig').splitlines():
            line=line.strip()
            if line.startswith('[') and line.endswith(']'): current=line[1:-1]
            elif current and '=' in line and not line.startswith('//'):
                field,value=line.split('=',1)
                native.setdefault(current,{})[field.lower()]=value.strip()
    catalogue = json.loads((root/'src/data/hotkey-catalog.json').read_text(encoding='utf-8'))['entries']
    common = {'move':'CmdMove','hold':'CmdHoldPos','attack':'CmdAttack','stop':'CmdStop',
              'patrol':'CmdPatrol','gather':'Ahar','escape':'CmdCancel','select':'Aneu',
              'uproot':'Aro1','root':'Aro1'}
    full_cases = []
    for entry in catalogue:
        raw, field, prefix = entry['raw'], 'Hotkey', None
        if entry['kind']=='ability': raw=entry.get('activeAbility',raw)
        if entry['kind']=='learn': field, prefix = 'Researchhotkey', 'CmdSelectSkill'
        elif entry['kind']=='build': prefix = 'CmdBuild'+{'human':'Human','orc':'Orc','nightelf':'NightElf','undead':'Undead'}[entry['race']]
        elif entry['kind']=='common':
            raw = common[entry['raw']]
            if entry['raw']=='uproot': field = 'Unhotkey'
        full_cases.append((entry['id'], raw, field, prefix, entry.get('researchLevel',1)))
    full_rows = prepare(data.decode('utf-8-sig'), full_cases,native)
    lines = ['-- Dev-only binding fixture; explicitly generated, not a production binding table.',
             'JTG.HotkeyComparisonBindingHash = '+json.dumps(hashlib.sha256(data).hexdigest()),
             'JTG.HotkeyComparisonBindings = {']
    for prompt, keys in rows:
        lines.append('  ['+json.dumps(prompt)+'] = {'+', '.join(map(json.dumps, keys))+'},')
    lines.append('}')
    lines.append('JTG.HotkeyFullAuditBindings = {')
    for prompt, keys in full_rows:
        lines.append('  ['+json.dumps(prompt)+'] = {'+', '.join(map(json.dumps, keys))+'},')
    lines.append('}')
    (root/'work').mkdir(exist_ok=True)
    (root/'work/hotkey-comparison-bindings.lua').write_text('\n'.join(lines)+'\n', encoding='utf-8')
    print(f'Prepared {sum(bool(keys) for _, keys in rows)}/{len(rows)} supported dev bindings.')
    print(f'Full audit: {sum(bool(keys) for _, keys in full_rows)}/{len(full_rows)} resolved custom/default bindings; others remain unverified.')
