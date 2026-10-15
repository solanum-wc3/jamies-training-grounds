"""Package supplied armor icons and draw Target Dummies' gold +/- icons."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageOps

output = Path(__file__).resolve().parent.parent / 'src/assets/menu'
source = output.parents[2] / 'design/menu-art/dummy-armor'
for name in ['Unarmed', 'Light', 'Medium', 'Heavy', 'Building', 'Hero']:
    # Preserve the user's complete square artwork; only normalize texture size.
    image = ImageOps.contain(Image.open(source / (name + '.png')).convert('RGBA'),
                             (128, 128), Image.Resampling.LANCZOS)
    texture = Image.new('RGBA', (128, 128), (0, 0, 0, 255))
    texture.alpha_composite(image, ((128-image.width)//2, (128-image.height)//2))
    texture.save(output / ('Armor' + name + '.dds'), pixel_format='DXT5')
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
