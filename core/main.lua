print '                \n +-+-+-+-+-+-+-+\n |E|S|P|C|O|R|E|\n +-+-+-+-+-+-+-+\n';
if file.exists('main.lock') then 
    print('main locked')
    return 
end
local ftr=require('futures')
ftr.spawn(function()
    if wifi then
        if file.exists('wifi.lock') then 
            wifi.setmode(wifi.NULLMODE)
            print('Wifi locked')
        else
            wificon = require('wificon')
            local ft_wifi = ftr.Future()
            wificon:start(ft_wifi:callbk())
            ft_wifi:wait()
            if mqtt then
                if file.exists('mqtt.lock') then 
                    print('mqtt locked') 
                else
                    mq = require('mqttcon')
                    local ft_mq = ftr.Future()
                    mq:start(ft_mq:callbk())
                    ft_mq:wait() 
                end
            end            
        end
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
