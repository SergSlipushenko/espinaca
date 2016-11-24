require 'utils'
wificon = nil
mq = nil
local start = function(services, when_connected)
    if services.wifi and wifi then
        wificon = loadfile('wificon.lua', wificon)
        if not wificon.running then 
            local ft_wifi = ftr.Future()
            ft_wifi:run(wificon.start, wificon, ft_wifi:callbk())
        end
        if services.mqtt and mqtt then
            mq = loadfile('mqttcon', mq)
            if not mq.running then
                local ft_mq = ftr.Future()
                ft_mq:run(mq.start, mq, ft_mq:callbk())
            end
        end
    end
    if when_connected then node.task.post(when_connected) end
end
local stop = function()
    if mq then mq:stop(); ftr.switch(); mq = nil end
    if wificon then wificon:stop(); ftr.switch(); wificon = nil end 
end
return {
    start = start,
    stop = stop
}
