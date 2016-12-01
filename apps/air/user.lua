return function()
    ft = ftr.Future():timeout(2000)
    mhz19:get_co2_level(ft:callbk())
    ppm = ft:result()
    ft=nil
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
    local unix_tm = rtctime.get()
    local tm = rtctime.epoch2cal(unix_tm+2*3600)
    local time = string.format("%02d:%02d:%02d", tm.hour, tm.min, tm.sec)
    dsp:draw(function(d)
        if timeit()/1000 < 150 then d:drawStr(0,0,'CO2:****')
        elseif ppm == nil then d:drawStr(0,0,'CO2:----'..ppm)
        else d:drawStr(0,0,'CO2:'..ppm) end
        d:drawStr(0,16,temp/10 .. '.' .. temp%10 .. ' ' .. hum .. '%')      
        d:drawStr(0,32,time)                
    end)
    print(ppm, temp,hum,press,heap)
    gpio.serout(pins.IO2,gpio.LOW,{5000,200000},3, function() end)
end
