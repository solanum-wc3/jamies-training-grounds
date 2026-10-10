"""Regenerate the Economy placement module and contained Economy card."""
import json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
layout = json.loads((ROOT / "design/tutorials/economy-layout.json").read_text(encoding="utf-8"))
fields = ("id", "rawcode", "faction", "x", "y", "facing", "appearance")
rows = ["-- Generated from design/tutorials/economy-layout.json.",
        "JTG.EconomyLayout = {"]
for placement in layout["placements"]:
    rows.append("    {" + ", ".join(key + "=" + json.dumps(placement[key])
                                    for key in fields) +
                (", gathering=" + json.dumps(placement["gathering"]) if "gathering" in placement else "") + "},")
rows.append("}")
(ROOT / "src/generated/economy-layout.lua").write_text("\n".join(rows) + "\n", encoding="utf-8")

image = Image.open(ROOT / "design/menu-art/economy-and-workers-source.png").convert("RGBA")
image = image.crop(image.getbbox())
image.thumbnail((256, 256), Image.Resampling.LANCZOS)
canvas = Image.new("RGBA", (256, 256))
canvas.alpha_composite(image, (256 - image.width, (256 - image.height) // 2))
canvas.save(ROOT / "src/assets/menu/EconomyAndWorkers.dds", pixel_format="DXT5")
