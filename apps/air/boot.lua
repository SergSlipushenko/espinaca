return function()
    mhz19 = require 'mhz19'
    pins = require 'pins'
    dsp = require 'pcd8544'
    htu = require 'htu21d'
    cfg = {
        warmcycles = 180000/ldfile('main_cfg.lua').cron.cycle,
        timezone = 2,
        timefmt = '%02d:%02d:%02d'}
    mhz19:init(pins.IO4)
    gpio.mode(pins.IO2, gpio.OUTPUT)
    gpio.write(pins.IO2, 1)
    sensor = nil
    if bme280.init(pins.IO0,pins.IO5) then sensor = 'bme'
    elseif htu:init(64, pins.IO0,pins.IO5) then sensor = 'htu' end
    print('Detected sensor: ', sensor) 
    dsp:init({cs=pins.IO15, dc=pins.IO12})
    dsp:draw(function(d)
        d:drawStr(0,0,'Connect')                
        d:drawStr(0,16,'to Wi-Fi')                
    end)      
    nt.deploy({wifi=true})
    dofile('rtc_sync.lua')()
    URL = 'http://api.thingspeak.com/update?api_key=%s&field1=%d&field2=%d&field3=%d&field4=%d&field5=%d'
end
