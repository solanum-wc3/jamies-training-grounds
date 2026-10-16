JTG={UI={}}
dofile('src/infrastructure/training.lua')
local callbacks={}
function JTG.StartScopedTimer(_,_,_,_,fn)
    local timer={fn=fn};callbacks[#callbacks+1]=timer;return timer
end
function PauseTimer(timer) timer.paused=true end
local ticks,starts={},0
local a={finished=false}
local timer=JTG.Training.Countdown(a,{scope={}},3,function(n) ticks[#ticks+1]=n end,
    function() starts=starts+1 end)
a.locallyPaused=true;timer.fn();assert(#ticks==1 and starts==0)
a.locallyPaused=false
timer.fn();timer.fn();timer.fn()
assert(table.concat(ticks,',')=='3,2,1' and starts==1 and timer.paused)
local cancelled=JTG.Training.Countdown(a,{scope={}},3,function() end,
    function() starts=starts+1 end)
a.finished=true;cancelled.fn()
assert(cancelled.paused and starts==1,'Finished activity started a new battle')
print('Passed: shared three-second countdown and finished-activity cancellation.')
