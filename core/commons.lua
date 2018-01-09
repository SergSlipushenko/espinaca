-- nt = require 'netcon'
-- ftr = require 'futures'
ldfile = function(fname, m)
    if m then return m end
    if file.exists(fname) then return dofile(fname) end
end
f_stub = function() end
NODEID = string.format('NODE-%x', node.chipid()):upper()
