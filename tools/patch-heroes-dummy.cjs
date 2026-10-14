// Add one selectable, attackable unit using the verified native archery-target
// model. Preserve all existing unit objects and stock overrides byte for byte.
const assert=require('node:assert/strict');
function patchHeroesDummy(buffer,model) {
    let offset=0;
    const int=()=>{const value=buffer.readInt32LE(offset);offset+=4;return value;};
    assert.equal(int(),3);
    const skipObjects=()=>{
        for(let objects=int();objects>0;objects--){
            offset+=8;
            for(let sets=int();sets>0;sets--){
                int();
                for(let mods=int();mods>0;mods--){
                    offset+=4;const type=int();
                    if(type===3){const end=buffer.indexOf(0,offset);assert(end>=offset);offset=end+1;}
                    else {assert(type>=0&&type<=2);offset+=4;}
                    offset+=4;
                }
            }
        }
    };
    skipObjects();const countOffset=offset,count=buffer.readInt32LE(offset);
    skipObjects();assert.equal(offset,buffer.length);
    const i32=value=>{const b=Buffer.alloc(4);b.writeInt32LE(value);return b;};
    const text=(key,value)=>Buffer.concat([Buffer.from(key),i32(3),Buffer.from(value+'\0'),Buffer.from('JHdm')]);
    const object=Buffer.concat([Buffer.from('hfooJHdm'),i32(1),i32(0),i32(2),
        text('unam','Target Dummies'),text('umdl',model)]);
    return Buffer.concat([buffer.subarray(0,countOffset),i32(count+1),buffer.subarray(countOffset+4),object]);
}
module.exports={patchHeroesDummy};
