local ftr = require('futures')
local wifi_connect=function(aps)
    wifi.setmode(wifi.STATION)
    wifi.setphymode(wifi.PHYMODE_N)
    for k, ap in ipairs(aps) do
        wifi.sta.config(ap.ssid,ap.pass,0)
        print('Try connect to '..ap.ssid)
        local ft = ftr.Future()
        ft:timeout(10000)
        wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, ft:callbk())
        wifi.sta.connect()
        local cdata = ft:result()
        if cdata then
            print('connected as '..cdata.IP)
            wifi.eventmon.unregister(wifi.eventmon.STA_GOT_IP)
            return
        else
            print('connection failed')
        end
        ft = nil
    end
end

return {
    running = false,
    start = function(self, on_connect)
        local secrets = dofile('secrets.lua')
        if self.running or not(secrets) or not(secrets.APS) then return end
        self.running = true
        ftr.spawn(function()
            while self.running do
                local rssi = wifi.sta.getrssi()
                if not(rssi) then
                    print('connection lost.')
                    wifi_connect(secrets.APS)
                    if on_connect then on_connect(); on_connect = nil end
                end
                ftr.sleep(7000)
            end
        end)
        return ff
    end,
    stop = function(self)
        wifi.sta.disconnect()
        self.running = false
    end
}
