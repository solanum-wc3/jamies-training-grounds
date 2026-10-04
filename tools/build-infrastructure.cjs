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

const version = 'v0.0.11';
const modeArgument = process.argv.find(argument => argument.startsWith('--mode='));
const buildMode = modeArgument ? modeArgument.slice('--mode='.length) : 'release';
assert(['release', 'development'].includes(buildMode),
    'Build mode must be release or development');
const isDevelopment = buildMode === 'development';
const sourcePath = path.join(root, 'reference/foundation/Jamies-Training-Grounds-v0.0.1-alpha.5.w3x');
const outputLabel = isDevelopment ? `${version}-dev` : version;
const outputPath = path.join(root, `outputs/Jamies-Training-Grounds-${outputLabel}.w3x`);
const reportPath = path.join(root,
    `outputs/Jamies-Training-Grounds-${outputLabel}-validation.json`);
const acceptedHash = 'a1ea7789e60b30e77d64f14337759842dff309d129929ef24defb1276cf1ba64';
const sharedModulePaths = [
    'src/infrastructure/core.lua',
    'src/generated/custom-keys.lua',
    'src/activities/camera-tutorial.lua',
    'src/activities/unit-controls-tutorial.lua',
    'src/activities/hotkey-setup-tutorial.lua',
    'src/activities/mining-micro.lua',
    'src/activities/surrounds.lua',
    'src/activities/windwalk-pop.lua',
    'src/activities/body-blocking.lua',
    'src/activities/power-building.lua',
    'src/infrastructure/catalog.lua',
    'src/infrastructure/ui.lua',
];
const modulePaths = [
    ...sharedModulePaths,
    ...(isDevelopment ? ['src/infrastructure/diagnostics.lua'] : []),
    'src/infrastructure/bootstrap.lua',
];
const assetPaths = [
    ['JTGOverlay\\UnitSquaresEnemy.dds', 'src/assets/overlay/UnitSquaresEnemy.dds'],
    ['JTGOverlay\\UnitSquaresPlayer.dds', 'src/assets/overlay/UnitSquaresPlayer.dds'],
    ['JTGMenu\\BodyBlocking.dds', 'src/assets/menu/BodyBlocking.dds'],
    ['JTGMenu\\BodyBlockingBriefing.dds', 'src/assets/menu/BodyBlockingBriefing.dds'],
    ['JTGMenu\\PowerBuilding.dds', 'src/assets/menu/PowerBuilding.dds'],
    ['JTGMenu\\ReflexTraining.dds', 'src/assets/menu/ReflexTraining.dds'],
    ['JTGMenu\\PeonMicro.dds', 'src/assets/menu/PeonMicro.dds'],
    ['JTGMenu\\WispMicro.dds', 'src/assets/menu/WispMicro.dds'],
    ['JTGMenu\\CameraControls.dds', 'src/assets/menu/CameraControls.dds'],
    ['JTGMenu\\UnitControls.dds', 'src/assets/menu/UnitControls.dds'],
    ['JTGMenu\\TutorialArrowDown.dds', 'src/assets/menu/TutorialArrowDown.dds'],
    ['JTGMenu\\WindwalkPop.dds', 'src/assets/menu/WindwalkPop.dds'],
    ['JTGMenu\\WindwalkPopBriefing.dds', 'src/assets/menu/WindwalkPopBriefing.dds'],
    ['JTGMenu\\ZeppelinMicro.dds', 'src/assets/menu/ZeppelinMicro.dds'],
    ['JTGQuest\\CameraSettingsZoom.dds', 'src/assets/menu/CameraSettingsZoom.dds'],
    ['JTGQuest\\IdleWorkerSettings.dds', 'src/assets/menu/IdleWorkerSettings.dds'],
    ['JTGMenu\\Surrounds.dds', 'src/assets/menu/Surrounds.dds'],
    ['JTGMenu\\SurroundsBriefing.dds', 'src/assets/menu/SurroundsBriefing.dds'],
    ['JTGMenu\\AoWCreeping.dds', 'src/assets/menu/AoWCreeping.dds'],
    ['JTGMenu\\BatSplitter.dds', 'src/assets/menu/BatSplitter.dds'],
    ['JTGMenu\\GoldMineMicro.dds', 'src/assets/menu/GoldMineMicro.dds'],
    ['JTGMenu\\GoldMineMicroBriefing.dds', 'src/assets/menu/GoldMineMicroBriefing.dds'],
    ['JTGMenu\\UnitComparison.dds', 'src/assets/menu/UnitComparison.dds'],
    ['JTGMenu\\DemoMode.dds', 'src/assets/menu/DemoMode.dds'],
    ['JTGMenu\\LearnToPlay.dds', 'src/assets/menu/LearnToPlay.dds'],
    ['JTGMenu\\AdvancedPlay.dds', 'src/assets/menu/AdvancedPlay.dds'],
    ['JTGMenu\\SkillTraining.dds', 'src/assets/menu/SkillTraining.dds'],
    ['JTGMenu\\ToolsExtras.dds', 'src/assets/menu/ToolsExtras.dds'],
    ['JTGMenu\\HotkeyTraining.dds', 'src/assets/menu/HotkeyTraining.dds'],
    ['JTGMenu\\HotkeySetup.dds', 'src/assets/menu/HotkeySetup.dds'],
    ['JTGMenu\\MissileDodging.dds', 'src/assets/menu/MissileDodging.dds'],
    ['JTGMenu\\StaffingHuman.dds', 'src/assets/menu/StaffingHuman.dds'],
    ['JTGMenu\\StaffingNightElf.dds', 'src/assets/menu/StaffingNightElf.dds'],
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
const configurationPaths = [
    ['war3mapSkin.txt', 'src/config/war3mapSkin.txt'],
];
// The foundation inherited object-skin tables from the source melee map.
// They redirect ordinary Blizzard objects (including Rings and Claws) to
// texture paths that are not part of the map and render as green squares on
// affected clients. Removing the tables restores every native object skin.
const removedArchivePaths = [
    'war3mapSkin.w3b',
    'war3mapSkin.w3t',
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
// Keep each source file in its own lexical scope. Warcraft uses Lua's normal
// limit for simultaneously active locals when it compiles war3map.lua. A flat
// concatenation makes every file-level local live until the end of the map
// script, so an otherwise valid new module can make Warcraft report the whole
// map as corrupted. Exported JTG members remain global across these scopes.
const bundle = moduleBuffers.map(module =>
    `-- BEGIN ${module.relativePath}\ndo\n${module.bytes.toString('utf8').trim()}\nend\n-- END ${module.relativePath}`
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
// The foundation's original start point is inside the southern training
// arena. Native notification history can record that location before the
// Camera tutorial has a chance to move it, and Warcraft exposes no API for
// clearing that history. Start the player at the tutorial base from config.
nextLua = nextLua.replace(
    'DefineStartLocation(0, 4864.0, 3456.0)',
    'DefineStartLocation(0, 3648.0, -5120.0)');
assert(nextLua.includes('function InitTrig_Infrastructure()'));
assert(nextLua.includes('function JTG.CreateBodyBlockingActivity(session)'),
    'Body Blocking activity factory is missing from the compiled map');
assert(nextLua.includes('id = "skills.body_blocking"'),
    'Body Blocking catalogue registration is missing from the compiled map');
assert(nextLua.includes('function JTG.CreatePowerBuildingActivity(session)'),
    'Power Building activity factory is missing from the compiled map');
assert(nextLua.includes('id = "tools.power_building"'),
    'Power Building catalogue registration is missing from the compiled map');
assert(nextLua.includes('function JTG.CreateCameraTutorialActivity(session)'),
    'Camera tutorial activity factory is missing from the compiled map');
assert(nextLua.includes('function JTG.CreateUnitControlsTutorialActivity(session)'),
    'Unit Controls tutorial activity factory is missing from the compiled map');
assert(nextLua.includes('title = "2. Unit Controls"'),
    'Unit Controls tutorial catalogue entry is missing from the compiled map');
assert(nextLua.includes('function JTG.CreateHotkeySetupTutorialActivity(session)'),
    'Hotkey Setup tutorial activity factory is missing from the compiled map');
assert(nextLua.includes('title = "3. Hotkey Setup"'),
    'Hotkey Setup tutorial catalogue entry is missing from the compiled map');
assert(nextLua.includes('CustomKeys-SolanumQWERTY.txt') &&
    nextLua.includes('CustomKeys-SolanumQWERTZ.txt') &&
    nextLua.includes('README_ShortcutSetup.txt') &&
    nextLua.includes('W3Champions.exe'),
    'Hotkey setup exports are missing from the compiled map');
assert(nextLua.includes('function JTG.CreateMiningMicroActivity(session)'),
    'Mining Micro activity factory is missing from the compiled map');
assert(nextLua.includes('title = "Mining Micro"'),
    'Mining Micro catalogue entry is missing from the compiled map');
assert(nextLua.includes('function JTG.RotateActivity()') &&
    nextLua.includes('captureRotatedState'),
    'Mining Micro rotation support is missing from the compiled map');
assert(nextLua.includes('function JTG.OpenSurroundsMenu') &&
    nextLua.includes('id = "skills.surround"'),
    'Surrounds briefing is missing from the compiled map');
assert(nextLua.includes('function JTG.CreateSurroundsActivity(session)') &&
    nextLua.includes('JTGToolbarSetups') &&
    nextLua.includes('JTGToolbarNext') &&
    nextLua.includes('JTGToolbarSquares'),
    'Surround Training activity or setup selector is missing from the compiled map');
assert(nextLua.includes('How to Surround') &&
    nextLua.includes('How it works...') &&
    nextLua.includes('JTGOverlay\\\\UnitSquaresPlayer.dds') &&
    nextLua.includes('JTGOverlay\\\\UnitSquaresEnemy.dds') &&
    nextLua.includes('CreateImage(texture, size, size, 0') &&
    nextLua.includes('function JTG.UnitObstructionHalfSize(collision)'),
    'Surround Training quests or authored unit-square overlays are missing');
assert(!nextLua.includes('Square Calibration') &&
    !nextLua.includes('Collision Diagnostics'),
    'Archived Surround calibration code remains in the playable map');
if (isDevelopment) {
    assert(nextLua.includes('function JTG.RunAutomatedLifecycleCheck()') &&
        nextLua.includes('"-diag-lifecycle"') &&
        nextLua.includes('id = PROBE_B'),
        'Development build is missing lifecycle diagnostics');
} else {
    assert(!nextLua.includes('function JTG.InitializeDiagnostics()') &&
        !nextLua.includes('dev.lifecycle') &&
        !nextLua.includes('-diag-'),
        'Release build contains development diagnostics');
}
assert(nextLua.includes('function JTG.CreateWindwalkPopActivity(session)'),
    'Windwalk Pop activity factory is missing from the compiled map');
assert(nextLua.includes('title = "Windwalk Pop"'),
    'Windwalk Pop catalogue entry is missing from the compiled map');
assert(nextLua.includes('JTGWindwalkPopResultReplay') &&
    nextLua.includes('squares = true'),
    'Windwalk Pop Replay or square overlays are missing');
assert(nextLua.includes('UI.PlaceToolbarButton(menu, 1, bar)') &&
    nextLua.includes('UI.PlaceToolbarButton(restart, 6, bar)') &&
    nextLua.includes('UI.PlaceToolbarButton(pause, 7, bar)') &&
    nextLua.includes('UI.PlaceToolbarButton(squares, 8, bar)'),
    'The standardized fixed toolbar layout is missing');
assert(nextLua.includes('SetBlight(HOTKEY_PLAYER, 4896, 3392, 1024, false)'),
    'Hotkey Setup blight cleanup is missing');
assert(nextLua.includes('centerSingleChoice = true'),
    'Centered single-choice activity menus are missing');
assert(nextLua.includes('title = "1. Camera"'),
    'Camera tutorial catalogue entry is missing from the compiled map');
assert(nextLua.includes('EVENT_GAME_LOADED') && nextLua.includes('RestoreLoadedGame'),
    'Save/load restoration infrastructure is missing from the compiled map');
assert(nextLua.includes('Skill Training - Race Specific'),
    'Race-specific Skill Training panels are missing from the compiled map');
assert(nextLua.includes('id = "nightelf", title = "Night Elf"'),
    'Race-specific Skill Training catalogue is missing from the compiled map');
assert(nextLua.includes('skills.peon_micro') && nextLua.includes('skills.wisp_micro'),
    'New racial micro entries are missing from the compiled map');
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
    str('Map navigation, activity lifecycle, Body Blocking and Power Building; source maintained in src/.'),
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
const displayVersion = isDevelopment ? `${version} DEVELOPMENT` : version;
wts = wts.replace(/(STRING 1\s*\{)[^}]*\}/,
    `$1\nJamie's Training Grounds ${displayVersion}\n}`);
changes.set('war3map.wts', Buffer.from(wts));
changes.set('war3map.w3b', addTrainingTreeObject(source.get('war3map.w3b')));
for (const [archivePath, relativePath] of assetPaths) {
    const bytes = fs.readFileSync(path.join(root, relativePath));
    if (relativePath.endsWith('.dds')) {
        assert.equal(bytes.toString('ascii', 0, 4), 'DDS ', relativePath + ' is not a DDS texture');
    }
    changes.set(archivePath, bytes);
}

function skipObjectTable(cursor) {
    const objectCount = cursor.int();
    for (let objectIndex = 0; objectIndex < objectCount; objectIndex++) {
        cursor.position += 8;
        const setCount = cursor.int();
        for (let setIndex = 0; setIndex < setCount; setIndex++) {
            cursor.int();
            const modificationCount = cursor.int();
            for (let modificationIndex = 0; modificationIndex < modificationCount;
                    modificationIndex++) {
                cursor.position += 4;
                const valueType = cursor.int();
                if (valueType === 3) cursor.text();
                else {
                    assert(valueType >= 0 && valueType <= 2,
                        'Unexpected object-data value type: ' + valueType);
                    cursor.position += 4;
                }
                cursor.position += 4;
            }
        }
    }
}

function addTrainingTreeObject(sourceObjects) {
    const cursor = new Cursor(sourceObjects);
    assert.equal(cursor.int(), 3, 'Unexpected destructable object-data version');
    skipObjectTable(cursor);
    const customCountOffset = cursor.position;
    const customCount = cursor.int();
    const customTree = Buffer.concat([
        Buffer.from('LTlt', 'ascii'),
        Buffer.from('JTtr', 'ascii'),
        i32(1),
        i32(0),
        i32(1),
        Buffer.from('bhps', 'ascii'),
        i32(0),
        i32(1000),
        Buffer.from('JTtr', 'ascii'),
    ]);
    return Buffer.concat([
        sourceObjects.subarray(0, customCountOffset),
        i32(customCount + 1),
        sourceObjects.subarray(customCountOffset + 4),
        customTree,
    ]);
}
for (const [archivePath, relativePath] of configurationPaths) {
    changes.set(archivePath, fs.readFileSync(path.join(root, relativePath)));
}

fs.mkdirSync(path.dirname(outputPath), {recursive: true});
fs.copyFileSync(sourcePath, outputPath);
const outputArchive = Archive.open(outputPath);
try {
    for (const name of removedArchivePaths) {
        if (outputArchive.hasFile(name)) outputArchive.removeFile(name);
    }
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
        if (name === '(attributes)' || name === '(listfile)' ||
                changes.has(name) || removedArchivePaths.includes(name)) continue;
        assert(verifyArchive.readFile(name).equals(bytes), 'Unexpected archive change: ' + name);
    }
    for (const name of removedArchivePaths) {
        assert(!verifyArchive.hasFile(name), 'Skin override remained in archive: ' + name);
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
    buildMode,
    purpose: isDevelopment ?
        'Internal development build with lifecycle diagnostics.' :
        'Public release build without development tools.',
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
    removedArchiveFiles: removedArchivePaths,
    preservedArchiveFiles: [...source.keys()].filter(name =>
        name !== '(attributes)' && name !== '(listfile)' && !changes.has(name)
    ).length,
    checks: {
        moduleLuaSyntax: 'PASS',
        compiledLuaSyntax: 'PASS',
        archiveRoundtrip: 'PASS',
        unchangedMembersByteIdentical: 'PASS',
        acceptedFoundationHashUnchanged: 'PASS',
        developmentToolBoundary: 'PASS',
    },
    output: path.relative(root, outputPath).replaceAll('\\', '/'),
    outputSha256: hash(fs.readFileSync(outputPath)),
    outputBytes: fs.statSync(outputPath).size,
};
fs.writeFileSync(reportPath, JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify(report, null, 2));
