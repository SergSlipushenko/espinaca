return function()
    pins = require 'pins'
    ftr = require 'futures'
    URL = 'http://api.thingspeak.com/update?api_key=%s&field1=%s&field2=%s&field3=%s&field4=%s&field5=%s'
    secrets = dofile 'secrets.lua'
    cfg = dofile('config.lua')
    gpio.mode(pins.IO15, gpio.OUTPUT)
    gpio.write(pins.IO15,gpio.LOW)
    ftr.sleep(30)
    gpio.mode(pins.IO4, gpio.OUTPUT)
    gpio.write(pins.IO4,gpio.HIGH)  
    ftr.sleep(30)
    res = bme280.init(pins.IO5,pins.IO0)
    ftr.sleep(100)
    if not res then print('BМE280 failed to init'); return end
    press, temp=bme280.baro()
    hum,_=bme280.humi()
    heap = tostring(node.heap())
    vdd = tostring(adc.readvdd33())
    press = tostring((press or 0)/10 - 101325)
    temp = tostring((temp or 0)/10)
    hum = tostring((hum or 0)/100)
    url=URL:format(secrets.TS.api_key,temp,hum,press,vdd,heap)
    print(url)
    ft_send = ftr.Future()
    http.get(url, nil, ft_send:callbk())
    print(ft_send:result()) 
    if mq and mq:running() then
        mq:publish('sensors/airmon/vdd', vdd)
        mq:publish('sensors/airmon/temp', temp)
        mq:publish('sensors/airmon/hum', hum)
        mq:publish('sensors/airmon/press', press)
        mq:publish('sensors/airmon/heap', heap)
        mq:publish('sensors/airmon/all', temp..' '..hum..' '..press..' '..vdd..' '..heap)
        print('data sent')
        mq:stop()
        wificon:stop()
    end
    print('job done in '..(timeit())..' ms')
    gpio.mode(pins.IO4, gpio.INPUT)
    ftr.sleep(30)
    gpio.mode(pins.IO15, gpio.INPUT)
    if cfg.sleep_on_done then
        print('go down for '.. (cfg.sleep_cycle or 0)/1000 .. 's')   
        ftr.sleep(30)        
        rtctime.dsleep(cfg.sleep_cycle*1000)
    end
end
