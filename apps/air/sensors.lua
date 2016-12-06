return function()
    if n_cycle >= cfg.warmcycles then 
        ft = ftr.Future():timeout(2000)
        mhz19:get_co2_level(ft:callbk())
        ppm = ft:result()
        if ppm and (ppm<300 or ppm>5500) then ppm=nil end
        ft=nil
    else ppm = nil end
    if sensor == 'bme' then
        press, temp=bme280.baro()
        temp = temp/10
        hum,_=bme280.humi()
        hum = hum/1000
        press = press/10 - 101325                
    elseif sensor == 'htu' then
        temp = htu:temp()/10
        press = 0
        hum = htu:hum()
    end             
    heap = node.heap()
    print(ppm,temp,hum,press,heap)
    gpio.serout(pins.IO2,gpio.LOW,{5000,200000},3, function() end)
end
