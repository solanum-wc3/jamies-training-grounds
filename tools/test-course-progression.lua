-- Exercise real factories and progression methods, without simulating pathfinding.
JTG = {UI = {}}
function FourCC(raw) return raw end
function Player(index) return index end
function GetRandomInt(low) return low end
function BlzFrameSetVisible() end
function JTG.UI.HideToolbar() end
local cards, resets = {}, 0
function JTG.UI.ShowResultCard(_, spec) cards[#cards + 1] = spec end
function JTG.ResetActivity() resets = resets + 1 end
dofile('src/activities/body-blocking.lua')
dofile('src/activities/windwalk-pop.lua')

for race, size in pairs({human=6, orc=6, nightelf=5, undead=5}) do
    local results = {}
    for index = 1, size do
        local route = {{x=1,y=2}}
        local run = JTG.CreateBodyBlockingActivity({restartData={
            mode='training', race=race, runnerIndex=index,
            raceResults=results, routeTemplate=route,
            squaresVisible=true, squareGridVisible=true}})
        run.runnerName, run.runnerFinishElapsed, run.referenceFinishElapsed = 'Runner', 20, 12
        run.collisionCount, run.bestStreak = 3, 2.5
        run.resultCard, run.resultTitleText = {}, 'placeholder'
        function run:pauseRound() self.paused = true end
        function run:setOverlayVisible() end
        assert(run:captureResetState().routeTemplate == route)
        assert(run:captureResetState().runnerIndex == index)
        run:finishRun(false)
        assert(run.paused and run.finished and results[index].score == 53)
        assert(results[index].delay == 8 and results[index].contacts == 3)
        assert(run.raceComplete == (index == size))
        local rendered = #cards
        run:finishRun(true)
        assert(#cards == rendered and results[index].score == 53, 'Finish applied twice')
        local state = run:captureResetState()
        assert(state.runnerIndex == (index == size and 1 or index + 1))
        assert(state.routeTemplate == nil and state.raceResults == results)
        assert(state.squaresVisible and state.squareGridVisible)
        run.replaying = true
        assert(run:captureResetState().runnerIndex == index, 'Replay advanced runner')
        run.replaying = false
        local previous = run:captureLastRunnerState()
        assert((index == 1 and previous == nil) or previous.runnerIndex == index - 1)
        local before = resets
        assert(run:nextStage() == (index < size))
        assert(resets == before + (index < size and 1 or 0))
    end
    assert(#results == size)
end
local custom = JTG.CreateBodyBlockingActivity({restartData={mode='custom', runnerId='hfoo'}})
custom.advancePending = true
assert(custom:captureResetState().runnerIndex == 1 and not custom:nextStage())

-- Carry state is copied, so editing a pending restart cannot mutate the old run.
for _, mode in ipairs({'hard', 'counterplay'}) do
    local input = {mode=mode, courseOrder={4,2,1,3}, courseResults={'success'},
        courseStage=2, counterplayDifficulty='hard', squaresVisible=true}
    local run = JTG.CreateWindwalkPopActivity({restartData=input})
    assert(run.courseOrder ~= input.courseOrder and run.courseResults ~= input.courseResults)
    local state = run:captureResetState()
    assert(state.mode == mode and state.courseStage == 2 and state.courseOrder[1] == 4)
    assert(state.courseOrder ~= run.courseOrder and state.courseResults ~= run.courseResults)
    state.courseOrder[1] = 1
    assert(run.courseOrder[1] == 4)
    assert(run:captureLastRunnerState().courseStage == 1)
end
for _, stage in ipairs({-2, 1, 10, 99}) do
    local run = JTG.CreateWindwalkPopActivity({restartData={mode='timed', timedStage=stage}})
    assert(run.timedStage == math.max(1, math.min(10, stage)))
    assert(run:captureResetState().timedStage == run.timedStage)
end
print('Passed: Body Blocking roster progression/replay boundaries and Windwalk course/timed carry state.')

-- Keep the real delayed-result flow, including returning before/after expiry.
local delayed, delayCount = nil, 0
function CreateTimer() return {} end
function JTG.ScopeTrackTimer(_, timer) return timer end
function JTG.GuardSession(_, callback) return callback end
function TimerStart(timer, delay, repeating, callback)
    assert(delay==1 and not repeating, 'Windwalk result delay changed')
    delayCount=delayCount+1;timer.callback=callback;delayed=timer
end
function JTG.ShowNavigationGrid() end
function JTG.UI.HideResultCard(card) card.visible=false end
function JTG.UI.ShowResultCard(card, spec)
    cards[#cards+1]=spec;card.visible=spec.visible~=false
end
local run=JTG.CreateWindwalkPopActivity({scope={}})
run.resultCard={visible=false}
run:finish('success','Test result','Test details')
assert(run.resultPending and not run.resultCard.visible and delayCount==1)
run:hidePresentationForMenu();run:restorePresentation()
assert(run.resultPending and not run.resultCard.visible,
    'Returning before the delay expired showed the result early')
run:hidePresentationForMenu();delayed.callback()
assert(not run.resultPending and not run.resultCard.visible,
    'Delayed result became visible over a menu')
run:restorePresentation()
assert(run.resultCard.visible and cards[#cards].title=='Test result')
run:hidePresentationForMenu();run:restorePresentation()
run:finish('failure','Incorrect replacement','')
assert(run.resultCard.visible and run.resultTitleText=='Test result' and delayCount==1,
    'Presentation restoration replayed completion or restarted its delay')
local normal=JTG.CreateWindwalkPopActivity({scope={}})
normal.resultCard={visible=false}
normal:finish('success','Normal result','')
assert(not normal.resultCard.visible)
delayed.callback();assert(normal.resultCard.visible, 'Visible delayed result never appeared')
print('Passed: Windwalk keeps its result delay, stays hidden behind menus and restores the saved result on return.')
