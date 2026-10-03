-- Placeholder briefing for the redesigned Surrounds training. Gameplay is
-- intentionally unavailable until the new exercise specification is ready.
JTG = JTG or {}

local SURROUNDS_PLACEHOLDER =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit.|n" ..
    "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.|n|n" ..
    "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris."

function JTG.OpenSurroundsMenu(originCategory)
    JTG.UI.ShowActivityBriefing({
        title = "Surrounds",
        activityId = "skills.surround",
        originCategory = originCategory or "skills",
        headingArtwork = "JTGMenu\\SurroundsBriefing.dds",
        headingArtworkWidth = 0.176,
        headingArtworkHeight = 0.086,
        headingArtworkOffsetX = -0.065,
        body = SURROUNDS_PLACEHOLDER,
        choices = {
            {label = "Start Training", primary = true, enabled = false},
            {label = "Custom", enabled = false},
        },
        backAction = function() JTG.UI.ShowCategory(originCategory or "skills") end,
        pageId = "root",
    })
end
