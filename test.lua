_u = require 'utils'
ftr = require 'futures'
nt = require 'netcon'
ftr.spawn(function()
print(node.heap())
nt.deploy({wifi=true})
nt.deploy({mqtt=true})
nt.deploy({wifi=false})
print(node.heap())
end) 


_u = require 'utils'
ftr = require 'futures'

ftr.spawn(function()
    print(node.heap()) 
    w = dofile('wificon.lua')
    f= ftr.Future()
    f:run(w.start,w, f:callbk())
    print(node.heap()) 
    m = dofile('mqttcon.lua')
    m:subscribe('t/t',0, function(msg) print(msg) end)
    f= ftr.Future()
    f:run(m.start,m, f:callbk())
    m:publish('t/t','HIII!',0,0)
    print(node.heap()) 
    m:stop()
    m = nil
    w:stop()
    w = nil
end)


ftr.spawn(function()
print(node.heap()) 
m = dofile('mqttcon.lua')
m:subscribe('t/t',0, function(msg) print(msg) end)
f= ftr.Future()
f:run(m.start,m, f:callbk())
m:publish('t/t','HIII!',0,0)
print(node.heap()) 
m:stop()
m = nil
end)

m.client:connect(m.MQTT.server, m.MQTT.port, 0, function(c) print('c') end, function(c,r) print('e',r) end)

_view=function() local _line if file.open("secrets.lua","r") then print("--FileView start") repeat _line = file.readline() if (_line~=nil) then print(string.sub(_line,1,-2)) end until _line==nil file.close() print("--FileView done.") else
print("\r--FileView error: can't open file") end end _view() _view=nil
