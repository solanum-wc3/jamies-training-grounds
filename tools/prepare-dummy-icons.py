"""Draw the simple gold +/- command icons used by Target Dummies."""
from pathlib import Path
from PIL import Image, ImageDraw

output = Path(__file__).resolve().parent.parent / 'src/assets/menu'
for name, plus in [('ArmorPlus', True), ('ArmorMinus', False)]:
    image = Image.new('RGBA', (128, 128), (22, 25, 29, 255))
    draw = ImageDraw.Draw(image)
    draw.rectangle((2, 2, 125, 125), outline=(140, 137, 122), width=5)
    draw.rectangle((9, 9, 118, 118), outline=(62, 59, 47), width=3)
    draw.rectangle((29, 58, 102, 73), fill=(0, 0, 0))
    if plus:
        draw.rectangle((58, 29, 73, 102), fill=(0, 0, 0))
    draw.rectangle((26, 55, 99, 70), fill=(255, 205, 60))
    if plus:
        draw.rectangle((55, 26, 70, 99), fill=(255, 205, 60))
    image.save(output / (name + '.dds'), pixel_format='DXT5')
