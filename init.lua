uart.setup(0, 115200, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1);
start = function() local ok, err = pcall(function() dofile('start.lua') end); if not(ok) then print(err) end end
local _, r = node.bootreason(); if (r ~= 6) and (r ~= 0) then local tt =tmr.create(); tt:alarm(3000, tmr.ALARM_SINGLE, start) else start() end