"""Export editable narration and progression snapshots from current tutorial sources.

Explicit --overwrite is required to replace files that may contain user edits.
"""
import argparse
import json
import re
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'work/lua-test-runtime'))
from lupa import LuaRuntime

def literal(source,name):
    start=re.search(r'local '+name+r'\s*=\s*\{',source).end()-1
    depth=0; pos=start
    while pos<len(source):
        char=source[pos]
        if source.startswith('--',pos):
            pos=source.find('\n',pos)
            if pos<0: raise ValueError(name)
            continue
        if char in "\"'":
            quote=char;pos+=1
            while source[pos]!=quote:
                pos+=2 if source[pos]=='\\' else 1
        elif char=='{': depth+=1
        elif char=='}':
            depth-=1
            if depth==0:
                return convert(LuaRuntime().execute('return '+source[start:pos+1]))
        pos+=1
    raise ValueError(name)

def convert(value):
    if not hasattr(value,'items'): return value
    pairs=dict(value.items())
    if pairs and set(pairs)==set(range(1,len(pairs)+1)):
        return [convert(pairs[i]) for i in range(1,len(pairs)+1)]
    return {key:convert(item) for key,item in pairs.items()}

def prose_key(value):
    return re.sub(r'([a-z])([A-Z])',r'\1 \2',str(value)).replace('-',' ')

def step_text(steps,prefix='Step',checkpoint='welcome'):
    result=[]
    for index,step in enumerate(steps,1):
        checkpoint=step.get('checkpoint',checkpoint)
        status=' — HIDDEN / DISABLED' if step.get('hidden') else ''
        result+=['',f'## {prefix} {index} — {checkpoint}{status}','', '### Narration','']
        result+=step.get('lines',[])
        result+=['','### Progression and scene actions','',f'- Checkpoint: `{checkpoint}`.']
        if step.get('terminal'):
            result+=['- Final step: return through Menu; no further narration step.']
        elif step.get('wait'):
            result+=['- Advance with '+('Next' if step.get('sectionEnd') else 'Continue')+'.']
        else:
            result+=[f"- Automatic advance after {step.get('delay',4)} seconds."]
        if step.get('hidden'): result+=['- Skipped in the current build; retained here for editing.']
        action=step.get('trigger',step.get('action'))
        if action: result+=[f'- Scene action: **{prose_key(action)}** (`{action}`).']
        for key in ('id','groupStart','sourceStop'):
            if key in step: result+=[f'- {prose_key(key).capitalize()}: `{step[key]}`.']
        remaining={key:value for key,value in step.items() if key not in
            ('lines','checkpoint','wait','sectionEnd','terminal','hidden','delay','trigger','action','id','groupStart','sourceStop')}
        if remaining:
            result+=['','Scene / restoration details:','', '```json',json.dumps(remaining,indent=2,ensure_ascii=False),'```']
        result+=['','### Your edits / notes','','']
    return result

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--overwrite',action='store_true')
    args=parser.parse_args()
    output=ROOT/'design/tutorials/editable'
    output.mkdir(parents=True,exist_ok=True)
    tutorials=[('01-camera','Camera','camera-tutorial.lua','TUTORIAL_STEPS'),
        ('02-unit-controls','Unit Controls','unit-controls-tutorial.lua','STEPS'),
        ('03-hotkey-setup','Hotkey Setup','hotkey-setup-tutorial.lua','STEPS'),
        ('04-economy-workers','Economy & Workers','economy-tutorial.lua',None)]
    for filename,title,source_file,table in tutorials:
        destination=output/(filename+'.md')
        if destination.exists() and not args.overwrite:
            raise SystemExit(f'Refusing to overwrite edits: {destination}')
        source=(ROOT/'src/activities'/source_file).read_text(encoding='utf-8')
        if table:
            steps=literal(source,table)
        else:
            steps=json.loads((ROOT/'design/tutorials/economy-script.json').read_text(encoding='utf-8'))
        if filename=='03-hotkey-setup':
            for index in (14,17,18,19,20): steps[index-1]['hidden']=True
        text=[f'# {title} — editable tutorial script','',
            'Snapshot of the current implementation, 13 October 2026.',
            'Edit narration directly and add progression or scene changes under Your edits / notes.',
            'Keep formatting tags such as `{Heading: ...}`, `{Input: ...}` and `{Button: ...}`.',
            'Edits here do not automatically update the map; these are authoring work files.',
            'Each numbered step is one narration stop. Blank lines in narration are intentional.',
            '',f'Implementation reference: `src/activities/{source_file}`.','',
            '## Shared progression','',
            '- Continue advances a narration stop; Next appears at section boundaries.',
            '- Back and Topics return to checkpoints using the tutorial restoration procedures.',
            '- Blue heading tags identify narration sub-sections.',
            '- Camera movements use the shared fixed duration (1.5 seconds).']
        if filename=='04-economy-workers':
            text+=['- Active-race units belong to the player and remain controllable.',
                '- Restore details below specify the state reconstructed when revisiting a step.']
        text+=step_text(steps)
        if 'local OPTIONAL_SECTIONS' in source:
            optional=literal(source,'OPTIONAL_SECTIONS')
            sections=optional.items() if isinstance(optional,dict) else enumerate(optional,1)
            for key,section in sections:
                title=section.get('title',section.get('label',key))
                section_id=section.get('id',key)
                text+=['',f"# Optional section: {title}",'',f'Internal section: `{section_id}`.',
                    'At the end of this optional section, Next returns to the main tutorial.']
                text+=step_text(section['steps'],'Optional step',section.get('checkpoint',str(title)))
        destination.write_text('\n'.join(text)+'\n',encoding='utf-8')
        print(f'{destination.name}: {len(steps)} main narration stops')

if __name__=='__main__': main()
