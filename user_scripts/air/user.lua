return function()
    ftr = require 'futures'
    cfg = dofile 'config.lua'
    mhz19 = require 'mhz19'
    pins = require 'pins'
    dsp = require 'pcd8544'
    htu = require 'htu21d'
    
    mhz19:init(cfg.mhz19_pin)
    gpio.mode(pins.IO2, gpio.OUTPUT)
    gpio.write(pins.IO2, 0)
    local sensor = nil
    if bme280.init(pins.IO0,pins.IO5) then sensor = 'bme'
    elseif htu:init(64, pins.IO0,pins.IO5) then sensor = 'htu' end
    dsp:init()
    URL = 'http://api.thingspeak.com/update?api_key=%s&field1=%d&field2=%d&field3=%d&field4=%d&field5=%d'
    while true do
        ft = ftr.Future():timeout(3000)
        mhz19:get_co2_level(ft:callbk())
        local ppm = ft:result()
        if ppm then
            local press,temp,hum
            if sensor == 'bme' then
                press, temp=bme280.baro()
                hum,_=bme280.humi()
                hum = hum/1000
                press = press/10 - 101325                
            elseif sensor == 'htu' then
                temp=htu:temp()
                press = 0
                hum = htu:hum()
            end            
            local heap = node.heap()          
            temp = temp/10
            dsp:draw(function(d)
                if timeit()/1000 < 120 then d:drawStr(0,0,'CO2:****')
                else d:drawStr(0,0,'CO2:'..ppm) end
                d:drawStr(0,16,'T: '..temp/10 .. '.' .. temp%10 .. 'C')
                d:drawStr(0,32,'H: '.. hum .. '%')                
            end)
            if cfg.verbose then
                print(ppm, temp,hum,press,heap)
            end
            if wificon and wificon.runninng then
                local url=URL:format(secrets.TS.api_key,ppm, temp,hum,press,heap)
                print(url)
                http.get(url, nil, function(c,d) print(c) end)
            end
            if mq and mq.running then
                mq:publish('sensors/airstation/co2', tostring(ppm))
                mq:publish('sensors/airstation/temp', tostring(temp))
                mq:publish('sensors/airstation/hum', tostring(hum))
                mq:publish('sensors/airstation/press', tostring(press))
                mq:publish('sensors/airstation/heap', tostring(heap))
            end            
        end
        gpio.serout(pins.IO2,gpio.LOW,{50000,100000},3, function() end)
        ftr.sleep(cfg.cycle)
    end
end
