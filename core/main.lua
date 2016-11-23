print '                \n +-+-+-+-+-+-+-+\n |E|S|P|C|O|R|E|\n +-+-+-+-+-+-+-+\n';
local now = tmr.now
local _start = now()
timeit = function() return (now()-_start)/1000 end
ftr=require('futures')
local main_cfg = dofile('main_cfg.lua')
wificon = nil; mq = nil
local net_conn = function(when_connected)
    if wifi and main_cfg.wifi then
        wificon = require('wificon')
        local ft_wifi = ftr.Future()
        wificon:start(ft_wifi:callbk())
        ft_wifi:wait()
        if main_cfg.sntp and sntp and rtctime then
            local ft_sync = ftr.Future()           
            sntp.sync('0.ua.pool.ntp.org', ft_sync:callbk(),ft_sync:callbk(true))
            if ft_sync:wait() then 
                local sec,usec = ft_sync:result()
                print('Time is :', sec)
                rtctime.set(sec, usec)
            else print('Time sync failed! Reason ', ft_sync:result()) end
        end
        if main_cfg.mqtt and mqtt then
            mq = require('mqttcon')
            local ft_mq = ftr.Future()
            mq:start(ft_mq:callbk())
            ft_mq:wait()
            if main_cfg.console then
                dofile('mqconsole.lua')
            end
        end
    else
        wifi.setmode(wifi.NULLMODE)
        print('wifi disabled')           
    end
    when_connected()
end
ftr.spawn(function()
    if main_cfg.wait_for_net then     
        local ft_net = ftr.Future()
        local when_connected = ft_net:callbk()
        ftr.spawn(function() net_conn(when_connected) end)
        ft_net:wait()
    else
        ftr.spawn(function() net_conn(function() end) end)
    end
    if file.exists('user.lock') then 
        print('user locked')
        return 
    end
    dofile('user.lua')
    print('user.lua loaded')
    if file.exists('run.lock') then 
        print('run locked') 
    else
        if run then
            ftr.spawn(run) 
            print('run executed') 
        else
            print('no run() to run')
        end
    end
end)
