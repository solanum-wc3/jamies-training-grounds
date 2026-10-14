"""Derive command relationships from installed melee data, never guessed icons.

Run extract-hotkey-data.ps1 first. Audit every referenced texture against CASC
before using --verified to publish the runtime catalogue.
"""
import argparse
import csv
import json
import re
import runpy
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / 'work/hotkey-native'
read_slk = runpy.run_path(str(Path(__file__).with_name('read-warcraft-slk.py')))['read_slk']

def sections(path):
    result, current = {}, None
    for line in path.read_text(encoding='utf-8-sig', errors='strict').splitlines():
        line = line.strip()
        if line.startswith('[') and line.endswith(']'):
            current = line[1:-1]
        elif current and '=' in line and not line.startswith('//'):
            key, value = line.split('=', 1)
            result.setdefault(current, {})[key.lower()] = value.strip()
    return result

def merged(pattern):
    result = {}
    for path in sorted(DATA.glob(pattern)):
        for raw, values in sections(path).items():
            result.setdefault(raw, {}).update(values)
    return result

uf, us, af, ast, upgrades = (merged(p) for p in
    ('*unitfunc.txt', '*unitstrings.txt', '*abilityfunc.txt', '*abilitystrings.txt', '*upgradefunc.txt'))
upgrade_names = merged('*upgradestrings.txt')
unit_skin = sections(DATA / 'unitskin.txt')
ability_skin = sections(DATA / 'abilityskin.txt')
item_ui = sections(DATA / 'itemfunc.txt')
item_names = sections(DATA / 'itemstrings.txt')
for raw, fields in sections(DATA / 'itemskin.txt').items():
    item_ui.setdefault(raw, {}).update(fields)
ua = read_slk(DATA / 'unitabilities.slk')
units = read_slk(DATA / 'unitdata.slk')
abilities = read_slk(DATA / 'abilitydata.slk')
upgrade_data = read_slk(DATA / 'upgradedata.slk')
items = read_slk(DATA / 'itemdata.slk')

# Explicit melee sources: don't accidentally include campaign or map variants.
SOURCES = {
 'human': 'Hpal Hamg Hmkg Hblm hpea hfoo hrif hkni hmpr hsor hspt hmtm hmtt hgyr hgry hdhw htow hkee hcas hbar halt hbla hlum hars harm hgra hvlt hhou hwtw hgtw hatw hctw'.split(),
 'orc': 'Obla Ofar Otch Oshd opeo ogru ohun otbk orai okod otau oshm odoc ospw ocat otbr owyv ogre ostr ofrt obar oalt ofor osld obea otto ovln otrb owtw'.split(),
 'nightelf': 'Edem Ekee Emoo Ewar ewsp earc esen edry edoc edcm edob edot edtm emtg ebal ehip ehpr efdr echm etol etoa etoe eate eaom eaow eaoe edos eden emow etrp'.split(),
 'undead': 'Udea Udre Ulic Ucrl uaco ugho ucry ugar uabo unec uban umtw uobs ubsp ushd unpl unp1 unp2 uaod usep ugol uzig uzg1 uzg2 utod uslh ubon usap ugrv utom'.split(),
 'neutral': 'ntav ngad ngme nmer nmr2 nmr3'.split(),
}
# Mercenaries are native stock, not a hand-maintained copy of icons/abilities.
for source in ('ntav', 'ngad', 'nmer', 'nmr2', 'nmr3'):
    SOURCES['neutral'] += uf[source].get('sellunits', '').split(',')
# Only purchasable neutral units belong in this trainer, not map creep camps.
SOURCES['neutral'] = list(dict.fromkeys(SOURCES['neutral']))

catalog, excluded = [], []
def first(value):
    return next(csv.reader([value],skipinitialspace=True))[0].strip() if value else ''
def description(value):
    text=first(value)
    def resolve(match):
        raw,field,percent=match.group(1),match.group(2),match.group(3)
        tables=(abilities,upgrade_data,units,items)
        row=next((table[raw] for table in tables if raw in table),{})
        val=next((v for k,v in row.items() if k.lower()==field.lower()),None)
        if val is None or val=='-': return match.group(0)
        try: return format(float(val)*(100 if percent else 1),'g')
        except ValueError: return val
    text=re.sub(r'<([^,<>]+),([^,<>]+)(,%)?>',resolve,text)
    # Do not expose unresolved native data markup. Preserve complete prose
    # sentences which contain no unresolved substitutions.
    if '<' in text:
        text=' '.join(part.strip() for part in re.split(r'(?<=[.!?])\s+',text) if '<' not in part)
    return text
def name(fields, fallback):
    value = fields.get('name', fields.get('tip', fallback))
    return re.sub(r'\|c[0-9a-fA-F]{8}|\|r|\|n', '', first(value))
def add(race, source, raw, kind, fields, order=None, ability=None, **extra):
    icon = first(fields.get('art:sd', fields.get('art', '')))
    source_icon = first(unit_skin[source].get('art:sd', unit_skin[source].get('art', '')))
    if not icon or not source_icon:
        raise AssertionError(f'Missing source icon: {source}/{raw}')
    entry = dict(id=f'{race}.{source}.{kind}.{raw}', race=race, source=source,
        sourceName=name(us.get(source, {}), source), name=name(fields, raw),
        raw=raw, kind=kind, icon=icon, sourceIcon=source_icon)
    entry['category']={'build':'worker-build','train':'building-unit','research':'building-research',
        'upgrade':'building-research','buy':'shop-purchase','hire':'shop-purchase',
        'ability':'unit-ability','learn':'hero-learn','common':'universal'}[kind]
    entry['description'] = description(fields.get('ubertip', ''))
    entry['sourceDescription'] = description(us.get(source, {}).get('ubertip', ''))
    pos=fields.get('buttonpos','').split(',')
    if len(pos)==2 and all(v.isdigit() for v in pos): entry['nativeSlot']=int(pos[0])+4*int(pos[1])
    entry['heroSkills']={raw:int(abilities[raw]['levels']) for raw in ua[source].get('heroAbilList','').split(',') if raw in abilities}
    if order: entry['order'] = order
    if ability: entry['ability'] = ability
    entry.update(extra)
    if extra.get('researchLevel',1)>1:
        entry['id'] += '.level'+str(extra['researchLevel'])
    catalog.append(entry)

def requirements(fields, race, level=0):
    result_units, result_research, unresolved = {}, {}, []
    key = 'requires' if level == 0 else 'requires'+str(level)
    raw_list = [raw for raw in fields.get(key,fields.get('requires','')).split(',') if raw]
    amounts = fields.get('requiresamount','').split(',')
    for index, raw in enumerate(raw_list):
        amount = int(amounts[index]) if index<len(amounts) and amounts[index].isdigit() else 1
        if raw in item_ui and raw not in items and item_ui[raw].get('dependencyor'):
            alternatives = item_ui[raw]['dependencyor'].split(',')
            raw = next((candidate for candidate in alternatives if units.get(candidate,{}).get('race')==race),alternatives[0])
        if raw in units: result_units[raw]=max(result_units.get(raw,0),amount)
        elif raw in upgrade_data: result_research[raw]=max(result_research.get(raw,0),amount)
        else: unresolved.append(raw)
    return result_units,result_research,unresolved

def complete_research_requirements(required_units,required_research,race):
    pending=list(required_research)
    seen=set()
    while pending:
        raw=pending.pop()
        if raw in seen: continue
        seen.add(raw)
        more_units,more_research,unknown=requirements(upgrades.get(raw,{}),race,required_research[raw]-1)
        assert not unknown,(raw,unknown)
        for unit,amount in more_units.items(): required_units[unit]=max(required_units.get(unit,0),amount)
        for tech,level in more_research.items():
            required_research[tech]=max(required_research.get(tech,0),level)
            if tech not in seen: pending.append(tech)

for race, sources in SOURCES.items():
    for source in sources:
        assert source in units and source in ua and source in unit_skin, source
        native = uf.get(source, {})
        for field, kind in [('trains','train'), ('builds','build'), ('researches','research'),
                            ('upgrade','upgrade'), ('sellunits','hire'), ('sellitems','buy'), ('makeitems','buy')]:
            for raw in native.get(field, '').split(','):
                if not raw: continue
                if kind in ('train','build','upgrade','hire'):
                    if raw not in units or raw not in unit_skin:
                        excluded.append(dict(source=source,raw=raw,reason='Referenced command has no native unit record'))
                        continue
                    fields = {**unit_skin[raw], **us.get(raw, {})}
                elif kind == 'research':
                    assert raw in upgrade_data, (source, raw)
                    fields = {**upgrades.get(raw, {}), **upgrade_names.get(raw, {})}
                else:
                    assert raw in items, (source, raw)
                    fields = {**item_ui[raw], **item_names[raw]}
                    assert name(fields, raw) != raw, f'Missing localized item name: {source}/{raw}'
                extra = {}
                if kind in ('train','hire') and ua.get(raw,{}).get('heroAbilList',''):
                    extra['heroRecruitment']=True
                native_pos=(upgrades.get(raw,{}) if kind=='research' else item_ui.get(raw,{}) if kind=='buy' else uf.get(raw,{})).get('buttonpos','').split(',')
                if len(native_pos)==2 and all(v.isdigit() for v in native_pos):
                    extra['nativeSlot']=int(native_pos[0])+4*int(native_pos[1])
                if kind == 'build':
                    builders = {'human':'AHbu','orc':'AObu','nightelf':'AEbu','undead':'AUbu'}
                    extra['ability'] = builders[race]
                    pos = af[builders[race]]['buttonpos'].split(',')
                    extra['openSlot'] = int(pos[0]) + 4 * int(pos[1])
                    extra['buildOrder'] = af[builders[race]]['order']
                    extra['buildIcon'] = ability_skin[builders[race]]['art']
                req_fields = upgrades.get(raw,{}) if kind=='research' else (item_ui.get(raw,{}) if kind=='buy' else uf.get(raw,{}))
                required_units,required_research,unknown = requirements(req_fields,race,1 if kind=='hire' and 'requires1' in req_fields else 0)
                # Altar hero recruitment also requires the race's main building;
                # that implicit melee requirement is absent from hero Requires.
                main_buildings={'human':('htow','hkee','hcas'),
                    'orc':('ogre','ostr','ofrt'),'nightelf':('etol','etoa','etoe'),
                    'undead':('unpl','unp1','unp2')}
                if extra.get('heroRecruitment') and kind in ('train','hire'):
                    tiers=main_buildings.get(race,main_buildings['human'])
                    for main in tiers: required_units.pop(main,None)
                    required_units[tiers[2]]=1
                complete_research_requirements(required_units,required_research,race)
                if unknown:
                    excluded.append(dict(source=source,raw=raw,reason='Unresolved requirements: '+','.join(unknown)))
                    continue
                # A finished source already supplies its own type requirement.
                if required_units.get(source)==1: required_units.pop(source)
                extra.update(requiredUnits=required_units,requiredResearch=required_research)
                levels=int(upgrade_data[raw]['maxlevel']) if kind=='research' else 1
                for level in range(1,levels+1):
                    level_fields=dict(fields)
                    level_extra=dict(extra)
                    if kind=='research':
                        # Native UI arrays contain a separate name, texture and
                        # description for each supported research level.
                        for key in ('name','tip','art','art:sd','ubertip'):
                            if key not in fields: continue
                            values=next(csv.reader([fields[key]],skipinitialspace=True))
                            value=values[min(level-1,len(values)-1)]
                            level_fields[key]='"'+value.replace('"','""')+'"'
                        req_units,req_research,unknown=requirements(req_fields,race,level-1)
                        assert not unknown,(raw,level,unknown)
                        complete_research_requirements(req_units,req_research,race)
                        if req_units.get(source)==1: req_units.pop(source)
                        level_extra.update(researchLevel=level,requiredUnits=req_units,requiredResearch=req_research)
                    add(race, source, raw, kind, level_fields, **level_extra)
        native_abilities = ','.join([ua[source].get('abilList',''),ua[source].get('heroAbilList','')])
        for raw in ua[source].get('heroAbilList','').split(','):
            if raw not in abilities: continue
            fields={**ability_skin.get(raw,{}),**af.get(raw,{}),**ast.get(raw,{})}
            fields['art']=fields.get('researchart',fields.get('art','')).replace('PassiveButtons\\PAS','CommandButtons\\BTN')
            pos=fields.get('researchbuttonpos','').split(',')
            assert len(pos)==2, (source,raw,'Missing learn position')
            add(race,source,raw,'learn',fields,ability=raw,order=raw,
                buildIcon='ReplaceableTextures\\CommandButtons\\BTNSkillz.blp',
                openSlot=11,buildOrder='skillmenu',learnSlot=int(pos[0])+4*int(pos[1]),
                description=description(fields.get('researchubertip',fields.get('ubertip',''))))
        for raw in dict.fromkeys(native_abilities.split(',')):
            if raw not in abilities: continue
            fields = {**ability_skin.get(raw, {}), **af.get(raw, {}), **ast.get(raw, {})}
            order = fields.get('order', '')
            autocast_off = fields.get('orderoff', '')
            # Neutral Heal inherits the engine's Anhe orders, despite the
            # UI function file reusing Priest Heal's order strings.
            if abilities[raw].get('code') == 'Anhe':
                order, autocast_off = 'creepheal', 'creephealoff'
            # The native UI text files omit or mislabel these engine orders.
            # Searing Arrows has a separate manual-target and autocast order.
            overrides={
                'Ambt':('recharge','rechargeoff'),
                'AHfa':('flamingarrowstarg','unflamingarrows'),
                'ANia':('incineratearrow','incineratearrowoff'),
            }
            if abilities[raw].get('code') in overrides:
                order, autocast_off = overrides[abilities[raw]['code']]
            icon = first(fields.get('art', ''))
            if not order or not icon or 'PassiveButtons' in icon or 'PASBTN' in icon or raw in ('AInv','Aroo','Aro1','Aro2'):
                excluded.append(dict(source=source,raw=raw,reason='Passive, engine command, or no native order metadata'))
                continue
            if source=='ubsp' and raw=='Aave':
                excluded.append(dict(source=source,raw=raw,reason='Destroyer Form is only actionable before transformation'))
                continue
            # Build-menu commands are represented by the buildings above.
            if raw in ('AHbu','AObu','AEbu','AUbu'): continue
            required_units,required_research,unknown = requirements(af.get(raw,{}),race)
            complete_research_requirements(required_units,required_research,race)
            if unknown:
                excluded.append(dict(source=source,raw=raw,reason='Unresolved requirements: '+','.join(unknown)))
                continue
            add(race, source, raw, 'ability', fields, order=order, ability=raw,
                autocastOff=autocast_off,
                activeAbility={'ANcs':'ANc3','ANsy':'ANs3'}.get(raw,raw),
                uprooted=raw=='Aeat',night=raw=='Ashm',
                requiredUnits=required_units,requiredResearch=required_research)

# Universal prompts omit the source icon, but retain a hidden native context.
for raw, label, order, icon, source, ability in [
 ('move','Move','move','BTNMove','hfoo',None),
 ('hold','Hold Position','holdposition','BTNHoldPosition','hfoo',None),
 ('attack','Attack','attack','BTNAttack','hfoo',None),
 ('stop','Stop','stop','BTNStop','hfoo',None),
 ('patrol','Patrol','patrol','BTNPatrol','hfoo',None),
 ('gather','Gather','harvest','BTNGatherGold','hpea',None),
 ('uproot','Uproot','unroot','BTNUproot','etol','Aro1'),
 ('root','Take Root','root','BTNRoot','etol','Aro1'),
 ('select','Select User','neutralinteract','BTNSelectUnit','ngme','Aneu'),
]:
    path='ReplaceableTextures\\CommandButtons\\'+icon+'.blp'
    add('common',source,raw,'common',dict(name=label,art=path),order=order,ability=ability,universal=True)

parser = argparse.ArgumentParser()
parser.add_argument('--verified', action='store_true')
args = parser.parse_args()
icon_paths = sorted({entry[key] for entry in catalog for key in ('icon','sourceIcon','buildIcon') if key in entry})
(ROOT/'work/hotkey-icon-paths.json').write_text(json.dumps(icon_paths,indent=2),encoding='utf-8')
if args.verified:
    verified = {row['path']:row['found'] for row in json.loads((ROOT/'work/hotkey-icons-verified.json').read_text(encoding='utf-8-sig'))}
    missing = [icon for icon in icon_paths if not verified.get(icon)]
    assert not missing, f'Icons missing from installed CASC: {missing}'
    snapshot = dict(game='Installed Warcraft III 3.0.0.24268 melee data', entries=catalog, excluded=excluded)
    (ROOT/'src/data/hotkey-catalog.json').write_text(json.dumps(snapshot,indent=2)+'\n',encoding='utf-8')
    (ROOT/'src/data/native-unit-ids.json').write_text(json.dumps(sorted(units),indent=2)+'\n',encoding='utf-8')
    def lua(value):
        if isinstance(value,bool): return 'true' if value else 'false'
        if isinstance(value,int): return str(value)
        if isinstance(value,dict): return '{'+', '.join('['+lua(key)+'] = '+lua(item) for key,item in value.items())+'}'
        return json.dumps(value,ensure_ascii=False)
    rows=['-- Generated from src/data/hotkey-catalog.json; native texture audit passed.', 'JTG = JTG or {}', 'JTG.HotkeyCatalog = {']
    rows += ['    {'+', '.join(key+' = '+lua(value) for key,value in entry.items())+'},' for entry in catalog]
    rows += ['}', '']
    # Practice lists are separate from the complete diagnostic catalogue.
    # Keep unresolved contexts available for targeted audits, not random play.
    unverified={
        'common.hpea.common.gather':'Native Gather activation is unresolved.',
        'common.ngme.common.select':'Native Select User activation is unresolved.',
        'neutral.nzep.ability.Adro':'Passenger loading / Unload activation is unresolved.',
        'undead.uaco.ability.Alam':'Sacrifice activation is unresolved.',
        'undead.ubsp.ability.Aabs':'Absorb Mana activation is unresolved.',
        'undead.Udre.ability.AUin':'Inferno activation is unresolved.',
    }
    pools={}
    pool_directory=ROOT/'src/data/hotkey-pools'
    pool_directory.mkdir(parents=True,exist_ok=True)
    for race in ('human','orc','nightelf','undead','neutral'):
        pools[race]=[entry['id'] for entry in catalog
            if entry['id'] not in unverified and
            (entry['race']==race or entry['race']=='common' and
                (entry['raw'] not in ('root','uproot') or race=='nightelf'))]
        (pool_directory/f'{race}.json').write_text(json.dumps(dict(race=race,
            commands=pools[race]),indent=2)+'\n',encoding='utf-8')
    rows+=['local hotkeyById = {}',
        'for _, entry in ipairs(JTG.HotkeyCatalog) do hotkeyById[entry.id] = entry end',
        'JTG.HotkeyPools = {']
    for race,ids in pools.items():
        rows+=['    '+race+' = {']+['        hotkeyById['+lua(key)+'],' for key in ids]+['    },']
    rows+=['}', 'JTG.HotkeyUnverified = '+lua(unverified),
        'JTG.HotkeyCommandsBySource = {}',
        'for _, entry in ipairs(JTG.HotkeyCatalog) do',
        '    local commands = JTG.HotkeyCommandsBySource[entry.source] or {}',
        '    commands[#commands+1] = entry',
        '    JTG.HotkeyCommandsBySource[entry.source] = commands',
        'end', '']
    prerequisite_units = sorted({source for sources in SOURCES.values() for source in sources
        if 'structure' in units[source].get('targType','')})
    rows += ['JTG.HotkeyPrerequisites = {' + ', '.join(lua(raw) for raw in prerequisite_units) + '}', '']
    rows += ['JTG.HotkeyRacePrerequisites = {']
    for race, sources in SOURCES.items():
        buildings = sorted({source for source in sources if 'structure' in units[source].get('targType','')})
        # Tavern hero purchases require an altar; one native Human altar suffices.
        if race == 'neutral': buildings.append('halt')
        rows += ['    '+race+' = {'+', '.join(lua(raw) for raw in buildings)+'},']
    rows += ['}', '']
    (ROOT/'src/generated/hotkey-catalog.lua').write_text('\n'.join(rows),encoding='utf-8')
    inventory=[]
    for race,sources in SOURCES.items():
        if race=='neutral': continue
        records={}
        reachable=set(sources)
        pending=list(sources)
        while pending:
            source=pending.pop()
            for field in ('trains','builds','upgrade'):
                for raw in uf.get(source,{}).get(field,'').split(','):
                    if raw in units and raw not in reachable:
                        reachable.add(raw)
                        pending.append(raw)
        for source in sorted(reachable):
            records[('unit/building',source)]={**uf.get(source,{}),**us.get(source,{})}
            for field,kind in [('researches','research'),('makeitems','item')]:
                for raw in uf.get(source,{}).get(field,'').split(','):
                    if raw: records[(kind,raw)]={**(upgrades.get(raw,{}) if kind=='research' else item_ui.get(raw,{})),**(upgrade_names.get(raw,{}) if kind=='research' else item_names.get(raw,{}))}
            for raw in (ua[source].get('abilList','')+','+ua[source].get('heroAbilList','')).split(','):
                if raw in af: records[('ability',raw)]={**af[raw],**ast.get(raw,{})}
        for (kind,raw),fields in sorted(records.items()):
            req={key:fields[key] for key in ('requires','requires1','requires2','requiresamount','requirescount','dependencyor') if key in fields}
            inventory.append(dict(race=race,kind=kind,raw=raw,name=name(fields,raw),requirements=req))
    (ROOT/'src/data/melee-prerequisites.json').write_text(json.dumps(dict(game=snapshot['game'],aliases={key:item_ui[key]['dependencyor'].split(',') for key in ('TWN1','TWN2','TWN3','TALT')},records=inventory),indent=2)+'\n',encoding='utf-8')
    review=['# Melee prerequisite inventory','', 'Generated from installed Warcraft III 3.0.0.24268 native data. An empty requirement means no explicit technology prerequisite; costs, food, cooldowns, stock and hero limits are separate. `Requires1` and `Requires2` are requirements for subsequent research/hero levels. `DependencyOr` lists alternative types which satisfy a dependency.','']
    labels={raw:name(us.get(raw,{}),raw) for raw in units}
    labels.update({raw:name(upgrade_names.get(raw,{}),raw) for raw in upgrade_data})
    for race in ('human','orc','nightelf','undead'):
        review+=['## '+{'human':'Human','orc':'Orc','nightelf':'Night Elf','undead':'Undead'}[race],'','| Type | Name / ID | Native prerequisites |','| --- | --- | --- |']
        for record in inventory:
            if record['race']!=race: continue
            req='; '.join(key+': '+', '.join(labels.get(raw,raw)+' (`'+raw+'`)' for raw in value.split(',') if raw) for key,value in record['requirements'].items() if value)
            review+=['| '+record['kind']+' | '+record['name']+' (`'+record['raw']+'`) | '+(req or 'None')+' |']
        review+=['']
    (ROOT/'docs/MELEE-PREREQUISITES.md').write_text('\n'.join(review)+'\n',encoding='utf-8')
print(f'{len(catalog)} commands; {len(icon_paths)} textures; by race: {dict(Counter(e["race"] for e in catalog))}')
