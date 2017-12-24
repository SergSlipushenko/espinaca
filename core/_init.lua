if wifi then wifi.setmode(wifi.NULLMODE) end
local now = tmr.now; _start = now(); timeit = function() return (now()-_start)/1000 end
go = function() return pcall(dofile,'main.lua') end
local _go = function()
    if file.exists('_lock.lua') then print('main locked') return end 
    local ok, err = go(); if not(ok) then print(err) end end
local _, r = node.bootreason(); 
if (r == 5) or (r == 6 and rtctime and rtctime.get() ~= 0) or (r == 6 and rtcfifo and rtcfifo.ready() == 1) then go()
else print('wait 5 sec'); local tt =tmr.create(); tt:alarm(5000, tmr.ALARM_SINGLE, _go) end
