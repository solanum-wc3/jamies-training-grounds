"""Prepare the authored map-selection picture; leave the terrain minimap intact.

Uses the accepted foundation's paletted BLP1 recipe, with all nine mip levels.
Normal builds consume the committed assets and do not require Pillow.
"""
from pathlib import Path
import struct
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'src/assets/preview'
OUT.mkdir(parents=True, exist_ok=True)
image = Image.open(ROOT / 'design/map-preview/map-selection.png').convert('RGB')
assert image.width == image.height, 'Map preview must be square; do not crop authored artwork silently'
image = image.resize((256, 256), Image.Resampling.LANCZOS)
palette_image = image.quantize(colors=256)
palette = palette_image.getpalette()[:768]
palette += [0] * (768 - len(palette))
bgra = b''.join(bytes((palette[i+2], palette[i+1], palette[i], 255)) for i in range(0, 768, 3))
offsets, sizes, mips = [], [], []
offset = 156 + 1024
for level in range(9):
    size = 256 >> level
    mip = image.resize((size, size), Image.Resampling.LANCZOS).quantize(
        palette=palette_image, dither=Image.Dither.NONE).tobytes()
    offsets.append(offset); sizes.append(len(mip)); mips.append(mip); offset += len(mip)
header = b'BLP1' + struct.pack('<6I', 1, 0, 256, 256, 5, 1)
header += struct.pack('<16I', *(offsets + [0] * 7)) + struct.pack('<16I', *(sizes + [0] * 7))
assert len(header) == 156
blp = OUT / 'war3mapMap.blp'
blp.write_bytes(header + bgra + b''.join(mips))
image.convert('RGBA').save(OUT / 'war3mapPreview.tga')
decoded = Image.open(blp)
decoded.load()
assert decoded.size == (256, 256)
for level in range(9):
    assert sizes[level] == (256 >> level) ** 2
    assert offsets[level] + sizes[level] <= blp.stat().st_size
with Image.open(OUT / 'war3mapPreview.tga') as tga:
    assert tga.size == (256, 256) and tga.convert('RGB').tobytes() == image.tobytes()
work = ROOT / 'work/map-preview-validation'
work.mkdir(parents=True, exist_ok=True)
decoded.convert('RGB').save(work / 'preview-decoded.png')
print('Passed: authored square preview, 256px BLP1 with nine mips, TGA roundtrip; terrain minimap untouched.')
