require 'commons'
ftr.spawn(function() ldfile('wsconsole.lua')('NODE') end)
require 'helpers'   

ftr.spawn(function() nt.deploy({wifi=true}) end)
ftr.spawn(function() nt.deploy({ws=false}) end)
ftr.spawn(function() nt.deploy({mqtt=true}) end)
wscon = ldfile('wscon.lua')
wscon:connect()
wscon:close()
wscon = nil
ftr.spawn(ldfile('mqconsole.lua'))
mqttcon:start()

nt.ws.on_receive = function(client, msg,opcode) print(msg, opcode) end
nt.ws:send('zzzzz')
for i=1,100 do nt.ws:buffered_send('ppp'..i) end
wscon:close()

ttt = tmr.create()
ws:connect('ws://192.168.88.248:8000/')
ttt:alarm(300, tmr.ALARM_AUTO, function() wscon:send('zzzzz',1) end)
ws:close()

viewfile('rtc_sync.lua')
=collectgarbage("count")

require 'commons'
require 'helpers'
=node.heap()
fifo_send={}
for a=1,300 do
table.insert(fifo_send, 'aaaaaaaaaaaaa'..a)
end
=node.heap()
repeat
l=table.remove(fifo_send, 1)
until l == nil
fifo_send=nil
=node.heap()

a={}
a[3]='dddddd'
=a[3]
aa = a[3]
=aa
a[3] = nil
