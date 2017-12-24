ftr = require 'futures'
ldfile = function(fname, m) 
    if m then return m 
    else if file.exists(fname) then return dofile(fname) end end 
end
nt = require 'netcon'
f_stub = function() end
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end