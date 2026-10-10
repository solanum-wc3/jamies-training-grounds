// Parse exactly the builder's module lists without publishing/overwriting maps.
const fs = require('node:fs');
const path = require('node:path');
const parser = require('luaparse');
const root = path.resolve(__dirname, '..');
const source = fs.readFileSync(path.join(__dirname, 'build-infrastructure.cjs'), 'utf8');
const shared = source.match(/const sharedModulePaths = (\[[\s\S]*?\n\]);/);
const modules = source.match(/const modulePaths = (\[[\s\S]*?\n\]);/);
if (!shared || !modules) throw new Error('Builder module list was not found');
const sharedPaths = Function(`return ${shared[1]};`)();
for (const development of [false, true]) {
    const paths = Function('sharedModulePaths', 'isDevelopment', `return ${modules[1]};`)(sharedPaths, development);
    const blocks = paths.map(file => {
        const lua = fs.readFileSync(path.join(root, file), 'utf8');
        try { parser.parse(lua, {luaVersion: '5.3'}); }
        catch (error) { throw new Error(`${file}: ${error.message}`); }
        return `do\n${lua}\nend`;
    });
    parser.parse(blocks.join('\n'), {luaVersion: '5.3'});
    console.log(`Passed: ${development ? 'development' : 'release'} Lua assembly (${paths.length} modules); no map written.`);
}
