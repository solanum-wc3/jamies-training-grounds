// Presentation-only XP buildings inherit native stats, but have no ground
// texture. Never change the stock units used by gameplay activities.
const assert=require('node:assert/strict');
const i32=value=>{const bytes=Buffer.alloc(4);bytes.writeInt32LE(value);return bytes;};
function presentationBuildings(data) {
    const raws=[...new Set(Object.values(data.racialUnits).flat().filter(row=>row.building).map(row=>row.raw))].sort();
    assert(raws.length<36*36,'Presentation building ID range exhausted');
    return Object.fromEntries(raws.map((raw,index)=>[raw,'jX'+index.toString(36).toUpperCase().padStart(2,'0')]));
}
function patchPresentationBuildings(buffer,mapping) {
    let offset=0;
    const int=()=>{const value=buffer.readInt32LE(offset);offset+=4;return value;};
    const raw=()=>{const value=buffer.toString('ascii',offset,offset+4);offset+=4;return value;};
    assert.equal(int(),3);
    const originals=new Map(),ids=new Set();let customCountOffset,customCount;
    for(let table=0;table<2;table++) {
        if(table===1)customCountOffset=offset;
        const count=int();if(table===1)customCount=count;
        for(let object=0;object<count;object++) {
            const parent=raw(),id=raw(),sets=[];ids.add(table===0?parent:id);
            for(let count=int();count>0;count--) {
                const flag=int(),mods=[];
                for(let count=int();count>0;count--) {
                    const begin=offset,field=raw(),type=int();
                    if(type===3){const end=buffer.indexOf(0,offset);assert(end>=offset);offset=end+1;}
                    else {assert(type>=0&&type<=2);offset+=4;}
                    offset+=4;mods.push({field,bytes:buffer.subarray(begin,offset)});
                }
                sets.push({flag,mods});
            }
            if(table===0)originals.set(parent,sets);
        }
    }
    assert.equal(offset,buffer.length,'Trailing unit object data');
    const additions=Object.entries(mapping).map(([parent,id])=>{
        assert(!ids.has(id),'Presentation unit ID collision: '+id);ids.add(id);
        const sets=originals.get(parent)||[{flag:0,mods:[]}];
        return Buffer.concat([Buffer.from(parent+id),i32(sets.length),...sets.flatMap(set=>{
            const mods=set.mods.filter(mod=>mod.field!=='uubs').map(mod=>
                Buffer.concat([mod.bytes.subarray(0,-4),Buffer.from(id)]));
            mods.push(Buffer.concat([Buffer.from('uubs'),i32(3),Buffer.from('_\0'),Buffer.from(id)]));
            return [i32(set.flag),i32(mods.length),...mods];
        })]);
    });
    return Buffer.concat([buffer.subarray(0,customCountOffset),i32(customCount+additions.length),
        buffer.subarray(customCountOffset+4),...additions]);
}
function configureDummyControl(script) {
    const start=script.lastIndexOf('function config()');
    assert(start>=0,'Map configuration missing');
    const config=script.slice(start),marker='InitAllyPriorities()';
    assert.equal(config.split(marker).length,2,'Map configuration boundary changed');
    return script.slice(0,start)+config.replace(marker,marker+
        '\n-- Player 6 is reserved for controllable hostile Target Dummies.\n'+
        'SetPlayerAlliance(Player(6), Player(0), ALLIANCE_SHARED_CONTROL, true)');
}
module.exports={presentationBuildings,patchPresentationBuildings,configureDummyControl};
