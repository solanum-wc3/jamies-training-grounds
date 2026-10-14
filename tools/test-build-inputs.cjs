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
