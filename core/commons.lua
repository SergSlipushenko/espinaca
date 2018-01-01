ftr = require 'futures'
ldfile = function(fname, m)
    if m then return m
    else if file.exists(fname) then return dofile(fname) end end
end
nt = require 'netcon'
f_stub = function() end
NODEID = string.format('NODE-%x', node.chipid()):upper()
function fifo_new () return {first = 0, last = -1} end
function fifo_push (fifo, value)
  local first = fifo.first - 1
  fifo.first = first
  fifo[first] = value
end
function fifo_pop (fifo)
  local last = fifo.last
  if fifo.first > last then return end
  local value = fifo[last]
  fifo[last] = nil         -- to allow garbage collection
  fifo.last = last - 1
  return value
end
function fifo_empty(fifo)
  return fifo.first > fifo.last
end