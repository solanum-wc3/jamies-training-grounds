/* Build the shared-infrastructure test on the accepted alpha.5 foundation.
 * The source map is immutable; only the Lua trigger, editor trigger source and
 * version string are replaced. Every other archive member is verified equal.
 */
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const assert = require('node:assert/strict');
const {createRequire} = require('node:module');

const root = path.resolve(__dirname, '..');
const req = createRequire(path.join(root, 'package.json'));
const {
    Archive,
    MPQ_FILE_COMPRESS,
    MPQ_FILE_REPLACEEXISTING,
    MPQ_COMPRESSION_ZLIB,
} = req('@jamiephan/stormlib');
const luaParser = req('luaparse');

const version = 'v0.0.4-alpha17';
const sourcePath = path.join(root, 'reference/foundation/Jamies-Training-Grounds-v0.0.1-alpha.5.w3x');
const outputPath = path.join(root, `outputs/Jamies-Training-Grounds-${version}.w3x`);
const reportPath = path.join(root, `outputs/Jamies-Training-Grounds-${version}-validation.json`);
const acceptedHash = 'a1ea7789e60b30e77d64f14337759842dff309d129929ef24defb1276cf1ba64';
const modulePaths = [
    'src/infrastructure/core.lua',
    'src/activities/body-blocking.lua',
    'src/activities/speed-building.lua',
    'src/infrastructure/catalog.lua',
    'src/infrastructure/ui.lua',
    'src/infrastructure/diagnostics.lua',
    'src/infrastructure/bootstrap.lua',
];
const assetPaths = [
    ['JTGMenu\\BodyBlocking.dds', 'src/assets/menu/BodyBlocking.dds'],
    ['JTGMenu\\BodyBlockingBriefing.dds', 'src/assets/menu/BodyBlockingBriefing.dds'],
    ['JTGMenu\\SpeedBuilding.dds', 'src/assets/menu/SpeedBuilding.dds'],
    ['JTGMenu\\Surrounds.dds', 'src/assets/menu/Surrounds.dds'],
    ['JTGMenu\\AoWCreeping.dds', 'src/assets/menu/AoWCreeping.dds'],
    ['JTGMenu\\BatSplitter.dds', 'src/assets/menu/BatSplitter.dds'],
    ['JTGMenu\\GoldMineMicro.dds', 'src/assets/menu/GoldMineMicro.dds'],
    ['JTGMenu\\UnitComparison.dds', 'src/assets/menu/UnitComparison.dds'],
    ['JTGMenu\\DemoMode.dds', 'src/assets/menu/DemoMode.dds'],
    ['JTGMenu\\LearnToPlay.dds', 'src/assets/menu/LearnToPlay.dds'],
    ['JTGMenu\\AdvancedPlay.dds', 'src/assets/menu/AdvancedPlay.dds'],
    ['JTGMenu\\SkillTraining.dds', 'src/assets/menu/SkillTraining.dds'],
    ['JTGMenu\\ToolsExtras.dds', 'src/assets/menu/ToolsExtras.dds'],
    ['JTGMenu\\HotkeyTraining.dds', 'src/assets/menu/HotkeyTraining.dds'],
    ['JTGMenu\\TooltipTL.dds', 'src/assets/menu/TooltipTL.dds'],
    ['JTGMenu\\TooltipTop.dds', 'src/assets/menu/TooltipTop.dds'],
    ['JTGMenu\\TooltipTR.dds', 'src/assets/menu/TooltipTR.dds'],
    ['JTGMenu\\TooltipLeft.dds', 'src/assets/menu/TooltipLeft.dds'],
    ['JTGMenu\\TooltipCenter.dds', 'src/assets/menu/TooltipCenter.dds'],
    ['JTGMenu\\TooltipRight.dds', 'src/assets/menu/TooltipRight.dds'],
    ['JTGMenu\\TooltipBL.dds', 'src/assets/menu/TooltipBL.dds'],
    ['JTGMenu\\TooltipBottom.dds', 'src/assets/menu/TooltipBottom.dds'],
    ['JTGMenu\\TooltipBR.dds', 'src/assets/menu/TooltipBR.dds'],
    ['JTGMenu\\MenuDivider.dds', 'src/assets/menu/MenuDivider.dds'],
];

const hash = buffer => crypto.createHash('sha256').update(buffer).digest('hex');
const i32 = number => { const buffer = Buffer.alloc(4); buffer.writeInt32LE(number); return buffer; };
const str = value => Buffer.from(value + '\0');

class Cursor {
    constructor(buffer, position = 0) { this.buffer = buffer; this.position = position; }
    int() { const value = this.buffer.readInt32LE(this.position); this.position += 4; return value; }
    text() {
        const end = this.buffer.indexOf(0, this.position);
        assert(end >= 0, 'Unterminated WTG string');
        const value = this.buffer.toString('utf8', this.position, end);
        this.position = end + 1;
        return value;
    }
}

const rawSource = fs.readFileSync(sourcePath);
assert.equal(hash(rawSource), acceptedHash, 'Accepted alpha.5 foundation changed; review before building');
const sourceArchive = Archive.open(sourcePath, {flags: 256});
const source = new Map(sourceArchive.getFileNames().map(name => [name, sourceArchive.readFile(name)]));
sourceArchive.close();

const moduleBuffers = modulePaths.map(relativePath => {
    const bytes = fs.readFileSync(path.join(root, relativePath));
    return {relativePath, bytes, sha256: hash(bytes)};
});
const bundle = moduleBuffers.map(module =>
    `-- BEGIN ${module.relativePath}\n${module.bytes.toString('utf8').trim()}\n-- END ${module.relativePath}`
).join('\n\n') + '\n';
luaParser.parse(bundle, {luaVersion: '5.3'});

const changes = new Map();
const compiled = source.get('war3map.lua').toString('utf8');
const oldStart = compiled.indexOf('-- Temporary inspection harness for the terrain foundation');
const oldEnd = compiled.indexOf('function InitCustomTriggers()', oldStart);
assert(oldStart >= 0 && oldEnd > oldStart, 'Foundation test harness boundary changed');
let nextLua = compiled.slice(0, oldStart) + bundle + '\n' + compiled.slice(oldEnd);
nextLua = nextLua
    .replaceAll('gg_trg_Foundation_Test', 'gg_trg_Infrastructure')
    .replaceAll('InitTrig_Foundation_Test', 'InitTrig_Infrastructure');
assert(nextLua.includes('function InitTrig_Infrastructure()'));
assert(nextLua.includes('function JTG.CreateBodyBlockingActivity(session)'),
    'Body Blocking activity factory is missing from the compiled map');
assert(nextLua.includes('id = "skills.body_blocking"'),
    'Body Blocking catalogue registration is missing from the compiled map');
assert(nextLua.includes('function JTG.CreateSpeedBuildingActivity(session)'),
    'Speed Building activity factory is missing from the compiled map');
assert(nextLua.includes('id = "tools.speed_building"'),
    'Speed Building catalogue registration is missing from the compiled map');
assert.equal((nextLua.match(/InitTrig_Infrastructure\(\)/g) || []).length, 2,
    'Infrastructure trigger must have one declaration and one initialization call');
assert(!nextLua.includes('FoundationStart'));
assert(!nextLua.includes('profile.pld'), 'Infrastructure candidate must not access the legacy profile');
assert(!nextLua.includes('Preloader('), 'Infrastructure candidate must not use preload-based persistence');
luaParser.parse(nextLua, {luaVersion: '5.3'});
changes.set('war3map.lua', Buffer.from(nextLua));

// Keep the editor trigger metadata aligned with the compiled Lua bundle.
const wtg = source.get('war3map.wtg');
assert.equal(wtg.readUInt32LE(4), 0x80000004);
const nameOffset = wtg.indexOf(Buffer.from('Foundation Test\0'));
assert(nameOffset > 0, 'Foundation Test trigger was not found');
const trigger = new Cursor(wtg, nameOffset);
assert.equal(trigger.text(), 'Foundation Test');
trigger.text();
const fields = [];
for (let index = 0; index < 8; index++) fields.push(trigger.int());
assert.equal(fields[2], 1, 'Expected enabled trigger');
assert.equal(fields[3], 1, 'Expected custom-text trigger');
const prefix = wtg.subarray(0, nameOffset - 4);
changes.set('war3map.wtg', Buffer.concat([
    prefix,
    i32(32),
    str('Shared Infrastructure'),
    str('Map navigation, activity lifecycle, Body Blocking and Speed Building; source maintained in src/.'),
    ...[fields[0], fields[1], 1, 1, fields[4], fields[5], fields[6], fields[7]].map(i32),
]));

const wct = source.get('war3map.wct');
assert(wct.length >= 8, 'Unexpected WCT header');
changes.set('war3map.wct', Buffer.concat([
    wct.subarray(0, 8),
    str('Map source is assembled from src/ in deterministic order.'),
    i32(0),
    i32(Buffer.byteLength(bundle)),
    Buffer.from(bundle),
]));

let wts = source.get('war3map.wts').toString('utf8');
assert(/STRING 1\s*\{[^}]*\}/.test(wts), 'Map title string was not found');
wts = wts.replace(/(STRING 1\s*\{)[^}]*\}/, `$1\nJamie's Training Grounds ${version}\n}`);
changes.set('war3map.wts', Buffer.from(wts));
for (const [archivePath, relativePath] of assetPaths) {
    const bytes = fs.readFileSync(path.join(root, relativePath));
    if (relativePath.endsWith('.dds')) {
        assert.equal(bytes.toString('ascii', 0, 4), 'DDS ', relativePath + ' is not a DDS texture');
    }
    changes.set(archivePath, bytes);
}

fs.mkdirSync(path.dirname(outputPath), {recursive: true});
fs.copyFileSync(sourcePath, outputPath);
const outputArchive = Archive.open(outputPath);
try {
    for (const [name, bytes] of changes) {
        outputArchive.addBuffer(name, bytes, {
            flags: MPQ_FILE_COMPRESS | MPQ_FILE_REPLACEEXISTING,
            compression: MPQ_COMPRESSION_ZLIB,
        });
    }
    outputArchive.flush();
} finally {
    outputArchive.close();
}

const verifyArchive = Archive.open(outputPath, {flags: 256});
try {
    for (const [name, bytes] of source) {
        if (name === '(attributes)' || name === '(listfile)' || changes.has(name)) continue;
        assert(verifyArchive.readFile(name).equals(bytes), 'Unexpected archive change: ' + name);
    }
    for (const [name, bytes] of changes) {
        assert(verifyArchive.readFile(name).equals(bytes), 'Archive roundtrip failed: ' + name);
    }
    luaParser.parse(verifyArchive.readFileAsString('war3map.lua'), {luaVersion: '5.3'});
} finally {
    verifyArchive.close();
}

assert.equal(hash(fs.readFileSync(sourcePath)), acceptedHash, 'Source foundation was modified');
const report = {
    version,
    purpose: 'Menu-aware exercise overlays and empty default Quest window.',
    acceptedFoundation: {
        path: path.relative(root, sourcePath).replaceAll('\\', '/'),
        sha256: acceptedHash,
        modified: false,
    },
    modules: moduleBuffers.map(module => ({path: module.relativePath, sha256: module.sha256})),
    assets: assetPaths.map(([archivePath, relativePath]) => ({
        archivePath,
        source: relativePath,
        sha256: hash(fs.readFileSync(path.join(root, relativePath))),
    })),
    bundleSha256: hash(Buffer.from(bundle)),
    changedArchiveFiles: [...changes.keys()],
    preservedArchiveFiles: [...source.keys()].filter(name =>
        name !== '(attributes)' && name !== '(listfile)' && !changes.has(name)
    ).length,
    checks: {
        moduleLuaSyntax: 'PASS',
        compiledLuaSyntax: 'PASS',
        archiveRoundtrip: 'PASS',
        unchangedMembersByteIdentical: 'PASS',
        acceptedFoundationHashUnchanged: 'PASS',
    },
    output: path.relative(root, outputPath).replaceAll('\\', '/'),
    outputSha256: hash(fs.readFileSync(outputPath)),
    outputBytes: fs.statSync(outputPath).size,
};
fs.writeFileSync(reportPath, JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify(report, null, 2));
