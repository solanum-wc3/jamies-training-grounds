"""Summarize selection transitions without treating activation as completed execution."""
import argparse
import json
from collections import Counter, defaultdict
from pathlib import Path

def records(path):
    for line in path.read_text(encoding='utf-8-sig').splitlines():
        if '//JTG_FULL|' in line:
            yield line.split('//JTG_FULL|',1)[1].split('"',1)[0].split('|')

def summarize(manifest):
    header=next(row for row in records(manifest) if row[0]=='manifest')
    trials=[]
    trial=None
    for batch in range(1,int(header[2])+1):
        for row in records(manifest.with_name(f'{manifest.stem}-{batch:03d}.pld')):
            if row[0]=='trial':
                trial={'job':int(row[1]),'repetition':int(row[3]),'dispatches':[]}
            elif trial is not None:
                if row[0]=='transition-method': trial['method']=row[1]
                elif row[0]=='selection-at-dispatch':
                    trial['dispatches'].append({'selected':row[1]=='true','buttons':[]})
                elif row[0]=='card-state':
                    trial['dispatches'][-1]['buttons'].append({'slot':int(row[1]),
                        'alpha':int(row[3]),'visible':row[5]=='true','enabled':row[7]=='true'})
                elif row[0]=='outcome':
                    trial.update(prompt=row[1],outcome=row[2])
                    trials.append(trial)
                    trial=None
    groups=defaultdict(list)
    for trial in trials:
        groups[f"{trial['method']}, repetition {trial['repetition']}"].append(trial)
    return {'state':header[8],'trials':len(trials),'groups':{
        key:dict(Counter(row['outcome'] for row in rows)) for key,rows in groups.items()},
        'details':trials,'note':'Activation-only confirms the button event, not completed casting or construction.'}

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('manifest',type=Path)
    args=parser.parse_args()
    print(json.dumps(summarize(args.manifest),indent=2))
