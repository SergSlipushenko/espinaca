local nt = {
    wifi = nil,
    mqtt = nil
}
local deploy = function(services)
    if services == nil then return end
    if services.wifi or services.mqtt then
        nt.wifi = ldfile('wificon.lua', nt.wifi) or ldfile('wificon.lc', nt.wifi)
        if not nt.wifi.running then 
            local ft_wifi = ftr.Future()
            ft_wifi:run(nt.wifi.start, nt.wifi, ft_wifi:callbk())
        end
    end
    if services.mqtt then
        nt.mqtt = ldfile('mqttcon.lua', nt.mqtt) or ldfile('mqttcon.lc', nt.mqtt)
        if not nt.mqtt.running then
            local ft_mq = ftr.Future()
            ft_mq:run(nt.mqtt.start, nt.mqtt, ft_mq:callbk())
        end
    end
    if services.mqtt == false or services.wifi == false then       
        if nt.mqtt then nt.mqtt:stop() end
        nt.mqtt = nil
    end
    if services.wifi == false then
        if nt.wifi then nt.wifi:stop() end
        nt.wifi = nil
    end
end
nt.deploy = deploy

return nt
