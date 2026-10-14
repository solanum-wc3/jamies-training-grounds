-- Verify the real registry and authored briefing rather than an invented layout.
JTG={}
function FourCC(raw) assert(type(raw)=='string' and #raw==4);return raw end
dofile('src/infrastructure/core.lua')
local menu
JTG.UI={ShowActivityBriefing=function(spec) menu=spec end,
    SetGameplayMenuPaused=function() end,ShowCategory=function() end}
dofile('src/activities/surrounds.lua')
dofile('src/infrastructure/catalog.lua')
local occupied,count={},0
for _,entry in ipairs(JTG.GetActivities('skills')) do
    local col,row=entry.catalogueColumn,entry.catalogueRow
    assert(col and row and col>=0 and col<3 and row>=0 and row<5,'Skill button outside standard grid: '..entry.id)
    local cell=col..':'..row
    assert(not occupied[cell],'Overlapping Skill Training buttons: '..entry.id..' and '..tostring(occupied[cell]))
    occupied[cell]=entry.id;count=count+1
end
assert(count==14,'Unexpected Skill Training button count')
assert(not JTG.Registry.byId['skills.power_build_micro'],'Removed placeholder is still registered')
assert(JTG.Registry.byId['skills.animation_cancel'].title=='Cancel Micro')
assert(JTG.Registry.byId['skills.reflex'].description==
    'Train your hand-eye coordination and your ability to read a battlefield!')
assert(JTG.Registry.byId['learn.heroes'].artwork=='JTGMenu\\HeroesTutorial.dds')
assert(JTG.Registry.byId['skills.reflex'].status=='available' and JTG.Registry.byId['skills.reflex'].cardStatus=='WIP')
JTG.OpenSurroundsMenu('skills',false)
assert(menu.body:find('|cffffcc00using your own units and their abilities|r',1,true),
    'Authored Yellow Font cue was not formatted on the actual briefing')
assert(not menu.body:find('{Yellow Font:',1,true),'Raw formatting cue remains visible')
assert(menu.body:find('\n\n',1,true),'Briefing paragraph breaks were lost')
assert(JTG.FormatSurroundQuestText('{Yellow Font: yellow} {Gold Font: gold} {Term: term}')==
    '|cffffcc00yellow|r |cffffcc00gold|r |cffff9933term|r')
print('Passed: real catalogue has no overlapping skill buttons, correct placeholders/tooltip and formatted Surrounds briefing.')

local art=JTG.Registry.byId['learn.heroes']
assert(art.artworkAlignTop and math.abs(art.artworkWidth-.096*1.2)<1e-9 and math.abs(art.artworkHeight-.048*1.2)<1e-9)
