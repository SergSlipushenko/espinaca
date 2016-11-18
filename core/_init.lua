uart.setup(0, 115200, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)
go = function() return pcall(function() dofile('main.lua') end) end
local _go = function()
    if file.exists('main.lock') then print('main locked') return end 
    local ok, err = go(); if not(ok) then print(err) end end
local _, r = node.bootreason(); if (r ~= 6) and (r ~= 0) then 
    local tt =tmr.create(); tt:alarm(5000, tmr.ALARM_SINGLE, _go) else _go() end
