"""Extract write-only timing exports. Never execute the exported preload script."""
import argparse
import csv
import io
import json
import re
from pathlib import Path


def analyze(text):
    chunks = {}
    manifest = re.search(r'//JTG_ROWS,(\d+)', text)
    for line in text.splitlines():
        if '//JTG_PART,' in line:
            row, part, total, payload = line.split('//JTG_PART,', 1)[1].split(',', 3)
            item = chunks.setdefault(int(row), {'total': int(total), 'parts': {}})
            item['parts'][int(part)] = payload
    if chunks:
        if manifest and set(chunks) != set(range(1, int(manifest.group(1))+1)):
            raise ValueError('Export is missing complete rows')
        lines = []
        for index in sorted(chunks):
            item = chunks[index]
            if set(item['parts']) != set(range(1, item['total']+1)):
                raise ValueError(f'Incomplete exported row {index}')
            lines.append(''.join(item['parts'][part] for part in range(1, item['total']+1)))
        text = '\n'.join(lines)
    lines = [line.split('//JTG_TIMING,', 1)[1] for line in text.splitlines() if '//JTG_TIMING,' in line]
    legacy_truncated = bool(lines and any(line.endswith('" )') for line in lines))
    if legacy_truncated:
        # Preserve the intact leading columns of the first native export.
        # Metadata/unit handles at the truncated tail cannot be recovered.
        lines = [re.sub(r'"\s*\)$', '', line) if line.endswith('" )') else line for line in lines]
    csv_text = '\n'.join(lines) if lines else text
    if legacy_truncated:
        header = next(csv.reader([lines[0]]))
        rows = [dict(zip(header, next(csv.reader([line])))) for line in lines[1:]]
    else:
        rows = list(csv.DictReader(io.StringIO(csv_text)))
    if legacy_truncated:
        for row in rows:
            row.pop(None, None)
            row['conditions'] = 'Legacy export truncated: original metadata and unit identity may be missing'
            row['unit_handle'] = ''
    required = {'run', 'time_s', 'event', 'role', 'quality', 'ability_or_item'}
    if not rows or not required.issubset(rows[0]):
        raise ValueError('No valid JTG timing rows found')
    grouped = {}
    for row in rows:
        row['time_s'] = float(row['time_s'])
        grouped.setdefault(row['run'], []).append(row)
    runs = []
    for run_id, events in grouped.items():
        events.sort(key=lambda e: e['time_s'])
        native = [e for e in events if e['quality'] == 'native_event']
        enemy_effects = [e for e in native if e['role'] == 'enemy' and e['event'] == 'ability_effect']
        anchor = enemy_effects[0]['time_s'] if enemy_effects else None
        requests = [e for e in events if e['event'] == 'batch_dodge_request' and e['quality'] == 'automation']
        dodge_anchor = requests[0]['time_s'] if requests else None
        pending = {}
        casts = []
        for event in native:
            key = (event.get('unit_handle') or event['role'], event['ability_or_item'])
            if event['event'] == 'cast_start':
                pending[key] = event
            elif event['event'] == 'ability_effect':
                start = pending.pop(key, None)
                casts.append(dict(role=event['role'], ability=event['ability_or_item'],
                                  start_s=start['time_s'] if start else None, effect_s=event['time_s'],
                                  start_to_effect_s=event['time_s']-start['time_s'] if start else None))
            elif event['event'] == 'cast_end':
                pending.pop(key, None)
        runs.append(dict(run=run_id, danger=events[0]['danger'], dodger=events[0]['dodger'], stage=events[0]['stage'],
                         conditions=events[0].get('conditions'),
                         truncated=any(e.get('truncated') == 'true' for e in events),
                         enemy_first_effect_s=anchor, casts=casts,
                         dodge_request_s=dodge_anchor,
                         setup_snapshots=[e for e in events if e['quality'] == 'native_snapshot'],
                         player_timeline=[dict(time_s=e['time_s'], event=e['event'], role=e['role'],
                                               ability=e['ability_or_item'], detail=e.get('detail'), quality=e['quality'],
                                               relative_to_first_enemy_effect_s=e['time_s']-anchor if anchor is not None else None,
                                               relative_to_dodge_request_s=e['time_s']-dodge_anchor if dodge_anchor is not None else None)
                                          for e in events if e['role'] in ('target', 'player', 'helper', 'player_created', 'replacement')],
                         damage_events=[e for e in native if e['event'] == 'damage'],
                         attack_starts=[e['time_s'] for e in native if e['event'] == 'attack_start'],
                         automation_events=[e for e in events if e['quality'] == 'automation']))
    return rows, dict(runs=runs, legacy_export_truncated=legacy_truncated, interpretation=[
        'Effect events are not universal missile-launch or hit events.',
        'Damage is recorded damage, not proof of every impact. Zero damage and absent damage are inconclusive.',
        'Sampled transitions occurred after the prior sample and no later than the recorded sample; engine granularity also applies.',
        'Relative times use the FIRST enemy effect in the run, not an automatically matched attack/cast cycle.',
        'Training inference rows are retained in CSV but excluded from measured cast intervals.',
        'No projectile flight time, disappearance time or successful dodge is manufactured from a timeout.'])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('export', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    rows, summary = analyze(args.export.read_text(encoding='utf-8-sig'))
    args.output.mkdir(parents=True, exist_ok=True)
    with (args.output / 'dodge-events.csv').open('w', encoding='utf-8', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    (args.output / 'dodge-timing-summary.json').write_text(json.dumps(summary, indent=2) + '\n', encoding='utf-8')
    print(f"Imported {len(rows)} observations in {len(summary['runs'])} runs")


if __name__ == '__main__':
    main()
