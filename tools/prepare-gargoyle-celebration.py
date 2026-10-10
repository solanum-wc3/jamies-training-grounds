"""Convert the five authored GIF frames into transparent Warcraft UI textures."""
import argparse
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
parser = argparse.ArgumentParser()
parser.add_argument("source", type=Path, nargs="?",
                    default=ROOT / "design" / "celebration")
args = parser.parse_args()
output = ROOT / "src" / "assets" / "celebration"
output.mkdir(parents=True, exist_ok=True)
for index in range(5):
    source = args.source / f"doge_frame_{index}_delay-0.1s.gif"
    image = Image.open(source).convert("RGBA")
    # Preserve the full frame and its transparency in a power-of-two texture.
    image = image.resize((256, 256), Image.Resampling.NEAREST)
    image.save(output / f"Doge{index}.dds", pixel_format="DXT5")
