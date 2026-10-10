"""Inventory timing inputs without presenting editor fields as runtime measurements."""
import json
import hashlib
import re
import runpy
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
read_slk = runpy.run_path(str(ROOT / 'tools/read-warcraft-slk.py'))['read_slk']


def main():
    catalogue = json.loads((ROOT / 'design/dodge-catalog.json').read_text(encoding='utf-8'))
    abilities = read_slk(ROOT / 'work/abilitydata.slk')
    weapons = read_slk(ROOT / 'work/unitweapons.slk')
    items = read_slk(ROOT / 'work/itemdata.slk')
    orders = {}
    for path in (ROOT / 'work').glob('*abilityfunc.txt'):
        raw = None
        for line in path.read_text(encoding='utf-8', errors='replace').splitlines():
            if re.fullmatch(r'\[.{4}\]', line.strip()):
                raw = line.strip()[1:-1]
            elif raw and line.lower().startswith('order='):
                orders[raw] = line.split('=', 1)[1].strip()

    def fields(unit, ability=None, weapon=0):
        row, spell = weapons.get(unit, {}), abilities.get(ability, {})
        return dict(unit_animation_cast_point=row.get('castpt'),
                    base_attack_damage_point=row.get('dmgpt' + str(weapon + 1)),
                    base_attack_cooldown=row.get('cool' + str(weapon + 1)),
                    ability_Cast1=spell.get('Cast1'), ability_Dur1=spell.get('Dur1'),
                    ability_DataA1=spell.get('DataA1'), ability_DataB1=spell.get('DataB1'),
                    weapon_type=row.get('weapTp' + str(weapon + 1)))

    dangers = []
    for entry in catalogue['dangers']:
        if entry['menuGroup'] not in ('Homing', 'Area', 'Ranged'):
            continue
        raw = entry.get('ability')
        issues = []
        if raw == 'AEsh':
            issues.append('Cast1 is reported as poison tick interval, not initial cast delay; existing summed tooltip is misleading.')
        if raw in ('AHbz', 'ANrf'):
            issues.append('Cast1 is a wave interval; do not add it universally to unit cast point.')
        if entry.get('orbOrder'):
            issues.append('Orb uses attack timing; attack speed modifies the animation damage point. Read current native weapon fields in game.')
        if entry['menuGroup'] == 'Ranged':
            issues.append('Attack-start event precedes launch. Native missile launch/impact timestamps are not directly exposed by this recorder.')
        if entry['unit'] == 'nwe1':
            issues.append('First Hawk has no native attack. Keep listed, but mark untestable if no attack is emitted.')
        if entry['unit'] == 'hrtt':
            issues.append('Barrage / air-only attack needs explicit native validation; a plain attack event may not represent every secondary projectile.')
        if entry['menuGroup'] == 'Area':
            issues.append('Effect event is not universally first damage; multi-wave, bouncing and charging abilities need separate interpretation.')
        dangers.append(dict(id=entry['id'], group=entry['menuGroup'], name=entry['name'], unit=entry['unit'],
                            ability=raw, weapon=entry.get('weapon', 0), orb=bool(entry.get('orbOrder')),
                            raw_fields=fields(entry['unit'], raw, entry.get('weapon', 0)),
                            catalogue_cast_point=entry.get('castPoint'),
                            catalogue_missile_speed=entry.get('missileSpeed'),
                            range=entry.get('range'), area=entry.get('area'),
                            events='attack_start, damage' if entry['kind'] == 'attack' or entry.get('orbOrder') else
                            'cast_start, cast_event, ability_effect, cast_finish, cast_end, damage, sampled buffs',
                            issues=issues, measured_status='pending_native_run'))

    names = {'AOwk': 'Wind Walk', 'AOmi': 'Mirror Image', 'AOsf': 'Feral Spirit re-summon'}
    manual = {
        'dodge.04': [('Build', None), ('Burrow loading', None)],
        'dodge.26': [('Build', None), ('Enter entangled gold mine', None), ('Detonate', 'Adtn')],
    }
    methods = []
    for entry in catalogue['dodgers']:
        item = entry.get('item') or entry.get('supportItem')
        raws = entry.get('abilities') or entry.get('supportAbilities') or []
        if item:
            raws = [raw for raw in items[item].get('abilList', '').split(',') if raw in abilities]
        choices = manual.get(entry['id']) or [(names.get(raw, entry['name']), raw) for raw in raws]
        if not choices:
            choices = [(entry['name'], None)]
        for index, (name, raw) in enumerate(choices, 1):
            caster = entry.get('support') if entry.get('supportAbilities') or entry.get('supportItem') else entry['unit']
            notes = ['Unit cast point is a raw animation field, not proven command-to-effect latency for this ability.']
            if entry['category'] == 'Invisibility' or raw == 'AOwk' or item in ('pinv', 'clsd'):
                notes.append('Measure invisibility as seen by the enemy separately from cast effect; fade sample is bounded by polling interval.')
            if item:
                notes.append('Items may bypass unit casting animation. Do not assume Tinker cast point applies.')
            if raw is None:
                notes.append('No spell rawcode in catalogue: use order, construction/load and sampled state events; do not substitute attack damage point.')
            methods.append(dict(id=f"{entry['id']}.{index}", choice_id=entry['id'], choice=entry['name'],
                                method=name, unit=caster, ability=raw, item=item, category=entry['category'],
                                order=orders.get(raw),
                                raw_fields=fields(caster, raw), notes=notes, measured_status='pending_native_run'))

    report = dict(schema=1, scope='All current Homing, Area, Ranged entries and individual dodge methods',
                  source='Installed game SYLK tables extracted into work; catalogue checked 2026-10-08',
                  source_sha256={str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest()
                                 for path in [ROOT / 'design/dodge-catalog.json', ROOT / 'work/abilitydata.slk',
                                              ROOT / 'work/unitweapons.slk', ROOT / 'work/itemdata.slk']},
                  runtime_measurements_performed=False, dangers=dangers, dodge_methods=methods)
    (ROOT / 'design/dodge-timing-audit.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    # Development-only automation input: orders come from installed game data.
    def lua(value):
        if value is None: return 'nil'
        if isinstance(value, str): return json.dumps(value)
        if isinstance(value, int): return str(value)
        if isinstance(value, list): return '{' + ','.join(lua(v) for v in value) + '}'
        return '{' + ','.join(k + '=' + lua(v) for k, v in value.items()) + '}'
    pawn_indices = {entry['id']: index for index, entry in enumerate(catalogue['dodgers'], 1)}
    batch_methods = [dict(id=e['id'], pawnIndex=pawn_indices[e['choice_id']], choice=e['choice_id'],
                          method=e['method'], ability=e['ability'], item=e['item'], order=e['order']) for e in methods]
    (ROOT / 'src/generated/dodge-timing-methods.lua').write_text(
        '-- Development-only. Generated by tools/audit-dodge-timing.py.\nJTG.DodgeTimingMethods=' + lua(batch_methods) + '\n', encoding='utf-8')
    lines = ['# Dodging timing inventory', '',
             'Generated by `tools/audit-dodge-timing.py`. **No in-game measurements have been performed.**', '',
             'Raw animation fields and ability fields are listed separately; they are not added together to claim a launch time.', '',
             '## Threats', '', '| Group | Entry | ID | Raw unit cast point | Raw attack point | Raw Cast1 | Runtime status |',
             '|---|---|---|---:|---:|---:|---|']
    for e in dangers:
        f = e['raw_fields']
        lines.append(f"| {e['group']} | {e['name']} | `{e['id']}` | {f['unit_animation_cast_point']} | {f['base_attack_damage_point']} | {f['ability_Cast1']} | Pending |")
    lines += ['', '## Individual dodge methods', '', '| Choice | Method | Caster | Ability/item | Raw unit cast point | Raw Cast1 |',
              '|---|---|---|---|---:|---:|']
    for e in methods:
        f = e['raw_fields']
        lines.append(f"| {e['choice']} | {e['method']} | `{e['unit']}` | `{e['ability'] or e['item'] or 'event-based'}` | {f['unit_animation_cast_point']} | {f['ability_Cast1']} |")
    lines += ['', '## Interpretation flags', '']
    for e in dangers:
        if e['issues']:
            lines.append(f"- **{e['name']}** (`{e['id']}`): " + ' '.join(e['issues']))
    (ROOT / 'docs/DODGE-TIMING-INVENTORY.md').write_text('\n'.join(lines) + '\n', encoding='utf-8')
    counts = {group: sum(e['group'] == group for e in dangers) for group in ('Homing', 'Area', 'Ranged')}
    print(json.dumps(dict(counts=counts, choices=len(catalogue['dodgers']), methods=len(methods))))


if __name__ == '__main__':
    main()
