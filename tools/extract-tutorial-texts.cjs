const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');

function matchingBrace(text, open) {
  let depth = 0;
  let quote = null;
  let escaped = false;
  for (let i = open; i < text.length; i += 1) {
    const c = text[i];
    if (quote) {
      if (escaped) escaped = false;
      else if (c === '\\') escaped = true;
      else if (c === quote) quote = null;
      continue;
    }
    if (c === '"' || c === "'") { quote = c; continue; }
    if (c === '{') depth += 1;
    else if (c === '}') {
      depth -= 1;
      if (depth === 0) return i;
    }
  }
  throw new Error('Unmatched table brace');
}

function luaStrings(text) {
  const values = [];
  const re = /"((?:\\.|[^"\\])*)"/g;
  let match;
  while ((match = re.exec(text))) {
    values.push(match[1]
      .replace(/\\n/g, '\n')
      .replace(/\\"/g, '"')
      .replace(/\\\\/g, '\\'));
  }
  return values;
}

function tableBody(source, declaration) {
  const start = source.indexOf(declaration);
  if (start < 0) throw new Error(`Missing ${declaration}`);
  const open = source.indexOf('{', start);
  return source.slice(open + 1, matchingBrace(source, open));
}

function lineBlocks(body) {
  const blocks = [];
  const re = /lines\s*=\s*{/g;
  let match;
  while ((match = re.exec(body))) {
    const open = body.indexOf('{', match.index);
    const close = matchingBrace(body, open);
    const context = body.slice(Math.max(0, match.index - 500), match.index);
    const checkpointMatches = [...context.matchAll(/checkpoint\s*=\s*"([^"]+)"/g)];
    blocks.push({
      lines: luaStrings(body.slice(open + 1, close)),
      checkpoint: checkpointMatches.length
        ? checkpointMatches[checkpointMatches.length - 1][1]
        : null,
    });
    re.lastIndex = close + 1;
  }
  return blocks;
}

function topicLabels(source) {
  let body;
  try { body = tableBody(source, 'local TOPICS ='); }
  catch { return []; }
  return [...body.matchAll(/label\s*=\s*"([^"]+)"/g)].map(m => m[1]);
}

function renderBlocks(blocks, heading) {
  const out = [`## ${heading}`, ''];
  blocks.forEach((block, index) => {
    const first = block.lines.find(line => line.startsWith('{Heading:'));
    const title = first ? first.slice(10, -1).trim() : null;
    const suffix = title ? ` — ${title}` : '';
    out.push(`### Progression point ${index + 1}${suffix}`, '', ...block.lines, '');
  });
  return out;
}

function cameraQuests() {
  return [
    '## Camera tutorial — Quest Log entries', '',
    '### Changing Default Camera Distance', '',
    'To change the default camera distance, go to {Menu: Gameplay -> Camera Settings}, enable {Menu: Improved Zoom}, and enter your preferred value.', '',
    'To do this, you need to leave this map temporarily. Before you do, you should make a {Term: Quicksave}. The default key for this is {Input: F6}.', '',
    '### Idle Worker Double-Tap', '',
    'To make centering the camera on an idle worker require a double-tap, go to {Menu: Gameplay -> Game Behavior}, and enable {Menu: Snap Camera to Worker on Double Click}.', '',
  ];
}

const tutorials = [
  {
    title: 'Camera tutorial', file: 'src/activities/camera-tutorial.lua',
    main: 'local TUTORIAL_STEPS =', optional: 'local OPTIONAL_SECTIONS =',
    menuTitle: '1. Camera',
    menuDescription: 'Learn how to move, zoom and quickly reposition the camera.',
  },
  {
    title: 'Unit Controls tutorial', file: 'src/activities/unit-controls-tutorial.lua',
    main: 'local STEPS =', optional: 'local OPTIONAL_SECTIONS =',
    menuTitle: '2. Unit Controls',
    menuDescription: 'Learn how to select units, read their interface and use their abilities.',
  },
  {
    title: 'Hotkey Setup tutorial', file: 'src/activities/hotkey-setup-tutorial.lua',
    main: 'local STEPS =', optional: null,
    menuTitle: '3. Hotkey Setup',
    menuDescription: 'Learn how to use and customize your hotkey layout.',
  },
];

const out = [
  '# Tutorial Text Review', '',
  'This file collects the player-facing instructional text from every currently implemented tutorial. It is arranged by progression point and keeps the authoring markers used by the map. Trigger logic and scene implementation details are omitted.', '',
  '## Formatting markers', '',
  '- `{Heading: ...}` — cyan section heading',
  '- `{Small Heading: ...}` — cyan subheading where supported',
  '- `{Button: ...}` — yellow interface button',
  '- `{Input: ...}` — yellow player input or key',
  '- `{Menu: ...}` — purple menu path or menu item',
  '- `{Term: ...}` — orange game term',
  '- `{Yellow Font: ...}` — yellow emphasis',
  '- `{Green Font: ...}` — green emphasis',
  '- `{Hotkeys}` — purple “Hotkeys” label', '',
  'Blank lines below separate review paragraphs. In game, the lines within one progression point are displayed together.', '',
];

for (const tutorial of tutorials) {
  const source = fs.readFileSync(path.join(root, tutorial.file), 'utf8');
  out.push(`# ${tutorial.title}`, '');
  out.push(`**Learn to Play entry:** ${tutorial.menuTitle}`, '',
    `**Tooltip:** ${tutorial.menuDescription}`, '');
  const topics = topicLabels(source);
  if (topics.length) out.push(`**Topic menu:** ${topics.join(' · ')}`, '');
  let blocks = lineBlocks(tableBody(source, tutorial.main));
  if (tutorial.title === 'Hotkey Setup tutorial') {
    // Match the disabled export stops declared by the activity.
    const hidden = source.match(/if not EXPORT_ENABLED then\s+for _, index in ipairs\(\{([\d, ]+)\}\)/);
    if (!hidden) throw new Error('Missing disabled Hotkey export stops');
    const indices = new Set(hidden ? hidden[1].split(',').map(Number) : []);
    blocks = blocks.filter((block, index) => !indices.has(index + 1))
      .map(block => ({...block, lines: block.lines.filter(line => !line.includes('{Button: Export}'))}));
  }
  out.push(...renderBlocks(blocks, 'Main progression'));
  if (tutorial.optional) {
    out.push(...renderBlocks(lineBlocks(tableBody(source, tutorial.optional)), 'Optional topics'));
  }
  if (tutorial.title === 'Camera tutorial') out.push(...cameraQuests());

}

const economy = JSON.parse(fs.readFileSync(path.join(root, 'design/tutorials/economy-script.json'), 'utf8'));
out.push('# Economy & Workers tutorial', '', '**Learn to Play entry:** 4. Economy & Workers', '');
out.push(...renderBlocks(economy, 'Main progression'));

const output = path.join(root, 'docs', 'TUTORIAL-TEXT-REVIEW.md');
fs.writeFileSync(output, `${out.join('\n').replace(/\n{3,}/g, '\n\n')}\n`);
console.log(output);
