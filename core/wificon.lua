require 'utils'
local APS = (ldfile('secrets.lua') or {}).APS
local connect=function(self, aps)
    if not aps then aps = APS end
    wifi.setmode(wifi.STATION)
    wifi.setphymode(wifi.PHYMODE_N)
    local ft_list = ftr.Future()
    local aps_around = ft_list:run(wifi.sta.getap,ft_list:callbk())
    if not aps_around then return end
    for _, ap in ipairs(aps) do
        if aps_around[ap.ssid] then
            wifi.sta.config(ap.ssid,ap.pass,0)
            print('Try connect to '..ap.ssid)
            local ft = ftr.Future():timeout(10000)
            wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, ft:callbk())
            wifi.sta.connect()
            if ft:wait() then
                print('connected as '..ft:result().IP)
                wifi.eventmon.unregister(wifi.eventmon.STA_GOT_IP)
                return true
            else
                print('connection failed')
            end
        else
            print('No '..ap.ssid..' around')
        end
    end
end

return {
    running = false,
    connect = connect,
    start = function(self, on_connect)
        if self.running or wifi.sta.getrssi() then 
            self.running = true
            if on_connect then
                node.task.post(function() on_connect(); on_connect = nil end)
            end
            return 
        end
        APS = (ldfile('secrets.lua') or {}).APS
        self.running = true
        local reconnect = function()
            if self.running and not wifi.sta.getrssi() then
                print('No wifi connection')
                self.running = false
                local r = self:connect()
                self.running = true
                return r                
            end
        end
        self.watchdog = tmr.create()
        self.watchdog:alarm(3000, tmr.ALARM_AUTO, function() ftr.spawn(reconnect) end)
        if reconnect() then
            if on_connect then
                node.task.post(function() on_connect(); on_connect = nil end)
            end
        end
    end,
    stop = function(self)
        self.running = false
        if self.watchdog then self.watchdog:unregister() end
        wifi.sta.disconnect()
        wifi.setmode(wifi.NULLMODE)        
        print 'wifi disconnected'
    end
}
