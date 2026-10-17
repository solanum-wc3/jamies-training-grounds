// A clean checkout must build without a developer's ignored audit files.
const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const parser=require('luaparse');
const root=path.resolve(__dirname,'..');
const source=fs.readFileSync(path.join(__dirname,'build-infrastructure.cjs'),'utf8');
const shared=source.match(/const sharedModulePaths = (\[[\s\S]*?\n\]);/)[1];
const modules=source.match(/const modulePaths = (\[[\s\S]*?\n\]);/)[1];
const sharedPaths=Function(`return ${shared};`)();
const noLocalFiles={existsSync:()=>false};
const paths=Function('sharedModulePaths','isDevelopment','fs','path','root',`return ${modules};`)
    (sharedPaths,true,noLocalFiles,path,root);
assert(!paths.some(file=>file.startsWith('work/')));
assert(paths.includes('src/generated/hotkey-comparison-defaults.lua'));
assert(paths.includes('src/generated/hotkey-audit-defaults.lua'));
assert(paths.includes('src/infrastructure/heroes-diagnostics.lua'));
const releasePaths=Function('sharedModulePaths','isDevelopment','fs','path','root',`return ${modules};`)
    (sharedPaths,false,noLocalFiles,path,root);
assert(!releasePaths.includes('src/infrastructure/heroes-diagnostics.lua'));
const blocks=paths.map(file=>{
    assert(fs.existsSync(path.join(root,file)),`Missing clean-checkout module: ${file}`);
    return `do\n${fs.readFileSync(path.join(root,file),'utf8')}\nend`;
});
parser.parse(blocks.join('\n'),{luaVersion:'5.3'});
const hasLocalFiles={existsSync:()=>true};
const localPaths=Function('sharedModulePaths','isDevelopment','fs','path','root',`return ${modules};`)
    (sharedPaths,true,hasLocalFiles,path,root);
assert(localPaths.includes('work/hotkey-comparison-bindings.lua'));
assert(localPaths.includes('work/hotkey-audit-exclusions.lua'));
assert.equal(localPaths.length,paths.length);
console.log('Passed: clean-checkout development modules and explicit local audit overrides.');

// Read the actual foundation, not a smaller mocked world rectangle: the old
// map-edge formula put shops on blocked terrain beyond the northern arena.
const {Archive}=require('@jamiephan/stormlib');
const foundation=Archive.open(path.join(root,'reference/foundation/Jamies-Training-Grounds-v0.0.1-alpha.5.w3x'),{flags:256});
const terrain=foundation.readFile('war3map.w3e'),pathing=foundation.readFile('war3map.wpm');
foundation.close();
let cursor=13;
for(let table=0;table<2;table++) {const count=terrain.readUInt32LE(cursor);cursor+=4+count*4;}
const height=terrain.readInt32LE(cursor+4),offsetX=terrain.readFloatLE(cursor+8),offsetY=terrain.readFloatLE(cursor+12);
const gridWidth=pathing.readInt32LE(8),gridHeight=pathing.readInt32LE(12);
function flags(x,y) {
    const gx=Math.floor((x-offsetX)/32),gy=Math.floor((y-offsetY)/32);
    assert(gx>=0 && gy>=0 && gx<gridWidth && gy<gridHeight,'Hotkey context outside pathing map');
    return pathing[16+gy*gridWidth+gx];
}
const catalogue=fs.readFileSync(path.join(root,'src/infrastructure/catalog.lua'),'utf8');
const arena=catalogue.match(/id = "arena.north", centerX = (\d+), centerY = (\d+)/);
assert(arena,'Northern arena missing');
const hotkey=fs.readFileSync(path.join(root,'src/activities/hotkey-training.lua'),'utf8');
assert(hotkey.includes("promptArena=assert(JTG.Scenes['arena.north']"));
const delta=hotkey.match(/self.spawnY=promptArena.centerY-(\d+)/);
assert(delta,'Hotkey preparation no longer derives from the arena');
const x=Number(arena[1]),y=Number(arena[2])-Number(delta[1]);
assert(flags(x,offsetY+(height-1)*128-1800)&2,'Regression reference no longer reproduces blocked placement');
for(const [label,cx,cy,radius] of [
    ['shop',x,y,224],['buyer/hiring area',x,y-320,128],
    ['prerequisite',x+450,y+600,224],['prepared Ancient/Burrow',x+800,y+1000,224],
]) {
    for(let px=cx-radius;px<=cx+radius;px+=32) for(let py=cy-radius;py<=cy+radius;py+=32)
        assert.equal(flags(px,py)&0x0a,0,`${label} overlaps unwalkable/unbuildable terrain at ${px},${py}`);
}
console.log('Passed: actual foundation pathing supports Hotkey shops, hiring space, prerequisites and prepared units; old map-edge point is blocked.');

// Hidden buildings still undergo native placement before being hidden. Check
// the maintained Items offsets against the real terrain, including footprints.
const heroesScenes=fs.readFileSync(path.join(root,'src/infrastructure/heroes-scenes.lua'),'utf8');
const hallPositions=heroesScenes.match(/local ITEM_HALL_POSITIONS=([^\r\n]+)/);
assert(hallPositions,'Items prerequisite position table missing');
assert(heroesScenes.includes('a.centerX+position[1],a.centerY+position[2]'),
    'Items prerequisite creation no longer uses the checked offsets');
const hallOffsets=[...hallPositions[1].matchAll(/\{(-?\d+),(-?\d+)\}/g)].map(match=>[Number(match[1]),Number(match[2])]);
assert.equal(hallOffsets.length,4);
const arenaX=Number(arena[1]),arenaY=Number(arena[2]);
// A 512-unit square conservatively covers the largest prerequisite footprint.
for(const [index,[dx,dy]] of hallOffsets.entries()) {
    for(let px=arenaX+dx-256;px<=arenaX+dx+256;px+=32)
        for(let py=arenaY+dy-256;py<=arenaY+dy+256;py+=32)
            assert.equal(flags(px,py)&0x0a,0,`Items prerequisite ${index+1} overlaps blocked terrain at ${px},${py}`);
}
for(const dx of [-2516,2644])
    assert(flags(arenaX+dx,arenaY+1236)&2,'Old Items corner no longer reproduces blocked placement');
console.log('Passed: all four hidden Items prerequisite footprints sit on clear foundation terrain; old northern corners are blocked.');
const bootstrap=fs.readFileSync(path.join(root,'src/infrastructure/bootstrap.lua'),'utf8');
const initialization=bootstrap.slice(bootstrap.indexOf('function JTG.Initialize()'));
assert(initialization.indexOf('JTG.InitializeTerrainBaseline()')>=0 &&
    initialization.indexOf('JTG.InitializeTerrainBaseline()')<initialization.indexOf('JTG.UI.Initialize()'),
    'Arena terrain baseline must precede interactive menus');

assert(paths.includes('src/infrastructure/target-dummies.lua'));
assert(!paths.some(file=>/demo-(?:mode|placement|catalog)/.test(file)),'Fixes-only release includes Demo');
const catalog=fs.readFileSync(path.join(root,'src/infrastructure/catalog.lua'),'utf8');
assert(!catalog.includes('JTG.CreateDemoModeActivity'),'Fixes-only release activates Demo');
assert(!source.includes('DemoModeBriefing.dds'),'Fixes-only release packages Demo artwork');
console.log('Passed: fixes-only module/catalogue/asset boundary excludes Demo.');
