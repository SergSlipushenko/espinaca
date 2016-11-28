local now = tmr.now; _start = now(); timeit = function() return (now()-_start)/1000 end
go = function() return pcall(dofile,'main.lua') end
local _go = function()
    if file.exists('main.lock') then print('main locked') return end 
    local ok, err = go(); if not(ok) then print(err) end end
local _, r = node.bootreason(); 
if (r == 5) or (r == 6 and rtctime and rtctime.get() ~= 0) then go()
elseif (rtcfifo and rtcfifo.ready() == 0) then _go()
else local tt =tmr.create(); tt:alarm(5000, tmr.ALARM_SINGLE, _go) end
