const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {parse, prepare, specs, marker} = require('./prepare-exercise-briefings.cjs');
const root = path.resolve(__dirname, '..');
for (const spec of specs) {
    const text = fs.readFileSync(path.join(root, 'design/exercises/editable', `${spec.file}.txt`), 'utf8').replace(/\r\n/g, '\n');
    const pages = parse(text, spec);
    assert.equal(Object.keys(pages).length, 2);
    assert.deepEqual(parse('\uFEFF' + text.replace(/\n/g, '\r\n'), spec), pages);
    const noted = text.replace('Your notes:', 'Your notes:\nDo not put this note in the game.');
    assert.deepEqual(parse(noted, spec), pages);
    assert.throws(() => parse(text.replace('Selection page 2', 'Selection page 1'), spec));
    assert.throws(() => parse(text.replace(`Source: src/activities/${spec.source}`, 'Source: wrong.lua'), spec));
    if (spec.dynamic) {
        assert.throws(() => parse(text.replace(marker, ''), spec));
        assert(pages[spec.dynamic].endsWith('\n\n'));
        assert(!pages[spec.dynamic].includes(marker));
    }
    assert(!Object.values(pages).some(text => text.includes('Your notes:')));
    assert.throws(() => parse(text.replace('Your notes:', '\u0001\nYour notes:'), spec));
}
prepare(true);
const builder = fs.readFileSync(path.join(root, 'tools/build-infrastructure.cjs'), 'utf8');
assert(builder.includes("require('./prepare-exercise-briefings.cjs').prepare()"));
assert(builder.includes("'src/generated/exercise-briefings.lua'"));
for (const [name, id] of [['hotkey-training', 'tools.hotkeys'], ['reflex-training', 'skills.reflex']]) {
    const source = fs.readFileSync(path.join(root, `src/activities/${name}.lua`), 'utf8');
    assert.equal((source.match(new RegExp(`BriefingText\\('${id.replace('.', '\\.')}'`, 'g')) || []).length, 2);
    assert(!source.includes('This exercise allows you to practice your hotkeys.'));
    assert(!source.includes('This exercise is a work in progress.'));
}
const production = fs.readFileSync(path.join(root, 'src/activities/hotkey-training.lua'), 'utf8');
assert(!/self\.(?:audit|comparison|eventTrace)|Preload|ForceUIKey|setNativeCardHidden|ORIGIN_FRAME_TOOLTIP/.test(production),
    'Development diagnostics or obsolete command-card hiding leaked into the production activity');
console.log('Passed: authored briefing pages, paragraph/dynamic boundaries, notes exclusion, drift checks and development-only Hotkey diagnostics.');
