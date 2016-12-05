return function()
    nt.deploy({wifi=true ,mqtt=true})
    pins = require 'pins'
    URL = 'http://api.thingspeak.com/update?api_key=%s&field1=%d&field2=%d&field3=%d&field4=%d&field5=%d'
    secrets = dofile 'secrets.lua'
    gpio.mode(pins.IO15, gpio.OUTPUT)
    gpio.write(pins.IO15,gpio.LOW)
    ftr.sleep(30)
    gpio.mode(pins.IO4, gpio.OUTPUT)
    gpio.write(pins.IO4,gpio.HIGH)  
    ftr.sleep(30)
    res = bme280.init(pins.IO5,pins.IO0)
    print(res)
    if not res then print('BМE280 failed to init'); return end
    ftr.sleep(142)
    press, temp=bme280.baro()
    humi,_=bme280.humi()
    press = press/10 - 101325
    heap = node.heap()
    vdd = adc.readvdd33()
    temp = temp/10
    humi = humi/1000
    print(temp,humi,press,vdd,heap)
    if nt.wifi.running then
        url=URL:format(secrets.TS.api_key,temp,humi,press,vdd,heap)
        print(url)
        ft_send = ftr.Future()
        http.get(url, nil, ft_send:callbk())
        print(ft_send:result())
    end
    if nt.mqtt.running then 
        nt.mqtt:publish('sensors/outdoor/temp', temp, 0, 1)
        nt.mqtt:publish('sensors/outdoor/vdd', vdd, 0, 1)
        print('published!')
    end
    gpio.mode(pins.IO4, gpio.INPUT)
    ftr.sleep(30)
    gpio.mode(pins.IO15, gpio.INPUT)
    nt.deploy({wifi=false})    
end
