return function()
    print('Blink exapmle')
    -- turn off  WIFI in order to save some RAM
    nt.deploy({wifi=false})
    local pins=require 'pins'
    gpio.mode(pins.IO2, gpio.OUTPUT)
    gpio.write(pins.IO2, gpio.HIGH)
    --we have to wait until blinking will finish
    local f = ftr.Future()
    f:run(gpio.serout,pins.IO2,gpio.LOW,{20000,50000},3, f:callbk())   
    print('VDD: ', adc.readvdd33(), 'Heap:', node.heap())
end
