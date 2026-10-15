const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const root=path.resolve(__dirname,'..');
const read=file=>JSON.parse(fs.readFileSync(path.join(root,file),'utf8'));
const data=read('src/data/heroes-tutorial-data.json');
const script=read('design/tutorials/heroes-script.json');
require('./prepare-heroes-tutorial.cjs').prepare(true);
assert.equal(script.steps.length,47);
const step=id=>script.steps.find(row=>row.id===id);
assert(!step('heroes.027')&&!step('heroes.010')&&!step('heroes.038'));
assert(step('heroes.028').lines.some(line=>line.includes('Afterwards')));
assert.equal(step('heroes.028').scene,'xp-range-1');
assert(step('heroes.039').lines.includes('Attack the Gnoll again, using your entire army! Keep both heroes within the circle.'));
assert(script.quest.includes('- Level 4: {Yellow Font: 50%}') && script.quest.includes('- Level 5 and above: {Yellow Font: 0%}'));
assert(!script.quest.includes('20% for every hero level'));
assert(!script.quest.includes('is multiplied'));
assert(script.steps.some(row=>row.lines.includes('Upon reaching tier 3, this bonus is raised to {Yellow Font: +30%}.')));
assert(script.steps.some(row=>row.lines.includes('Destroying it requires three attacks.')));
assert.equal(data.xpRange,1200);
assert.deepEqual(data.creepFactors,[.8,.7,.6,.5,0]);
assert.equal(Object.keys(data.heroStats).length,25);
assert.deepEqual(new Set(Object.values(data.heroStats).map(row=>row.dice+'D'+row.sides)),
    new Set(['2D4','2D6','2D12','2D11','3D10']));
for(const rows of Object.values(data.racialUnits)) {
    assert.equal(new Set(rows.map(row=>row.raw)).size,rows.length);
    for(const row of rows) {
        assert.match(row.raw,/^[a-z][A-Za-z0-9]{3}$/,'Hero incorrectly included in racial XP list');
        assert(row.xp>=0&&row.food>=0&&row.level>=0);
    }
}
assert.equal(data.racialUnits.neutral.length,25);
assert(!data.racialUnits.nightelf.some(row=>row.raw==='even'));
assert(data.racialUnits.nightelf.some(row=>row.raw==='espv'));
assert.equal(data.racialUnits.neutral.find(row=>row.raw==='nba2').food,0);
assert(data.racialUnits.neutral.every(row=>row.summon));
for(const raw of ['nba2','nfac','nfa1','nfa2','ncgb','ncg1','ncg2','npn1','npn2','npn3',
    'ngz1','ngz2','ngz3','nqb1','nqb2','nqb3','nwe1','nwe2','nwe3',
    'nlv1','nlv2','nlv3','ndr1','ndr2','ndr3']) {
    assert(data.racialUnits.neutral.some(row=>row.raw===raw));
}
for(const [race,raws] of Object.entries({human:['hgtw','hctw','hatw'],orc:['owtw','otrb'],
    nightelf:['etrp'],undead:['uzg1','uzg2','unp1','unp2']})) {
    for(const raw of raws) assert(data.racialUnits[race].some(row=>row.raw===raw&&row.building));
}
const items=data.itemGroups.flatMap(group=>group.items);
assert.equal(items.length,49);assert.equal(new Set(items).size,49);
assert(data.itemGroups.every(group=>group.campLevel>0));
const i32=n=>{const b=Buffer.alloc(4);b.writeInt32LE(n);return b;};
const existing=Buffer.concat([i32(3),i32(1),Buffer.from('hfoo'),i32(0),i32(1),i32(0),i32(1),
    Buffer.from('uhpm'),i32(0),i32(420),Buffer.from('hfoo'),i32(0)]);
const {patchHeroesDummy,createHeroesDummyAbilities}=require('./patch-heroes-dummy.cjs');
const result=patchHeroesDummy(existing,data.dummyModel);
assert.deepEqual(result.subarray(0,existing.length-4),existing.subarray(0,existing.length-4));
assert.equal(result.readInt32LE(existing.length-4),1);
assert.equal(result.subarray(existing.length,existing.length+8).toString(),'hfoojHdm');
assert(result.includes(Buffer.from('Target Dummie\0')));
assert(result.includes(Buffer.from(data.dummyModel+'\0')));
assert.equal(result.subarray(-4).toString(),'jHdm');
// Decode the emitted native tables, including level/data-pointer fields.
function decode(buffer,ability=false) {
    let offset=0;
    const int=()=>{const n=buffer.readInt32LE(offset);offset+=4;return n;};
    const raw=()=>{const s=buffer.toString('ascii',offset,offset+4);offset+=4;return s;};
    assert.equal(int(),3);const tables=[];
    for(let table=0;table<2;table++) {
        const objects=[];
        for(let count=int();count>0;count--) {
            const parent=raw(),id=raw(),mods={};
            for(let sets=int();sets>0;sets--) {
                int();
                for(let count=int();count>0;count--) {
                    const field=raw(),type=int();let level=0,pointer=0,value;
                    if(ability) {level=int();pointer=int();}
                    if(type===3) {const end=buffer.indexOf(0,offset);assert(end>=offset);value=buffer.toString('utf8',offset,end);offset=end+1;}
                    else {value=type===0?buffer.readInt32LE(offset):buffer.readFloatLE(offset);offset+=4;}
                    raw();mods[field]={value,level,pointer};
                }
            }
            objects.push({parent,id,mods});
        }
        tables.push(objects);
    }
    assert.equal(offset,buffer.length);return tables;
}
const dummy=decode(result)[1][0].mods;
assert.equal(dummy.unam.value,'Target Dummie');assert.equal(dummy.utip.value,'Target Dummie');
assert.equal(dummy.uabi.value,'JHdN,JHdH,JHa3,JHdP,JHdM');assert.equal(dummy.uaen.value,0);
assert.equal(dummy.udef.value,0);assert.equal(dummy.udty.value,'large');
assert.equal(dummy.umvt.value,'none');assert.equal(dummy.ufoo.value,0);
const controls=decode(createHeroesDummyAbilities(),true)[1];
assert.equal(controls.length,10);
for(const [index,control] of controls.entries()) {
    assert.equal(control.parent,'ANcl');
    assert.equal(control.mods.Ncl2.value,0);assert.equal(control.mods.Ncl3.value,1);
    assert.equal(control.mods.Ncl1.value,0);assert.equal(control.mods.Ncl5.value,0);
    assert.equal(control.mods.Ncl6.pointer,6);assert.equal(control.mods.Ncl6.level,1);
    assert.equal(control.mods.amcs.value,0);assert.equal(control.mods.acdn.value,0);
    if(index<2) {
        assert.equal(control.id,index===0?'JHdN':'JHdH');assert.equal(control.mods.abpx.value,index);
        assert(control.mods.aart.value.includes(index===0?'BTNStop.blp':'BTNAttack.blp'));
    } else if(index<8) {
        const type=data.dummyArmorTypes[index-2];
        assert.equal(control.id,type.raw);assert.equal(control.mods.aart.value,type.icon);
        assert.equal(control.mods.abpx.value,0);assert.equal(control.mods.abpy.value,1);
    } else {
        assert.equal(control.mods.abpx.value,3);assert.equal(control.mods.abpy.value,index===8?1:2);
        assert(control.mods.aart.value.endsWith(index===8?'ArmorPlus.dds':'ArmorMinus.dds'));
    }
}
assert.equal(new Set(controls.map(control=>control.mods.Ncl6.value)).size,controls.length);
assert.deepEqual(data.dummyArmorTypes.map(type=>type.defense),[7,0,1,2,3,5]);
assert.equal(decode(result)[1][0].id[0],'j','Dummy must not use a hero-class uppercase unit ID');
console.log('Passed: Heroes authored decisions, native data groups, unique TM drops and preserved unit overrides.');
