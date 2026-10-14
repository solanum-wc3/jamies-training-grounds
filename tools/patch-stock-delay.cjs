// Patch only stock-start fields in v3 unit/item object tables.
const assert=require('node:assert/strict');
const integer=value=>{const b=Buffer.alloc(4);b.writeInt32LE(value);return b;};
function patchStockDelay(buffer,ids,field) {
    let offset=0;
    const int=()=>{const n=buffer.readInt32LE(offset);offset+=4;return n;};
    const raw=()=>{const s=buffer.toString('ascii',offset,offset+4);offset+=4;return s;};
    assert.equal(int(),3,'Expected v3 object table');
    const tables=[];
    for(let table=0;table<2;table++) {
        const objects=[];
        for(let count=int();count>0;count--) {
            const old=raw(),id=raw(),sets=[];
            for(let count=int();count>0;count--) {
                const flag=int(),mods=[];
                for(let count=int();count>0;count--) {
                    const begin=offset,key=raw(),type=int();
                    if(type===3) {const end=buffer.indexOf(0,offset);assert(end>=offset);offset=end+1;}
                    else {assert(type>=0&&type<=2);offset+=4;}
                    offset+=4;
                    mods.push({key,bytes:buffer.subarray(begin,offset)});
                }
                sets.push({flag,mods});
            }
            objects.push({old,id,sets});
        }
        tables.push(objects);
    }
    assert.equal(offset,buffer.length,'Trailing object data');
    for(const id of [...new Set(ids)].sort()) {
        let object=tables[0].find(o=>o.old===id);
        if(!object) {object={old:id,id:'\0\0\0\0',sets:[{flag:0,mods:[]}]};tables[0].push(object);}
        const bytes=Buffer.concat([Buffer.from(field,'ascii'),integer(0),integer(0),Buffer.from(id,'ascii')]);
        assert(object.sets.length>0);
        for(const set of object.sets) {
            set.mods=set.mods.filter(m=>m.key!==field);
            set.mods.push({key:field,bytes});
        }
    }
    return Buffer.concat([integer(3),...tables.flatMap(objects=>[integer(objects.length),
        ...objects.flatMap(o=>[Buffer.from(o.old,'ascii'),Buffer.from(o.id,'ascii'),integer(o.sets.length),
            ...o.sets.flatMap(s=>[integer(s.flag),integer(s.mods.length),...s.mods.map(m=>m.bytes)])])])]);
}
module.exports={patchStockDelay};
