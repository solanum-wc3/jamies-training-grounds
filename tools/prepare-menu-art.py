"""Prepare authored menu art for Warcraft III while preserving editable sources."""
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "design" / "menu-art"
OUTPUT = ROOT / "src" / "assets" / "menu"
OUTPUT.mkdir(parents=True, exist_ok=True)

CARDS = {
    "Surrounds": ("surrounds-source.png", 1.15, 0.50),
    "AoWCreeping": ("aow-creeping-source.png", 1.05, 0.47),
    "BatSplitter": ("bat-splitter-source.png", 1.05, 0.50),
    "GoldMineMicro": ("gold-mine-micro-source.png", 1.05, 0.50),
    "UnitComparison": ("unit-comparison-source.png", 1.02, 0.50),
    "DemoMode": ("demo-mode-source.png", 1.25, 0.28),
}


def card_crop(image, zoom, focal_y):
    """Crop around the composition without distorting it into the 2:1 card slot."""
    width = min(image.width, round(image.width / zoom))
    height = min(image.height, round(width / 2))
    width = min(width, height * 2)
    left = max(0, min(image.width - width, (image.width - width) // 2))
    centre_y = round(image.height * focal_y)
    top = max(0, min(image.height - height, centre_y - height // 2))
    return image.crop((left, top, left + width, top + height)).resize(
        (1024, 512), Image.Resampling.LANCZOS
    )


generated = []
for output_name, (source_name, zoom, focal_y) in CARDS.items():
    source = Image.open(SOURCE / source_name).convert("RGBA")
    assert source.getchannel("A").getextrema()[0] == 0, source_name + " must retain transparency"
    card = card_crop(source, zoom, focal_y)
    card_path = OUTPUT / f"{output_name}.dds"
    card.save(card_path, pixel_format="DXT5")
    generated.append((card_path, (1024, 512)))

    # White with the source artwork's alpha, reduced to a light hover wash.
    alpha = card.getchannel("A").point(lambda value: round(value * 0.25))
    hover = Image.new("RGBA", card.size, (255, 255, 255, 0))
    hover.putalpha(alpha)
    hover_path = OUTPUT / f"{output_name}Hover.dds"
    hover.save(hover_path, pixel_format="DXT5")
    generated.append((hover_path, (1024, 512)))

# The supplied frame already has a transparent opening. Put a nearly opaque
# black field behind it, then resize the complete frame without rebuilding or
# stretching individual edges.
frame = Image.open(SOURCE / "menu-frame-source.png").convert("RGBA")
menu = Image.new("RGBA", frame.size, (0, 0, 0, 240))
menu.alpha_composite(frame)
menu = menu.resize((1024, 752), Image.Resampling.LANCZOS)
menu_path = OUTPUT / "MenuBackdrop.dds"
menu.save(menu_path, pixel_format="DXT5")
generated.append((menu_path, (1024, 752)))

# A lighter, more transparent field for delayed descriptive tooltips.
tooltip = Image.new("RGBA", (64, 64), (38, 38, 38, 145))
tooltip_path = OUTPUT / "TooltipGrey.dds"
tooltip.save(tooltip_path, pixel_format="DXT5")
generated.append((tooltip_path, (64, 64)))

# Native-inspired tooltip field: translucent blue-black, restrained warm-gold
# outline, and transparent rounded corners. It is authored near the runtime
# aspect ratio so stretching remains subtle without requiring an FDF nine-slice.
tooltip_native = Image.new("RGBA", (512, 128), (0, 0, 0, 0))
tooltip_draw = ImageDraw.Draw(tooltip_native)
tooltip_draw.rounded_rectangle(
    (2, 2, 509, 125), radius=10,
    fill=(8, 15, 22, 218), outline=(164, 126, 30, 220), width=2,
)
tooltip_native_path = OUTPUT / "TooltipNative.dds"
tooltip_native.save(tooltip_native_path, pixel_format="DXT5")
generated.append((tooltip_native_path, (512, 128)))

# Nine-slice runtime skin. Only straight sections stretch; the four rounded
# corners retain their shape at every tooltip height.
tooltip_nine = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
tooltip_nine_draw = ImageDraw.Draw(tooltip_nine)
tooltip_nine_draw.rounded_rectangle(
    (3, 3, 124, 124), radius=12,
    fill=(25, 39, 52, 135), outline=(232, 174, 34, 255), width=5,
)
slice_specs = {
    "TooltipTL": ((0, 0, 32, 32), (32, 32)),
    "TooltipTop": ((32, 0, 96, 32), (64, 32)),
    "TooltipTR": ((96, 0, 128, 32), (32, 32)),
    "TooltipLeft": ((0, 32, 32, 96), (32, 64)),
    "TooltipCenter": ((32, 32, 96, 96), (64, 64)),
    "TooltipRight": ((96, 32, 128, 96), (32, 64)),
    "TooltipBL": ((0, 96, 32, 128), (32, 32)),
    "TooltipBottom": ((32, 96, 96, 128), (64, 32)),
    "TooltipBR": ((96, 96, 128, 128), (32, 32)),
}
for output_name, (box, expected_size) in slice_specs.items():
    output_path = OUTPUT / f"{output_name}.dds"
    tooltip_nine.crop(box).save(output_path, pixel_format="DXT5")
    generated.append((output_path, expected_size))

# Subtle wash placed above the regular button texture but below card content.
button_hover = Image.new("RGBA", (64, 64), (255, 255, 255, 24))
button_hover_path = OUTPUT / "ButtonHover.dds"
button_hover.save(button_hover_path, pixel_format="DXT5")
generated.append((button_hover_path, (64, 64)))

for path, expected_size in generated:
    decoded = Image.open(path).convert("RGBA")
    assert decoded.size == expected_size
    assert decoded.getchannel("A").getextrema()[1] > 0

print(f"Prepared {len(generated)} menu DDS textures; DXT5 decode passed")
