"""Fit the existing authored artwork into briefing textures without card crops."""
from pathlib import Path
from PIL import Image

root=Path(__file__).resolve().parent.parent
for name,source in [('ReflexTraining','reflex-training-source.png'),('HotkeyTraining','hotkey-training-source.png')]:
    image=Image.open(root/'design/menu-art'/source).convert('RGBA')
    image.thumbnail((512,256),Image.Resampling.LANCZOS)
    canvas=Image.new('RGBA',(512,256),(0,0,0,0))
    canvas.alpha_composite(image,((512-image.width)//2,(256-image.height)//2))
    output=root/'src/assets/menu'/f'{name}Briefing.dds'
    canvas.save(output,pixel_format='DXT5')
    print(output.name)
