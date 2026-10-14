"""Prepare authored menu art for Warcraft III while preserving editable sources."""
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "design" / "menu-art"
OUTPUT = ROOT / "src" / "assets" / "menu"
OUTPUT.mkdir(parents=True, exist_ok=True)
CARD_SIZE = (512, 256)
ROOT_CARD_SIZE = (256, 128)
CATEGORY_CARD_SIZE = (416, 200)

CARDS = {
    "HeroesTutorial": ("heroes-tutorial-source.png", 1.0, 0.50, 0.50, "contain"),
    "GargoyleSurrounds": ("gargoyle-surrounds-source.png", 1.0, 0.50, 0.50, "gargoyle_card"),
    "CombatMicro": ("combat-micro-source.png", 1.0, 0.50, 0.50, "contain"),
    # Keep the original card treatment: a centered 2:1 crop at the authored
    # scale.  The briefing uses the full transparent composition separately.
    "BodyBlocking": ("body-blocking-source.png", 1.0, 0.50, 0.50, "crop"),
    "Surrounds": ("surrounds-source.png", 1.15, 0.50),
    "AoWCreeping": ("aow-creeping-source.png", 1.05, 0.47),
    "BatSplitter": ("bat-splitter-source.png", 1.05, 0.50),
    "GoldMineMicro": ("gold-mine-micro-source.png", 1.05, 0.50),
    "UnitComparison": ("unit-comparison-source.png", 1.02, 0.50),
    "DemoMode": ("demo-mode-source.png", 1.25, 0.28),
    # Preserve the complete construction scene; the transparent source is
    # already composed as a wide card and only needs fitting to the slot.
    "PowerBuilding": ("power-building-source.png", 1.0, 0.50, 0.50, "contain"),
    # Frame the stretching pose around the arms and shoulders; the legs and
    # most of the torso intentionally fall outside the narrow menu card.
    "ReflexTraining": ("reflex-training-source.png", 1.24, 0.30, 0.50, "crop"),
    "PeonMicro": ("peon-micro-source.png", 1.0, 0.50, 0.50, "contain"),
    "WispMicro": ("wisp-micro-source.png", 1.0, 0.50, 0.50, "contain"),
    # Keep the cameraman large and crop below the arms for the narrow card.
    "CameraControls": ("camera-controls-source.png", 1.20, 0.40, 0.36, "crop"),
    # The Unit Controls card receives a custom leg crop below, then contains
    # the complete remaining puppet composition in the button slot.
    "UnitControls": ("unit-controls-source.png", 1.0, 0.50, 0.50, "puppet"),
    # Retain the authored horizontal band from 1/8 to 4/8 of the image:
    # remove one eighth from the top and four eighths from the bottom.
    "WindwalkPop": ("windwalk-pop-source.png", 1.0, 0.50, 0.50, "windwalk_band"),
    # Keep the zeppelin dominant while retaining the hanging Footmen.
    "ZeppelinMicro": ("zeppelin-micro-source.png", 1.0, 0.42, 0.50, "crop"),
    # Wide training cards supplied for the next content pass.
    "MissileDodging": ("missile-dodging-source.png", 1.0, 0.50, 0.50, "crop"),
    "HotkeySetup": ("hotkey-setup-source.png", 1.05, 0.59, 0.50, "hotkey_card"),
}

STAFFING_CARDS = {
    "StaffingHuman": "staffing-human-source.png",
    "StaffingNightElf": "staffing-nightelf-source.png",
}

ROOT_CARDS = {
    # Root cards retain the complete visible composition. Learn to Play uses
    # slightly more of its available slot than the other three root cards.
    "LearnToPlay": ("learn-to-play-source.png", "contain", 1.40, 0.50, 0.50),
    "AdvancedPlay": ("advanced-play-source.png", "contain", 1.17, 0.50, 0.50),
    "SkillTraining": ("skill-training-source.png", "contain", 1.17, 0.50, 0.50),
    "ToolsExtras": ("tools-extras-source.png", "contain", 1.17, 0.50, 0.50),
    "HotkeyTraining": ("hotkey-training-source.png", "crop", 1.00, 0.48, 0.64),
}


def card_crop(image, zoom, focal_y, focal_x=0.50, mode="crop"):
    """Crop around the composition without distorting it into the 2:1 card slot."""
    if mode == "contain":
        card = Image.new("RGBA", CARD_SIZE, (0, 0, 0, 0))
        art = image.copy()
        art.thumbnail(card.size, Image.Resampling.LANCZOS)
        card.alpha_composite(art, ((card.width - art.width) // 2, (card.height - art.height) // 2))
        return card
    width = min(image.width, round(image.width / zoom))
    height = min(image.height, round(width / 2))
    width = min(width, height * 2)
    centre_x = round(image.width * focal_x)
    left = max(0, min(image.width - width, centre_x - width // 2))
    centre_y = round(image.height * focal_y)
    top = max(0, min(image.height - height, centre_y - height // 2))
    return image.crop((left, top, left + width, top + height)).resize(
        CARD_SIZE, Image.Resampling.LANCZOS
    )


def contain_visible(image, size, fill, offset_x=0, offset_y=0):
    """Fit the complete non-transparent composition with controlled padding."""
    alpha_box = image.getchannel("A").getbbox()
    visible = image.crop(alpha_box) if alpha_box is not None else image.copy()
    target = (
        max(1, round(size[0] * fill)),
        max(1, round(size[1] * fill)),
    )
    visible.thumbnail(target, Image.Resampling.LANCZOS)
    card = Image.new("RGBA", size, (0, 0, 0, 0))
    card.alpha_composite(visible, (
        (size[0] - visible.width) // 2 + offset_x,
        (size[1] - visible.height) // 2 + offset_y,
    ))
    return card


generated = []
for output_name, values in CARDS.items():
    source_name, zoom, focal_y = values[:3]
    focal_x = values[3] if len(values) > 3 else 0.50
    mode = values[4] if len(values) > 4 else "crop"
    source = Image.open(SOURCE / source_name).convert("RGBA")
    if output_name != "WindwalkPop":
        assert source.getchannel("A").getextrema()[0] == 0, source_name + " must retain transparency"
    if mode == "gargoyle_card":
        # Match the narrow right-hand artwork frame without squeezing the
        # composition. Crop the sides while keeping the central target visible.
        output_size = (320, 256)
        crop_width = min(source.width, round(source.height * 1.25))
        left = (source.width - crop_width) // 2
        card = source.crop((left, 0, left + crop_width, source.height)).resize(
            output_size, Image.Resampling.LANCZOS)
    elif mode == "hotkey_card":
        # Keep the card at full button height, but narrow its source crop so
        # the flames leave a safety gap after the title. The authored texture
        # matches the runtime frame ratio and therefore is not squeezed.
        output_size = (460, 256)
        width = min(source.width, round(source.width / zoom))
        height = min(source.height,
                     round(width * output_size[1] / output_size[0]))
        centre_x = round(source.width * focal_x)
        left = max(0, min(source.width - width, centre_x - width // 2))
        centre_y = round(source.height * focal_y)
        top = max(0, min(source.height - height, centre_y - height // 2))
        card = source.crop((left, top, left + width, top + height)).resize(
            output_size, Image.Resampling.LANCZOS)
    elif mode == "puppet":
        # Remove only the Grunt's legs, preserving the puppeteer's hand,
        # strings, axe, torso and both arms before fitting the whole scene.
        leg_crop = source.crop((0, 0, source.width, round(source.height * 0.75)))
        card = contain_visible(leg_crop, CARD_SIZE, 0.98,
                               offset_x=round(CARD_SIZE[0] * 0.06))
    elif mode == "windwalk_band":
        # Keep the requested 3/8-high authored band. Fill the button height
        # without distorting it. Preserve the left edge and remove excess
        # width only from the right when reaching the full button's ratio.
        band = source.crop((
            0, round(source.height * 1 / 8),
            source.width, round(source.height * 4 / 8),
        ))
        # The runtime card moves the composition 0.009 to the right and clips
        # it at the button's right edge. Author only that visible portion so
        # no frame content can spill over the border.
        windwalk_card_size = (444, 140)
        crop_width = round(
            band.height * windwalk_card_size[0] / windwalk_card_size[1])
        card = band.crop((0, 0, min(band.width, crop_width),
            band.height)).resize(windwalk_card_size, Image.Resampling.LANCZOS)
    else:
        card = card_crop(source, zoom, focal_y, focal_x, mode)
    card_path = OUTPUT / f"{output_name}.dds"
    card.save(card_path, pixel_format="DXT5")
    generated.append((card_path, card.size))

    # White with the source artwork's alpha, reduced to a light hover wash.
    alpha = card.getchannel("A").point(lambda value: round(value * 0.25))
    hover = Image.new("RGBA", card.size, (255, 255, 255, 0))
    hover.putalpha(alpha)
    hover_path = OUTPUT / f"{output_name}Hover.dds"
    hover.save(hover_path, pixel_format="DXT5")
    generated.append((hover_path, hover.size))

# The Staffing Units sources are square command-button icons. Keep their
# aspect ratio and place them on the right half of the wide catalogue card,
# matching the treatment used by the other race-specific entries.
for output_name, source_name in STAFFING_CARDS.items():
    source = Image.open(SOURCE / source_name).convert("RGBA")
    card = Image.new("RGBA", CARD_SIZE, (0, 0, 0, 0))
    art = source.copy()
    art.thumbnail((220, 220), Image.Resampling.LANCZOS)
    card.alpha_composite(art, (CARD_SIZE[0] - art.width - 14,
                               (CARD_SIZE[1] - art.height) // 2))
    card_path = OUTPUT / f"{output_name}.dds"
    card.save(card_path, pixel_format="DXT5")
    generated.append((card_path, card.size))

# Root catalogue and Hotkey Trainer artwork is displayed in comparatively
# small button slots. A 256x128 DXT5 texture preserves the visible detail while
# avoiding the map-size cost of the larger exercise-card source resolution.
for output_name, (source_name, mode, amount, focal_y, focal_x) in ROOT_CARDS.items():
    source = Image.open(SOURCE / source_name).convert("RGBA")
    output_size = ROOT_CARD_SIZE if output_name == "HotkeyTraining" else CATEGORY_CARD_SIZE
    if mode == "contain":
        # Enlarge the four top-level compositions inside the fixed button-sized
        # texture. The wide canvas preserves their sides; excess height is
        # clipped evenly at the top and bottom.
        fill = amount if output_name == "HotkeyTraining" else 1.22
        card = contain_visible(source, output_size, fill)
    else:
        card = card_crop(source, amount, focal_y, focal_x).resize(
            output_size, Image.Resampling.LANCZOS
        )
    card_path = OUTPUT / f"{output_name}.dds"
    card.save(card_path, pixel_format="DXT5")
    generated.append((card_path, output_size))

# Bat Splitting's briefing uses the complete authored source at 50% dimensions.
# Pad the compressed texture to 4px blocks; never crop the composition.
bat_source = Image.open(SOURCE / "bat-splitter-source.png").convert("RGBA")
bat_half = bat_source.resize((round(bat_source.width * 0.5), round(bat_source.height * 0.5)), Image.Resampling.LANCZOS)
bat_size = tuple((value + 3) // 4 * 4 for value in bat_half.size)
bat_briefing = Image.new("RGBA", bat_size, (0, 0, 0, 0))
bat_briefing.alpha_composite(bat_half, (0, 0))
bat_path = OUTPUT / "BatSplitterBriefing.dds"
bat_briefing.save(bat_path, pixel_format="DXT5")
generated.append((bat_path, bat_size))

# Briefings preserve the whole transparent composition.  Cards intentionally
# use their tighter 2:1 crop, so the two UI contexts can be art-directed
# independently.
gargoyle_source = Image.open(SOURCE / "gargoyle-surrounds-source.png").convert("RGBA")
gargoyle_briefing = contain_visible(gargoyle_source, (512, 256), 1.0)
gargoyle_path = OUTPUT / "GargoyleSurroundsBriefing.dds"
gargoyle_briefing.save(gargoyle_path, pixel_format="DXT5")
generated.append((gargoyle_path, (512, 256)))
briefing_source = Image.open(SOURCE / "body-blocking-source.png").convert("RGBA")
briefing = Image.new("RGBA", (512, 256), (0, 0, 0, 0))
briefing_art = briefing_source.copy()
briefing_art.thumbnail(briefing.size, Image.Resampling.LANCZOS)
briefing.alpha_composite(briefing_art, (
    (briefing.width - briefing_art.width) // 2,
    (briefing.height - briefing_art.height) // 2,
))
briefing_path = OUTPUT / "BodyBlockingBriefing.dds"
briefing.save(briefing_path, pixel_format="DXT5")
generated.append((briefing_path, (512, 256)))

mining_briefing_source = Image.open(
    SOURCE / "gold-mine-micro-source.png"
).convert("RGBA")
mining_briefing = Image.new("RGBA", (512, 256), (0, 0, 0, 0))
mining_briefing_art = mining_briefing_source.copy()
mining_briefing_art.thumbnail(mining_briefing.size, Image.Resampling.LANCZOS)
mining_briefing.alpha_composite(mining_briefing_art, (
    (mining_briefing.width - mining_briefing_art.width) // 2,
    (mining_briefing.height - mining_briefing_art.height) // 2,
))
mining_briefing_path = OUTPUT / "GoldMineMicroBriefing.dds"
mining_briefing.save(mining_briefing_path, pixel_format="DXT5")
generated.append((mining_briefing_path, (512, 256)))

surrounds_briefing_source = Image.open(
    SOURCE / "surrounds-source.png"
).convert("RGBA")
surrounds_briefing = Image.new("RGBA", (512, 256), (0, 0, 0, 0))
surrounds_briefing_art = surrounds_briefing_source.copy()
surrounds_briefing_art.thumbnail(surrounds_briefing.size,
                                 Image.Resampling.LANCZOS)
surrounds_briefing.alpha_composite(surrounds_briefing_art, (
    (surrounds_briefing.width - surrounds_briefing_art.width) // 2,
    (surrounds_briefing.height - surrounds_briefing_art.height) // 2,
))
surrounds_briefing_path = OUTPUT / "SurroundsBriefing.dds"
surrounds_briefing.save(surrounds_briefing_path, pixel_format="DXT5")
generated.append((surrounds_briefing_path, (512, 256)))

windwalk_briefing_source = Image.open(
    SOURCE / "windwalk-pop-source.png"
).convert("RGBA")
windwalk_briefing = Image.new("RGBA", (512, 256), (0, 0, 0, 0))
windwalk_briefing_art = windwalk_briefing_source.copy()
windwalk_briefing_art.thumbnail(windwalk_briefing.size, Image.Resampling.LANCZOS)
windwalk_briefing.alpha_composite(windwalk_briefing_art, (
    (windwalk_briefing.width - windwalk_briefing_art.width) // 2,
    (windwalk_briefing.height - windwalk_briefing_art.height) // 2,
))
windwalk_briefing_path = OUTPUT / "WindwalkPopBriefing.dds"
windwalk_briefing.save(windwalk_briefing_path, pixel_format="DXT5")
generated.append((windwalk_briefing_path, (512, 256)))

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

# A solid rule shared by content and footer dividers. A thin frame sampling the
# tooltip-border texture can land on either its gold edge or dark interior.
menu_divider = Image.new("RGBA", (64, 4), (239, 174, 33, 255))
menu_divider_path = OUTPUT / "MenuDivider.dds"
menu_divider.save(menu_divider_path, pixel_format="DXT5")
generated.append((menu_divider_path, (64, 4)))

# Rotate the supplied right-facing pointer clockwise so it points down. The
# complete visible arrow is retained with a small transparent safety margin.
arrow_source = Image.open(
    SOURCE / "tutorial-arrow-right-source.png"
).convert("RGBA")
arrow_down = arrow_source.rotate(-90, expand=True, resample=Image.Resampling.BICUBIC)
tutorial_arrow = contain_visible(arrow_down, (128, 128), 0.92)
tutorial_arrow_path = OUTPUT / "TutorialArrowDown.dds"
tutorial_arrow.save(tutorial_arrow_path, pixel_format="DXT5")
generated.append((tutorial_arrow_path, (128, 128)))
welcome_arrow_path = OUTPUT / "TutorialArrowUp.dds"
tutorial_arrow.transpose(Image.Transpose.ROTATE_180).save(welcome_arrow_path, pixel_format="DXT5")
generated.append((welcome_arrow_path, (128, 128)))

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
    assert expected_size[0] % 4 == 0 and expected_size[1] % 4 == 0, \
        f"{path.name} dimensions must align to DXT5's 4x4 blocks"
    decoded = Image.open(path).convert("RGBA")
    assert decoded.size == expected_size
    assert decoded.getchannel("A").getextrema()[1] > 0

print(f"Prepared {len(generated)} menu DDS textures; DXT5 decode passed")
