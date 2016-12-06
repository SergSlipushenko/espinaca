return function()
    local unix_tm = rtctime.get()
    local time
    if unix_tm > 0 then
        local tm = rtctime.epoch2cal(unix_tm+2*3600)
        time = string.format(cfg.timefmt, tm.hour, tm.min, tm.sec)
    else
        time = string.format(cfg.timefmt, 88, 88, 88)
    end
    dsp:draw(function(d)
        if n_cycle < cfg.warmcycles then d:drawStr(0,0,'CO2:****')
        elseif ppm then d:drawStr(0,0,'CO2:'..ppm) end
        if temp and hum then
            d:drawStr(0,16,temp/10 .. '.' .. temp%10 .. ' ' .. hum .. '%')
        end      
        d:drawStr(0,32,time)                
    end)
end
