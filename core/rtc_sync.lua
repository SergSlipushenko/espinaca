require 'commons'
return function()
    if sntp and nt.wifi and nt.wifi.running then
        local ntp_server = ldfile('main_cfg.lua').sntp_server
        local ft_sync = ftr.Future():timeout(7000)
        if ntp_server then
            local attempt = 3
            while attempt > 0 do           
                sntp.sync(server, ft_sync:callbk(),ft_sync:errcallbk())
                if ft_sync:wait() then 
                    local sec,usec = ft_sync:result()
                    print('(SNTP)Time synced to :', sec, usec)
                    return
                else
                    print('Time sync failed! Reason ', ft_sync:result(), 'Attempt ', attempt)
                end
                attempt = attempt - 1
            end
        else
            http.get('http://currentmillis.com/time/seconds-since-unix-epoch.php', {}, ft_sync:callbk())
            local c, data = ft_sync:result()
            if data then 
                sec = tonumber(data)
                rtctime.set(sec, 0) 
                print('(HTTP)Time synced to :', sec, 0)
            end
        end
    end
    if rtctime.get() == 0 then 
        rtctime.set(978307200, 0) 
        print('Time is :', rtctime.get())
    end
end
