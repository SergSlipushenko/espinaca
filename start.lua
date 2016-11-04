print '                \n +-+-+-+-+-+-+-+\n |E|S|P|C|O|R|E|\n +-+-+-+-+-+-+-+\n';
if wifi then
    if file.exists('wifi.lock') then 
        wifi.setmode(wifi.NULLMODE)
        print('Wifi locked')
    else
        wificon = require('wificon')
        wificon:start() 
        if mqtt then
            if file.exists('mqtt.lock') then print('mqtt locked') else
                mq = require('mqttcon')
                mq:start() 
            end
        end
    end
end
if file.exists('main.lock') then print('main locked') return end
if file.exists('main.lua') then
    dofile('main.lua')
    print('main executed')
    if file.exists('run.lock') then print('run locked') else
        if run then 
            node.task.post(run); 
            print('run executed'); 
        else
            print('no run() to run')
        end
    end 
end