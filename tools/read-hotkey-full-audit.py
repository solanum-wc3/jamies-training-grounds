"""Read only batches listed by the latest full-audit manifest; retain inconclusive evidence."""
import argparse
import json
from collections import Counter, defaultdict
from pathlib import Path


def records(path):
    for line in path.read_text(encoding='utf-8-sig').splitlines():
        if '//JTG_FULL|' in line:
            yield line.split('//JTG_FULL|', 1)[1].split('"', 1)[0].split('|')


def summarize(manifest):
    header = next(row for row in records(manifest) if row[0]=='manifest')
    batches, state = int(header[2]), header[8]
    outcomes, controls, setup_errors = [], [], []
    for index in range(1, batches+1):
        path = manifest.parent/f'{manifest.stem}-{index:03d}.pld'
        if not path.exists():
            raise ValueError(f'Missing audit batch {index}')
        trial = {}
        for row in records(path):
            if row[0]=='trial':
                trial={'job': int(row[1]), 'repetition': int(row[3]), 'control': row[5]=='true'}
            elif row[0]=='outcome':
                result={**trial, 'prompt': row[1], 'outcome': row[2], 'control_healthy': row[4]=='true'}
                if trial.get('setup_error'):
                    result['reported_outcome']=result['outcome']
                    result['outcome']='setup-error'
                (controls if trial.get('control') else outcomes).append(result)
            elif row[0]=='evidence':
                result['evidence']={row[1]:row[2]=='true',row[3]:row[4]=='true',row[5]:row[6]=='true'}
            elif row[0]=='setup-error':
                trial['setup_error']=row[1]
                setup_errors.append({**trial,'error':row[1]})
    groups=defaultdict(list)
    for result in outcomes:
        groups[result['prompt']].append(result)
    return {'state': state, 'batches': batches, 'counts': dict(Counter(r['outcome'] for r in outcomes)),
            'controls': controls, 'setup_errors': setup_errors,
            'inconsistent': [prompt for prompt, rows in groups.items() if len({r['outcome'] for r in rows})>1],
            'missing_repetitions': [prompt for prompt, rows in groups.items() if len(rows)!=3],
            'note': 'No-activation evidence is not proof of a wrong binding. Activation-only is not proof of execution.',
            'prompts': dict(groups)}


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('manifest',type=Path)
    args=parser.parse_args()
    print(json.dumps(summarize(args.manifest),indent=2))
