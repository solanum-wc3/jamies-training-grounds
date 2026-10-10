"""Build the shared in-game test catalogue and workbook inventory.

Weapon classifications come from locally extracted installed-game SYLK tables.
Spell grouping describes targeting, not an assumed dodge outcome.
"""
import json
from pathlib import Path
import runpy
import re
read_slk = runpy.run_path(str(Path(__file__).with_name("read-warcraft-slk.py")))["read_slk"]

ROOT = Path(__file__).resolve().parent.parent
weapons = read_slk(ROOT / "work/unitweapons.slk")
unit_abilities = read_slk(ROOT / "work/UnitAbilities.slk")
ability_data = read_slk(ROOT / "work/abilitydata.slk")
unit_data = read_slk(ROOT / "work/unitdata.slk")
balance = read_slk(ROOT / "work/unitbalance.slk")
unit_ui = read_slk(ROOT / "work/unitui.slk")
items = read_slk(ROOT / "work/itemdata.slk")
ability_ui = {}
unit_ui_values = {}
for path in (ROOT / "work").glob("*unitfunc.txt"):
    current = None
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        if re.fullmatch(r"\[.{4}\]", line.strip()): current = line.strip()[1:-1]
        elif current and "=" in line and not line.lstrip().startswith("//"):
            key, value = line.split("=", 1)
            unit_ui_values.setdefault(current, {})[key.strip().lower()] = value.strip()
icon_names = dict(re.findall(r'(\w{4})\s*=\s*"(BTN[^"\n]+)"',
                            (ROOT / "src/activities/surrounds.lua").read_text(encoding="utf-8")))
icon_names.update(dict(hmtm="BTNMortarTeam", ocat="BTNDemolisher", osp1="BTNSerpentWard", osp2="BTNSerpentWard", osp3="BTNSerpentWard", otrb="BTNOrcBurrow",
    owtw="BTNOrcTower", hgtw="BTNGuardTower", hatw="BTNArcaneTower", hctw="BTNCannonTower",
    hgyr="BTNFlyingMachine", hrtt="BTNSeigeEngine", hphx="BTNPhoenix",
    uzg1="BTNSpiritTower", uzg2="BTNFrostTower", unp1="BTNHallOfTheDead", unp2="BTNBlackCitadel",
    Edmm="BTNMetamorphosis", Ewar="BTNHeroWarden", edtm="BTNStormCrowForm",
    etrp="BTNAncientProtector", nlv1="BTNLavaSpawn", npn2="BTNStormBrewmaster", npn3="BTNEarthBrewmaster",
    nqb1="BTNQuillBeast", nqb2="BTNQuillBeast", nqb3="BTNQuillBeast", nqb4="BTNQuillBeast", nwe1="BTNSummonHawk", nwe2="BTNSummonHawk", nwe3="BTNSummonHawk", nzep="BTNGoblinZeppelin"))
for path in (ROOT / "work").glob("*abilityfunc.txt"):
    current = None
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        if re.fullmatch(r"\[.{4}\]", line.strip()):
            current = line.strip()[1:-1]
        elif current and "=" in line and not line.lstrip().startswith("//"):
            key, value = line.split("=", 1)
            ability_ui.setdefault(current, {})[key.strip().lower()] = value.strip()

danger = []
dodgers = []


def attack(race, raw, name, **extra):
    row = weapons[raw]
    types = [row.get("weapTp1", ""), row.get("weapTp2", "")]
    selected = types[extra.get("weapon", 0)]
    range_value = row.get(f"rangeN{extra.get('weapon', 0) + 1}", "450")
    attack_range = float(range_value) if range_value not in ("", "-", "_") else 450
    category = "Artillery" if selected.startswith("artillery") else "Ranged attacks"
    entry = dict(id=f"attack.{raw}.{len(danger)}", race=race, unit=raw,
                 name=name, category=category, kind="attack", weaponTypes=" / ".join(types),
                 targetTypes=" / ".join([row.get("targs1", ""), row.get("targs2", "")]),
                 distance=max(180, min(650, attack_range * 0.75)))
    entry.update(extra)
    danger.append(entry)


def spell(race, unit, name, ability, order, kind, category, distance=450, **extra):
    assert ability in ability_data, ability
    entry = dict(id=f"spell.{ability}", race=race, unit=unit, name=name,
                 category=category, kind=kind, ability=ability, order=order,
                 distance=distance, weaponTypes="Spell", targetTypes="Native spell targets")
    entry.update(extra)
    danger.append(entry)


attacks = {
    "orc": [("Ofar", "Far Seer"), ("Oshd", "Shadow Hunter"), ("ohun", "Troll Headhunter"),
            ("otbk", "Troll Berserker"), ("otbr", "Troll Batrider"), ("owyv", "Wind Rider"),
            ("okod", "Kodo Beast"), ("oshm", "Shaman"), ("odoc", "Witch Doctor"),
            ("ospw", "Spirit Walker"), ("ocat", "Demolisher"), ("otrb", "Orc Burrow"),
            ("owtw", "Watch Tower"), ("osp1", "Serpent Ward 1"), ("osp2", "Serpent Ward 2"), ("osp3", "Serpent Ward 3")],
    "human": [("hrif", "Rifleman"), ("hspt", "Spell Breaker"), ("hmpr", "Priest"), ("hsor", "Sorceress"),
              ("hmtm", "Mortar Team"), ("hgry", "Gryphon Rider"), ("hwat", "Water Elemental Level 1"), ("hwt2", "Water Elemental Level 2"), ("hwt3", "Water Elemental Level 3"),
              ("hdhw", "Dragonhawk Rider"), ("hphx", "Phoenix"), ("Hamg", "Archmage"),
              ("Hblm", "Blood Mage"), ("hgtw", "Guard Tower"), ("hatw", "Arcane Tower"),
              ("hctw", "Cannon Tower"), ("hgyr", "Flying Machine ground attack"),
              ("hrtt", "Siege Engine Barrage")],
    "undead": [("ugar", "Gargoyle"), ("ubsp", "Destroyer"), ("ucry", "Crypt Fiend"),
               ("unec", "Necromancer"), ("uban", "Banshee"), ("ufro", "Frost Wyrm"),
               ("uskm", "Skeleton Mage"), ("umtw", "Meat Wagon"), ("uzg1", "Spirit Tower"),
               ("uzg2", "Nerubian Tower"), ("unp2", "Black Citadel"), ("unp1", "Halls of the Dead"),
               ("Ulic", "Lich"), ("uobs", "Obsidian Statue")],
    "nightelf": [("Ekee", "Keeper of the Grove"), ("Emoo", "Priestess of the Moon"),
                 ("Edmm", "Demon Hunter demon form"), ("earc", "Archer"), ("esen", "Huntress"),
                 ("ebal", "Glaive Thrower"), ("edry", "Dryad"), ("efdr", "Faerie Dragon"),
                 ("echm", "Chimaera"), ("edot", "Druid of the Talon caster form"),
                 ("edtm", "Druid of the Talon crow form"), ("ehpr", "Hippogryph Rider"),
                 ("etrp", "Ancient Protector"), ("espv", "Avatar of Vengeance"),
                 ("even", "Spirit of Vengeance")],
    "neutral": [("Nfir", "Firelord"), ("nlv1", "Lava Spawn 1"), ("nlv2", "Lava Spawn 2"), ("nlv3", "Lava Spawn 3"), ("Nbrn", "Dark Ranger"),
                ("Nngs", "Naga Sea Witch"), ("npn2", "Storm Spirit"),
                ("nqb1", "Beastmaster Quillbeast 1"), ("nqb2", "Beastmaster Quillbeast 2"), ("nqb3", "Beastmaster Quillbeast 3"), ("nqb4", "Beastmaster Quillbeast 4"),
                ("nwe1", "Beastmaster Hawk 1"), ("nwe2", "Beastmaster Hawk 2"), ("nwe3", "Beastmaster Hawk 3")],
}
for race, units in attacks.items():
    for raw, name in units:
        kwargs = {}
        if raw == "hgyr": kwargs.update(research=["Rhgb"], weapon=1)
        if raw == "echm": kwargs.update(weapon=1, note="Use the regular ground attack, not Corrosive Breath against buildings.")
        if raw == "etrp": kwargs.update(weapon=1, note="Use the ranged attack, not the uprooted melee attack.")
        if raw == "ugar": kwargs.update(weapon=1, note="Ranged weapon targets ground units; the air weapon is melee.")
        if raw == "hrtt": kwargs.update(research=["Rhrt"], weapon=1,
                                         note="Barrage requires an air target; ground weapon is instant.")
        if raw == "otrb": kwargs.update(support="opeo", note="Burrow is staffed by a Peon.")
        if raw == "hgry": kwargs.update(research=["Rhsb"], note="Ground line attack and air missile differ.")
        attack(race, raw, name, **kwargs)

spell("orc", "okod", "Kodo Beast: Devour", "Adev", "devour", "target", "Direct target effects", 150)
spell("orc", "orai", "Raider: Ensnare", "Aens", "ensnare", "target", "Homing missiles", research=["Roen"])
spell("orc", "Otch", "Tauren Chieftain: Shockwave", "AOsh", "shockwave", "point", "Area spells")
spell("orc", "Otch", "Tauren Chieftain: War Stomp", "AOws", "stomp", "immediate", "Area spells", 120)
spell("human", "Hmkg", "Mountain King: Thunder Clap", "AHtc", "thunderclap", "immediate", "Area spells", 120)
spell("human", "Hmkg", "Mountain King: Storm Bolt", "AHtb", "thunderbolt", "target", "Homing missiles")
spell("human", "Hamg", "Archmage: Blizzard", "AHbz", "blizzard", "point", "Area spells")
spell("undead", "Ucrl", "Crypt Lord: Impale", "AUim", "impale", "point", "Area spells")
spell("undead", "Udre", "Dread Lord: Carrion Swarm", "AUcs", "carrionswarm", "point", "Area spells")
spell("undead", "Udea", "Death Knight: Death Coil", "AUdc", "deathcoil", "target", "Homing missiles",
      note="Enemy undead targets are invalid for Death Coil.")
spell("undead", "ucry", "Crypt Fiend: Web", "Aweb", "web", "target", "Homing missiles", research=["Ruwb"],
      note="Requires an air target.")
spell("nightelf", "Emoo", "Priestess of the Moon: Searing Arrows", "AHfa", "flamingarrowstarg", "target", "Ranged attacks")
spell("nightelf", "Ewar", "Warden: Fan of Knives", "AEfk", "fanofknives", "immediate", "Area spells", 120)
spell("nightelf", "Ewar", "Warden: Shadow Strike", "AEsh", "shadowstrike", "target", "Homing missiles")
spell("neutral", "Nngs", "Naga Sea Witch: Frost Arrows", "ANfa", "coldarrowstarg", "target", "Ranged attacks")
spell("neutral", "Npbm", "Pandaren Brewmaster: Breath of Fire", "ANbf", "breathoffire", "point", "Area spells")
spell("neutral", "Npbm", "Pandaren Brewmaster: Drunken Haze", "ANdh", "drunkenhaze", "target", "Direct target effects")
spell("neutral", "Nplh", "Pit Lord: Rain of Fire", "ANrf", "rainoffire", "point", "Area spells")
spell("neutral", "Ntin", "Tinker: Cluster Rockets", "ANcs", "clusterrockets", "point", "Area spells")
spell("neutral", "Nalc", "Alchemist: Acid Bomb", "ANab", "acidbomb", "target", "Homing missiles")
spell("neutral", "Nbrn", "Dark Ranger: Black Arrow", "ANba", "blackarrow", "target", "Ranged attacks")
spell("neutral", "Nfir", "Firelord: Incinerate", "ANia", "incineratearrow", "target", "Ranged attacks")
spell("neutral", "npn2", "Storm Spirit: Cyclone", "ACcy", "cyclone", "target", "Direct target effects")
spell("orc", "Ofar", "Far Seer: Chain Lightning", "AOcl", "chainlightning", "target", "Area spells")
spell("orc", "otbr", "Batrider: Unstable Concoction", "Auco", "unstableconcoction", "target", "Area spells", note="Requires an air target.")
spell("undead", "Ucrl", "Crypt Lord: Impale (unit target)", "AUim", "impale", "target", "Direct target effects")


def dodge(race, unit, name, category, abilities=(), **extra):
    entry = dict(id=f"dodge.{len(dodgers)+1:02}", race=race, unit=unit, name=name,
                 category=category, abilities=list(abilities))
    entry.update(extra)
    for ability in abilities:
        assert ability in ability_data, ability
    dodgers.append(entry)


dodge("orc", "Obla", "Blademaster: Wind Walk", "Invisibility", ["AOwk"])
dodge("orc", "Obla", "Blademaster: Mirror Image", "Replacement / removal", ["AOmi"])
dodge("orc", "osw1", "Spirit Wolf: re-summon", "Replacement / removal", support="Ofar", supportAbilities=["AOsf"], summon=True)
dodge("orc", "opeo", "Peon: enter Orc Burrow", "Loading / building", support="otrb")
dodge("orc", "opeo", "Peon: construct a building", "Loading / building", building=True)
dodge("orc", "Oshd", "Shadow Hunter: Big Bad Voodoo", "Invulnerability", ["AOvd"],
      support="ohun", note="Voodoo protects nearby allies, not the caster. Enemy targets the Headhunter.", targetSupport=True)
dodge("human", "Hmkg", "Mountain King: Avatar", "Transformation", ["AHav"])
dodge("human", "Hpal", "Paladin: Divine Shield", "Invulnerability", ["AHds"])
dodge("human", "hsor", "Sorceress: Invisibility", "Invisibility", ["Aivs"], research=["Rhst"], support="hfoo", targetSupport=True)
dodge("human", "hfoo", "Staff of Sanctuary", "Teleportation", support="Hpal", supportItem="ssan", home="htow")
dodge("human", "Hamg", "Archmage: Mass Teleport", "Teleportation", ["AHmt"], home="htow")
dodge("undead", "ugar", "Gargoyle: Stone Form", "Transformation", ["Astn"], research=["Rusf"])
dodge("undead", "ucry", "Crypt Fiend: Burrow", "Invisibility", ["Abur"], research=["Rubu"])
dodge("undead", "uobs", "Obsidian Statue: Destroyer Form", "Transformation", ["Aave"], research=["Rusp"], resources=True)
dodge("undead", "ucs2", "Carrion Beetle: Burrow", "Invisibility", ["Abu2"])
dodge("undead", "uban", "Banshee: Anti-Magic Shell", "Magic protection", ["Aams"], research=["Ruba"], support="ugho", supportOwner="neutral", targetSupport=True, supportOffsetY=50)
for unit, name in [("Emoo", "Priestess of the Moon")]:
    dodge("nightelf", unit, "Shadowmeld", "Invisibility", ["Ashm"], night=True, icon="ReplaceableTextures\\CommandButtons\\BTNAmbush.blp")
dodge("nightelf", "Ewar", "Warden: Blink", "Teleportation", ["AEbl"])
dodge("nightelf", "efdr", "Faerie Dragon: Phase Shift", "Invulnerability", ["Apsh"])
dodge("nightelf", "Edem", "Demon Hunter: Metamorphosis", "Transformation", ["AEme"])
dodge("nightelf", "edoc", "Druid of the Claw: Bear Form", "Transformation", ["Abrf"], research=["Redc"])
dodge("nightelf", "edot", "Druid of the Talon: Crow Form", "Transformation", ["Arav"], research=["Redt"])
dodge("nightelf", "earc", "Archer: mount Hippogryph", "Replacement / removal", support="ehip", research=["ehip"])
dodge("nightelf", "ehip", "Hippogryph: pick up Archer", "Replacement / removal", support="earc", research=["ehip"])
dodge("nightelf", "ehpr", "Hippogryph Rider: dismount", "Replacement / removal", ["Adec"])
dodge("nightelf", "ewsp", "Wisp: Detonate", "Replacement / removal", ["Adtn"])
dodge("nightelf", "ewsp", "Wisp: construct a building", "Loading / building", building=True, blight=False)
dodge("nightelf", "ewsp", "Wisp: enter Gold Mine", "Loading / building", mine=True)
dodge("nightelf", "hfoo", "Staff of Preservation", "Teleportation", support="Ekee", supportItem="spre", home="etol")
dodge("nightelf", "hfoo", "Anti-Magic Potion", "Magic protection", item="pams")
dodge("neutral", "Npal", "Forsaken Paladin: Righteous Fury", "Movement", ["ANcp"])
dodge("neutral", "Npbm", "Pandaren Brewmaster: Storm, Earth and Fire", "Replacement / removal", ["ANef"])
dodge("neutral", "Ntin", "Tinker: Robo-Goblin", "Transformation", ["ANrg"])
dodge("neutral", "hfoo", "Goblin Zeppelin: load unit", "Loading / building", support="nzep", icon="ReplaceableTextures\\CommandButtons\\BTNGoblinZeppelin.blp")
dodge("neutral", "Hpal", "Scroll of Town Portal", "Teleportation", item="stwp", home="htow")
dodge("neutral", "Hpal", "Cloak of Shadows", "Invisibility", item="clsd", night=True)
dodge("neutral", "Hpal", "Potion of Invisibility", "Invisibility", item="pinv")
dodge("neutral", "Hpal", "Potion of Invulnerability", "Invulnerability", item="pnvu")
dodge("undead", "uaco", "Acolyte", "Loading / building", hauntedMine=True)
dodge("neutral", "hfoo", "Move on the ground", "Movement", note="Baseline for spatial dodging.")

# One icon per unit, retaining all of its native dodge methods and facilities.
merged = []
by_unit = {}
for entry in dodgers:
    if entry.get("item") or entry.get("supportItem") or entry["name"] == "Move on the ground":
        merged.append(entry)
        continue
    key = (entry["race"], entry["unit"])
    previous = by_unit.get(key)
    if previous is None:
        by_unit[key] = entry
        merged.append(entry)
    else:
        previous["abilities"] = list(dict.fromkeys(previous["abilities"] + entry["abilities"]))
        previous["research"] = list(dict.fromkeys(previous.get("research", []) + entry.get("research", [])))
        for field in ("building", "mine", "hauntedMine"):
            if entry.get(field): previous[field] = True
        previous["name"] = {"Obla":"Blademaster", "opeo":"Peon: Build, Burrow", "ewsp":"Wisp: Build, Goldmine, Detonate", "Npal":"Forsaken Paladin"}.get(entry["unit"], previous["name"])
dodgers = [e for e in merged if e["unit"]!="uaco" and "AHmt" not in e["abilities"]]
danger = [e for e in danger if e.get("ability") not in ("Aweb", "ACcy")]

def numeric(value, default=0):
    try: return float(value)
    except (ValueError, TypeError): return default

def stats(unit, ability=None, weapon=0):
    row = weapons.get(unit, {})
    a = ability_data.get(ability, {})
    ui = ability_ui.get(ability, {})
    suffix = str(weapon + 1)
    cast_point = numeric(row.get("castpt")) if ability else numeric(row.get("dmgpt" + suffix))
    return dict(attackSpeedDependent=ability is None, castTime=cast_point, castPoint=cast_point, abilityCastTime=numeric(a.get("Cast1")),
        baseAttackCooldown=numeric(row.get("cool" + suffix)), spellTargets=a.get("targs1", ""),
        range=numeric(a.get("Rng1")) if ability else numeric(row.get("rangeN" + suffix)),
        minRange=numeric(row.get("minRange")) if not ability else 0,
        missileSpeed=numeric(ui.get("missilespeed")) if ability else numeric(unit_ui_values.get(unit, {}).get("missilespeed" + suffix, unit_ui_values.get(unit, {}).get("missilespeed"))),
        area=numeric(a.get("Area1")) if ability else numeric(row.get("Qarea" + suffix)),
        duration=numeric(a.get("Dur1")), buffs=[b for b in a.get("BuffID1", "").split(",") if len(b) == 4])

for entry in danger:
    entry.update(stats(entry["unit"], entry.get("ability"), entry.get("weapon", 0)))
    if entry.get("ability") in ("AHbz", "ANrf"):
        entry["waveInterval"] = numeric(ability_data[entry["ability"]].get("Cast1"))
    # These area spells have no explicit target mask in AbilityData.
    # Do not interpret an empty mask as being able to hit flying units.
    if entry.get("ability") in ("AHbz", "ANrf"):
        entry["spellTargets"] = "ground,structure"
    if entry["kind"] == "attack" and weapons[entry["unit"]].get("weapTp" + str(entry.get("weapon", 0) + 1)) == "instant":
        entry["missileSpeed"] = 0
    if entry["kind"] == "attack":
        entry["menuGroup"] = "Artillery" if entry["unit"] in ("hmtm", "ocat", "umtw", "ebal") else "Ranged"
        if entry["menuGroup"] == "Artillery": entry["groundAttack"] = True
    else:
        entry["menuGroup"] = {"Area spells": "Area", "Direct target effects": "Homing", "Homing missiles": "Homing", "Ranged attacks": "Homing"}[entry["category"]]
        if entry["ability"] == "Adev": entry["menuGroup"] = "Devour"
        if entry["ability"] == "ANdh": entry["menuGroup"] = "Homing"
        if entry["ability"] == "ANab": entry["menuGroup"] = "Area"
    orb_orders = {"AHfa": "flamingarrows", "ANfa": "coldarrows", "ANba": "blackarrowon", "ANia": "incineratearrowon"}
    if entry.get("ability") in orb_orders:
        entry["orbOrder"] = orb_orders[entry["ability"]]
        entry["castTime"] = numeric(weapons[entry["unit"]].get("dmgpt1"))
        entry["castPoint"] = entry["castTime"]
        entry["attackSpeedDependent"] = True
    if entry.get("ability") == "AUim": entry["instantProjectile"] = True
    if entry.get("ability") == "AOsh": entry["areaText"] = "125 units wide"
    if entry.get("ability") == "ANcs": entry["areaText"] = "200 units radius on lvl 1"
    if entry.get("ability") in ("ANbf", "AUcs"):
        row = ability_data[entry["ability"]]
        entry["waveDistance"] = numeric(row.get("DataC1"))
        entry["finalRadius"] = numeric(row.get("DataD1"))
        entry["areaText"] = ("Expanding cone; " + format(entry["area"],".3g") + " units initial width; "
            + format(numeric(row.get("DataD1")),".3g") + " units final radius")
    if entry.get("ability") == "AOsh":
        entry["waveDistance"] = numeric(ability_data["AOsh"].get("DataC1"))
    if entry.get("ability") == "AOcl": entry["areaText"] = format(entry["area"],".3g") + " units bounce range"
    if entry.get("ability") == "AUim" and entry["menuGroup"] == "Area":
        entry["waveDistance"] = numeric(ability_data["AUim"].get("DataA1"))
        entry["areaText"] = "Line-shaped"
    entry["distance"] = max(64, (entry["range"] or entry["area"] or 450) - 32)
    entry["resolveWindow"] = 2
    if entry.get("ability") in ("AHbz", "ANrf"):
        row = ability_data[entry["ability"]]
        entry["cooldown"] = numeric(row.get("Cool1"))
        entry["resolveWindow"] = numeric(row.get("DataA1")) * (numeric(row.get("Cast1")) + numeric(row.get("DataD1"))) + numeric(row.get("Dur1")) + 2
    if entry.get("ability") == "ANcs": entry["resolveWindow"] = 8
    if entry.get("ability") == "Auco":
        entry["area"] = numeric(ability_data["Auco"].get("DataC1"))
        entry["chargeSpeed"] = numeric(ability_data["Auco"].get("DataF1"))
    if entry.get("ability") == "AHmt": entry["channelTime"] = numeric(ability_data["AHmt"].get("DataB1"))
for entry in dodgers:
    if entry.get("item"):
        entry["unit"] = "Ntin"
        entry["removeAbilities"] = unit_abilities["Ntin"]["heroAbilList"].split(",")
    if entry.get("supportItem"):
        entry["support"] = "Ntin"
        entry["selectSupport"] = True
        entry["removeSupportAbilities"] = unit_abilities["Ntin"]["heroAbilList"].split(",")
    raw = next(iter(entry.get("abilities") or entry.get("supportAbilities") or []), None)
    if not raw and (entry.get("item") or entry.get("supportItem")):
        item_row = items[entry.get("item") or entry["supportItem"]]
        raw = next((x for x in item_row.get("abilList", "").split(",") if x in ability_data), None)
    entry.update(stats(entry.get("support") if entry.get("supportAbilities") else entry["unit"], raw))
    if raw == "AHmt": entry["channelTime"] = numeric(ability_data[raw].get("DataB1"))
    entry["statsKnown"] = raw is not None
    if entry["id"] == "dodge.23":
        # User-approved loading approximation, not a measured mounting delay.
        entry["activationNote"] = "Instant"
    if entry.get("item") or entry.get("supportItem") or raw == "AOwk":
        entry["castPoint"] = 0
    if raw in ("AHds", "AIvu", "AIvl", "Aams", "AIam"):
        entry["protectionDuration"] = numeric(ability_data[raw].get("Dur1"))
    # These fields are identified by the installed AbilityMetaData and editor
    # labels: Shm1 = Fade Duration, Owk1/Ivs1 = Transition Time.
    if raw in ("Ashm", "AIhm", "AOwk", "Aivs"):
        entry["fadeDuration"] = numeric(ability_data[raw].get("DataA1"))
    elif raw in ("AIv1", "AIv2"):
        entry["fadeUnknown"] = True  # No transition-time field is exposed.

# Keep observed casting and activation distinct. These portable aggregates
# are reviewed measurements; regenerating the catalogue needs no local export.
measurements = json.loads((ROOT / "design/dodge-activation-measurements.json").read_text())
for entry in danger + dodgers:
    raw = entry.get("ability") or next(iter(entry.get("abilities") or entry.get("supportAbilities") or []), None)
    if not raw and (entry.get("item") or entry.get("supportItem")):
        raw = next((x for x in items[entry.get("item") or entry["supportItem"]].get("abilList", "").split(",") if x in ability_data), None)
    item = entry.get("item") or entry.get("supportItem")
    raw = {"pams": "AIxs", "ssan": "ANsa", "spre": "ANpr"}.get(item, raw)
    if raw in measurements["castPoints"] and not entry.get("orbOrder"):
        entry["measuredCastPoint"] = measurements["castPoints"][raw]["seconds"]
    if entry in dodgers and raw in measurements["activation"]:
        entry["measuredActivation"] = measurements["activation"][raw]
        if raw in ("AOwk", "Ashm", "AIhm", "AIv1", "AIv2", "Aivs"):
            cast_delay = measurements["castPoints"].get(raw, {}).get("minimum", 0)
            entry["measuredFadeDuration"] = round(max(0, entry["measuredActivation"]["seconds"] - cast_delay), 3)
    if entry in dodgers and raw == "AItp":
        entry["activationNote"] = "Instant"
    if entry in dodgers and entry["id"] == "dodge.01":
        entry["activationNote"] = ("Wind Walk\nInstant\nFade duration: "
            + format(entry["measuredFadeDuration"], ".3g")
            + "s\n\nMirror Image\nCast Point: 0.3s\nHidden: 0.305s after command\nInvulnerable: 0.305s after command")
    if entry in dodgers and (entry["unit"] in ("earc", "ehip", "ehpr") or entry.get("support")=="nzep"):
        entry["activationNote"] = "Instant"
    if entry in dodgers and raw in ("AEme", "Abrf"):
        # Form completion does not establish the onset of projectile disjoining.
        entry["activationNote"] = "Instant"
    if entry in dodgers and raw in ("AOmi", "ANef"):
        seconds=measurements["activation"][raw]["seconds"]
        point=measurements["castPoints"][raw]["seconds"]
        entry["activationNote"] = ("Cast Point: " + format(point,".3g") + "s\nHidden: "
            + format(seconds,".3g") + "s after command\nInvulnerable: " + format(seconds,".3g") + "s after command")

# The artillery units also remain available as targeted ranged-attack cases.
for entry in list(danger):
    if entry["menuGroup"] == "Artillery":
        targeted = dict(entry, id=entry["id"] + ".targeted", menuGroup="Ranged", groundAttack=False,
            name=entry["name"] + ": targeted attack")
        danger.append(targeted)
seen = set()
for entry in danger:
    if entry["id"] in seen: entry["id"] += "." + entry["kind"]
    assert entry["id"] not in seen
    seen.add(entry["id"])

# Native classic icon definitions, including item artwork.
item_icons={}
current=None
for line in (ROOT / "work/itemfunc.txt").read_text(encoding="utf-8",errors="replace").splitlines():
    if re.fullmatch(r"\[.{4}\]",line.strip()): current=line.strip()[1:-1]
    elif current and line.lower().startswith("art="): item_icons[current]=line.split("=",1)[1].strip()
for entry in dodgers:
    item=entry.get("item") or entry.get("supportItem")
    if item and item in item_icons: entry["icon"]=item_icons[item]

# Verify every unit and item against the installed game; unknown rawcodes must
# be resolved before an alpha can be built.
for entry in danger + dodgers:
    for field in ("unit", "support", "home"):
        if field in entry:
            assert entry[field] in unit_abilities, (entry["name"], field, entry[field])
    for field in ("item", "supportItem"):
        if field in entry:
            assert entry[field] in items, (entry["name"], entry[field])
    icon = ("ReplaceableTextures\\CommandButtons\\" + icon_names[entry["unit"]] + ".blp"
            if entry["unit"] in icon_names else "")
    entry["icon"] = entry.get("icon") or (icon if icon not in ("", "_") else "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp")
    if "ability" in entry:
        entry["hero"] = entry["ability"] in unit_abilities[entry["unit"]].get("heroAbilList", "").split(",")
    abilities = ([entry["ability"]] if "ability" in entry else entry.get("abilities", []))
    tech = list(entry.get("research", []))
    for ability in abilities:
        ui = ability_ui.get(ability, {})
        for requirement in ui.get("requires", "").split(","):
            if len(requirement) == 4 and requirement not in tech:
                tech.append(requirement)
    if tech: entry["research"] = tech


def lua(value):
    if isinstance(value, str): return json.dumps(value, ensure_ascii=False)
    if isinstance(value, bool): return "true" if value else "false"
    if isinstance(value, (int, float)): return str(value)
    if isinstance(value, list): return "{" + ", ".join(lua(item) for item in value) + "}"
    return "{" + ", ".join(f"{key} = {lua(item)}" for key, item in value.items()) + "}"


traits = {}
tech = set()
for raw,row in balance.items():
    abilities = unit_abilities.get(raw, {})
    data = unit_data.get(raw, {})
    traits[raw] = dict(hero=bool(abilities.get("heroAbilList", "_").strip("_ -")),
        undead="undead" in row.get("type", "").split(",") or raw.startswith("u") or raw.startswith("U") or raw=="Npal",
        flying=data.get("movetp", "").lower()=="fly", level=numeric(row.get("level")),
        mechanical="mechanical" in row.get("type", "").lower().split(","),
        movementSpeed=numeric(row.get("spd")))
    tech.update(x for x in row.get("upgrades", "").split(",") if len(x)==4)
    # All abilities and their prerequisites can be enabled while preserving hero selection.
for entry in danger + dodgers:
    tech.update(entry.get("research", []))

(ROOT / "src/generated/melee-tech.lua").write_text("-- Generated melee technology catalogue; shared by tutorials and trainings.\nJTG = JTG or {}\nJTG.MeleeTech = " + lua(sorted(tech)) + "\n", encoding="utf-8")

out = ROOT / "src/generated/dodge-catalog.lua"
out.write_text("-- Generated from tools/prepare-dodge-catalog.py.\nJTG = JTG or {}\n"
               + "JTG.DodgeDangers = {\n" + ",\n".join("    " + lua(row) for row in danger) + "\n}\n"
               + "JTG.DodgeUnitTraits = " + lua(traits) + "\nJTG.DodgeTech = JTG.MeleeTech\n"
               + "JTG.DodgePawns = {\n" + ",\n".join("    " + lua(row) for row in dodgers) + "\n}\n", encoding="utf-8")
(ROOT / "design/dodge-catalog.json").write_text(json.dumps(dict(dangers=danger, dodgers=dodgers), indent=2), encoding="utf-8")
print(f"Verified and generated {len(danger)} dangers and {len(dodgers)} dodge cases")
