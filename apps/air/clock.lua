return function()
    if not (temp and hum and press) then return end
    local unix_tm = rtctime.get()
    local tm = rtctime.epoch2cal(unix_tm+2*3600)
    local time = string.format(cfg.timefmt, tm.hour, tm.min, tm.sec)
    dsp:draw(function(d)
        if timeit()/1000 < cfg.warmtime then d:drawStr(0,0,'CO2:****')
        elseif ppm == nil then d:drawStr(0,0,'CO2:----')
        else d:drawStr(0,0,'CO2:'..ppm) end
        d:drawStr(0,16,temp/10 .. '.' .. temp%10 .. ' ' .. hum .. '%')      
        d:drawStr(0,32,time)                
    end)
end