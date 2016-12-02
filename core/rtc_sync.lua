require 'utils'
return function()
    if sntp and nt.wifi and nt.wifi.running then
        local server = ldfile('main_cfg.lua').sntp_server
        local ft_sync = ftr.Future()
        local attempt = 3
        while attempt > 0 do           
            sntp.sync(server, ft_sync:callbk(),ft_sync:errcallbk())
            if ft_sync:wait() then 
                local sec,usec = ft_sync:result()
                print('Time synced to :', sec, usec)
                return
            else
                print('Time sync failed! Reason ', ft_sync:result(), 'Attempt ', attempt)
            end
            attempt = attempt - 1
        end
    end
    if rtctime.get() == 0 then 
        rtctime.set(978307200, 0) 
        print('Time is :', rtctime.get())
    end
end
