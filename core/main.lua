print '                \n +-+-+-+-+-+-+-+\n |E|S|P|C|O|R|E|\n +-+-+-+-+-+-+-+\n';
local ftr=require('futures')
local main_cfg = dofile('config.lua').main
ftr.spawn(function()
    if wifi and main_cfg.wifi then
        wificon = require('wificon')
        local ft_wifi = ftr.Future()
        wificon:start(ft_wifi:callbk())
        ft_wifi:wait()
        if mqtt and main_cfg.mqtt then
            mq = require('mqttcon')
            local ft_mq = ftr.Future()
            mq:start(ft_mq:callbk())
            ft_mq:wait()
            if main_cfg.console then
                local connected = false
                local node_name = string.format('NODE-%x', node.chipid()):upper()
                mq:subscribe('node/'..node_name..'/stdin', 0, function(msg)
                    if connected and msg == ':q!' then 
                        connected = false
                        node.output(nil)
                        return
                    end
                    if not connected then 
                        connected = true
                        node.output(function(msg) 
                            if mq.running then
                                mq:publish('node/'..node_name..'/stdout', msg)
                            end
                        end, 1)       
                    end
                    if connected then
                        mq:publish('node/'..node_name..'/stdout', msg) 
                        node.input(msg) 
                    end
                end)
            end
        else
            print('mqtt disabled')
        end
    else
        wifi.setmode(wifi.NULLMODE)
        print('wifi disabled')           
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
