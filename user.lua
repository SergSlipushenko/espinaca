-- Application example
ftr = require 'futures'
cfg = dofile 'config.lua'
mhz19 = require 'mhz19'
pins = require 'pins'

mhz19:init(cfg.mhz19_pin)
gpio.mode(pins.IO2, gpio.OUTPUT)
gpio.write(pins.IO2, 0)
bme280.init(pins.IO0,pins.IO5)
URL = 'http://api.thingspeak.com/update?api_key=%s&field1=%d&field2=%d&field3=%d&field4=%d&field5=%d'
secrets = dofile 'secrets.lua'

function run()
    for i=18,1,-1 do 
        ftr.sleep(10000)
        gpio.serout(pins.IO2,gpio.LOW,{50000,100000},i, function() end)
    end
    while true do
        mhz19:get_co2_level(function(ppm) 
            local press, temp=bme280.baro()
            local hum,_=bme280.humi()
            local heap = node.heap()
            press = press/10 - 101325
            temp = temp/10
            hum = hum/100
            if cfg.verbose then
                print(ppm, temp,hum,press,heap)
            end
            if cfg.send then
                url=URL:format(secrets.TS.api_key,ppm, temp,hum,press,heap)
                http.get(url, nil, function(c,d) print(c) end)
            end
            if mq and mq.running then
                mq:publish('sensors/airstation/co2', tostring(ppm))
                mq:publish('sensors/airstation/temp', tostring(temp))
                mq:publish('sensors/airstation/hum', tostring(hum))
                mq:publish('sensors/airstation/press', tostring(press))
                mq:publish('sensors/airstation/heap', tostring(heap))
            end            
        end)
        gpio.serout(pins.IO2,gpio.LOW,{50000,100000},3, function() end)
        ftr.sleep(cfg.cycle)
    end
end