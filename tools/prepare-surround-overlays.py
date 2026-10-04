"""Convert the authored translucent unit-square overlays for Warcraft III."""
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "design" / "overlays"
OUTPUT = ROOT / "src" / "assets" / "overlay"
OUTPUT.mkdir(parents=True, exist_ok=True)

for name in ("UnitSquaresEnemy", "UnitSquaresPlayer"):
    image = Image.open(SOURCE / f"{name}.png").convert("RGBA")
    image = image.resize((128, 128), Image.Resampling.NEAREST)
    image.save(OUTPUT / f"{name}.dds", pixel_format="DXT5")
