"""Summarize native interactive audit evidence; never infer passes from frame enablement."""
import argparse
import json
from pathlib import Path


def summarize(text):
    rows = []
    control = 'missing'
    state = 'missing'
    current = None
    for line in text.splitlines():
        if '//JTG_AUDIT|' not in line:
            continue
        # Preload output is a wrapped diagnostic, not a clean text export.
        fields = line.split('//JTG_AUDIT|', 1)[1].split('"', 1)[0].split('|')
        if fields[0] == 'race':
            control, state = fields[3], fields[5]
        elif fields[0] == 'begin':
            current = {'prompt': fields[1], 'card_visible': fields[3] == 'true',
                       'keys': [], 'events': [], 'requirements': [], 'result': 'pending'}
            rows.append(current)
        elif current and fields[0] == 'key':
            current['keys'].append({'code': int(fields[1]), 'time': float(fields[3])})
        elif current and fields[0] == 'event':
            current['events'].append({'kind': fields[1], 'origin': fields[2], 'time': float(fields[4])})
        elif current and fields[0] in ('requires-unit', 'requires-research'):
            current['requirements'].append({'type': fields[0], 'raw': fields[1],
                                            'expected': int(fields[3]), 'actual': int(fields[5])})
        elif current and fields[0] == 'result':
            current['result'] = fields[2]
        elif current and fields[0] == 'pending-key':
            current['keys'].append({'code': int(fields[1]), 'time': float(fields[2])})
        elif current and fields[0] == 'pending-event':
            current['events'].append({'kind': fields[1], 'origin': fields[2], 'time': float(fields[3])})
    return {'control': control, 'state': state, 'valid_control': control == 'passed',
            'note': 'Activation does not prove spell execution. Skips and pending rows are unverified.',
            'counts': {result: sum(row['result'] == result for row in rows)
                       for result in sorted({row['result'] for row in rows})},
            'requirements_unsatisfied': [row['prompt'] for row in rows
                                        if any(req['actual'] < req['expected'] for req in row['requirements'])],
            'trials': rows}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('report', type=Path)
    args = parser.parse_args()
    print(json.dumps(summarize(args.report.read_text(encoding='utf-8-sig')), indent=2))
