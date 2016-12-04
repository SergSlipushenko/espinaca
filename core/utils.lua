wifi.setmode(wifi.NULLMODE)
_heap = node.heap()
ftr = require 'futures'
ldfile = function(fname, m) 
    if m then return m 
    else if file.exists(fname) then return dofile(fname) end end 
end
pheap = function() print(_heap - node.heap()); _heap = node.heap() end
f_stub = function() end
