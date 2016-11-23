if sntp and rtctime then
    ftr.spawn(function()
        local ft_sync = ftr.Future()           
        sntp.sync('0.ua.pool.ntp.org', ft_sync:callbk(),ft_sync:callbk(true))
        if ft_sync:wait() then 
            local sec,usec = ft_sync:result()
            print('Time is :', sec)
            rtctime.set(sec, usec)
        else print('Time sync failed! Reason ', ft_sync:result()) end
    end)
end