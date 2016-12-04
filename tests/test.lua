require 'netcon'
ftr.spawn(function()
print(node.heap())
nt.deploy({wifi=true ,mqtt=true})
print(node.heap())
ftr.sleep(1000)
print(node.heap())
end)

ftr.spawn(function()
    m = dofile('mqttcon.lua')
    m:subscribe('t/t',0, function(msg) print(msg) end)
    print('z')
    f= ftr.Future()
    f:run(m.start,m, f:callbk())
    print('z')
    m:publish('t/t','HIII!',0,0)
    print(node.heap()) 
    m:stop()
    print('z')    
    m = nil
end)

wific = require 'wificon'
ftr.spawn(function()
nt.deploy({mqtt=true})
end) 




ftr.spawn(function()
print(node.heap())
nt.deploy({wifi=true})
nt.deploy({mqtt=true})
nt.deploy({wifi=false})
print(node.heap())
end) 


require 'commons'
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
