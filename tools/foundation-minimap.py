"""Build the browser preview and runtime terrain minimap as Warcraft BLP1.

Reforged displays war3mapMap.blp in the map browser. The map swaps to the real
terrain minimap after initialization. BLP1 uses all nine mip levels.
"""
from pathlib import Path
import json
import math
import struct
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
WORK = ROOT / 'work' / 'baseline-build'
plan = json.loads((WORK / 'build-plan.json').read_text())
area = plan['area']
original = Image.open(WORK / 'war3mapMap.blp').convert('RGB')
result = original.copy()
terrain = (WORK / 'patched-war3map.w3e').read_bytes()
width, height, ox, oy, header = (plan[k] for k in ('width','height','ox','oy','header'))
textures = plan['textures']
colors = {
    'Ldrt': (139, 111, 68),
    'Ldro': (146, 120, 76),
    'Ldrg': (116, 94, 60),
    'Lrok': (96, 96, 80),
    'Lgrs': (91, 122, 53),
    'Lgrd': (66, 104, 45),
}
# Saved playable rectangle, before adding the camera's viewport margins.
bounds = (-7936, -8192, 7936, 7680)
for py in range(256):
    for px in range(256):
        wx = bounds[0] + (px + .5) / 256 * (bounds[2] - bounds[0])
        wy = bounds[3] - (py + .5) / 256 * (bounds[3] - bounds[1])
        if not (area['minX'] <= wx <= area['maxX'] and area['minY'] <= wy <= area['maxY']):
            continue
        edge = min(wx-area['minX'], area['maxX']-wx, wy-area['minY'], area['maxY']-wy)
        vx = max(0, min(width-1, round((wx-ox)/128)))
        vy = max(0, min(height-1, round((wy-oy)/128)))
        texture_index = terrain[header+(vy*width+vx)*7+4] & 0x0f
        color = colors[textures[texture_index]]
        # A small deterministic brightness shift retains tile variation without a grid.
        shift = round(3*math.sin(wx/137)+2*math.sin(wy/181))
        color = tuple(max(0,min(255,c+shift)) for c in color)
        result.putpixel((px, py), color)
result.save(WORK / 'foundation-minimap.png')

def encode_blp(image, target, decoded_target):
    image = image.convert('RGB').resize((256,256), Image.Resampling.LANCZOS)
    palette_image = image.quantize(colors=256)
    palette = palette_image.getpalette()[:768]
    palette += [0] * (768-len(palette))
    bgra = b''.join(bytes((palette[i+2], palette[i+1], palette[i], 255)) for i in range(0,768,3))
    offsets, sizes, mips = [], [], []
    offset = 156 + 1024
    for level in range(9):
        size = 256 >> level
        mip = image.resize((size,size), Image.Resampling.LANCZOS).quantize(
            palette=palette_image, dither=Image.Dither.NONE).tobytes()
        offsets.append(offset)
        sizes.append(len(mip))
        mips.append(mip)
        offset += len(mip)
    offsets += [0] * (16-len(offsets))
    sizes += [0] * (16-len(sizes))
    blp_header = b'BLP1' + struct.pack('<6I', 1, 0, 256, 256, 5, 1)
    blp_header += struct.pack('<16I', *offsets) + struct.pack('<16I', *sizes)
    assert len(blp_header) == 156
    blp = blp_header + bgra + b''.join(mips)
    target.write_bytes(blp)
    decoded = Image.open(target)
    decoded.load()
    assert decoded.size == (256,256)
    decoded.convert('RGB').save(decoded_target)
    return len(blp)

minimap_bytes = encode_blp(result, WORK / 'patched-war3mapMap_ingame.blp',
                           WORK / 'foundation-minimap-decoded.png')
preview = Image.open(ROOT / 'reference' / 'legacy' / 'arthas-jaina-preview.png')
preview_bytes = encode_blp(preview, WORK / 'patched-war3mapMap.blp',
                           WORK / 'browser-preview-decoded.png')
print(f'BLP1 minimap: {minimap_bytes} bytes; preview: {preview_bytes} bytes; Pillow decode passed')
