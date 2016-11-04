local ftr = require('futures')
local secrets = require('secrets')
local wifi_connect=function()
    wifi.setmode(wifi.STATION)
    wifi.setphymode(wifi.PHYMODE_N)
    for k, ap in ipairs(secrets.APS) do
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
    start = function(self)
        if self.running then return end
        self.running = true
        ftr.spawn(function()
            while self.running do
                local rssi = wifi.sta.getrssi()
                if not(rssi) then
                    print('connection lost.')
                    wifi_connect()
                end
                ftr.sleep(7000)
            end
        end)
    end,
    stop = function(self)
        wifi.sta.disconnect()
        self.running = false
    end
}
