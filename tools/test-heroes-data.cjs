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
assert(step('heroes.039').lines.some(line=>line.includes('only your Paladin')));
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
const {patchHeroesDummy}=require('./patch-heroes-dummy.cjs');
const result=patchHeroesDummy(existing,data.dummyModel);
assert.deepEqual(result.subarray(0,existing.length-4),existing.subarray(0,existing.length-4));
assert.equal(result.readInt32LE(existing.length-4),1);
assert.equal(result.subarray(existing.length,existing.length+8).toString(),'hfooJHdm');
assert(result.includes(Buffer.from('Target Dummies\0')));
assert(result.includes(Buffer.from(data.dummyModel+'\0')));
assert.equal(result.subarray(-4).toString(),'JHdm');
console.log('Passed: Heroes authored decisions, native data groups, unique TM drops and preserved unit overrides.');
