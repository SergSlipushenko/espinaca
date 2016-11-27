require 'utils'
wificon = nil
mq = nil
local start = function(services)
    if services.wifi and wifi then
        wificon = ldfile('wificon.lua', wificon)
        if not wificon.running then 
            local ft_wifi = ftr.Future()
            ft_wifi:run(wificon.start, wificon, ft_wifi:callbk())
        end
        if services.mqtt and mqtt then
            mq = ldfile('mqttcon.lua', mq)
            if not mq.running then
                local ft_mq = ftr.Future()
                ft_mq:run(mq.start, mq, ft_mq:callbk())
            end
        end
    end
end
local stop = function()
    if mq then mq:stop(); ftr.switch(); mq = nil end
    if wificon then wificon:stop(); ftr.switch(); wificon = nil end 
end
return {
    start = start,
    stop = stop
}
