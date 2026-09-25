/* Extract the exact custom menu artwork referenced by v0.92's menu-building
 * functions. The source archive is read-only and must match the recorded hash.
 */
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const assert = require('node:assert/strict');
const {createRequire} = require('node:module');

const root = path.resolve(__dirname, '..');
const req = createRequire(path.join(root, 'package.json'));
const {Archive} = req('@jamiephan/stormlib');
const sourcePath = process.argv[2];
if (!sourcePath) {
    throw new Error('Usage: node tools/extract-legacy-menu-assets.cjs <path-to-v0.92.w3x>');
}

const expectedSourceHash = 'e789410d5dcae58413bcfaa8919905248fa188ea13e01f6cfc7bed47a69681c8';
const outputDir = path.join(root, 'reference/legacy/menu-assets');
const hash = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const sourceBytes = fs.readFileSync(sourcePath);
assert.equal(hash(sourceBytes), expectedSourceHash,
    'Legacy archive differs from the authoritative v0.92 source');

const assets = [
    ['TrainingMenuBackground.dds', 'menu background'],
    ['UnitBlockActionButton.dds', 'compact Human-console frame used by upper control buttons'],
    ['TrainingPathCardBorder.dds', 'training-path yellow border'],
    ['TrainingPathWorkers.dds', 'Learn the Basics path artwork'],
    ['TrainingPathAdvanced.dds', 'Advanced Techniques path artwork'],
    ['TrainingCourseButtonBlank.dds', 'blank course/navigation card'],
    ['TrainingCourseButtonHover.dds', 'shared course/path-card mouse-over highlight'],
    ['TrainingCourseButtonKnowledge.dds', 'Warcraft III Quiz'],
    ['TrainingCourseButtonUnitBlock.dds', 'Body Blocking'],
    ['TrainingCourseButtonSurround.dds', 'Surround Training'],
    ['TrainingCourseButtonMicro.dds', 'Micro Training'],
    ['TrainingCourseButtonGoblinLab.dds', 'Goblin Lab Creeping'],
    ['TrainingCourseButtonGoldMine.dds', 'Gold Mine Micro'],
    ['TrainingCourseButtonMercenary.dds', 'Merc Camp Creeping'],
    ['TrainingCourseButtonDamageCalculator.dds', 'Demo Mode'],
    ['TrainingCourseButtonExpoHarassment.dds', 'Expo Harassment'],
    ['TrainingCourseButtonBatSplitter.dds', 'Bat Splitter'],
    ['TrainingCourseButtonBaseLayout.dds', 'Base Layout'],
    ['TrainingCourseButtonSpeedBuilder.dds', 'Speed Builder Comparison'],
    ['TrainingCourseButtonReflexes.dds', 'Reflexes'],
    ['TrainingCourseButton.dds', 'Unit Comparison'],
    ['TrainingCourseButtonHotkeyTrainer.dds', 'Hotkey Trainer'],
    ['TrainingCourseButtonWindwalkPop.dds', 'Windwalk Pop'],
    ['TrainingCourseButtonAowCreeping.dds', 'AoW Creeping'],
    ['TrainingCourseButtonStaffingUnits.dds', 'Staffing Units'],
    ['TrainingCourseButtonZeppelinMicro.dds', 'Zeppelin Micro'],
    ['TrainingCourseButtonGargoyleSurround.dds', 'Gargoyle Surround'],
];
const supportFiles = [
    ['TrainingCourseUI.toc', 'loads the custom button frame definition'],
    ['TrainingCourseButton.fdf', 'defines the native tracked hover layer'],
];

fs.mkdirSync(outputDir, {recursive: true});
const archive = Archive.open(sourcePath, {flags: 256});
const manifest = {
    source: path.basename(sourcePath),
    sourceSha256: expectedSourceHash,
    scope: 'Custom DDS graphics referenced by the v0.92 training-path and course-button menu code.',
    files: [],
    supportFiles: [],
};
try {
    for (const [name, purpose] of assets) {
        assert(archive.hasFile(name), 'Missing legacy menu asset: ' + name);
        const bytes = archive.readFile(name);
        assert.equal(bytes.toString('ascii', 0, 4), 'DDS ', name + ' is not a DDS texture');
        const height = bytes.readUInt32LE(12);
        const width = bytes.readUInt32LE(16);
        const target = path.join(outputDir, name);
        fs.writeFileSync(target, bytes);
        assert(fs.readFileSync(target).equals(bytes), 'Extraction verification failed: ' + name);
        manifest.files.push({name, purpose, width, height, bytes: bytes.length, sha256: hash(bytes)});
    }
    for (const [name, purpose] of supportFiles) {
        assert(archive.hasFile(name), 'Missing legacy menu support file: ' + name);
        const bytes = archive.readFile(name);
        const target = path.join(outputDir, name);
        fs.writeFileSync(target, bytes);
        assert(fs.readFileSync(target).equals(bytes), 'Extraction verification failed: ' + name);
        manifest.supportFiles.push({name, purpose, bytes: bytes.length, sha256: hash(bytes)});
    }
} finally {
    archive.close();
}

fs.writeFileSync(path.join(outputDir, 'manifest.json'), JSON.stringify(manifest, null, 2) + '\n');
console.log(JSON.stringify({
    outputDir,
    extractedGraphics: manifest.files.length,
    extractedSupportFiles: manifest.supportFiles.length,
    sourceSha256: expectedSourceHash,
}, null, 2));
