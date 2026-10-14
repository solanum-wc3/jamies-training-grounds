"""Create editable text snapshots of implemented exercise briefing pages."""
import json
import re
from pathlib import Path
import importlib.util
spec=importlib.util.spec_from_file_location('tutorial_export',Path(__file__).with_name('export-tutorial-workfiles.py'))
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
literal=module.literal
from lupa import LuaRuntime

ROOT=Path(__file__).resolve().parents[1]
STRING=r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\''
EXPRESSION=r'(?:'+STRING+r')(?:\s*\.\.\s*(?:'+STRING+r'))*'

def decode(expression):
    return LuaRuntime().execute('return '+expression).replace('|n','\n')

def export(filename,title,source_file,constants=(),extra=(),selections=True):
    if filename in {'reflex-training','hotkey-trainer'}:
        raise ValueError('Authoritative briefing files cannot be overwritten by snapshot export')
    source=(ROOT/'src/activities'/source_file).read_text(encoding='utf-8')
    pages=[]
    for variable,label in constants:
        match=re.search(r'local '+variable+r'\s*=\s*('+EXPRESSION+r')',source)
        assert match,variable
        pages.append((label,decode(match[1])))
    if 'local BRIEFING = {' in source:
        for name,text in literal(source,'BRIEFING').items(): pages.append((name,text))
    for index,match in enumerate(re.finditer(r'(?:\bbody|spec\.body)\s*=\s*('+EXPRESSION+r')',source),1):
        if not selections: continue
        text=decode(match[1])
        end=match.end()
        if source[end:].lstrip().startswith('..'):
            if filename=='dodging': continue
            text+='[DYNAMIC TEXT — selected unit/ability or selection summary]'
        if text and not any(text==old for _,old in pages): pages.append((f'Selection page {index}',text))
    pages+=list(extra)
    destination=ROOT/'design/exercises/editable'/(filename+'.txt')
    if destination.exists() and '--overwrite' not in __import__('sys').argv:
        raise ValueError(f'Refusing to overwrite edits: {destination}')
    content=[title+' — editable briefings','',
        'Current implementation snapshot: 13 October 2026.',
        'Edit the text and blank lines directly. Formatting tags are preserved.',
        'Page labels and placeholders identify which menu uses the text.',
        'Edits here do not automatically update the map.',
        'This file covers briefing text, not unit tooltips, quest instructions or end cards.',
        '', 'Source: src/activities/'+source_file]
    for label,text in pages:
        content+=['','='*60,label,'='*60,'',text,'','Your notes:','']
    destination.write_text('\n'.join(content)+'\n',encoding='utf-8')
    print(destination.name+': '+str(len(pages))+' pages')

if __name__=='__main__':
    (ROOT/'design/exercises/editable').mkdir(parents=True,exist_ok=True)
    export('body-blocking','Body Blocking','body-blocking.lua',[('BODY_BLOCKING_INTRO','Main briefing')])
    export('surrounds','Surrounds','surrounds.lua',[('INTRO','Main briefing')])
    export('gargoyle-surrounds','Gargoyle Surrounds','surrounds.lua',[('GARGOYLE_INTRO','Main briefing')],selections=False)
    export('windwalk-pop','Windwalk Pop','windwalk-pop.lua',[('WINDWALK_POP_INTRO','Main briefing')])
    export('mining-micro','Mining Micro','mining-micro.lua',[('MINING_MICRO_INTRO','Main briefing')])
    export('bat-splitting','Bat Splitting','bat-splitting.lua',[('INTRO','Main briefing')])
    export('dodging','Dodging','missile-dodging.lua',extra=[
        ('Ability disjoin — choose dodger','Choose which ability you want to use to try to disjoin [chosen projectile]!\nYou will advance through three stages after three successful disjoins.\nBe careful! Not every ability works quickly enough to be able to disjoin every projectile.'),
        ('Attack disjoin — choose dodger','Choose which ability you want to use to try to disjoin [chosen projectile]!'),
        ('Area — choose dodge ability','Choose which ability you want to use to try to avoid [chosen area ability]!')])
    # These are now authored files, not replaceable snapshots.
    for name in ('reflex-training','hotkey-trainer'):
        assert (ROOT/'design/exercises/editable'/(name+'.txt')).is_file(), 'Missing authored briefing: '+name
        print(name+': authoritative text retained')
    export('power-building','Power Building','power-building.lua',[('POWER_BUILDING_INTRO','Main briefing')])
