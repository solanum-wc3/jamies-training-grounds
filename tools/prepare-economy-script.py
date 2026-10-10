import json
from pathlib import Path
root=Path(__file__).resolve().parent.parent
def lua(value):
    if isinstance(value,bool): return 'true' if value else 'false'
    if isinstance(value,str): return json.dumps(value,ensure_ascii=False)
    if isinstance(value,list): return '{'+', '.join(lua(v) for v in value)+'}'
    if isinstance(value,dict): return '{'+', '.join(k+'='+lua(v) for k,v in value.items())+'}'
    return str(value)
steps=json.loads((root/'design/tutorials/economy-script.json').read_text(encoding='utf-8'))
ids=set()
for step in steps:
    identifier=step['id']
    if identifier in ids: raise ValueError('Duplicate Economy step: '+identifier)
    ids.add(identifier)
    if not isinstance(step['action'],str): raise ValueError('Use a named Economy action')
    if not 1 <= step['restore']['race'] <= 4: raise ValueError('Invalid checkpoint faction')
(root/'src/generated/economy-script.lua').write_text('-- Generated from design/tutorials/economy-script.json.\nJTG.EconomySteps = '+lua(steps)+'\n',encoding='utf-8')
