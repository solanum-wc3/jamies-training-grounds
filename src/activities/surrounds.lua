-- Surround Training: trap a runner with practical, race-specific armies.
JTG = JTG or {}

local INTRO =
    "Sometimes the best thing to do in a fight, is to run away, since any " ..
    "unit that survives the battle can be healed and fight again.\n" ..
    "Units have to stand still for a moment to do an attack, so they are " ..
    "much less effective when having to chase an enemy.\n\n" ..
    "By blocking a unit on all four sides, you can box them in and stop " ..
    "their movement completely.\n" ..
    "This can allow you to freely finish off enemy units, especially " ..
    "important ones like heroes.\n\n" ..
    "In this exercise you can practice surrounding units, by using your " ..
    "own units and their abilities."

local GARGOYLE_INTRO =
    "Since Gargoyles are flying units, they do not obstruct the " ..
    "movement of ground units. Their {Button: Stone Form} changes this: " ..
    "once they land as statues, they occupy space like ordinary ground " ..
    "units.\n\n" ..
    "In this, you can practice surrounding units using Stone Form.\n\n" ..
    "Check the {Button: Quest Log} for precise instructions!"

local GARGOYLE_QUEST_TEXT =
    "Flying Gargoyles can overlap ground units because they have no ground " ..
    "obstruction. This changes immediately when they use {Button: Stone " ..
    "Form}.\n\n" ..
    "Use your hero or casters to stop or slow the target, move the Gargoyles " ..
    "into position around all four sides, and then turn them into statues. " ..
    "The target must be blocked in all four cardinal directions.\n\n" ..
    "Tip: If you have selected only Gargoyles and give them a {Term: Move} " ..
    "command on the ground, they will bunch up. If you then give them smaller " ..
    "{Term: Move} commands nearby, four of them will form a diamond formation, " ..
    "perfect for establishing a surround.\n\n" ..
    "Press the {Button: Squares} button to compare the flying and Stone Form " ..
    "states. A tiny box appears immediately once you activate Stone " ..
    "Form, and becomes larger once the Gargoyle hits the ground. The tiny one " ..
    "alone can be enough to box in a target, by blocking snapping points on " ..
    "the navigation grid."

JTG.SurroundHowToQuestText =
    "To surround an enemy, you have to block them in all four cardinal " ..
    "directions (right, left, up, down).\n" ..
    "This means the minimum amount of units you need for a successful " ..
    "surround, is four.\n" ..
    "The size of your units, and of the units you want to surround does not " ..
    "matter for this. Four Peasants can surround a Kodo! (You will need " ..
    "five though, in case one gets eaten!)\n\n" ..
    "One way to do the surround is to individually send one unit to each " ..
    "the four sides.\n" ..
    "This is simple, but it is slow, and very hard to do in the heat of " ..
    "battle.\n\n" ..
    "Another way is to select all of your units while they are already " ..
    "standing arranged around the enemy unit.\n" ..
    "Then you use the {Term: Move} command on the enemy, about four or five " ..
    "times in a row.\n" ..
    "This is quicker, but you have to hope for the best, since not all sides " ..
    "may be blocked off in the end.\n" ..
    "It might require you make some quick adjustments for one or two of your " ..
    "units.\n\n" ..
    "Lastly, you can purposefully arrange your units in a wide cross " ..
    "shape, meaning they are already arranged in something like the final " ..
    "position: one in every cardinal direction, and an empty space in " ..
    "the middle.\n" ..
    "Then you give them a {Term: Move} command that makes them run diagonally " ..
    "across the path of the enemy unit, so the enemy unit ends up in the " ..
    "middle of the formation without displacing anyone.\n" ..
    "Then you use the {Term: Move} command on the enemy, about four or five " ..
    "times in a row.\n" ..
    "This has a better chance of success, but you might still have to make " ..
    "a quick adjustment or two.\n\n" ..
    "No matter the method, this is a tricky and micro intensive skill.\n\n" ..
    "Note: You cannot use the {Term: Attack} command to do surrounds, even " ..
    "with melee units, as it often will not move the units close enough."

JTG.SurroundHowItWorksQuestText =
    "Surrounding exploits a fundamental aspect of Warcraft III's engine.\n\n" ..
    "Every unit blocks the movement of other units with a square-shaped " ..
    "area.\n" ..
    "Some are bigger and some are smaller, but they all have four equal " ..
    "sides.\n" ..
    "This square always faces the same direction and does not turn with " ..
    "the unit.\n\n" ..
    "A {Term: Move} command on another unit stops your units before these " ..
    "areas touch, but this obstruction box becomes important when the " ..
    "surrounded unit tries to escape through a gap.\n\n" ..
    "For this reason, the unit can move through smaller spaces when moving " ..
    "straight up and down or side to side, compared to moving diagonally.\n\n" ..
    "Press the {Button: Squares} button to display the areas that units " ..
    "obstruct. These areas snap to a grid of 32x32 in-game units, so they do " ..
    "not move seamlessly like the units do, and they may not always be where " ..
    "you think they are based on the model's position. You can also display " ..
    "a finer grid of 8x8 in-game units."

JTG.SurroundMixedSelectionsQuestText =
    "Be careful when controlling units of different types in the same " ..
    "selection!\n" ..
    "Even without {Term: Formation Movement}, the units can interfere with " ..
    "each other when it comes to movement behavior.\n" ..
    "This is probably because of differences in size and turn rate, and what " ..
    "seems to happen is that the smaller units start using the bigger units' " ..
    "values for pathfinding.\n\n" ..
    "For this reason, surrounds tend to work more consistently when using " ..
    "only units of one type in the same selection, or at least of similar " ..
    "size.\n\n" ..
    "You can try surrounding a unit with Peons and a single Kodo Beast, to " ..
    "see this effect."

local RACES = {
    {key = "human", label = "Human",
        artwork = "UI\\Glues\\Loading\\Backgrounds\\Campaigns\\HumanSymbol.dds"},
    {key = "orc", label = "Orc",
        artwork = "UI\\Glues\\Loading\\Backgrounds\\Campaigns\\OrcSymbol.dds"},
    {key = "undead", label = "Undead",
        artwork = "UI\\Glues\\Loading\\Backgrounds\\Campaigns\\UndeadSymbol.dds"},
    {key = "nightelf", label = "Night Elf",
        artwork = "UI\\Glues\\Loading\\Backgrounds\\Campaigns\\NightElfSymbol.dds"},
    {key = "neutral", label = "Neutral"},
}

local RACE_CHOICE_ICON_SIZE = 0.0396
local RACE_CHOICE_ICON_OFFSET_X = 0.051

-- Custom Surrounds is built on data columns so later selectors can reuse the
-- same briefing grid without encoding a separate frame for every unit.
local function CustomUnit(label, rawcode, enabled, hero, key)
    return {label = label, rawcode = rawcode, enabled = enabled ~= false,
        hero = hero == true, kind = "unit", key = key or rawcode}
end

local function CustomAbility(label, rawcode, enabled, ultimate)
    return {label = label, rawcode = rawcode, enabled = enabled ~= false,
        ultimate = ultimate == true, kind = "ability"}
end

local CUSTOM_RACE_COLUMNS = {
    human = {
        {CustomUnit("Peasant", "hpea"), CustomUnit("Militia", "hmil")},
        {CustomUnit("Footman", "hfoo"), CustomUnit("Rifleman", "hrif"),
            CustomUnit("Knight", "hkni")},
        {CustomUnit("Sorceress", "hsor"), CustomUnit("Priest", "hmpr"),
            CustomUnit("Spell Breaker", "hspt")},
        {CustomUnit("Flying Machine", "hgyr", false),
            CustomUnit("Mortar Team", "hmtt"),
            CustomUnit("Siege Engine", "hmtn")},
        {CustomUnit("Dragonhawk Rider", "hdhw", false),
            CustomUnit("Gryphon Rider", "hgry", false)},
        {CustomUnit("Archmage", "Hamg", true, true),
            CustomUnit("Mountain King", "Hmkg", true, true),
            CustomUnit("Paladin", "Hpal", true, true),
            CustomUnit("Blood Mage", "Hblm", true, true)},
        {CustomUnit("Water Elemental Level 1", "hwat"),
            CustomUnit("Water Elemental Level 2", "hwt2"),
            CustomUnit("Water Elemental Level 3", "hwt3"),
            CustomUnit("Phoenix", "hphx", false)},
    },
    orc = {
        {CustomUnit("Peon", "opeo")},
        {CustomUnit("Grunt", "ogru"), CustomUnit("Headhunter", "ohun"),
            CustomUnit("Berserker", "otbk"), CustomUnit("Demolisher", "odem")},
        {CustomUnit("Shaman", "oshm"), CustomUnit("Witch Doctor", "odoc")},
        {CustomUnit("Raider", "orai"), CustomUnit("Wind Rider", "owyv", false),
            CustomUnit("Kodo Beast", "okod"),
            CustomUnit("Troll Batrider", "otbr", false)},
        {CustomUnit("Spirit Walker", "ospw"), CustomUnit("Tauren", "otau")},
        {CustomUnit("Blademaster", "Obla", true, true),
            CustomUnit("Far Seer", "Ofar", true, true),
            CustomUnit("Tauren Chieftain", "Otch", true, true),
            CustomUnit("Shadow Hunter", "Oshd", true, true)},
        {CustomUnit("Spirit Wolf", "osw1"), CustomUnit("Dire Wolf", "osw2"),
            CustomUnit("Shadow Wolf", "osw3")},
        {CustomUnit("Serpent Ward 1", "o001", false),
            CustomUnit("Serpent Ward 2", "o002", false),
            CustomUnit("Serpent Ward 3", "o003", false)},
    },
    undead = {
        {CustomUnit("Acolyte", "uaco"), CustomUnit("Shade", "ushd", false)},
        {CustomUnit("Ghoul", "ugho"), CustomUnit("Crypt Fiend", "ucry"),
            CustomUnit("Gargoyle", "ugar", false)},
        {CustomUnit("Banshee", "uban"), CustomUnit("Necromancer", "unec")},
        {CustomUnit("Meat Wagon", "umtw"), CustomUnit("Abomination", "uabo"),
            CustomUnit("Obsidian Statue", "uobs"),
            CustomUnit("Destroyer", "ubsp", false)},
        {CustomUnit("Frost Wyrm", "ufro", false)},
        {CustomUnit("Death Knight", "Udea", true, true),
            CustomUnit("Dreadlord", "Udre", true, true),
            CustomUnit("Lich", "Ulic", true, true),
            CustomUnit("Crypt Lord", "Ucrl", true, true)},
        {CustomUnit("Skeleton", "uske"), CustomUnit("Skeleton Mage", "uskm"),
            CustomUnit("Infernal", "uin1")},
        {CustomUnit("Carrion Beetle Lvl 1", "ucs1"),
            CustomUnit("Carrion Beetle Lvl 2", "ucs2"),
            CustomUnit("Carrion Beetle Lvl 3", "ucs3")},
    },
    nightelf = {
        {CustomUnit("Wisp", "ewsp")},
        {CustomUnit("Archer", "earc"), CustomUnit("Huntress", "esen"),
            CustomUnit("Glaive Thrower", "ebal")},
        {CustomUnit("Dryad", "edry"),
            CustomUnit("Druid of the Claw (Night Elf Form)", "edoc"),
            CustomUnit("Druid of the Claw (Bear Form)", "edcm"),
            CustomUnit("Mountain Giant", "emtg")},
        {CustomUnit("Hippogryph", "ehip", false),
            CustomUnit("Hippogryph Rider", "ehpr", false),
            CustomUnit("Druid of the Talon (Night Elf Form)", "edot"),
            CustomUnit("Druid of the Talon (Stormcrow Form)", "etot", false),
            CustomUnit("Faerie Dragon", "efdr", false)},
        {CustomUnit("Chimaera", "echm", false)},
        {CustomUnit("Demon Hunter", "Edem", true, true),
            CustomUnit("Keeper of the Grove", "Ekee", true, true),
            CustomUnit("Priestess of the Moon", "Emoo", true, true),
            CustomUnit("Warden", "Ewdn", true, true)},
        {CustomUnit("Treant Level 1", "efon", true, false, "efon1"),
            CustomUnit("Treant Level 2", "efon", true, false, "efon2"),
            CustomUnit("Treant Level 3", "efon", true, false, "efon3")},
        {CustomUnit("Avatar of Vengeance", "espv"),
            CustomUnit("Spirit of Vengeance", "even")},
    },
    neutral = {
        {CustomUnit("Naga Sea Witch", "Nngs", true, true),
            CustomUnit("Dark Ranger", "Nbrn", true, true),
            CustomUnit("Pandaren Brewmaster", "Npbm", true, true),
            CustomUnit("Firelord", "Nfir", true, true)},
        {CustomUnit("Pit Lord", "Nplh", true, true),
            CustomUnit("Beastmaster", "Nbst", true, true),
            CustomUnit("Goblin Tinker", "Ntin", true, true),
            CustomUnit("Goblin Alchemist", "Nalc", true, true)},
        {CustomUnit("Forsaken Paladin", "Npal", true, true)},
        {CustomUnit("Quilbeast", "nqb1"), CustomUnit("Dire Quilbeast", "nqb2"),
            CustomUnit("Raging Quilbeast", "nqb3")},
        {CustomUnit("Bear", "ngz1"), CustomUnit("Raging Bear", "ngz2"),
            CustomUnit("Spirit Bear", "ngz3")},
        {CustomUnit("Hawk", "nwe1", false), CustomUnit("Thunder Hawk", "nwe2", false),
            CustomUnit("Spirit Hawk", "nwe3", false)},
        {CustomUnit("Lava Spawn Level 1", "nlv1"),
            CustomUnit("Lava Spawn Level 2", "nlv2"),
            CustomUnit("Lava Spawn Level 3", "nlv3")},
        {CustomUnit("Lesser Dark Minion", "ndr1"),
            CustomUnit("Dark Minion", "ndr2"),
            CustomUnit("Greater Dark Minion", "ndr3")},
        {CustomUnit("Doom Guard", "nbal")},
    },
}

local CUSTOM_HERO_ABILITIES = {
    Hamg = {
        CustomAbility("Blizzard", "AHbz", false),
        CustomAbility("Summon Water Elemental", "AHwe"),
        CustomAbility("Brilliance Aura", "AHab", false),
        CustomAbility("Mass Teleport", "AHmt", false, true),
    },
    Hmkg = {
        CustomAbility("Storm Bolt", "AHtb"),
        CustomAbility("Thunder Clap", "AHtc"),
        CustomAbility("Bash", "AHbh", false),
        CustomAbility("Avatar", "AHav", false, true),
    },
    Hpal = {
        CustomAbility("Holy Light", "AHhb", false),
        CustomAbility("Divine Shield", "AHds", false),
        CustomAbility("Devotion Aura", "AHad", false),
        CustomAbility("Resurrection", "AHre", false, true),
    },
    Hblm = {
        CustomAbility("Flame Strike", "AHfs", false),
        CustomAbility("Banish", "AHbn"),
        CustomAbility("Siphon Mana", "AHdr", false),
        CustomAbility("Phoenix", "AHpx", false, true),
    },
    Obla = {
        CustomAbility("Wind Walk", "AOwk", false),
        CustomAbility("Mirror Image", "AOmi", false),
        CustomAbility("Critical Strike", "AOcr", false),
        CustomAbility("Bladestorm", "AOww", false, true),
    },
    Ofar = {
        CustomAbility("Chain Lightning", "AOcl", false),
        CustomAbility("Far Sight", "AOfs", false),
        CustomAbility("Feral Spirit", "AOsf"),
        CustomAbility("Earthquake", "AOeq", true, true),
    },
    Otch = {
        CustomAbility("Shockwave", "AOsh", false),
        CustomAbility("War Stomp", "AOws"),
        CustomAbility("Endurance Aura", "AOae"),
        CustomAbility("Reincarnation", "AOre", false, true),
    },
    Oshd = {
        CustomAbility("Healing Wave", "AOhw"),
        CustomAbility("Hex", "AOhx"),
        CustomAbility("Serpent Ward", "AOsw"),
        CustomAbility("Big Bad Voodoo", "AOvd", false, true),
    },
    Udea = {
        CustomAbility("Death Coil", "AUdc", false),
        CustomAbility("Death Pact", "AUdp", false),
        CustomAbility("Unholy Aura", "AUau"),
        CustomAbility("Animate Dead", "AUan", false, true),
    },
    Udre = {
        CustomAbility("Carrion Swarm", "AUcs", false),
        CustomAbility("Sleep", "AUsl"),
        CustomAbility("Vampiric Aura", "AUav", false),
        CustomAbility("Inferno", "AUin", true, true),
    },
    Ulic = {
        CustomAbility("Frost Nova", "AUfn"),
        CustomAbility("Frost Armor", "AUfa", false),
        CustomAbility("Dark Ritual", "AUdr", false),
        CustomAbility("Death and Decay", "AUdd", false, true),
    },
    Ucrl = {
        CustomAbility("Impale", "AUim"),
        CustomAbility("Spiked Carapace", "AUts", false),
        CustomAbility("Carrion Beetles", "AUcb", false),
        CustomAbility("Locust Swarm", "AUls", false, true),
    },
    Edem = {
        CustomAbility("Mana Burn", "AEmb", false),
        CustomAbility("Immolation", "AEim", false),
        CustomAbility("Evasion", "AEev", false),
        CustomAbility("Metamorphosis", "AEme", true, true),
    },
    Ekee = {
        CustomAbility("Entangling Roots", "AEer"),
        CustomAbility("Force of Nature", "AEfn", false),
        CustomAbility("Thorns Aura", "AEah", false),
        CustomAbility("Tranquility", "AEtq", false, true),
    },
    Emoo = {
        CustomAbility("Scout", "AEst", false),
        CustomAbility("Searing Arrows", "AEfa", false),
        CustomAbility("Trueshot Aura", "AEar", false),
        CustomAbility("Starfall", "AEsf", false, true),
    },
    Ewdn = {
        CustomAbility("Fan of Knives", "AEfk", false),
        CustomAbility("Blink", "AEbl"),
        CustomAbility("Shadow Strike", "AEsh"),
        CustomAbility("Vengeance", "AEsv", false, true),
    },
    Nngs = {
        CustomAbility("Forked Lightning", "ANfl", false),
        CustomAbility("Frost Arrows", "ANfa"),
        CustomAbility("Mana Shield", "ANms", false),
        CustomAbility("Tornado", "ANto", true, true),
    },
    Nbrn = {
        CustomAbility("Silence", "ANsi", false),
        CustomAbility("Black Arrow", "ANba", false),
        CustomAbility("Life Drain", "ANdr", false),
        CustomAbility("Charm", "ANch", false, true),
    },
    Npbm = {
        CustomAbility("Breath of Fire", "ANbf", false),
        CustomAbility("Drunken Haze", "ANdh"),
        CustomAbility("Drunken Brawler", "ANdb", false),
        CustomAbility("Storm, Earth and Fire", "ANef", true, true),
    },
    Nfir = {
        CustomAbility("Soul Burn", "ANso", false),
        CustomAbility("Summon Lava Spawn", "ANlm"),
        CustomAbility("Incinerate", "ANia", false),
        CustomAbility("Volcano", "ANvc", true, true),
    },
    Nplh = {
        CustomAbility("Rain of Fire", "ANrf", false),
        CustomAbility("Howl of Terror", "ANht", false),
        CustomAbility("Cleaving Attack", "ANca", false),
        CustomAbility("Doom", "ANdo", false, true),
    },
    Nbst = {
        CustomAbility("Summon Bear", "ANsg"),
        CustomAbility("Summon Quilbeast", "ANsq"),
        CustomAbility("Summon Hawk", "ANsw", false),
        CustomAbility("Stampede", "ANst", true, true),
    },
    Ntin = {
        CustomAbility("Pocket Factory", "ANsy"),
        CustomAbility("Cluster Rockets", "ANcs", false),
        CustomAbility("Engineering Upgrade", "ANeg", false),
        CustomAbility("Robo-Goblin", "ANrg", true, true),
    },
    Nalc = {
        CustomAbility("Healing Spray", "ANhs", false),
        CustomAbility("Chemical Rage", "ANcr"),
        CustomAbility("Acid Bomb", "ANab", false),
        CustomAbility("Transmute", "ANtm", true, true),
    },
    Npal = {
        CustomAbility("Righteous Fury", "ANcp"),
        CustomAbility("Consecration", "AHcr", false),
        CustomAbility("Sacred Aura", "AHpa", false),
        CustomAbility("Cleansing Fire", "AHcl", true, true),
    },
}

local CUSTOM_UNIT_BY_KEY = {}
for _, columns in pairs(CUSTOM_RACE_COLUMNS) do
    for _, column in ipairs(columns) do
        for _, item in ipairs(column) do
            CUSTOM_UNIT_BY_KEY[item.key] = item
        end
    end
end

local CUSTOM_UNIT_ICONS = {
    hpea = "BTNPeasant", hmil = "BTNMilitia", hfoo = "BTNFootman",
    hrif = "BTNRifleman", hkni = "BTNKnight", hsor = "BTNSorceress",
    hmpr = "BTNPriest", hspt = "BTNSpellBreaker",
    hgyr = "BTNFlyingMachine", hmtt = "BTNMortarTeam",
    hmtn = "BTNSteamTank", hdhw = "BTNDragonHawk",
    hgry = "BTNGryphonRider", Hamg = "BTNHeroArchMage",
    Hmkg = "BTNHeroMountainKing", Hpal = "BTNHeroPaladin",
    Hblm = "BTNHeroBloodElfPrince",
    hwat = "BTNSummonWaterElemental",
    hwt2 = "BTNSummonWaterElemental",
    hwt3 = "BTNSummonWaterElemental", hphx = "BTNCancel",
    opeo = "BTNPeon", ogru = "BTNGrunt", ohun = "BTNHeadhunter",
    otbk = "BTNHeadHunterBerserker", odem = "BTNDemolisher",
    oshm = "BTNShaman", odoc = "BTNWitchDoctor", orai = "BTNRaider",
    owyv = "BTNWyvernRider", okod = "BTNKodoBeast",
    otbr = "BTNTrollBatRider", ospw = "BTNSpiritWalker",
    otau = "BTNTauren", okod = "BTNKotoBeast",
    Obla = "BTNHeroBlademaster",
    Ofar = "BTNHeroFarseer", Otch = "BTNHeroTaurenChieftain",
    Oshd = "BTNShadowHunter", osw1 = "BTNSpiritWolf",
    osw2 = "BTNSpiritWolf", osw3 = "BTNSpiritWolf",
    o001 = "BTNSerpentWard", o002 = "BTNSerpentWard",
    o003 = "BTNSerpentWard",
    uaco = "BTNAcolyte", ushd = "BTNShade", ugho = "BTNGhoul",
    ucry = "BTNCryptFiend", ugar = "BTNGargoyle", uban = "BTNBanshee",
    unec = "BTNNecromancer", umtw = "BTNMeatWagon",
    uabo = "BTNAbomination", uobs = "BTNObsidianStatue",
    ubsp = "BTNDestroyer", ufro = "BTNFrostWyrm",
    Udea = "BTNHeroDeathKnight", Udre = "BTNHeroDreadLord",
    Ulic = "BTNHeroLich", Ucrl = "BTNHeroCryptLord",
    uske = "BTNSkeletonWarrior", uskm = "BTNSkeletonMage",
    uin1 = "BTNInfernal", ucs1 = "BTNCarrionScarabsOff",
    ucs2 = "BTNCarrionScarabsOff", ucs3 = "BTNCarrionScarabsOff",
    ewsp = "BTNWisp", earc = "BTNArcher", esen = "BTNHuntress",
    ebal = "BTNGlaiveThrower",
    edry = "BTNDryad", edoc = "BTNDruidOfTheClaw",
    edcm = "BTNBearForm", edob = "BTNBearForm", emtg = "BTNMountainGiant",
    ehip = "BTNHippogriff", ehpr = "BTNHippogriffRider",
    edot = "BTNDruidOfTheTalon", etot = "BTNStormCrowForm",
    efdr = "BTNFaerieDragon", echm = "BTNChimaera",
    Edem = "BTNHeroDemonHunter", Ekee = "BTNKeeperOfTheGrove",
    Emoo = "BTNPriestessOfTheMoon", Ewdn = "BTNHeroWarden",
    efon = "BTNEnt", espv = "BTNAvengingWatcher",
    even = "BTNSpiritOfVengeance2",
    Nngs = "BTNNagaSeaWitch", Nbrn = "BTNBansheeRanger",
    Npbm = "BTNPandarenBrewmaster", Nfir = "BTNHeroAvatarOfFlame",
    Nplh = "BTNPitLord", Nbst = "BTNBeastMaster",
    Ntin = "BTNHeroTinker", Nalc = "BTNHeroAlchemist",
    Npal = "BTNForsakenPaladin",
    ndr1 = "BTNSkeletonWarrior", ndr2 = "BTNSkeletonWarrior",
    ndr3 = "BTNSkeletonWarrior",
}

local CUSTOM_UNIT_ABILITY_ICONS = {
    hwat = "AHwe", hwt2 = "AHwe", hwt3 = "AHwe", hphx = "AHpx",
    osw1 = "AOsf", osw2 = "AOsf", osw3 = "AOsf",
    o001 = "AOsw", o002 = "AOsw", o003 = "AOsw",
    uin1 = "AUin",
    efon = "AEfn", espv = "AEsv", etot = "Arav", even = "Avng",
    nqb1 = "ANsq", nqb2 = "ANsq", nqb3 = "ANsq",
    ngz1 = "ANsg", ngz2 = "ANsg", ngz3 = "ANsg",
    nwe1 = "ANsw", nwe2 = "ANsw", nwe3 = "ANsw",
    nlv1 = "ANlm", nlv2 = "ANlm", nlv3 = "ANlm", nbal = "ANdo",
}

local function CustomUnitIcon(rawcode)
    if CUSTOM_UNIT_ABILITY_ICONS[rawcode] ~= nil then
        return BlzGetAbilityIcon(FourCC(CUSTOM_UNIT_ABILITY_ICONS[rawcode]))
    end
    return "ReplaceableTextures\\CommandButtons\\" ..
        (CUSTOM_UNIT_ICONS[rawcode] or "BTNCancel") .. ".blp"
end

-- Shared read-only selector data for exercises that use the same unit grid.
function JTG.GetSurroundCustomRaceColumns(race)
    return CUSTOM_RACE_COLUMNS[race] or {}
end

function JTG.GetSurroundCustomUnitIcon(rawcode)
    return CustomUnitIcon(rawcode)
end

local SETUPS = {
    human = {
        {name = "Mountain King 1", units = {{"Hmkg", 1, "AHtb"}, {"hfoo", 4}}},
        {name = "Mountain King 2", units = {{"Hmkg", 1, "AHtc"}, {"hfoo", 4}}},
        {name = "Blood Mage", units = {{"Hblm", 1, "AHbn"}, {"hfoo", 4}}},
        {name = "Sorceresses", units = {{"hsor", 2}, {"hfoo", 4}}},
        {name = "Militia", units = {{"hmil", 8}}},
        {name = "Peasants", units = {{"hpea", 8}}},
        {name = "Footmen", units = {{"hfoo", 6}}},
        {name = "Knights", units = {{"hkni", 4}}},
    },
    orc = {
        {name = "Shadow Hunter", units = {{"Oshd", 1, "AOhx"}, {"ogru", 4}}},
        {name = "Tauren Chieftain", units = {{"Otch", 1, "AOws"}, {"ogru", 4}}},
        {name = "Shamans", units = {{"oshm", 2}, {"ogru", 4}}},
        {name = "Raiders", units = {{"orai", 2}, {"ogru", 4}}},
        {name = "Peons", units = {{"opeo", 8}}},
        {name = "Grunts", units = {{"ogru", 6}}},
        {name = "Taurens", units = {{"otau", 4}}},
    },
    undead = {
        {name = "Dread Lord", units = {{"Udre", 1, "AUsl"}, {"ugho", 4}}},
        {name = "Crypt Lord", units = {{"Ucrl", 1, "AUim"}, {"ugho", 5}}},
        {name = "Necromancers", units = {{"unec", 2}, {"ugho", 4}}},
        {name = "Lich", units = {{"Ulic", 1, "AUfn"}, {"ugho", 6}}},
        {name = "Frost Wyrm", units = {{"ufro", 1}, {"ugho", 5}}},
        {name = "Ghouls", units = {{"ugho", 6}}},
        {name = "Crypt Fiends", units = {{"ucry", 5}}},
    },
    nightelf = {
        {name = "Keeper of the Grove", units = {{"Ekee", 1, "AEer"}, {"esen", 4}}},
        {name = "Dryads", units = {{"edry", 4}, {"earc", 4}}},
        {name = "Huntresses", units = {{"esen", 6}}},
    },
    neutral = {
        {name = "Naga Sea Witch", units = {{"Nngs", 1, "ANfa"}, {"hfoo", 5}}},
        {name = "Pandaren Brewmaster", units = {{"Npbm", 1, "ANdh"}, {"ogru", 5}}},
        {name = "Forsaken Paladin", units = {{"Npal", 1, "ANcp"}, {"ugho", 5}}},
    },
}

local GARGOYLE_SETUPS = {
    {name = "Dread Lord", units = {{"Udre", 1, "AUsl"}, {"ugar", 4}}},
    {name = "Crypt Lord", units = {{"Ucrl", 1, "AUim"}, {"ugar", 5}}},
    {name = "Necromancers",
        units = {{"unec", 2}, {"ugar", 5}}},
    {name = "Lich", units = {{"Ulic", 1, "AUfn"}, {"ugar", 6}}},
    {name = "Frost Wyrm", units = {{"ufro", 1}, {"ugar", 5}}},
    {name = "6 Gargoyles", units = {{"ugar", 6}}},
    {name = "4 Gargoyles", units = {{"ugar", 4}}},
    {name = "Naga Sea Witch", units = {{"Nngs", 1, "ANfa"}, {"ugar", 6}}},
    {name = "Pandaren Brewmaster",
        units = {{"Npbm", 1, "ANdh"}, {"ugar", 6}}},
    {name = "Forsaken Paladin",
        units = {{"Npal", 1, "ANcp"}, {"ugar", 6}}},
}

local RUNNERS = {
    {id = FourCC("ogru"), name = "Grunt"},
    {id = FourCC("Edem"), name = "Demon Hunter"},
}

local DISABLING_BUFFS = {
    FourCC("BHtb"), -- Storm Bolt
    FourCC("BOws"), -- War Stomp
    FourCC("BUsl"), -- Sleep
    FourCC("BUim"), -- Impale
    FourCC("BEer"), -- Entangling Roots
}

function JTG.FormatSurroundQuestText(text)
    local formatted = text:gsub("{Button:%s*(.-)}", "|cffffcc00%1|r")
    formatted = formatted:gsub("{Gold Font:%s*(.-)}", "|cffffcc00%1|r")
    formatted = formatted:gsub("{Term:%s*(.-)}", "|cffff9933%1|r")
    return formatted:gsub("{Input:%s*(.-)}", "|cff80ff80%1|r")
end

local function AddButton(scope, parent, name, label, width, height, action)
    local button = JTG.ScopeTrackFrame(scope, BlzCreateFrameByType("GLUETEXTBUTTON",
        name, parent, "ScriptDialogButton", 0))
    BlzFrameSetSize(button, width, height)
    BlzFrameSetText(button, label)
    local trigger = JTG.ScopeTrackTrigger(scope, CreateTrigger())
    BlzTriggerRegisterFrameEvent(trigger, button, FRAMEEVENT_CONTROL_CLICK)
    TriggerAddAction(trigger, function()
        if JTG.UI and JTG.UI.PlayButtonSound then
            JTG.UI.PlayButtonSound("normal")
        end
        if JTG.UI and JTG.UI.ReleaseFrameFocus then
            JTG.UI.ReleaseFrameFocus(BlzGetTriggerFrame())
        end
        action()
        if JTG.UI and JTG.UI.ReleaseKeyboardFocusAfterClick then
            JTG.UI.ReleaseKeyboardFocusAfterClick()
        end
    end)
    return button
end

local function TrainAbilities(unit, abilities)
    if abilities == nil then return end
    if type(abilities) == "string" then abilities = {abilities} end
    if IsUnitType(unit, UNIT_TYPE_HERO) then
        SetHeroLevel(unit, math.max(1, #abilities), false)
        local selectedLevels = {}
        for _, rawcode in ipairs(abilities) do
            SelectHeroSkill(unit, FourCC(rawcode))
            selectedLevels[rawcode] = (selectedLevels[rawcode] or 0) + 1
        end
        -- Custom selections may deliberately choose an ultimate below its
        -- normal hero-level requirement. Preserve that exact requested build.
        for rawcode, level in pairs(selectedLevels) do
            local abilityId = FourCC(rawcode)
            if GetUnitAbilityLevel(unit, abilityId) < level then
                UnitAddAbility(unit, abilityId)
                SetUnitAbilityLevel(unit, abilityId, level)
            end
        end
        UnitModifySkillPoints(unit, -GetHeroSkillPoints(unit))
        SetUnitState(unit, UNIT_STATE_MANA, BlzGetUnitMaxMana(unit))
    else
        for _, rawcode in ipairs(abilities) do
            UnitAddAbility(unit, FourCC(rawcode))
        end
    end
end

function JTG.OpenSurroundsMenu(originCategory, pauseGame, restorePage,
        restoreData)
    local active = JTG.Controller.session
    local returning = active ~= nil and active.id == "skills.surround"
    local selection = {race = "human", setupIndex = 1, runnerIndex = 1}
    for key, value in pairs((active and active.restartData) or {}) do
        selection[key] = value
    end
    for key, value in pairs(restoreData or {}) do selection[key] = value end
    selection.customCounts = selection.customCounts or {}
    selection.customOrder = selection.customOrder or {}
    selection.customAbilities = selection.customAbilities or {}
    selection.customRemoveMode = selection.customRemoveMode == true

    local function releasePause()
        if JTG.UI then JTG.UI.SetGameplayMenuPaused(false) end
    end
    local function resume()
        releasePause()
        JTG.ResumeActivity()
    end
    local function launch(race)
        releasePause()
        selection.race = race
        selection.setupIndex = 1
        selection.runnerIndex = 1
        local data = {
            race = race, setupIndex = 1, runnerIndex = 1,
            skipIntro = returning,
        }
        if JTG.Controller.session ~= nil then
            JTG.StartActivityAfterCleanup("skills.surround",
                originCategory or "skills", data, nil, "briefing-restart")
        else
            JTG.StartActivity("skills.surround", originCategory or "skills", data)
        end
    end
    local function customUnitCount()
        local count = 0
        for _, amount in pairs(selection.customCounts) do
            count = count + amount
        end
        return count
    end
    local function customHeroCount()
        local count = 0
        for key, amount in pairs(selection.customCounts) do
            local item = CUSTOM_UNIT_BY_KEY[key]
            if amount > 0 and item ~= nil and item.hero then count = count + 1 end
        end
        return count
    end
    local function customSummary()
        local heroes, units = {}, {}
        for _, itemKey in ipairs(selection.customOrder) do
            local amount = selection.customCounts[itemKey] or 0
            local item = CUSTOM_UNIT_BY_KEY[itemKey]
            if amount > 0 and item ~= nil then
                if item.hero then
                    local parts = {item.label}
                    for _, ability in ipairs(CUSTOM_HERO_ABILITIES[item.rawcode] or {}) do
                        local level = selection.customAbilities[item.rawcode .. ":" ..
                            ability.rawcode] or 0
                        if level > 0 then
                            parts[#parts + 1] = ability.label .. " Lvl" ..
                                tostring(level)
                        end
                    end
                    heroes[#heroes + 1] = table.concat(parts, ", ")
                else
                    units[#units + 1] = item.label .. " x" .. tostring(amount)
                end
            end
        end
        local combined = {}
        for _, value in ipairs(heroes) do combined[#combined + 1] = value end
        for _, value in ipairs(units) do combined[#combined + 1] = value end
        if #combined == 0 then return "No units selected." end
        return table.concat(combined, "; ") .. "."
    end
    local function customArmyData()
        local army = {}
        for _, itemKey in ipairs(selection.customOrder) do
            local amount = selection.customCounts[itemKey] or 0
            local item = CUSTOM_UNIT_BY_KEY[itemKey]
            if amount > 0 and item ~= nil then
                local abilities = {}
                for _, ability in ipairs(CUSTOM_HERO_ABILITIES[item.rawcode] or {}) do
                    local level = selection.customAbilities[item.rawcode .. ":" ..
                        ability.rawcode] or 0
                    for _ = 1, level do abilities[#abilities + 1] = ability.rawcode end
                end
                army[#army + 1] = {item.rawcode, amount, abilities}
            end
        end
        return army
    end
    local function launchCustom()
        if customUnitCount() < 4 then return end
        releasePause()
        local data = {
            race = "custom", setupIndex = 1, runnerIndex = 1,
            customArmy = customArmyData(), skipIntro = returning,
        }
        if JTG.Controller.session ~= nil then
            JTG.StartActivityAfterCleanup("skills.surround",
                originCategory or "skills", data, nil, "briefing-restart")
        else
            JTG.StartActivity("skills.surround", originCategory or "skills", data)
        end
    end
    local function clearCustomSelection()
        selection.customCounts = {}
        selection.customOrder = {}
        selection.customAbilities = {}
        selection.customRemoveMode = false
    end
    local showRoot, showRaces, showCustomRaces, showCustomGrid
    local function show(spec, page)
        spec.title = "Surrounds"
        spec.activityId = "skills.surround"
        spec.originCategory = originCategory or "skills"
        if not spec.hideHeadingArtwork then
            spec.headingArtwork = "JTGMenu\\SurroundsBriefing.dds"
            spec.headingArtworkWidth = 0.176
            spec.headingArtworkHeight = 0.086
        end
        spec.body = spec.body or INTRO
        spec.pageId = page
        spec.restoreData = selection
        spec.pauseGame = pauseGame == true
        if pauseGame then
            local primaryAction = spec.primaryAction
            local primaryLabel = spec.primaryLabel
            local primaryEnabled = spec.primaryEnabled
            if string.sub(page or "", 1, 7) == "custom-" then
                -- While an exercise is paused, Resume and Exit own the footer.
                -- Exit returns to this same selector in its normal state, where
                -- Back and Begin become available without losing the selection.
                spec.primaryAction = nil
                spec.primaryLabel = nil
                spec.primaryEnabled = nil
            end
            spec.resumeAction = resume
            spec.exitAction = function()
                JTG.StopActivity("menu-exit")
                pauseGame = false
                returning = false
                spec.resumeAction = nil
                spec.exitAction = nil
                spec.primaryAction = primaryAction
                spec.primaryLabel = primaryLabel
                spec.primaryEnabled = primaryEnabled
                show(spec, page)
            end
        end
        JTG.UI.ShowActivityBriefing(spec)
    end
    showRoot = function()
        show({
            choices = {
                {label = "Start Training", primary = true,
                    action = showRaces},
                {label = "Custom", action = showCustomRaces},
            },
            backAction = function()
                if pauseGame then JTG.UI.ShowCategory(originCategory or "skills")
                else JTG.UI.ShowCategory(originCategory or "skills") end
            end,
        }, "root")
    end
    showRaces = function()
        local choices = {}
        for _, race in ipairs(RACES) do
            local key, label = race.key, race.label
            table.insert(choices, {label = label, primary = true,
                icon = race.artwork,
                iconSize = RACE_CHOICE_ICON_SIZE,
                iconOffsetX = RACE_CHOICE_ICON_OFFSET_X,
                action = function() launch(key) end})
        end
        show({
            choices = choices,
            backAction = showRoot,
        }, "races")
    end
    showCustomRaces = function()
        local enough = customUnitCount() >= 4
        show({
            body = "Choose up to 12 units!\n\n" .. customSummary(),
            choices = {
                {label = "Human", primary = true, icon = RACES[1].artwork,
                    iconSize = RACE_CHOICE_ICON_SIZE,
                    iconOffsetX = RACE_CHOICE_ICON_OFFSET_X,
                    action = function() showCustomGrid("human") end},
                {label = "Orc", primary = true, icon = RACES[2].artwork,
                    iconSize = RACE_CHOICE_ICON_SIZE,
                    iconOffsetX = RACE_CHOICE_ICON_OFFSET_X,
                    action = function() showCustomGrid("orc") end},
                {label = "Undead", primary = true, icon = RACES[3].artwork,
                    iconSize = RACE_CHOICE_ICON_SIZE,
                    iconOffsetX = RACE_CHOICE_ICON_OFFSET_X,
                    action = function() showCustomGrid("undead") end},
                {label = "Night Elf", primary = true, icon = RACES[4].artwork,
                    iconSize = RACE_CHOICE_ICON_SIZE,
                    iconOffsetX = RACE_CHOICE_ICON_OFFSET_X,
                    action = function() showCustomGrid("nightelf") end},
                {label = "Neutral", primary = true,
                    icon = "ReplaceableTextures\\CommandButtons\\BTNTavern.blp",
                    iconSize = RACE_CHOICE_ICON_SIZE * 0.6,
                    iconOffsetX = RACE_CHOICE_ICON_OFFSET_X,
                    action = function() showCustomGrid("neutral") end},
                {label = "Begin", primary = true, enabled = enough,
                    action = enough and launchCustom or nil},
            },
            hideHeadingArtwork = true,
            backAction = function()
                clearCustomSelection()
                showRoot()
            end,
        }, "custom-races")
    end
    showCustomGrid = function(race)
        local choices = {}
        local columns = CUSTOM_RACE_COLUMNS[race] or {}
        local function refresh() showCustomGrid(race) end
        local function addUnit(item)
            if not item.enabled or customUnitCount() >= 12 then return end
            local current = selection.customCounts[item.key] or 0
            if item.hero and current >= 1 then return end
            if item.hero and customHeroCount() >= 3 then return end
            if current == 0 then
                selection.customOrder[#selection.customOrder + 1] = item.key
            end
            selection.customCounts[item.key] = current + 1
            refresh()
        end
        local function removeUnit(item)
            local current = selection.customCounts[item.key] or 0
            if current <= 0 then return end
            selection.customCounts[item.key] = current - 1
            if current == 1 then
                for index = #selection.customOrder, 1, -1 do
                    if selection.customOrder[index] == item.key then
                        table.remove(selection.customOrder, index)
                    end
                end
                if item.hero then
                    for _, ability in ipairs(CUSTOM_HERO_ABILITIES[item.rawcode] or {}) do
                        selection.customAbilities[item.rawcode .. ":" ..
                            ability.rawcode] = nil
                    end
                end
            end
            refresh()
        end
        choices[#choices + 1] = {
            label = selection.customRemoveMode and "Remove Mode" or "Add Mode",
            tooltip = selection.customRemoveMode and
                "Left-click units and abilities to remove them." or
                "Left-click units and abilities to add them.",
            icon = selection.customRemoveMode and
                "ReplaceableTextures\\CommandButtons\\BTNCancel.blp" or
                "ReplaceableTextures\\CommandButtons\\BTNSkillz.blp",
            column = 0, row = 0,
            action = function()
                selection.customRemoveMode = not selection.customRemoveMode
                refresh()
            end,
        }
        for columnIndex, column in ipairs(columns) do
            for rowIndex, item in ipairs(column) do
                local definition = item
                choices[#choices + 1] = {
                    label = definition.label,
                    unitRawcode = definition.rawcode,
                    icon = CustomUnitIcon(definition.rawcode),
                    enabled = definition.enabled,
                    column = columnIndex, row = rowIndex - 1,
                    action = function()
                        if selection.customRemoveMode then removeUnit(definition)
                        else addUnit(definition) end
                    end,
                    rightAction = function() removeUnit(definition) end,
                }
            end
        end
        local abilityColumn = #columns + 1
        for _, itemKey in ipairs(selection.customOrder) do
            local selectedItem = CUSTOM_UNIT_BY_KEY[itemKey]
            local heroRawcode = selectedItem and selectedItem.rawcode or itemKey
            if (selection.customCounts[itemKey] or 0) > 0 then
                local abilities = CUSTOM_HERO_ABILITIES[heroRawcode]
                if abilities ~= nil then
                    for rowIndex, ability in ipairs(abilities) do
                        local definition = ability
                        local key = heroRawcode .. ":" .. definition.rawcode
                        local function addAbility()
                            if not definition.enabled then return end
                            local maximum = definition.ultimate and 1 or 3
                            selection.customAbilities[key] = math.min(maximum,
                                (selection.customAbilities[key] or 0) + 1)
                            refresh()
                        end
                        local function removeAbility()
                            selection.customAbilities[key] = math.max(0,
                                (selection.customAbilities[key] or 0) - 1)
                            refresh()
                        end
                        choices[#choices + 1] = {
                            label = definition.label,
                            icon = BlzGetAbilityIcon(FourCC(definition.rawcode)),
                            enabled = definition.enabled,
                            column = abilityColumn, row = rowIndex - 1,
                            action = function()
                                if selection.customRemoveMode then removeAbility()
                                else addAbility() end
                            end,
                            rightAction = removeAbility,
                        }
                    end
                    abilityColumn = abilityColumn + 1
                end
            end
        end
        local enough = customUnitCount() >= 4
        show({
            body = "Choose up to 12 units!\n\n" .. customSummary(),
            choices = choices,
            commandGridChoices = true,
            commandGridColumns = math.max(10, abilityColumn),
            commandGridRows = 5,
            commandGridButtonSize = 0.029,
            commandGridStep = 0.030,
            commandGridTop = -0.205,
            hideHeadingArtwork = true,
            backAction = showCustomRaces,
            primaryLabel = "Begin", primaryEnabled = enough,
            primaryAction = enough and launchCustom or nil,
        }, "custom-" .. race)
    end
    if restorePage == "races" then
        showRaces()
    elseif restorePage == "custom-races" then
        showCustomRaces()
    elseif restorePage ~= nil and
            string.sub(restorePage, 1, 7) == "custom-" then
        showCustomGrid(string.sub(restorePage, 8))
    else
        showRoot()
    end
end

function JTG.OpenGargoyleSurroundMenu(originCategory, pauseGame)
    local function releasePause()
        if JTG.UI then JTG.UI.SetGameplayMenuPaused(false) end
    end
    local function launch()
        releasePause()
        local data = {setupIndex = 1, runnerIndex = 1, gargoyleMode = true}
        if JTG.Controller.session ~= nil then
            JTG.StartActivityAfterCleanup("skills.gargoyle",
                originCategory or "skills", data, nil, "briefing-restart")
        else
            JTG.StartActivity("skills.gargoyle", originCategory or "skills", data)
        end
    end
    local function show()
        local spec = {
            title = "Gargoyle Surrounds",
            activityId = "skills.gargoyle",
            originCategory = originCategory or "skills",
            body = JTG.FormatSurroundQuestText(GARGOYLE_INTRO),
            headingArtwork = "JTGMenu\\GargoyleSurroundsBriefing.dds",
            headingArtworkWidth = 0.176,
            headingArtworkHeight = 0.086,
            centerSingleChoice = true,
            choices = {{label = "Start Training", primary = true,
                action = launch}},
            pageId = "root",
            pauseGame = pauseGame == true,
            backAction = function()
                releasePause()
                JTG.UI.ShowCategory(originCategory or "skills")
            end,
        }
        if pauseGame then
            spec.resumeAction = function()
                releasePause()
                JTG.ResumeActivity()
            end
            spec.exitAction = function()
                JTG.StopActivity("menu-exit")
                pauseGame = false
                show()
            end
        end
        JTG.UI.ShowActivityBriefing(spec)
    end
    show()
end

local function CreateSurroundsActivity(session, gargoyleMode)
    local data = session.restartData or {}
    local activity = {
        gargoyleMode = gargoyleMode == true or data.gargoyleMode == true,
        race = data.race or "human",
        customArmy = data.customArmy,
        setupIndex = data.setupIndex or 1,
        runnerIndex = data.runnerIndex or 1,
        skipIntro = data.skipIntro == true,
        army = {},
        runner = nil,
        running = false,
        finished = false,
        countdownActive = false,
        runnerWaiting = false,
        countdownValue = 3,
        locallyPaused = false,
        setupsOpen = false,
        presentationVisible = true,
        holdTime = 0,
        healElapsed = 0,
        previousRunnerX = nil,
        previousRunnerY = nil,
        squaresVisible = data.squaresVisible == true,
        squareGridVisible = data.squareGridVisible == true,
        squareEntries = {},
    }

    function activity:makeTimer(period, repeating, callback)
        return JTG.StartScopedTimer(session, session.scope, period, repeating,
            callback)
    end

    function activity:currentSetup()
        if self.gargoyleMode then
            self.setupIndex = math.max(1,
                math.min(#GARGOYLE_SETUPS, self.setupIndex))
            return GARGOYLE_SETUPS[self.setupIndex], GARGOYLE_SETUPS
        end
        if self.race == "custom" and self.customArmy ~= nil then
            local custom = {name = "Custom", units = self.customArmy}
            return custom, {custom}
        end
        local list = SETUPS[self.race] or SETUPS.human
        self.setupIndex = math.max(1, math.min(#list, self.setupIndex))
        return list[self.setupIndex], list
    end

    function activity:captureResetState()
        return {
            race = self.race, setupIndex = self.setupIndex,
            runnerIndex = self.runnerIndex, skipIntro = true,
            squaresVisible = self.squaresVisible,
            squareGridVisible = self.squareGridVisible,
            customArmy = self.customArmy,
            gargoyleMode = self.gargoyleMode,
        }
    end

    function activity:hasNextRun()
        local _, list = self:currentSetup()
        return self.runnerIndex == 1 or self.setupIndex < #list
    end

    function activity:nextStage()
        if not self:hasNextRun() then return false end
        if self.runnerIndex == 1 then
            self.runnerIndex = 2
        else
            self.setupIndex = self.setupIndex + 1
            self.runnerIndex = 1
        end
        self:setSetupsOpen(false)
        JTG.ResetActivity()
        return true
    end

    function activity:createCourseMarkers()
        self.startLine = JTG.ScopeTrackLightning(session.presentationScope,
            AddLightning("DRAL", false, self.startX, self.arenaMinY,
                self.startX, self.arenaMaxY))
        self.finishLine = JTG.ScopeTrackLightning(session.presentationScope,
            AddLightning("DRAL", false, self.finishX, self.arenaMinY,
                self.finishX, self.arenaMaxY))
        if self.startLine ~= nil then
            SetLightningColor(self.startLine, 0.25, 1.0, 0.25, 0.90)
        end
        if self.finishLine ~= nil then
            SetLightningColor(self.finishLine, 1.0, 0.30, 0.25, 0.90)
        end
        self.startTag = JTG.ScopeTrackTextTag(session.presentationScope, CreateTextTag())
        SetTextTagText(self.startTag, "START", 0.022)
        SetTextTagPos(self.startTag, self.startX - 70, self.laneY + 590, 24)
        SetTextTagColor(self.startTag, 100, 255, 100, 255)
        self.finishTag = JTG.ScopeTrackTextTag(session.presentationScope, CreateTextTag())
        SetTextTagText(self.finishTag, "FINISH", 0.022)
        SetTextTagPos(self.finishTag, self.finishX - 85, self.laneY + 590, 24)
        SetTextTagColor(self.finishTag, 255, 100, 80, 255)
    end

    function activity:createSquareOverlays()
        self.squareEntries = {}
        if self.runner ~= nil then
            self:addSquareOverlay(self.runner,
                JTG.UnitSquareEnemyTexture)
        end
        for _, unit in ipairs(self.army) do
            self:addSquareOverlay(unit,
                JTG.UnitSquarePlayerTexture)
        end
    end

    function activity:updateSquareOverlays()
        JTG.ShowNavigationGrid(self.navigationGridImages,
            self.squareGridVisible and self.presentationVisible)
        for _, entry in ipairs(self.squareEntries) do
            if entry.unit ~= nil and GetUnitTypeId(entry.unit) ~= 0 then
                local obstructionHalf = nil
                local unitType = GetUnitTypeId(entry.unit)
                if unitType == FourCC("ugrm") or
                        not IsUnitType(entry.unit, UNIT_TYPE_FLYING) then
                    local collision = BlzGetUnitCollisionSize(entry.unit)
                    if collision > 0 then
                        obstructionHalf = JTG.UnitObstructionHalfSize(collision)
                    end
                end
                local centerX = JTG.UnitObstructionGridCenter(GetUnitX(entry.unit))
                local centerY = JTG.UnitObstructionGridCenter(GetUnitY(entry.unit))
                for half, image in pairs(entry.images) do
                    SetImagePosition(image, centerX - half, centerY - half, 2)
                    ShowImage(image, obstructionHalf == half and
                        self.squaresVisible and self.presentationVisible)
                end
                if obstructionHalf ~= nil and entry.images[obstructionHalf] == nil then
                    local size = obstructionHalf * 2.0
                    local image = JTG.ScopeTrackImage(session.presentationScope,
                        CreateImage(entry.texture, size, size, 0,
                            centerX - obstructionHalf, centerY - obstructionHalf, 2,
                            0, 0, 0, 2))
                    SetImageRenderAlways(image, true)
                    SetImageAboveWater(image, true, true)
                    entry.images[obstructionHalf] = image
                    ShowImage(image,
                        self.squaresVisible and self.presentationVisible)
                end
            end
        end
        JTG.ShowNavigationGrid(self.navigationDotsImages,
            self.squaresVisible and self.presentationVisible)
    end

    function activity:addSquareOverlay(unit, texture)
        table.insert(self.squareEntries,
            {unit = unit, texture = texture, images = {}})
    end

    function activity:toggleSquares()
        if not self.squaresVisible then
            self.squaresVisible = true
            self.squareGridVisible = false
        elseif not self.squareGridVisible then
            self.squareGridVisible = true
        else
            self.squaresVisible = false
            self.squareGridVisible = false
        end
        self:updateSquareOverlays()
        if JTG.UI and JTG.UI.SetSquaresActive then
            JTG.UI.SetSquaresActive(self.squaresVisible)
        end
    end

    function activity:createCountdownUI()
        local gameUI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        self.countdownFrame = JTG.ScopeTrackFrame(session.presentationScope,
            BlzCreateFrameByType("TEXT", "JTGSurroundCountdown", gameUI, "", 0))
        BlzFrameSetSize(self.countdownFrame, 0.20, 0.08)
        BlzFrameSetAbsPoint(self.countdownFrame, FRAMEPOINT_CENTER, 0.40, 0.38)
        BlzFrameSetTextAlignment(self.countdownFrame, TEXT_JUSTIFY_MIDDLE,
            TEXT_JUSTIFY_CENTER)
        BlzFrameSetScale(self.countdownFrame, 2.45)
        BlzFrameSetEnable(self.countdownFrame, false)
        BlzFrameSetVisible(self.countdownFrame, false)
    end

    function activity:createStatusUI()
        local gameUI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        self.statusFrame = JTG.ScopeTrackFrame(session.presentationScope,
            BlzCreateFrameByType("TEXT", "JTGSurroundStatus", gameUI, "", 0))
        BlzFrameSetSize(self.statusFrame, 0.58, 0.045)
        BlzFrameSetAbsPoint(self.statusFrame, FRAMEPOINT_TOP, 0.40, 0.505)
        BlzFrameSetTextAlignment(self.statusFrame, TEXT_JUSTIFY_MIDDLE,
            TEXT_JUSTIFY_CENTER)
        BlzFrameSetScale(self.statusFrame, 1.20)
        BlzFrameSetEnable(self.statusFrame, false)
    end

    function activity:updateStatus()
        local setup = self:currentSetup()
        local runner = RUNNERS[self.runnerIndex]
        local hold = math.min(100, math.floor(self.holdTime / 3.0 * 100 + 0.5))
        BlzFrameSetText(self.statusFrame,
            "|cffffcc00" .. setup.name .. "|r  vs " .. runner.name ..
            "   Still " .. tostring(hold) .. "%")
    end

    activity.resultActions = {
        next = function(self)
            if self.resultAction == "finish" then
                JTG.ExitActivity()
                return
            end
            if self.resultAction == "next_round" then
                self.runnerIndex = 2
            elseif self.resultAction == "next_setup" then
                self.setupIndex = self.setupIndex + 1
                self.runnerIndex = 1
            end
            JTG.ResetActivity()
        end,
    }

    function activity:createResultUI()
        self.resultCard = JTG.UI.CreateResultCard(session, {
            name = "JTGSurroundResult", width = 0.36,
            detailsHeight = 0.060, centerY = 0.33,
        })
        self.resultPanel = self.resultCard.panel
        if self.gargoyleMode then
            self.celebrationFrame = JTG.ScopeTrackFrame(session.presentationScope,
                BlzCreateFrameByType("BACKDROP", "JTGSurroundCelebration",
                    self.resultPanel, "", 0))
            BlzFrameSetSize(self.celebrationFrame, 0.080, 0.092)
            BlzFrameSetPoint(self.celebrationFrame, FRAMEPOINT_BOTTOMLEFT,
                self.resultPanel, FRAMEPOINT_BOTTOMLEFT, 0, 0)
            BlzFrameSetEnable(self.celebrationFrame, false)
            BlzFrameSetVisible(self.celebrationFrame, false)
        end
    end

    function activity:playCelebration()
        local sound = CreateSound("JTGCelebration\\HotDiggedyDog.mp3",
            false, false, false, 10, 10, "DefaultEAXON")
        SetSoundChannel(sound, 5)
        SetSoundVolume(sound, 100)
        -- The imported clip is 44.1 kHz CBR without an Info/Xing frame.
        -- Keep the requested five-second duration and normal playback pitch.
        SetSoundPitch(sound, 1.0)
        local durationMilliseconds = 5000
        SetSoundDuration(sound, durationMilliseconds)
        JTG.ScopeBorrow(session.scope, function()
            StopSound(sound, true, false)
        end)
        StartSound(sound)
        self.celebrationActive = true
        local frameIndex = 0
        local elapsed = 0
        local duration = 15.0
        BlzFrameSetTexture(self.celebrationFrame,
            "JTGCelebration\\Doge0.dds", 0, true)
        BlzFrameSetVisible(self.celebrationFrame, self.presentationVisible)
        local timer
        timer = self:makeTimer(0.1, true, function()
            elapsed = elapsed + 0.1
            if elapsed >= duration then
                self.celebrationActive = false
                BlzFrameSetVisible(self.celebrationFrame, false)
                PauseTimer(timer)
                return
            end
            frameIndex = (frameIndex + 1) % 5
            BlzFrameSetTexture(self.celebrationFrame,
                "JTGCelebration\\Doge" .. frameIndex .. ".dds", 0, true)
        end)
    end

    function activity:renderResultPresentation(visible)
        if self.resultCard == nil or self.resultTitleText == nil then return end
        JTG.UI.ShowResultCard(self.resultCard, {
            title = self.resultTitleText,
            tone = self.resultTone,
            details = self.resultDetailsText or "",
            visible = visible ~= false,
            actions = {
                hide = self.resultTone == "success" and {} or nil,
                retry = {},
                next = self.resultAction ~= "retry" and
                    {label = self.resultPrimaryLabel or "Next"} or nil,
                menu = {},
            },
        })
    end

    function activity:createSetupsUI()
        local gameUI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        local _, list = self:currentSetup()
        local panelHeight = JTG.TutorialMenuHeight(#list) + 0.015
        self.setupsPanel = JTG.ScopeTrackFrame(session.presentationScope,
            JTG.UI.CreateNativePanel("JTGSurroundSetups", gameUI, 0.20,
                panelHeight))
        BlzFrameSetAbsPoint(self.setupsPanel, FRAMEPOINT_TOPRIGHT, 0.795, 0.485)
        self.setupButtons = {}
        for index, setup in ipairs(list) do
            local setupIndex = index
            local button = AddButton(session.presentationScope,
                self.setupsPanel, "JTGSurroundSetup" .. tostring(index),
                setup.name, 0.155, 0.026, function()
                    self.setupIndex = setupIndex
                    self.runnerIndex = 1
                    self.setupsOpen = false
                    JTG.ResetActivity()
                end)
            BlzFrameSetPoint(button, FRAMEPOINT_TOP, self.setupsPanel,
                FRAMEPOINT_TOP, 0, -0.038 - (index - 1) * 0.029)
            self.setupButtons[index] = button
        end
        local close = AddButton(session.presentationScope, self.setupsPanel,
            "JTGSurroundSetupsClose", "Close", 0.10, 0.026,
            function() self:setSetupsOpen(false) end)
        BlzFrameSetPoint(close, FRAMEPOINT_BOTTOM, self.setupsPanel,
            FRAMEPOINT_BOTTOM, 0, 0.025)
        BlzFrameSetVisible(self.setupsPanel, false)
    end

    function activity:setSetupsOpen(open)
        self.setupsOpen = open == true
        if self.setupsPanel ~= nil then
            BlzFrameSetVisible(self.setupsPanel,
                self.presentationVisible and self.setupsOpen)
        end
        PauseUnit(self.runner, self.locallyPaused or self.setupsOpen or
            self.countdownActive or self.runnerWaiting or self.finished)
        for _, unit in ipairs(self.army) do
            PauseUnit(unit, self.locallyPaused or self.setupsOpen or
                self.countdownActive or self.finished)
        end
    end

    function activity:toggleSetups()
        if self.finished then return end
        self:setSetupsOpen(not self.setupsOpen)
    end

    function activity:setOverlayVisible(visible)
        self.presentationVisible = visible == true
        if self.statusFrame ~= nil then
            BlzFrameSetVisible(self.statusFrame,
                self.presentationVisible and not self.finished)
        end
        if self.countdownFrame ~= nil then
            BlzFrameSetVisible(self.countdownFrame,
                self.presentationVisible and self.countdownActive)
        end
        if self.setupsPanel ~= nil then
            BlzFrameSetVisible(self.setupsPanel,
                self.presentationVisible and self.setupsOpen)
        end
        if self.resultPanel ~= nil then
            BlzFrameSetVisible(self.resultPanel,
                self.presentationVisible and self.finished)
        end
        if self.startTag ~= nil then SetTextTagVisibility(self.startTag, visible) end
        if self.finishTag ~= nil then SetTextTagVisibility(self.finishTag, visible) end
        self:updateSquareOverlays()
        if self.celebrationFrame ~= nil then
            BlzFrameSetVisible(self.celebrationFrame,
                self.presentationVisible and self.celebrationActive == true)
        end
    end

    function activity:spawnArmy()
        local setup = self:currentSetup()
        local specs = setup.units
        local total = 0
        for _, spec in ipairs(specs) do total = total + spec[2] end
        local number = 0
        for _, spec in ipairs(specs) do
            local unitId = FourCC(spec[1])
            for _ = 1, spec[2] do
                number = number + 1
                local angle = 2 * math.pi * (number - 1) / total
                local radius = 190
                local x = self.finishX + math.cos(angle) * radius
                local y = self.laneY + math.sin(angle) * radius
                local unit = JTG.ScopeTrackUnit(session.scope,
                    BlzCreateUnitWithSkin(Player(0), unitId,
                        x, y, 180, unitId))
                SetUnitAcquireRange(unit, 0)
                TrainAbilities(unit, spec[3])
                PauseUnit(unit, true)
                table.insert(self.army, unit)
            end
        end
        if GetLocalPlayer() == Player(0) then
            ClearSelection()
            for _, unit in ipairs(self.army) do SelectUnit(unit, true) end
        end
    end

    function activity:spawnRunner()
        local runnerData = RUNNERS[self.runnerIndex]
        self.runner = JTG.ScopeTrackUnit(session.scope,
            BlzCreateUnitWithSkin(Player(1), runnerData.id, self.startX,
                self.laneY, 0, runnerData.id))
        SetUnitAcquireRange(self.runner, 0)
        PauseUnit(self.runner, true)
        self.previousRunnerX = GetUnitX(self.runner)
        self.previousRunnerY = GetUnitY(self.runner)
    end


    function activity:beginRun()
        self.running = true
        self.countdownActive = false
        self.runnerWaiting = true
        PauseUnit(self.runner, true)
        for _, unit in ipairs(self.army) do PauseUnit(unit, false) end
        BlzFrameSetText(self.countdownFrame, "|cff80ff80GO!|r")
        self:makeTimer(0.65, false, function()
            BlzFrameSetVisible(self.countdownFrame, false)
        end)
        self:makeTimer(2.0, false, function()
            if self.finished then return end
            self.runnerWaiting = false
            PauseUnit(self.runner,
                self.locallyPaused or self.setupsOpen or self.finished)
            IssuePointOrder(self.runner, "move", self.finishX + 300, self.laneY)
        end)
    end

    function activity:countdownTick()
        if self.locallyPaused then return end
        if self.countdownValue > 1 then
            self.countdownValue = self.countdownValue - 1
            BlzFrameSetText(self.countdownFrame, "|cffffcc00" ..
                tostring(self.countdownValue) .. "|r")
        else
            PauseTimer(self.countdownTimer)
            self.countdownValue = 0
            self:beginRun()
        end
    end

    function activity:finish(success, reason)
        if self.finished then return end
        self.finished = true
        self.running = false
        PauseUnit(self.runner, true)
        for _, unit in ipairs(self.army) do PauseUnit(unit, true) end
        self:setSetupsOpen(false)
        local setup, list = self:currentSetup()
        if success then
            self.resultTitleText = "SURROUND COMPLETE"
            self.resultTone = "success"
            if self.runnerIndex == 1 then
                self.resultAction = "next_round"
                self.resultPrimaryLabel = "Next Round"
                self.resultDetailsText =
                    "The Grunt stayed fully surrounded.\nNext: Demon Hunter."
            elseif self.setupIndex < #list then
                self.resultAction = "next_setup"
                self.resultPrimaryLabel = "Next Setup"
                self.resultDetailsText =
                    "Both runners were surrounded with this setup."
            else
                self.resultAction = "finish"
                self.resultPrimaryLabel = "Finish"
                self.resultDetailsText = self.gargoyleMode and
                    "You completed every Gargoyle setup." or
                    "You completed every " .. self.race .. " setup."
            end
        else
            self.resultAction = "retry"
            self.resultPrimaryLabel = "Retry"
            self.resultTitleText = "RUNNER ESCAPED"
            self.resultTone = "failure"
            self.resultDetailsText = reason or
                "The runner reached the finish line."
        end
        self:renderResultPresentation(false)
        if JTG.UI then JTG.UI.HideToolbar() end
        self:makeTimer(1.0, false, function()
            self:renderResultPresentation(self.presentationVisible)
            if success and self.gargoyleMode and #setup.units == 1 and
                    setup.units[1][1] == "ugar" and setup.units[1][2] == 4 then
                self:playCelebration()
            end
        end)
    end

    function activity:update()
        -- Keep diagnostic presentation live during countdowns and other
        -- non-running phases. Reset/Next can preserve Squares: On, so these
        -- images must not wait for the exercise to enter its running state.
        self:updateSquareOverlays()
        if self.locallyPaused or self.setupsOpen or not self.running or
                self.finished then return end
        if GetUnitTypeId(self.runner) == 0 or
                IsUnitType(self.runner, UNIT_TYPE_DEAD) then
            self:finish(false, "The runner was killed before it was surrounded.")
            return
        end
        if self.runnerWaiting then
            return
        end
        self.healElapsed = self.healElapsed + 0.05
        if self.healElapsed >= 2.0 then
            self.healElapsed = self.healElapsed - 2.0
            SetWidgetLife(self.runner, BlzGetUnitMaxHP(self.runner))
        end
        if GetUnitCurrentOrder(self.runner) == 0 then
            IssuePointOrder(self.runner, "move", self.finishX + 300, self.laneY)
        end
        local x, y = GetUnitX(self.runner), GetUnitY(self.runner)
        if x >= self.finishX then
            SetUnitX(self.runner, self.finishX)
            IssueImmediateOrder(self.runner, "stop")
            self:updateSquareOverlays()
            self:finish(false, "The runner crossed the finish line.")
            return
        end
        -- Measure confinement over the whole hold window, rather than each
        -- tick: a trapped runner may keep wiggling inside a small pocket.
        local dx, dy = x - self.previousRunnerX, y - self.previousRunnerY
        local confined = dx * dx + dy * dy <= 32.0 * 32.0
        local disabled = false
        for _, buffId in ipairs(DISABLING_BUFFS) do
            if GetUnitAbilityLevel(self.runner, buffId) > 0 then
                disabled = true
                break
            end
        end
        local activelyMoving = GetUnitCurrentOrder(self.runner) ==
            OrderId("move")
        if confined and activelyMoving and not disabled then
            self.holdTime = self.holdTime + 0.05
        else
            self.holdTime = 0
            self.previousRunnerX, self.previousRunnerY = x, y
        end
        self:updateStatus()
        if self.holdTime >= 3.0 then
            self:finish(true)
        end
    end

    function activity:createTrainingQuests()
        local definitions
        if self.gargoyleMode then
            definitions = {{
                title = "Gargoyle Surrounds",
                icon = "ReplaceableTextures\\CommandButtons\\BTNStoneForm.blp",
                text = GARGOYLE_QUEST_TEXT,
                required = true,
            }}
        else
            definitions = {
            {
                title = "How to Surround",
                icon = "ReplaceableTextures\\CommandButtons\\BTNMassTeleport.blp",
                text = JTG.SurroundHowToQuestText,
                required = true,
            },
            {
                title = "How it works...",
                icon = "ReplaceableTextures\\CommandButtons\\BTNSkillz.blp",
                text = JTG.SurroundHowItWorksQuestText,
                required = false,
            },
            {
                title = "Tip: Mixed Selections",
                icon = "ReplaceableTextures\\CommandButtons\\BTNMove.blp",
                text = JTG.SurroundMixedSelectionsQuestText,
                required = false,
            },
            }
        end
        self.quests = {}
        for _, definition in ipairs(definitions) do
            local quest = JTG.ScopeTrackQuest(session.scope, CreateQuest())
            QuestSetTitle(quest, definition.title)
            QuestSetDescription(quest,
                JTG.FormatSurroundQuestText(definition.text))
            QuestSetIconPath(quest, definition.icon)
            QuestSetRequired(quest, definition.required)
            QuestSetDiscovered(quest, true)
            QuestSetEnabled(quest, true)
            table.insert(self.quests, quest)
        end
    end

    function activity:setup(current)
        self.scene = current.scene
        local p0, p1 = Player(0), Player(1)
        JTG.BorrowCamera(current.scope, p0)
        local oldController = GetPlayerController(p1)
        local oldColor = GetPlayerColor(p1)
        local passive01 = GetPlayerAlliance(p0, p1, ALLIANCE_PASSIVE)
        local passive10 = GetPlayerAlliance(p1, p0, ALLIANCE_PASSIVE)
        JTG.ScopeBorrow(current.scope, function()
            SetPlayerController(p1, oldController)
            SetPlayerColor(p1, oldColor)
            SetPlayerAlliance(p0, p1, ALLIANCE_PASSIVE, passive01)
            SetPlayerAlliance(p1, p0, ALLIANCE_PASSIVE, passive10)
        end)
        SetPlayerController(p1, MAP_CONTROL_COMPUTER)
        SetPlayerColor(p1, ConvertPlayerColor(1))
        SetPlayerAlliance(p0, p1, ALLIANCE_PASSIVE, false)
        SetPlayerAlliance(p1, p0, ALLIANCE_PASSIVE, false)

        -- Unlock non-hero command sets in every preset and Custom selection.
        -- Caster training has two levels; attack/armor upgrades are excluded.
        local abilityResearch = {
            Rhde = 1, Rhfl = 1, Rhcd = 1, Rhpt = 2, Rhst = 2,
            Rhse = 1, Rhfc = 1, Rhrt = 1, Rhfs = 1, Rhss = 1,
            Rhgb = 1, Rhhb = 1, Rhsb = 1, Rhri = 1, Rhan = 1, Rhlh = 2,
            Rhpm = 1, Ropm = 1, Rupm = 1, Repm = 1,
            Roen = 1, Rost = 2, Rowt = 2, Rowd = 2, Rows = 2,
            Robs = 1, Rotr = 1, Ropg = 1, Rosp = 1, Robf = 1,
            Robk = 1, Rolf = 1, Roch = 1, Rovs = 1, Ronv = 1, Rorb = 1,
            Rusf = 1, Ruwb = 1, Rubu = 1, Rusp = 1,
            Rune = 2, Ruba = 2, Rupc = 1, Rusm = 1, Rugf = 1,
            Ruex = 1, Ruac = 1, Rufb = 1,
            Redt = 2, Redc = 2, Resi = 1, Reeb = 1, Reec = 1,
            Rehs = 1, Rers = 1, Rews = 1, Remg = 1, Resc = 1,
            Rewh = 1, Reuv = 1, Recb = 1, Reib = 1, Remk = 1,
            usap = 1, ehip = 1,
        }
        for rawcode, level in pairs(abilityResearch) do
            local upgrade = FourCC(rawcode)
            local oldLevel = GetPlayerTechCount(p0, upgrade, true)
            JTG.ScopeBorrow(current.scope, function()
                SetPlayerTechResearched(p0, upgrade, oldLevel)
            end)
            SetPlayerTechResearched(p0, upgrade, math.max(oldLevel, level))
        end

        JTG.ResetWorldFog(p0)
        JTG.ScopeRevealScene(current.scope, current.scene, p0)

        self.startX = current.scene.centerX - 1200
        self.finishX = current.scene.centerX + 1200
        self.laneY = current.scene.centerY
        self.arenaMinY = current.scene.centerY - 620
        self.arenaMaxY = current.scene.centerY + 620
        self.navigationGridImages = JTG.CreateNavigationGridOverlay(
            session.presentationScope, current.scene)
        self.navigationDotsImages = JTG.CreateNavigationDotsOverlay(
            session.presentationScope, current.scene)
        self:createCourseMarkers()
        self:createTrainingQuests()
        self:createCountdownUI()
        self:createStatusUI()
        self:createResultUI()
        self:createSetupsUI()
        self:spawnRunner()
        self:spawnArmy()
        self:createSquareOverlays()
        self:updateStatus()
        self.updateTimer = self:makeTimer(0.05, true,
            function() self:update() end)
    end

    function activity:start(current)
        if GetLocalPlayer() == Player(0) then
            SetCameraPosition(current.scene.centerX, current.scene.centerY)
        end
        self.countdownActive = true
        self.countdownValue = 3
        BlzFrameSetText(self.countdownFrame, "|cffffcc003|r")
        BlzFrameSetVisible(self.countdownFrame, true)
        self.countdownTimer = self:makeTimer(1.0, true,
            function() self:countdownTick() end)
        if JTG.UI and JTG.UI.SetNextEnabled then
            JTG.UI.SetNextEnabled(self:hasNextRun())
            JTG.UI.SetSquaresActive(self.squaresVisible)
        end
        if not self.skipIntro and JTG.UI and JTG.UI.HighlightQuestButton then
            JTG.UI.HighlightQuestButton(5.0)
        end
    end

    function activity:setPaused(paused)
        self.locallyPaused = paused == true
        if self.runner ~= nil then
            PauseUnit(self.runner, self.locallyPaused or self.setupsOpen or
                self.countdownActive or self.runnerWaiting or self.finished)
        end
        for _, unit in ipairs(self.army) do
            PauseUnit(unit, self.locallyPaused or self.setupsOpen or
                self.countdownActive or self.finished)
        end
    end

    function activity:restorePresentation()
        self.presentationVisible = true
        self:setOverlayVisible(true)
        if self.finished then
            self:renderResultPresentation(true)
            if JTG.UI then JTG.UI.HideToolbar() end
        elseif JTG.UI then
            JTG.UI.ShowToolbar(session.descriptor.capabilities)
            JTG.UI.SetNextEnabled(self:hasNextRun())
            JTG.UI.SetSquaresActive(self.squaresVisible)
        end
    end

    function activity:hidePresentationForMenu()
        self:setOverlayVisible(false)
        JTG.UI.HideResultCard(self.resultCard)
    end

    function activity:rebuildPresentation()
        self.countdownFrame = nil
        self.statusFrame = nil
        self.resultCard = nil
        self.resultPanel = nil
        self.setupsPanel = nil
        self.startLine = nil
        self.finishLine = nil
        self.startTag = nil
        self.finishTag = nil
        self.squareEntries = {}
        self.navigationGridImages = JTG.CreateNavigationGridOverlay(
            session.presentationScope, self.scene)
        self.navigationDotsImages = JTG.CreateNavigationDotsOverlay(
            session.presentationScope, self.scene)
        self:createCourseMarkers()
        self:createCountdownUI()
        self:createStatusUI()
        self:createResultUI()
        self:createSetupsUI()
        self:createSquareOverlays()
        self:updateStatus()
        if self.finished then
            self:renderResultPresentation(true)
        end
        self:setOverlayVisible(true)
    end

    function activity:discardPresentationForLoad()
        self.resultCard = nil
        self.resultPanel = nil
        if self.startLine ~= nil then DestroyLightning(self.startLine) end
        if self.finishLine ~= nil then DestroyLightning(self.finishLine) end
        if self.startTag ~= nil then DestroyTextTag(self.startTag) end
        if self.finishTag ~= nil then DestroyTextTag(self.finishTag) end
        for _, entry in ipairs(self.squareEntries or {}) do
            for _, image in pairs(entry.images or {}) do DestroyImage(image) end
        end
        for _, image in ipairs(self.navigationGridImages or {}) do
            DestroyImage(image)
        end
        for _, image in ipairs(self.navigationDotsImages or {}) do
            DestroyImage(image)
        end
        self.startLine = nil
        self.finishLine = nil
        self.startTag = nil
        self.finishTag = nil
        self.squareEntries = {}
        self.navigationGridImages = {}
        self.navigationDotsImages = {}
    end

    function activity:cleanup()
        self.army = {}
        self.runner = nil
        self.quests = {}
    end

    return activity
end

function JTG.CreateSurroundsActivity(session)
    return CreateSurroundsActivity(session, false)
end

function JTG.CreateGargoyleSurroundActivity(session)
    return CreateSurroundsActivity(session, true)
end
