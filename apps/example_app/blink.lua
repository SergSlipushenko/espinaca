return function()
    print('Blink exapmle')
    -- turn off  WIFI in order to save some RAM
    local pins=require 'pins'
    gpio.mode(pins.IO2, gpio.OUTPUT)
    gpio.write(pins.IO2, gpio.HIGH)
    --we have to wait until blinking will finish
    for i=5,1,-1 do
        print(i)
        gpio.write(pins.IO2, gpio.LOW)
        ftr.sleep(300)
        gpio.write(pins.IO2, gpio.HIGH)
        ftr.sleep(1000)
    end
    print('VDD: ', adc.readvdd33(), 'Heap:', node.heap())
end
