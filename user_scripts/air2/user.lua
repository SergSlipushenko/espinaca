pins = require 'pins'
ftr = require 'futures'


function run()
    cfg = dofile('config.lua')
    gpio.mode(pins.IO15, gpio.OUTPUT)
    gpio.write(pins.IO15,gpio.LOW)
    ftr.sleep(30)
    gpio.mode(pins.IO4, gpio.OUTPUT)
    gpio.write(pins.IO4,gpio.HIGH)  
    ftr.sleep(30)
    res = bme280.init(pins.IO5,pins.IO0)
    ftr.sleep(100)
    if not res then
        print('MBE280 faild to init')
        return
    end
    press, temp=bme280.baro()
    hum,_=bme280.humi()
    heap = tostring(node.heap())
    vdd = tostring(adc.readvdd33())
    press = tostring((press or 0)/10 - 101325)
    temp = tostring((temp or 0)/10)
    hum = tostring((hum or 0)/100)
    print(temp,hum,press,vdd,heap)
    if mq then
        mq:publish('sensors/air2/vdd', vdd)
        mq:publish('sensors/air2/temp', temp)
        mq:publish('sensors/air2/hum', hum)
        mq:publish('sensors/air2/press', press)
        mq:publish('sensors/air2/heap', heap)
        mq:publish('sensors/air2/all', temp..' '..hum..' '..press..' '..vdd..' '..heap)
        print('data sent')
        mq:stop()
        wificon:stop()
    end
    print('job done in '..((now() - very_now)/1000)..' ms')
    print('go down for '.. (cfg.sleep_cycle or 0)/1000 .. 's')   
    gpio.mode(pins.IO4, gpio.INPUT)
    ftr.sleep(30)
    gpio.mode(pins.IO15, gpio.INPUT)
    ftr.sleep(30)
    rtctime.dsleep(cfg.sleep_cycle*1000)
end
