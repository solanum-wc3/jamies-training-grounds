/* Build the current map on the immutable accepted alpha.5 foundation.
 * Explicit changes include Lua, editor metadata, assets and native overrides.
 * All other listed archive members are verified byte-identical.
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

// Refresh only generated briefing text; author files are never overwritten.
require('./prepare-exercise-briefings.cjs').prepare();
require('./prepare-heroes-tutorial.cjs').prepare();

const version = 'v0.1.3-alpha50';
const modeArgument = process.argv.find(argument => argument.startsWith('--mode='));
const buildMode = modeArgument ? modeArgument.slice('--mode='.length) : 'release';
assert(['release', 'development'].includes(buildMode),
    'Build mode must be release or development');
const isDevelopment = buildMode === 'development';
const sourcePath = path.join(root, 'reference/foundation/Jamies-Training-Grounds-v0.0.1-alpha.5.w3x');
const outputLabel = isDevelopment
    ? `${version}-dev`
    : version;
const outputArgument = process.argv.find(argument => argument.startsWith('--output-dir='));
const outputDirectory = outputArgument
    ? path.resolve(root, outputArgument.slice('--output-dir='.length))
    : path.join(root, 'outputs');
const outputPath = path.join(outputDirectory, `Jamies-Training-Grounds-${outputLabel}.w3x`);
const reportPath = path.join(outputDirectory,
    `Jamies-Training-Grounds-${outputLabel}-validation.json`);
const acceptedHash = 'a1ea7789e60b30e77d64f14337759842dff309d129929ef24defb1276cf1ba64';
const sharedModulePaths = [
    'src/infrastructure/core.lua',
    'src/infrastructure/training.lua',
    'src/generated/exercise-briefings.lua',
    'src/infrastructure/tutorial.lua',
    'src/generated/custom-keys.lua',
    'src/generated/melee-tech.lua',
    'src/generated/dodge-catalog.lua',
    'src/generated/hotkey-catalog.lua',
    'src/generated/economy-layout.lua',
    'src/generated/economy-script.lua',
    'src/infrastructure/economy-layout.lua',
    'src/activities/economy-tutorial.lua',
    'src/activities/camera-tutorial.lua',
    'src/activities/unit-controls-tutorial.lua',
    'src/activities/hotkey-setup-tutorial.lua',
    'src/generated/heroes-tutorial.lua',
    'src/infrastructure/heroes-scenes.lua',
    'src/activities/heroes-tutorial.lua',
    'src/activities/mining-micro.lua',
    'src/activities/surrounds.lua',
    'src/activities/windwalk-pop.lua',
    'src/activities/body-blocking.lua',
    'src/activities/bat-splitting.lua',
    'src/activities/reflex-training.lua',
    'src/activities/hotkey-training.lua',
    'src/activities/missile-dodging.lua',
    'src/activities/power-building.lua',
    'src/infrastructure/catalog.lua',
    'src/infrastructure/ui.lua',
];
const modulePaths = [
    ...sharedModulePaths,
    ...(isDevelopment ? [
        'src/generated/dev-sounds.lua',
        'src/infrastructure/sound-preview.lua',
        'src/infrastructure/diagnostics.lua',
        'src/infrastructure/hotkey-diagnostics.lua',
        'src/infrastructure/hotkey-audit.lua',
        fs.existsSync(path.join(root,'work/hotkey-comparison-bindings.lua'))
            ? 'work/hotkey-comparison-bindings.lua' : 'src/generated/hotkey-comparison-defaults.lua',
        fs.existsSync(path.join(root,'work/hotkey-audit-exclusions.lua'))
            ? 'work/hotkey-audit-exclusions.lua' : 'src/generated/hotkey-audit-defaults.lua',
        'src/infrastructure/hotkey-comparison.lua',
        'src/infrastructure/hotkey-full-audit.lua',
        'src/infrastructure/economy-layout-export.lua',
        'src/infrastructure/collision-order-diagnostics.lua',
        'src/infrastructure/collision-footprint-diagnostics.lua',
        'src/infrastructure/collision-placement-diagnostics.lua',
        'src/infrastructure/dodge-timing-diagnostics.lua',
        'src/generated/dodge-timing-methods.lua',
        'src/infrastructure/dodge-timing-batch.lua',
    ] : []),
    'src/infrastructure/bootstrap.lua',
];
const assetPaths = [
    ['JTGOverlay\\HeroesXPRing.dds', 'src/assets/overlay/HeroesXPRing.dds'],
    ['JTGMenu\\EconomyAndWorkers.dds', 'src/assets/menu/EconomyAndWorkers.dds'],
    ['JTGMenu\\HeroesTutorial.dds', 'src/assets/menu/HeroesTutorial.dds'],
    ['JTGMenu\\GargoyleSurrounds.dds', 'src/assets/menu/GargoyleSurrounds.dds'],
    ['JTGMenu\\GargoyleSurroundsBriefing.dds', 'src/assets/menu/GargoyleSurroundsBriefing.dds'],
    ['JTGMenu\\CombatMicro.dds', 'src/assets/menu/CombatMicro.dds'],
    ['JTGCelebration\\HotDiggedyDog.mp3', 'src/assets/celebration/HotDiggedyDog.mp3'],
    ...Array.from({length: 5}, (_, index) =>
        [`JTGCelebration\\Doge${index}.dds`, `src/assets/celebration/Doge${index}.dds`]),
    ['JTGOverlay\\32x32NavigationGridDots.dds', 'src/assets/overlay/32x32NavigationGridDots.dds'],
    ['JTGOverlay\\8x8NavigationGrid.dds', 'src/assets/overlay/8x8NavigationGrid.dds'],
    ['JTGOverlay\\UnitSquaresEnemy.dds', 'src/assets/overlay/UnitSquaresEnemy.dds'],
    ['JTGOverlay\\UnitSquaresPlayer.dds', 'src/assets/overlay/UnitSquaresPlayer.dds'],
    ['JTGMenu\\BodyBlocking.dds', 'src/assets/menu/BodyBlocking.dds'],
    ['JTGMenu\\BodyBlockingBriefing.dds', 'src/assets/menu/BodyBlockingBriefing.dds'],
    ['JTGMenu\\PowerBuilding.dds', 'src/assets/menu/PowerBuilding.dds'],
    ['JTGMenu\\ReflexTraining.dds', 'src/assets/menu/ReflexTraining.dds'],
    ['JTGMenu\\ReflexTrainingBriefing.dds', 'src/assets/menu/ReflexTrainingBriefing.dds'],
    ['JTGMenu\\HotkeyTrainingBriefing.dds', 'src/assets/menu/HotkeyTrainingBriefing.dds'],
    ['JTGMenu\\OpaqueBlack.dds', 'src/assets/menu/OpaqueBlack.dds'],
    ['JTGMenu\\PeonMicro.dds', 'src/assets/menu/PeonMicro.dds'],
    ['JTGMenu\\WispMicro.dds', 'src/assets/menu/WispMicro.dds'],
    ['JTGMenu\\CameraControls.dds', 'src/assets/menu/CameraControls.dds'],
    ['JTGMenu\\UnitControls.dds', 'src/assets/menu/UnitControls.dds'],
    ['JTGMenu\\TutorialArrowDown.dds', 'src/assets/menu/TutorialArrowDown.dds'],
    ['JTGMenu\\TutorialArrowUp.dds', 'src/assets/menu/TutorialArrowUp.dds'],
    ['JTGMenu\\WindwalkPop.dds', 'src/assets/menu/WindwalkPop.dds'],
    ['JTGMenu\\WindwalkPopBriefing.dds', 'src/assets/menu/WindwalkPopBriefing.dds'],
    ['JTGMenu\\ZeppelinMicro.dds', 'src/assets/menu/ZeppelinMicro.dds'],
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
    ['JTGMenu\\BatSplitterBriefing.dds', 'src/assets/menu/BatSplitterBriefing.dds'],
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
    // Replaced by native Reveal and Peon quest icons.
    'JTGQuest\\CameraSettingsZoom.dds',
    'JTGQuest\\IdleWorkerSettings.dds',
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
assert(nextLua.includes('commandGridChoices = true') &&
    nextLua.includes('JTGActivityBriefingCommandChoice') &&
    nextLua.includes('BTNGryphonAviary.blp') &&
    nextLua.includes('BTNFarm.blp') &&
    nextLua.includes('BTNHumanWatchTower.blp') &&
    nextLua.includes('BRIEFING_COMMAND_BUTTON_STEP = BRIEFING_COMMAND_BUTTON_SIZE') &&
    !nextLua.includes('function JTG.GetUnitCommandCardMetadata('),
    'Reusable command-card briefing grid is missing from the compiled map');
assert(nextLua.includes('ReplaceableTextures\\\\CommandButtons\\\\BTNSkillz.blp'),
    'Surrounds Hero Abilities quest icon is missing from the compiled map');
assert(nextLua.includes('local function HasAvailableRaceActivity(') &&
    nextLua.includes('status = hasAvailableActivity and "available" or "planned"'),
    'Race catalogue buttons do not reflect playable activity availability');
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
    assert(nextLua.includes('JTG-Hotkey-Debug.pld') && nextLua.includes('self.diagnostics={'),
        'Development build is missing the Hotkey diagnostics adapter');
    assert(nextLua.includes('function JTG.RunAutomatedLifecycleCheck()') &&
        nextLua.includes('"-diag-lifecycle"') &&
        nextLua.includes('id = PROBE_B'),
        'Development build is missing lifecycle diagnostics');
    assert(nextLua.includes('JTG.Dev.DodgeTiming = Timing') && nextLua.includes('"-timing-on"') &&
        nextLua.includes('"-timing-batch"') && nextLua.includes('"-timing-activation"'),
        'Development build is missing Dodging timing observations');
    assert(nextLua.includes('JTG-Economy-Layout.pld'), 'Development base workspace is missing');
    assert(nextLua.includes('JTG.DevSoundPreviews') && nextLua.includes('JTGDevSoundPreviewOpen'),
        'Development build is missing selected sound previews');
} else {
    assert(!nextLua.includes('-hotkey-debug') && !nextLua.includes('JTG-Hotkey-Debug.pld') &&
        !nextLua.includes('self.diagnostics={'), 'Release build contains Hotkey development tooling');
    assert(!nextLua.includes('function JTG.InitializeDiagnostics()') &&
        !nextLua.includes('JTG.DevSoundPreviews') && !nextLua.includes('JTGDevSoundPreviewOpen') &&
        !nextLua.includes('dev.lifecycle') &&
        !nextLua.includes('-diag-') && !nextLua.includes('JTG.Dev.DodgeTiming') &&
        !nextLua.includes('"-timing-on"') && !nextLua.includes('JTG.DodgeTimingMethods') &&
        !nextLua.includes('"-timing-batch"') && !nextLua.includes('"-timing-activation"') && !nextLua.includes('JTG-Economy-Layout.pld'),
        'Release build contains development diagnostics');
}
assert(nextLua.includes('function JTG.CreateWindwalkPopActivity(session)'),
    'Windwalk Pop activity factory is missing from the compiled map');
assert(nextLua.includes('title = "Windwalk Pop"'),
    'Windwalk Pop catalogue entry is missing from the compiled map');
assert(nextLua.includes('local COURSE_SETUPS = {') &&
    nextLua.includes('function activity:startCourseCountdownFormation()') &&
    nextLua.includes('if moveCount <= 4 then') &&
    nextLua.includes('IssueTargetOrder(unit, "attack", self.surroundee)') &&
    nextLua.includes('TimerStart(moveTimer, 0.60, true') &&
    nextLua.includes('function activity:captureLastRunnerState()') &&
    nextLua.includes('self.courseStage < 4 and "Next Stage" or "Restart Course"'),
    'Windwalk Pop four-stage racial courses are missing from the compiled map');
assert(nextLua.includes('function UI.CreateResultCard(session, options)') &&
    nextLua.includes('function JTG.ActivateResultAction(action)') &&
    nextLua.includes('RESULT_TITLE_COLORS') &&
    nextLua.includes('name = "JTGWindwalkPopResult"') &&
    nextLua.includes('name = "JTGSurroundResult"') &&
    nextLua.includes('name = "JTGBodyBlockResult"') &&
    nextLua.includes('squares = true'),
    'Shared result cards, exercise actions or square overlays are missing');
assert(nextLua.includes('local CUSTOM_RACE_COLUMNS = {') &&
    nextLua.includes('showCustomGrid = function(race)') &&
    nextLua.includes('selection.customAbilities') &&
    nextLua.includes('selection.customRemoveMode') &&
    nextLua.includes('customHeroCount() >= 3') &&
    nextLua.includes('RegisterRightClick(button') &&
    nextLua.includes('commandGridColumns = math.max(10, abilityColumn)'),
    'Surrounds custom selector foundation is missing');
assert(nextLua.includes('UI.PlaceToolbarButton(menu, 1, bar)') &&
    nextLua.includes('UI.PlaceToolbarButton(restart, 6, bar)') &&
    nextLua.includes('UI.PlaceToolbarButton(pause, 7, bar)') &&
    nextLua.includes('UI.PlaceToolbarButton(squares, 8, bar)'),
    'The standardized fixed toolbar layout is missing');
assert(nextLua.includes('local function CreateStandardMenuShell(') &&
    nextLua.includes('local SECTIONED_CATEGORY_LAYOUTS = {advanced = true}') &&
    nextLua.includes('function UI.ShowCategoryRace(categoryId, raceId)') &&
    nextLua.includes('spec.headingArtworkCenterX or BRIEFING_IMAGE_CENTER_X') &&
    nextLua.includes('firstChoiceY + BRIEFING_DIVIDER_BUTTON_GAP'),
    'Shared menu and briefing layout infrastructure is incomplete');
assert(nextLua.includes('local belongsOnGeneralPage = category == "skills"') &&
    nextLua.includes('selection.race="human"; showBriefing(\'duration\')') &&
    nextLua.includes('selection.race="orc"; showBriefing(\'duration\')') &&
    nextLua.includes("label='One Minute'") && nextLua.includes("label='Unlimited'"),
    'Flat Skill Training navigation or Mining Micro race choices are missing');
assert(nextLua.includes('JTG.ClearBlightAfterActivity(current,') &&
    nextLua.includes('function JTG.ClearBlightAfterActivity('),
    'Hotkey Setup post-disposal blight cleanup is missing');
assert(nextLua.includes('centerSingleChoice = true'),
    'Centered single-choice activity menus are missing');
assert(nextLua.includes('title = "1. Camera"'),
    'Camera tutorial catalogue entry is missing from the compiled map');
assert(nextLua.includes('EVENT_GAME_LOADED') && nextLua.includes('RestoreLoadedGame'),
    'Save/load restoration infrastructure is missing from the compiled map');
assert(nextLua.includes('function JTG.StartScopedTimer(') &&
    nextLua.includes('function JTG.ScopeRevealScene(') &&
    nextLua.includes('function JTG.ClearBlightAfterActivity(') &&
    nextLua.includes('RunActivityFinalizers(session, reason)'),
    'Shared activity lifecycle helpers are missing');
assert(nextLua.includes('category.title .. " - Race Specific"') &&
    nextLua.includes('JTG.Races = {'),
    'Shared race-specific category panels are missing from the compiled map');
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
const displayVersion = outputLabel;
wts = wts.replace(/(STRING 1\s*\{)[^}]*\}/,
    `$1\nJamie's Training Grounds ${displayVersion}\n}`);
assert(wts.includes(`Jamie's Training Grounds ${outputLabel}`),
    'Map-selection title does not contain the current build label');
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
if (isDevelopment) {
    const {patchStockDelay}=require('./patch-stock-delay.cjs');
    const commands=JSON.parse(fs.readFileSync(path.join(root,'src/data/hotkey-catalog.json'),'utf8')).entries;
    changes.set('war3map.w3u',patchStockDelay(source.get('war3map.w3u'),
        commands.filter(e=>e.kind==='hire').map(e=>e.raw),'usst'));
    changes.set('war3map.w3t',patchStockDelay(source.get('war3map.w3t'),
        commands.filter(e=>e.kind==='buy').map(e=>e.raw),'isst'));
}

const heroesNativeData=JSON.parse(fs.readFileSync(path.join(root,'src/data/heroes-tutorial-data.json'),'utf8'));
const {patchHeroesDummy,createHeroesDummyAbilities}=require('./patch-heroes-dummy.cjs');
const {patchStockDelay:patchHeroStockDelay}=require('./patch-stock-delay.cjs');
changes.set('war3map.w3t',patchHeroStockDelay(changes.get('war3map.w3t')||source.get('war3map.w3t'),
    Object.values(heroesNativeData.shops).flat().concat(heroesNativeData.itemGroups.flatMap(group=>group.items)),'isst'));
changes.set('war3map.w3u',patchHeroesDummy(changes.get('war3map.w3u')||source.get('war3map.w3u'),heroesNativeData.dummyModel));
assert(!source.has('war3map.w3a')&&!changes.has('war3map.w3a'),
    'Merge existing ability overrides before adding Heroes dummy commands');
changes.set('war3map.w3a',createHeroesDummyAbilities());

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
        assert(!verifyArchive.hasFile(name), 'Removed member remained in archive: ' + name);
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
        sharedActivityLifecycle: 'PASS',
        sharedResultCards: 'PASS',
        sharedMenuLayouts: 'PASS',
    },
    output: path.relative(root, outputPath).replaceAll('\\', '/'),
    outputSha256: hash(fs.readFileSync(outputPath)),
    outputBytes: fs.statSync(outputPath).size,
};
fs.writeFileSync(reportPath, JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify(report, null, 2));
