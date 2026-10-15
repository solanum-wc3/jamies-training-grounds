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
    const text=(key,value)=>Buffer.concat([Buffer.from(key),i32(3),Buffer.from(value+'\0'),Buffer.from('jHdm')]);
    const number=(key,value)=>Buffer.concat([Buffer.from(key),i32(0),i32(value),Buffer.from('jHdm')]);
    const mods=[text('unam','Target Dummie'),text('utip','Target Dummie'),text('utub','Target Dummie'),
        text('umdl',model),text('uabi','JHdN,JHdH,JHa3,JHdP,JHdM'),text('umvt','none'),
        number('udef',0),text('udty','large'),number('uaen',0),number('umvs',0),number('ufoo',0)];
    const object=Buffer.concat([Buffer.from('hfoojHdm'),i32(1),i32(0),i32(mods.length),...mods]);
    return Buffer.concat([buffer.subarray(0,countOffset),i32(count+1),buffer.subarray(countOffset+4),object]);
}
// The foundation has no ability overrides. Keep this table explicit and local:
// Non-targeted Channel commands, with distinct native orders and no costs.
function createHeroesDummyAbilities() {
    const i32=value=>{const b=Buffer.alloc(4);b.writeInt32LE(value);return b;};
    const real=value=>{const b=Buffer.alloc(4);b.writeFloatLE(value);return b;};
    const armor=require('../src/data/heroes-tutorial-data.json').dummyArmorTypes;
    const objects=[['JHdN','Neutral Mode','ReplaceableTextures\\CommandButtons\\BTNStop.blp','berserk',0,0],
        ['JHdH','Hostile Mode','ReplaceableTextures\\CommandButtons\\BTNAttack.blp','roar',1,0],
        ...armor.map((type,index)=>[type.raw,'Change Armor Type',type.icon,
            ['frenzy','defend','undefend','immolation','unimmolation','howlofterror'][index],0,1]),
        ['JHdP','Raise Armor','JTGMenu\\ArmorPlus.dds','fanofknives',3,1],
        ['JHdM','Lower Armor','JTGMenu\\ArmorMinus.dds','thunderclap',3,2],
    ].map(([id,name,icon,order,x,y])=>{
        const mod=(field,type,value,level=0,pointer=0)=>Buffer.concat([
            Buffer.from(field),i32(type),i32(level),i32(pointer),
            type===3?Buffer.from(value+'\0'):type===0?i32(value):real(value),Buffer.from(id)]);
        const mods=[mod('anam',3,name),mod('aart',3,icon),
            mod('atp1',3,name,1),mod('aub1',3,name,1),mod('aher',0,0),mod('alev',0,1),
            mod('abpx',0,x),mod('abpy',0,y),mod('arac',3,'other'),mod('areq',3,''),mod('ahky',3,''),
            mod('amcs',0,0,1),mod('acdn',2,0,1),mod('acas',2,0,1),
            mod('acat',3,''),mod('atat',3,''),mod('aeat',3,''),
            mod('Ncl1',2,0,1,1),mod('Ncl2',0,0,1,2),mod('Ncl3',0,1,1,3),
            mod('Ncl4',2,0,1,4),mod('Ncl5',0,0,1,5),mod('Ncl6',3,order,1,6)];
        return Buffer.concat([Buffer.from('ANcl'+id),i32(1),i32(0),i32(mods.length),...mods]);
    });
    return Buffer.concat([i32(3),i32(0),i32(objects.length),...objects]);
}
module.exports={patchHeroesDummy,createHeroesDummyAbilities};
