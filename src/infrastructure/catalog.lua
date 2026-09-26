-- Declarative content catalogue. Planned entries intentionally have no factory.
JTG = JTG or {}

JTG.Categories = {
    {id = "learn", title = "Learn to Play", summary = "Warcraft III controls and fundamentals.", artwork = "JTGMenu\\LearnToPlay.dds"},
    {id = "advanced", title = "Advanced Play", summary = "Competitive strategy, planning and decision-making.", artwork = "JTGMenu\\AdvancedPlay.dds"},
    {id = "skills", title = "Skill Training", summary = "Focused exercises for mechanical skills.", artwork = "JTGMenu\\SkillTraining.dds"},
    {id = "tools", title = "Tools & Extras", summary = "Analysis tools, demonstrations, quizzes and games.", artwork = "JTGMenu\\ToolsExtras.dds"},
}

JTG.RegisterScene({
    id = "arena.south", centerX = 4864, centerY = 3456,
    minX = 2048, minY = 2048, maxX = 7808, maxY = 4864,
})
JTG.RegisterScene({
    id = "arena.north", centerX = 4864, centerY = 6016,
    minX = 2048, minY = 4864, maxX = 7808, maxY = 7552,
})

local planned = {
    {"learn.camera", "learn", "Camera & Interface", "Move, pan, zoom and orient the camera."},
    {"learn.selection", "learn", "Unit Selection & Commands", "Select units, form groups and issue orders."},
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

    {"skills.surround", "skills", "Surrounds", "Trap a target with coordinated movement.", "JTGMenu\\Surrounds.dds"},
    {"skills.bat_splitter", "skills", "Bat Splitter", "Split vulnerable air units under pressure.", "JTGMenu\\BatSplitter.dds"},
    {"skills.micro", "skills", "Micro Training", "Control mixed armies efficiently."},
    {"skills.gold_mine", "skills", "Gold Mine Micro", "Optimize workers around a contested mine.", "JTGMenu\\GoldMineMicro.dds"},
    {"skills.staffing", "skills", "Staffing Units", "Save and reposition units with a Staff."},
    {"skills.zeppelin", "skills", "Zeppelin Micro", "Load, unload and protect transported units."},
    {"skills.reflex", "skills", "Reflex Training", "React quickly and accurately to visual targets."},
    {"skills.lab_creep", "skills", "Goblin Lab Creeping", "Practice a Goblin Laboratory creep route."},
    {"skills.aow_creep", "skills", "AoW Creeping", "Practice Ancient of War creeping.", "JTGMenu\\AoWCreeping.dds"},
    {"skills.gargoyle", "skills", "Gargoyle Surround", "Surround targets with flying units."},
    {"skills.merc_creep", "skills", "Merc Camp Creeping", "Practice a Mercenary Camp creep route."},
    {"skills.windwalk", "skills", "Windwalk Pop", "Use collision timing to displace units."},

    {"tools.demo", "tools", "Demo Mode", "Explore units and mechanics freely.", "JTGMenu\\DemoMode.dds"},
    {"tools.hotkeys", "tools", "Hotkey Trainer", "Learn command-card and inventory hotkeys.", "JTGMenu\\HotkeyTraining.dds"},
    {"tools.quiz", "tools", "Warcraft III Quiz", "Test knowledge of units and mechanics."},
    {"tools.compare", "tools", "Unit Comparison", "Compare unit statistics and interactions.", "JTGMenu\\UnitComparison.dds"},
}

JTG.RegisterActivity({
    id = "skills.body_blocking",
    category = "skills",
    title = "Body Blocking",
    description = "Stay in front of a runner and use unit collision to delay it.",
    artwork = "JTGMenu\\BodyBlocking.dds",
    status = "available",
    sceneId = "arena.south",
    capabilities = {restart = true, menu = true},
    menu = JTG.OpenBodyBlockingMenu,
    factory = JTG.CreateBodyBlockingActivity,
})

for _, entry in ipairs(planned) do
    JTG.RegisterActivity({
        id = entry[1], category = entry[2], title = entry[3], description = entry[4],
        artwork = entry[5], status = "planned", capabilities = {},
    })
end
