"""Compile the small, user-selected development sound list into Lua."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
catalog = json.loads((ROOT / 'src/data/dev-sound-previews.json').read_text())['sounds']
assert len({entry['name'] for entry in catalog}) == len(catalog)
lines = ['-- Selected development-only sound previews. Source: src/data/dev-sound-previews.json',
         'JTG.DevSoundPreviews = {']
for entry in catalog:
    assert entry['files'] and entry['label']
    quote = lambda value: json.dumps(value, ensure_ascii=False)
    paths = '{' + ','.join(quote(path) for path in entry['files']) + '}'
    lines.append('    {name=' + quote(entry['name']) + ',note=' + quote(entry['note']) +
                 ',label=' + quote(entry['label']) + ',files=' + paths +
                 ',exactVariant=' + ('true' if entry['exactVariant'] else 'false') + '},')
lines.append('}')
(ROOT / 'src/generated/dev-sounds.lua').write_text('\n'.join(lines) + '\n')
print(f'Compiled {len(catalog)} selected sound previews; no audio imported.')
