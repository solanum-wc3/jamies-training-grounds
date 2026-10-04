-- Declarative content catalogue. Planned entries intentionally have no factory.
JTG = JTG or {}

JTG.Categories = {
    {id = "learn", title = "Learn to Play", summary = "Warcraft III controls and fundamentals.", artwork = "JTGMenu\\LearnToPlay.dds"},
    {id = "advanced", title = "Advanced Play", summary = "Competitive strategy, planning and decision-making.", artwork = "JTGMenu\\AdvancedPlay.dds"},
    {id = "skills", title = "Skill Training", summary = "Focused exercises for mechanical skills.", artwork = "JTGMenu\\SkillTraining.dds"},
    {id = "tools", title = "Tools & Extras", summary = "Analysis tools, demonstrations, quizzes and games.", artwork = "JTGMenu\\ToolsExtras.dds"},
}

JTG.SkillRaces = {
    {id = "human", title = "Human", artwork = "UI\\Glues\\Loading\\Backgrounds\\Campaigns\\HumanSymbol.dds"},
    {id = "orc", title = "Orc", artwork = "UI\\Glues\\Loading\\Backgrounds\\Campaigns\\OrcSymbol.dds"},
    {id = "undead", title = "Undead", artwork = "UI\\Glues\\Loading\\Backgrounds\\Campaigns\\UndeadSymbol.dds"},
    {id = "nightelf", title = "Night Elf", artwork = "UI\\Glues\\Loading\\Backgrounds\\Campaigns\\NightElfSymbol.dds"},
}

JTG.RegisterScene({
    id = "arena.south", centerX = 4864, centerY = 3456,
    minX = 2048, minY = 2048, maxX = 7808, maxY = 4864,
})
JTG.RegisterScene({
    id = "arena.north", centerX = 4864, centerY = 6016,
    minX = 2048, minY = 4864, maxX = 7808, maxY = 7552,
})
JTG.RegisterScene({
    -- Preserved Twisted Meadows terrain at the imported main Orc base.
    id = "tutorial.camera", centerX = 3648, centerY = -5120,
})

local planned = {
    {"learn.economy", "learn", "Workers & Resources", "Gather resources and keep workers productive."},
    {"learn.base", "learn", "Build Your Base", "Place and construct the buildings you need."},
    {"learn.units", "learn", "Units & Food", "Train an army and manage the food limit."},
    {"learn.heroes", "learn", "Heroes & Levels", "Learn hero growth, skills and revival."},
    {"learn.creeping", "learn", "Creeping & Items", "Fight neutral camps and use their rewards."},
    {"learn.combat", "learn", "Combat & Counters", "Understand focus fire, counters and damage."},
    {"learn.tech", "learn", "Tech & Upkeep", "Advance your tech and manage upkeep."},

    {"advanced.build_orders", "advanced", "Build Orders", "Practice race-specific openings and timings."},
    {"advanced.base_layouts", "advanced", "Base Layouts", "Plan building placement for defense and movement."},
    {"advanced.scouting", "advanced", "Scouting & Information", "Find information and act on what you learn."},
    {"advanced.expansions", "advanced", "Expansions & Timing", "Choose when and where to expand."},
    {"advanced.composition", "advanced", "Army Composition", "Adapt units and upgrades to the opponent."},
    {"advanced.matchups", "advanced", "Matchup Plans", "Develop plans for common race matchups."},

    {"skills.bat_splitter", "skills", "Bat Splitter", "Split vulnerable air units under pressure.", "JTGMenu\\BatSplitter.dds"},
    {"skills.missile_dodging", "skills", "Missile Dodging", "Avoid incoming projectiles with precise movement and timing.", "JTGMenu\\MissileDodging.dds"},
    {"skills.micro", "skills", "Micro Training", "Control mixed armies efficiently."},
    {"skills.staffing", "skills", "Staffing Units", "Save and reposition units with a Staff.", nil, {"human", "nightelf"}, {
        human = "JTGMenu\\StaffingHuman.dds",
        nightelf = "JTGMenu\\StaffingNightElf.dds",
    }},
    {"skills.merc_creep", "skills", "Merc Camp Creeping", "Practice a Mercenary Camp creep route.", nil, {"human"}},
    {"skills.lab_creep", "skills", "Goblin Lab Creeping", "Practice a Goblin Laboratory creep route.", nil, {"human"}},
    {"skills.gargoyle", "skills", "Gargoyle Surround", "Surround targets with flying units.", nil, {"undead"}},
    {"skills.aow_creep", "skills", "AoW Creeping", "Practice Ancient of War creeping.", "JTGMenu\\AoWCreeping.dds", {"nightelf"}},
    {"skills.peon_micro", "skills", "Peon Micro", "Practice Peon movement and survival under pressure.", "JTGMenu\\PeonMicro.dds", {"orc"}},
    {"skills.wisp_micro", "skills", "Wisp Micro", "Practice Wisp movement and survival under pressure.", "JTGMenu\\WispMicro.dds", {"nightelf"}},
    {"skills.zeppelin", "skills", "Zeppelin Micro", "Load, unload and protect transported units.", "JTGMenu\\ZeppelinMicro.dds"},
    {"skills.reflex", "skills", "Reflex Training", "React quickly and accurately to visual targets.", "JTGMenu\\ReflexTraining.dds"},

    {"tools.demo", "tools", "Demo Mode", "Explore units and mechanics freely.", "JTGMenu\\DemoMode.dds"},
    {"tools.hotkeys", "tools", "Hotkey Trainer", "Learn command-card and inventory hotkeys.", "JTGMenu\\HotkeyTraining.dds"},
    {"tools.quiz", "tools", "Warcraft III Quiz", "Test knowledge of units and mechanics."},
    {"tools.compare", "tools", "Unit Comparison", "Compare unit statistics and interactions.", "JTGMenu\\UnitComparison.dds"},
}

JTG.RegisterActivity({
    id = "learn.camera",
    category = "learn",
    title = "1. Camera",
    description = "Learn how to move, zoom and quickly reposition the camera.",
    artwork = "JTGMenu\\CameraControls.dds",
    labelInset = 0.022,
    status = "available",
    sceneId = "tutorial.camera",
    capabilities = {menu = false, pause = false, quests = true},
    factory = JTG.CreateCameraTutorialActivity,
})

JTG.RegisterActivity({
    id = "learn.unit_controls",
    category = "learn",
    title = "2. Unit Controls",
    description = "Learn how to select units, read their interface and use their abilities.",
    artwork = "JTGMenu\\UnitControls.dds",
    labelInset = 0.022,
    status = "available",
    sceneId = "arena.south",
    capabilities = {menu = false, pause = false, quests = false},
    factory = JTG.CreateUnitControlsTutorialActivity,
})

JTG.RegisterActivity({
    id = "learn.hotkey_setup",
    category = "learn",
    title = "3. Hotkey Setup",
    description = "Compare hotkey layouts and export editable QWERTY or QWERTZ bindings.",
    artwork = "JTGMenu\\HotkeySetup.dds",
    artworkWidth = 0.08625,
    artworkHeight = 0.048,
    artworkOffsetX = 0.050875,
    centerArtwork = true,
    labelInset = 0.022,
    status = "available",
    sceneId = "arena.south",
    capabilities = {menu = false, pause = false, quests = false},
    factory = JTG.CreateHotkeySetupTutorialActivity,
})

JTG.RegisterActivity({
    id = "skills.gold_mine",
    category = "skills",
    title = "Mining Micro",
    description = "Optimize four-worker gold mining against fixed reference economies.",
    artwork = "JTGMenu\\GoldMineMicro.dds",
    skillRaces = {"human", "orc"},
    status = "available",
    sceneId = "arena.north",
    capabilities = {restart = true, rotate = true, menu = true, pause = true, quests = true},
    menu = JTG.OpenMiningMicroMenu,
    factory = JTG.CreateMiningMicroActivity,
})

JTG.RegisterActivity({
    id = "skills.surround",
    category = "skills",
    title = "Surrounds",
    menuOrder = 20,
    description = "Trap a target with coordinated movement.",
    artwork = "JTGMenu\\Surrounds.dds",
    status = "available",
    sceneId = "arena.south",
    capabilities = {restart = true, menu = true, pause = true,
        setups = true, next = true, squares = true, quests = true},
    menu = JTG.OpenSurroundsMenu,
    factory = JTG.CreateSurroundsActivity,
})

JTG.RegisterActivity({
    id = "skills.windwalk",
    category = "skills",
    title = "Windwalk Pop",
    description = "Use Wind Walk collision to free a surrounded Grunt.",
    artwork = "JTGMenu\\WindwalkPop.dds",
    artworkWidth = 0.15223,
    artworkHeight = 0.048,
    artworkOffsetX = 0.014885,
    centerArtwork = true,
    skillRaces = {"orc"},
    status = "available",
    sceneId = "arena.north",
    capabilities = {restart = true, menu = true, pause = true, quests = true,
        squares = true},
    menu = JTG.OpenWindwalkPopMenu,
    factory = JTG.CreateWindwalkPopActivity,
})

JTG.RegisterActivity({
    id = "skills.body_blocking",
    category = "skills",
    title = "Body Blocking",
    menuOrder = 10,
    description = "Stay in front of a runner and use unit collision to delay it.",
    artwork = "JTGMenu\\BodyBlocking.dds",
    status = "available",
    sceneId = "arena.south",
    capabilities = {restart = true, menu = true, lastRunner = true, pause = true, quests = true},
    menu = JTG.OpenBodyBlockingMenu,
    factory = JTG.CreateBodyBlockingActivity,
})

JTG.RegisterActivity({
    id = "tools.power_building",
    category = "tools",
    title = "Power Building",
    description = "Compare how additional Peasants affect construction time and resource cost.",
    artwork = "JTGMenu\\PowerBuilding.dds",
    status = "available",
    sceneId = "arena.south",
    capabilities = {menu = true, pause = true, quests = true},
    menu = JTG.OpenPowerBuildingMenu,
    factory = JTG.CreatePowerBuildingActivity,
})

for _, entry in ipairs(planned) do
    JTG.RegisterActivity({
        id = entry[1], category = entry[2], title = entry[3], description = entry[4],
        artwork = entry[5], skillRaces = entry[6], artworkByRace = entry[7],
        status = "planned", capabilities = {},
    })
end
