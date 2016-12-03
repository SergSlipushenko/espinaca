wifi.setmode(wifi.NULLMODE)
_heap = node.heap()
ftr = require 'futures'
ldfile = function(fname, m) 
    if m then return m 
    else if file.exists(fname) then return dofile(fname) end end 
end
if rtcfifo then 
    if rtcfifo.ready() == 0 then
        rtcmem.write32(ldfile('main_cfg.lua').cron.cycle_cell, 0)
    end
    rtcfifo.prepare()
end
pheap = function() print(_heap - node.heap()); _heap = node.heap() end
f_stub = function() end
