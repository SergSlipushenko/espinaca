require 'commons'
nt = require 'netcon'
ftr = require 'futures'
ldfile('wsconsole.lua')()
require 'helpers'   

ftr.spawn(function() nt.deploy({wifi=false}) end)
ftr.spawn(function() nt.deploy({ws=true}) end)
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

leds = require 'leds'
ws2812.init()
total = 20
buf = ws2812.newBuffer(total, 3)
tt = tmr.create()
tt:alarm(1000, tmr.ALARM_AUTO, function()
g, r, b = leds.hsv2grb(math.random(0,359), 255, 255);buf:fill(r, g, b);ws2812.write(buf)
end)

mode('pulse_rainbow')
clr_timers()
g, r, b = 100,5,0
buf:fill(g,r,b);buf:set(1, 0, 0, 0);ws2812.write(buf)
tt = tmr.create()
table.insert(timers, tt)
tt:alarm(40, tmr.ALARM_AUTO, function()buf:shift(1);buf:set(1, 0, 0, 0);buf:set(1, g, r, b);ws2812.write(buf) end)
cc={0, 12, 25, 100, 150, 230, 280}
=node.random(1,2)
