/* Reproducible, narrowly scoped patch of the supplied Reforged map.
 * Source format references and design decisions: docs/decisions/0002-terrain-foundation.md.
 * Existing records are copied byte-for-byte instead of reserialized. Fail closed
 * on a changed reference hash, unexpected record layout, or any out-of-area edit.
 */
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const assert = require('node:assert/strict');
const {createRequire} = require('node:module');
const root = path.resolve(__dirname, '..');
const req = createRequire(path.join(root, 'work/mpq-tool/package.json'));
const {Archive, MPQ_FILE_COMPRESS, MPQ_FILE_REPLACEEXISTING, MPQ_COMPRESSION_ZLIB} = req('@jamiephan/stormlib');
const luaParser = req('luaparse');
const original = path.join(root, 'reference/twisted-meadows/TwistedMeadows-v1.9-original.w3x');
const version = 'v0.0.1-alpha.5';
const output = path.join(root, `outputs/Jamies-Training-Grounds-${version}.w3x`);
const work = path.join(root, 'work/baseline-build');
const hash = b => crypto.createHash('sha256').update(b).digest('hex');
const sourceHash = 'd4e444bfb6c0063da75fb88b8a57490b5d299f59d0f88344ac9910d1e45ffa3f';
const A = {minX:2048, minY:2048, maxX:7808, maxY:7552};
const inside = (x,y) => x>=A.minX && x<=A.maxX && y>=A.minY && y<=A.maxY;
const i32 = n => {const b=Buffer.alloc(4);b.writeInt32LE(n);return b;};
const str = s => Buffer.from(s+'\0');
const raw=fs.readFileSync(original);
assert.equal(hash(raw),sourceHash,'Reference map changed; review before rebuilding');
fs.mkdirSync(path.dirname(output),{recursive:true});
fs.mkdirSync(work,{recursive:true});
const archive=Archive.open(original,{flags:256});
const source=new Map(archive.getFileNames().map(n=>[n,archive.readFile(n)]));
archive.close();
const changes=new Map();
const report={version,sourceSha256:sourceHash,area:A,output,preservation:{},removed:{}};

// Binary cursors are used only to find record boundaries. Surviving record bytes
// are never rewritten, preserving random drops, scale, skin, ownership and IDs.
class Cursor {
    constructor(b,p=0){this.b=b;this.p=p;}
    skip(n){this.p+=n;assert(this.p<=this.b.length);}
    int(){const n=this.b.readInt32LE(this.p);this.skip(4);return n;}
    count(){const n=this.int();assert(n>=0&&n<100000,'Invalid count');return n;}
    float(){const n=this.b.readFloatLE(this.p);this.skip(4);assert(Number.isFinite(n));return n;}
    text(){const end=this.b.indexOf(0,this.p);assert(end>=0);const s=this.b.toString('utf8',this.p,end);this.p=end+1;return s;}
}
function parsePlaced(b,unit){
    assert.equal(b.toString('ascii',0,4),'W3do');
    const c=new Cursor(b,4),version=c.int(),subversion=c.int(),count=c.count();
    assert.equal(version,8);assert.equal(subversion,11);
    const records=[];
    for(let i=0;i<count;i++){
        const start=c.p,id=b.toString('ascii',c.p,c.p+4);c.skip(8);
        const x=c.float(),y=c.float();c.skip(4+4+12+4); // Z, angle, scale, Reforged skin.
        let owner;
        if(unit){
            c.skip(1);owner=c.int();c.skip(2+4+4+4);
            for(let j=0,n=c.count();j<n;j++)c.skip(c.count()*8);
            c.skip(12+12); // Gold/acquisition/hero level, then hero attributes.
            c.skip(c.count()*8);c.skip(c.count()*12);
            const flag=c.int();
            if(flag===0)c.skip(4);else if(flag===1)c.skip(8);
            else {assert.equal(flag,2);c.skip(c.count()*8);}
            c.skip(12);
        }else{
            c.skip(2+4);
            for(let j=0,n=c.count();j<n;j++)c.skip(c.count()*8);
            c.skip(4);
        }
        records.push({id,x,y,owner,raw:b.subarray(start,c.p)});
    }
    const tail=b.subarray(c.p);
    if(unit)assert.equal(tail.length,0);
    else {assert.equal(tail.length,8+tail.readInt32LE(4)*16);}
    return {records,tail};
}
for(const [name,unit] of [['war3map.doo',false],['war3mapUnits.doo',true]]){
    const b=source.get(name),parsed=parsePlaced(b,unit);
    const retained=parsed.records.filter(r=>!inside(r.x,r.y));
    const removed=parsed.records.filter(r=>inside(r.x,r.y));
    let tail=parsed.tail;
    if(!unit){
        const kept=[];
        for(let j=0;j<tail.readInt32LE(4);j++){
            const r=tail.subarray(8+j*16,24+j*16);
            const x=-10240+r.readInt32LE(8)*128,y=-10240+r.readInt32LE(12)*128;
            if(!inside(x,y))kept.push(r);
        }
        report.removed.terrainDoodads=tail.readInt32LE(4)-kept.length;
        tail=Buffer.concat([tail.subarray(0,4),i32(kept.length),...kept]);
    }
    const next=Buffer.concat([b.subarray(0,12),i32(retained.length),...retained.map(r=>r.raw),tail]);
    const check=parsePlaced(next,unit);
    assert.equal(check.records.length,retained.length);
    check.records.forEach((r,i)=>assert(r.raw.equals(retained[i].raw)));
    changes.set(name,next);
    report.removed[name]={count:removed.length,byType:removed.reduce((a,r)=>(a[r.id]=(a[r.id]||0)+1,a),{})};
    report.preservation[name]={outsideRecordsIdentical:retained.length};
}

// W3E is a 161x161 vertex grid. Changes are limited to vertices inside A.
const terrain=Buffer.from(source.get('war3map.w3e'));
const tc=new Cursor(terrain,4);assert.equal(tc.int(),11);tc.skip(1+4);
const textures=[];for(let i=0,n=tc.count();i<n;i++){textures.push(terrain.toString('ascii',tc.p,tc.p+4));tc.skip(4);}
tc.skip(tc.count()*4);const width=tc.int(),height=tc.int(),ox=tc.float(),oy=tc.float(),header=tc.p;
assert.equal(width,161);assert.equal(height,161);assert.equal(terrain.length,header+width*height*7);
const originalTerrain=source.get('war3map.w3e');
const grass=textures.indexOf('Lgrs'),darkGrass=textures.indexOf('Lgrd');
const dirt=textures.indexOf('Ldrt'),roughDirt=textures.indexOf('Ldrg'),rock=textures.indexOf('Lrok');
assert([grass,darkGrass,dirt,roughDirt,rock].every(i=>i>=0));
let changedVertices=0;const textureCounts={};
for(let y=0;y<height;y++)for(let x=0;x<width;x++){
    const wx=ox+x*128,wy=oy+y*128,p=header+(y*width+x)*7;
    if(!inside(wx,wy))continue;
    const edge=Math.min(wx-A.minX,A.maxX-wx,wy-A.minY,A.maxY-wy);
    // One raised cliff band around the flat meadow, entirely within the district.
    const ridge=edge<=256;
    // Keep Twisted Meadows' hand-authored ground-painting pattern inside the
    // flattened district. Only the raised perimeter receives a forced texture.
    const texture=ridge?rock:(originalTerrain[p+4]&0x0f);
    terrain.writeUInt16LE(8192,p);terrain.writeUInt16LE(8192,p+2);
    terrain[p+4]=texture;
    terrain[p+5]=ridge?0:(originalTerrain[p+5]&0x1f);
    terrain[p+6]=0x10|(ridge?3:2); // Rock cliff texture, cliff level 3 or 2.
    textureCounts[textures[texture]]=(textureCounts[textures[texture]]||0)+1;
    changedVertices++;
}
for(let y=0;y<height;y++)for(let x=0;x<width;x++)if(!inside(ox+x*128,oy+y*128)){
    const p=header+(y*width+x)*7;assert(terrain.subarray(p,p+7).equals(source.get('war3map.w3e').subarray(p,p+7)));
}
changes.set('war3map.w3e',terrain);
report.preservation.terrain={changedVertices,textureCounts,outsideVerticesIdentical:true};

// Pathing and shadow grids use 32-unit cells. Leave a 384-unit exclusion band
// at the ridge, including a margin at the edge where old/new cliffs meet.
const pathing=Buffer.from(source.get('war3map.wpm')),shadow=Buffer.from(source.get('war3map.shd'));
assert.equal(pathing.toString('ascii',0,4),'MP3W');
const pw=pathing.readInt32LE(8),ph=pathing.readInt32LE(12);
assert.equal(pw,640);assert.equal(ph,640);assert.equal(shadow.length,pw*ph);
let changedCells=0,blockedCells=0;
for(let y=0;y<ph;y++)for(let x=0;x<pw;x++){
    const wx=ox+x*32+16,wy=oy+y*32+16,index=y*pw+x;
    if(!inside(wx,wy))continue;
    const edge=Math.min(wx-A.minX,A.maxX-wx,wy-A.minY,A.maxY-wy);
    const blocked=edge<384;
    pathing[16+index]=blocked?0x0e:0; // Unwalkable, unflyable, unbuildable.
    shadow[index]=0;changedCells++;if(blocked)blockedCells++;
}
for(let y=0;y<ph;y++)for(let x=0;x<pw;x++)if(!inside(ox+x*32+16,oy+y*32+16)){
    const i=y*pw+x;assert.equal(pathing[16+i],source.get('war3map.wpm')[16+i]);assert.equal(shadow[i],source.get('war3map.shd')[i]);
}
changes.set('war3map.wpm',pathing);changes.set('war3map.shd',shadow);
report.preservation.pathing={changedCells,blockedCells,outsideCellsIdentical:true};

// Preserve standard generated unit setup and drop tables, but remove the W3C
// module bundle in full (including zoom, hidden menu buttons and local settings).
const script=source.get('war3map.lua').toString('utf8');
const bundle=script.indexOf('\nlocal ____modules = {}');assert(bundle>0);
let lua=script.slice(0,bundle);
let removedRuntimeUnits=0;
lua=lua.replace(/u = BlzCreateUnitWithSkin\(p, FourCC\("([^"]+)"\), ([\d.-]+), ([\d.-]+),[^\n]*\n[\s\S]*?(?=u = BlzCreateUnitWithSkin|\nend\r?\n)/g,(block,id,x,y)=>{
    if(inside(Number(x),Number(y))){removedRuntimeUnits++;return '';}
    return block;
});
const removedPlacedUnits=parsePlaced(source.get('war3mapUnits.doo'),true).records.filter(r=>inside(r.x,r.y)&&r.id!=='sloc');
assert.equal(removedRuntimeUnits,removedPlacedUnits.length,'Compiled/editor unit removals disagree');
const harness=fs.readFileSync(path.join(root,'src/foundation-test.lua'),'utf8');
const oldTrigger=lua.indexOf('function Trig_Melee_Initialization_Actions()');
const nextFunction=lua.indexOf('function InitCustomTriggers()',oldTrigger);
assert(oldTrigger>0&&nextFunction>oldTrigger);
lua=lua.slice(0,oldTrigger)+harness+'\n\n'+lua.slice(nextFunction);
lua=lua.replaceAll('gg_trg_Melee_Initialization','gg_trg_Foundation_Test').replaceAll('InitTrig_Melee_Initialization','InitTrig_Foundation_Test');
function replaceLuaFunction(text,name,body){
    const pattern=new RegExp(`function ${name}\\(\\)\\r?\\n[\\s\\S]*?\\r?\\nend`);
    assert(pattern.test(text),`Missing Lua function ${name}`);
    return text.replace(pattern,`function ${name}()\n${body}\nend`);
}
lua=replaceLuaFunction(lua,'InitCustomPlayerSlots',[
    'SetPlayerStartLocation(Player(0), 0)',
    'SetPlayerColor(Player(0), ConvertPlayerColor(0))',
    'SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)',
    'SetPlayerRaceSelectable(Player(0), true)',
    'SetPlayerController(Player(0), MAP_CONTROL_USER)'
].join('\n'));
lua=replaceLuaFunction(lua,'InitCustomTeams','SetPlayerTeam(Player(0), 0)');
lua=replaceLuaFunction(lua,'InitAllyPriorities','');
lua=replaceLuaFunction(lua,'config',[
    'SetMapName("TRIGSTR_001")',
    'SetMapDescription("TRIGSTR_003")',
    'SetMapFlag(MAP_FOG_HIDE_TERRAIN, true)',
    'SetMapFlag(MAP_FOG_MAP_EXPLORED, false)',
    'SetMapFlag(MAP_FOG_ALWAYS_VISIBLE, false)',
    'SetPlayers(1)',
    'SetTeams(1)',
    'SetGamePlacement(MAP_PLACEMENT_FIXED)',
    'DefineStartLocation(0, 4864.0, 3456.0)',
    'InitCustomPlayerSlots()',
    'SetPlayerSlotAvailable(Player(0), MAP_CONTROL_USER)',
    'InitGenericPlayerSlots()',
    'InitAllyPriorities()'
].join('\n'));
luaParser.parse(lua,{luaVersion:'5.3'});
assert(!/MeleeStarting|MeleeInitVictoryDefeat|MeleeClearExcessUnits|local ____modules/.test(lua));
assert.equal((lua.match(/SetPlayerSlotAvailable/g)||[]).length,1);
assert(lua.includes('SetPlayerRaceSelectable(Player(0), true)'));
changes.set('war3map.lua',Buffer.from(lua));
fs.writeFileSync(path.join(work,'foundation.lua'),lua);
report.removed.runtimeUnits=removedRuntimeUnits;
report.removed.w3cBundleBytes=Buffer.byteLength(script.slice(bundle));

// Make the editor's trigger sources agree with the compiled Lua. Keep Reforged
// metadata/version and category IDs, converting the one GUI trigger to Lua text.
const wtg=source.get('war3map.wtg');
assert.equal(wtg.readUInt32LE(4),0x80000004);assert.equal(wtg.readInt32LE(8),7);
const nameOffset=wtg.indexOf(Buffer.from('Melee Initialization\0'));assert(nameOffset>0);
const tr=new Cursor(wtg,nameOffset);tr.text();tr.text();const fields=[];for(let i=0;i<8;i++)fields.push(tr.int());
assert.equal(fields[2],1);assert.equal(fields[3],0);assert.equal(fields[7],9);
const prefix=Buffer.from(wtg.subarray(0,nameOffset-4));
assert.equal(prefix.readInt32LE(12+3*8),1);prefix.writeInt32LE(0,12+3*8);prefix.writeInt32LE(1,12+5*8);
const triggerId=0x05000000;
changes.set('war3map.wtg',Buffer.concat([prefix,i32(32),str('Foundation Test'),str('Temporary terrain inspection harness; see src/foundation-test.lua.'),...[0,triggerId,1,1,0,1,fields[6],0].map(i32)]));
changes.set('war3map.wct',Buffer.concat([source.get('war3map.wct').subarray(0,8),str('Training foundation test. Source maintained in src/foundation-test.lua.'),i32(0),i32(Buffer.byteLength(harness)),Buffer.from(harness)]));

// The MMP file is the marker layer drawn over the browser preview. Runtime units
// and buildings supply the useful in-game minimap icons, so the browser layer can
// remain empty without affecting the terrain minimap restored after loading.
const mmp=source.get('war3map.mmp');assert.equal(mmp.readInt32LE(0),0);
const markerCount=mmp.readInt32LE(4);assert.equal(mmp.length,8+markerCount*16);
changes.set('war3map.mmp',Buffer.concat([i32(0),i32(0)]));
report.removed.minimapMarkers=markerCount;

// Convert the four-player melee lobby to one trainee with a selectable race. Preserve map
// bounds, environment, data-set, and all availability tables byte-for-byte.
const info=source.get('war3map.w3i');
const ic=new Cursor(info);const format=ic.int();assert.equal(format,31);
ic.skip(4+4+16); // Save count, editor version, game version.
for(let n=0;n<4;n++)ic.text();
ic.skip(8*4+4*4+4+4); // Camera bounds, complements, playable size.
const flagsOffset=ic.p,oldFlags=ic.int();ic.skip(1);
ic.skip(4);
const loadingModelStart=ic.p;ic.text();const loadingModelEnd=ic.p;
for(let n=0;n<3;n++)ic.text();ic.skip(4);
for(let n=0;n<4;n++)ic.text();
ic.skip(4+4+4+4+4+4);ic.text();ic.skip(1+4+4+4+4);
const playerCountOffset=ic.p,oldPlayerCount=ic.count();assert.equal(oldPlayerCount,4);
for(let n=0;n<oldPlayerCount;n++){
    ic.skip(16);ic.text();ic.skip(8+16);
}
const oldForceCount=ic.count();assert.equal(oldForceCount,1);
for(let n=0;n<oldForceCount;n++){ic.skip(8);ic.text();}
const availabilityTail=info.subarray(ic.p);assert.equal(availabilityTail.length,16);
const infoHeader=Buffer.concat([
    info.subarray(0,loadingModelStart),
    str('LoadingScreen.mdx'),
    info.subarray(loadingModelEnd,playerCountOffset)
]);
// Use one custom force without locking the trainee's race choice. Clear the
// partially-visible mask flag so unexplored terrain is fully black.
infoHeader.writeInt32LE((oldFlags&~0x37)|0x40,flagsOffset);
const player=Buffer.concat([
    i32(0),i32(1),i32(1),i32(1),str('TRIGSTR_005'),
    (()=>{const b=Buffer.alloc(8);b.writeFloatLE(4864,0);b.writeFloatLE(3456,4);return b;})(),
    i32(0),i32(0),i32(0),i32(0)
]);
const force=Buffer.concat([i32(0),i32(1),str('TRIGSTR_006')]);
const nextInfo=Buffer.concat([infoHeader,i32(1),player,i32(1),force,availabilityTail]);
changes.set('war3map.w3i',nextInfo);
report.lobby={players:1,defaultRace:'Human',raceSelectable:true,start:[4864,3456],customPreview:true};
report.visibility={default:'fully masked unexplored terrain',activityOverrides:'planned in shared lifecycle'};

// Neutral object/skin modifications are retained to avoid changing the preserved
// southern camps. Imported interface/icon overrides can be safely removed now.
const remove=[...source.keys()].filter(n=>/^(?:loot-indicator\\|UI\\MiniMap\\|ReplaceableTextures\\|_teen\.w3mod\\ReplaceableTextures\\)/i.test(n)||n==='conversation.json');
report.removed.archiveFiles=remove;
let wts=source.get('war3map.wts').toString('utf8');
wts=wts.replace(/(STRING 1\s*\{)[^}]*\}/,`$1\nJamie\'s Training Grounds ${version}\n}`)
    .replace(/(STRING 2\s*\{)[^}]*\}/,'$1\nSolo\n}')
    .replace(/(STRING 3\s*\{)[^}]*\}/,'$1\nA comprehensive Warcraft III teaching and practice map, covering everything from basic controls to advanced competitive techniques through guided tutorials and focused exercises.\n}')
    .replace(/(STRING 4\s*\{)[^}]*\}/,'$1\nJamie & Solanum\n}')
    .replace(/(STRING 5\s*\{)[^}]*\}/,'$1\nTrainee\n}')
    .replace(/(STRING 6\s*\{)[^}]*\}/,'$1\nTraining\n}');
changes.set('war3map.wts',Buffer.from(wts));

// Preserve the legacy map's custom loading screen exactly: the model is a
// fullscreen quad whose material references FullScreen.dds.
const loadingModel=fs.readFileSync(path.join(root,'reference/legacy/LoadingScreen.mdx'));
const loadingTexture=fs.readFileSync(path.join(root,'reference/legacy/FullScreen.dds'));
assert.equal(loadingModel.toString('ascii',0,4),'MDLX');
assert.equal(loadingTexture.toString('ascii',0,4),'DDS ');
assert(loadingModel.includes(Buffer.from('FullScreen.dds\0')));
changes.set('LoadingScreen.mdx',loadingModel);
changes.set('FullScreen.dds',loadingTexture);
report.loadingScreen={model:'LoadingScreen.mdx',texture:'FullScreen.dds',source:'legacy map'};

// Reforged's browser reads war3mapMap.blp instead of war3mapPreview.tga. Package
// the portrait there, then restore the separately generated terrain minimap at runtime.
for(const [name,b] of changes)fs.writeFileSync(path.join(work,'patched-'+name),b);
fs.writeFileSync(path.join(work,'build-plan.json'),JSON.stringify({area:A,width,height,ox,oy,header,textures},null,2));
if(process.argv.includes('--prepare')){console.log(JSON.stringify(report,null,2));process.exit(0);}
const browserPreview=fs.readFileSync(path.join(work,'patched-war3mapMap.blp'));
const ingameMinimap=fs.readFileSync(path.join(work,'patched-war3mapMap_ingame.blp'));
assert.equal(browserPreview.toString('ascii',0,4),'BLP1');
assert.equal(ingameMinimap.toString('ascii',0,4),'BLP1');
changes.set('war3mapMap.blp',browserPreview);
changes.set('war3mapMap_ingame.blp',ingameMinimap);
report.preview={browser:'Arthas and Jaina',menuMarkers:0,ingame:'patched terrain minimap',runtimeSwap:'BlzChangeMinimapTerrainTex'};
fs.copyFileSync(original,output);
// Update the non-MPQ map-list title; keep the MPQ archive at its original offset.
const outRaw=fs.readFileSync(output);
if(outRaw.toString('ascii',0,4)==='HM3W'){
    const endName=outRaw.indexOf(0,8),newName=str("Jamie's Training Grounds");
    const headerCopy=Buffer.concat([outRaw.subarray(0,8),newName,outRaw.subarray(endName+1,endName+9)]);
    outRaw.fill(0,0,512);headerCopy.copy(outRaw);fs.writeFileSync(output,outRaw);
}else assert.equal(outRaw.toString('ascii',0,4),'MPQ\x1a');
const out=Archive.open(output);
try{
    for(const name of remove)out.removeFile(name);
    for(const [name,b] of changes)out.addBuffer(name,b,{flags:MPQ_FILE_COMPRESS|MPQ_FILE_REPLACEEXISTING,compression:MPQ_COMPRESSION_ZLIB});
    out.flush();
}finally{out.close();}
const verify=Archive.open(output,{flags:256});
try{
    for(const [name,b] of source){
        if(['(attributes)','(listfile)'].includes(name)||remove.includes(name)||changes.has(name))continue;
        assert(verify.readFile(name).equals(b),'Unexpected change to '+name);
    }
    for(const [name,b] of changes)assert(verify.readFile(name).equals(b),'Archive roundtrip failed '+name);
    for(const name of remove)assert(!verify.hasFile(name));
    luaParser.parse(verify.readFileAsString('war3map.lua'),{luaVersion:'5.3'});
}finally{verify.close();}
assert.equal(hash(fs.readFileSync(original)),sourceHash);
report.outputSha256=hash(fs.readFileSync(output));report.outputBytes=fs.statSync(output).size;
report.changedArchiveFiles=[...changes.keys()];report.luaSyntax='PASS';report.archiveRoundtrip='PASS';
fs.writeFileSync(path.join(root,`outputs/Jamies-Training-Grounds-${version}-validation.json`),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report,null,2));
