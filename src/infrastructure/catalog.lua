-- Declarative content catalogue. Planned entries intentionally have no factory.
JTG = JTG or {}

JTG.Categories = {
    {id = "learn", title = "Learn to Play", summary = "Warcraft III controls and fundamentals.",
        description = "This series of tutorials will teach you the fundamentals of Warcraft III controls and gameplay. If you are new to the game, this is a good place to start!",
        artwork = "JTGMenu\\LearnToPlay.dds"},
    {id = "advanced", title = "Advanced Play", summary = "Competitive strategy, planning and decision-making.",
        description = "This series of tutorials will teach you about more advanced and specific aspects of Warcraft III. Once you know the absolute fundamentals, this is where you should continue, if you want to play in multiplayer.",
        artwork = "JTGMenu\\AdvancedPlay.dds"},
    {id = "skills", title = "Skill Training", summary = "Focused exercises for specific mechanical skills.",
        description = "These are focused exercises to practice very specific mechanical skills. You should have a grasp of the fundamentals before you practice them.",
        artwork = "JTGMenu\\SkillTraining.dds"},
    {id = "tools", title = "Tools & Extras", summary = "Analysis tools, demonstrations, quizzes and games.",
        description = "This section contains analysis tools, demonstrations, quizzes and games.",
        artwork = "JTGMenu\\ToolsExtras.dds"},
}

JTG.Races = {
    {id = "human", title = "Human", artwork = "UI\\Glues\\Loading\\Backgrounds\\Campaigns\\HumanSymbol.dds"},
    {id = "orc", title = "Orc", artwork = "UI\\Glues\\Loading\\Backgrounds\\Campaigns\\OrcSymbol.dds"},
    {id = "undead", title = "Undead", artwork = "UI\\Glues\\Loading\\Backgrounds\\Campaigns\\UndeadSymbol.dds"},
    {id = "nightelf", title = "Night Elf", artwork = "UI\\Glues\\Loading\\Backgrounds\\Campaigns\\NightElfSymbol.dds"},
}
-- Compatibility name for activity modules written before race menus became
-- shared by more than Skill Training.
JTG.SkillRaces = JTG.Races

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
    {"learn.economy", "learn", "4. Economy\n& Workers", "Learn how to gather and manage your resources.", "JTGMenu\\EconomyAndWorkers.dds"},
    {"learn.heroes", "learn", "5. Heroes", "Learn hero growth, skills and revival."},
    {"learn.combat", "learn", "6. Combat", "Understand focus fire, counters and damage."},
    {"learn.creeping", "learn", "7. Creeping", "Fight neutral camps and use their rewards."},
    {"learn.base", "learn", "8. The Base", "Construct buildings and advance through technology."},

    {"advanced.build_orders", "advanced", "Build Orders", "Practice race-specific openings and timings."},
    {"advanced.base_layouts", "advanced", "Base Layouts", "Plan building placement for defense and movement."},
    {"advanced.scouting", "advanced", "Scouting & Information", "Find information and act on what you learn."},
    {"advanced.expansions", "advanced", "Expansions & Timing", "Choose when and where to expand."},
    {"advanced.composition", "advanced", "Army Composition", "Adapt units and upgrades to the opponent."},
    {"advanced.matchups", "advanced", "Matchup Plans", "Develop plans for common race matchups."},

    {"skills.micro", "skills", "Combat Micro", "Control mixed armies efficiently.", "JTGMenu\\CombatMicro.dds"},
    {"skills.staffing", "skills", "Staffing Units", "Save and reposition units with a Staff.", nil, {"human", "nightelf"}, {
        human = "JTGMenu\\StaffingHuman.dds",
        nightelf = "JTGMenu\\StaffingNightElf.dds",
    }},
    {"skills.merc_creep", "advanced", "Merc Camp Creeping", "Practice a Mercenary Camp creep route.", nil, {"human"}},
    {"skills.lab_creep", "advanced", "Goblin Lab Creeping", "Practice a Goblin Laboratory creep route.", nil, {"human"}},
    {"skills.aow_creep", "advanced", "AoW Creeping", "Practice Ancient of War creeping.", "JTGMenu\\AoWCreeping.dds", {"nightelf"}},
    {"skills.peon_micro", "skills", "Peon Micro", "Practice Peon movement and survival under pressure.", "JTGMenu\\PeonMicro.dds", {"orc"}},
    {"skills.wisp_micro", "skills", "Wisp Micro", "Practice Wisp movement and survival under pressure.", "JTGMenu\\WispMicro.dds", {"nightelf"}},
    {"skills.zeppelin", "skills", "Zeppelin Micro", "Load, unload and protect transported units.", "JTGMenu\\ZeppelinMicro.dds"},

    {"tools.demo", "tools", "Demo Mode", "Explore units and mechanics freely.", "JTGMenu\\DemoMode.dds"},
    {"tools.hotkeys", "tools", "Hotkey Trainer", "Learn command-card and inventory hotkeys.", "JTGMenu\\HotkeyTraining.dds"},
    {"tools.quiz", "tools", "Warcraft III Quiz", "Test knowledge of units and mechanics."},
    {"tools.compare", "tools", "Unit Comparison", "Compare unit statistics and interactions.", "JTGMenu\\UnitComparison.dds"},
}

JTG.RegisterActivity({
    id = "skills.reflex", category = "skills", title = "Reflex Training",
    description = "Find the requested units in a moving crowd.",
    artwork = "JTGMenu\\ReflexTraining.dds", status = "available", sceneId = "arena.south",
    cameraDistance = 1650,
    capabilities = {restart = true, menu = true, pause = true, quests = false},
    menu = JTG.OpenReflexTrainingMenu, factory = JTG.CreateReflexTrainingActivity,
})

JTG.RegisterActivity({
    id = "skills.bat_splitter", category = "skills", title = "Bat Splitting",
    description = "Split Gryphon Riders apart to avoid Unstable Concoction splash damage.",
    artwork = "JTGMenu\\BatSplitter.dds", races = {"human"},
    status = "available", sceneId = "arena.south",
    capabilities = {restart = true, next = true, menu = true, pause = true, quests = false},
    menu = JTG.OpenBatSplittingMenu, factory = JTG.CreateBatSplittingActivity,
})

JTG.RegisterActivity({
    id = "skills.missile_dodging", category = "skills", title = "Dodging",
    description = "Test dodge methods against attacks, missiles, artillery and area spells.",
    artwork = "JTGMenu\\MissileDodging.dds", status = "available", sceneId = "arena.south",
    capabilities = {restart = true, next = true, menu = true, pause = true, quests = false},
    menu = JTG.OpenMissileDodgingMenu, factory = JTG.CreateMissileDodgingActivity,
})

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
    description = "Learn how to use and customize your hotkey layout.",
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
    races = {"human", "orc"},
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
    description = "Stop a unit completely through collision, by surrounding it with your own.",
    artwork = "JTGMenu\\Surrounds.dds",
    status = "available",
    sceneId = "arena.south",
    capabilities = {restart = true, menu = true, pause = true,
        setups = true, next = true, squares = true, quests = true},
    menu = JTG.OpenSurroundsMenu,
    factory = JTG.CreateSurroundsActivity,
})

JTG.RegisterActivity({
    id = "skills.gargoyle",
    category = "skills",
    title = "Gargoyle Surrounds",
    menuOrder = 30,
    description = "Turn flying Gargoyles into a ground surround with Stone Form.",
    artwork = "JTGMenu\\GargoyleSurrounds.dds",
    artworkWidth = 0.060,
    artworkHeight = 0.048,
    races = {"undead"},
    status = "available",
    sceneId = "arena.south",
    capabilities = {restart = true, menu = true, pause = true,
        setups = true, next = true, squares = true, quests = true},
    menu = JTG.OpenGargoyleSurroundMenu,
    factory = JTG.CreateGargoyleSurroundActivity,
})

JTG.RegisterActivity({
    id = "skills.windwalk",
    category = "skills",
    title = "Windwalk Pop",
    description = "Use Wind Walk to free surrounded units.",
    artwork = "JTGMenu\\WindwalkPop.dds",
    artworkWidth = 0.15223,
    artworkHeight = 0.048,
    artworkOffsetX = 0.014885,
    centerArtwork = true,
    races = {"orc"},
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
    description = "Slow down a unit through collision, by having one of your own stay in front of it.",
    artwork = "JTGMenu\\BodyBlocking.dds",
    status = "available",
    sceneId = "arena.south",
    capabilities = {restart = true, menu = true, lastRunner = true,
        next = true, pause = true, squares = true, quests = true},
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
        artwork = entry[5], races = entry[6], artworkByRace = entry[7],
        status = "planned", capabilities = {},
    })
end

JTG.Registry.byId["learn.economy"].artworkWidth = 0.0585
JTG.Registry.byId["learn.economy"].artworkHeight = 0.0585
JTG.Registry.byId["learn.economy"].artworkOffsetX = -0.009
JTG.Registry.byId["learn.economy"].cardTitle = "4. Economy\n    & Workers"

for index, id in ipairs({"learn.camera", "learn.unit_controls", "learn.hotkey_setup",
    "learn.economy", "learn.heroes", "learn.combat", "learn.creeping", "learn.base"}) do
    JTG.Registry.byId[id].menuOrder = index
end

local skillColumns = {
    {"skills.body_blocking", "skills.surround", "skills.missile_dodging",
        "skills.micro", "skills.reflex"},
    {"skills.zeppelin", "skills.gold_mine", "skills.bat_splitter", "skills.staffing"},
    {"skills.gargoyle", "skills.windwalk", "skills.peon_micro", "skills.wisp_micro"},
}
for column, ids in ipairs(skillColumns) do
    for row, id in ipairs(ids) do
        local descriptor = JTG.Registry.byId[id]
        descriptor.menuOrder = (column - 1) * 5 + row
        descriptor.catalogueColumn = column - 1
        descriptor.catalogueRow = row - 1
    end
end

local economy=JTG.Registry.byId["learn.economy"]
economy.status="available"
economy.sceneId="tutorial.camera"
economy.factory=JTG.CreateEconomyTutorialActivity
economy.capabilities={menu=true,pause=true}
