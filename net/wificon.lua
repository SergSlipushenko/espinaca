return {
    running = false,
    start = function(self, on_connect)
        if self.running or wifi.sta.status == wifi.STA_GOTIP then
            self.running = true
            if on_connect then
                node.task.post(function() on_connect(); on_connect = nil end)
            end
            return
        end
        self.running = true
        local APS = (ldfile('secrets.lua') or {}).APS
        if not APS then return end
        wifi.setmode(wifi.STATION)
        wifi.setphymode(wifi.PHYMODE_N)
        wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
            print("Connected to SSID: "..T.SSID)
        end)
        wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
            print("Disconneced from SSID: "..T.SSID.." Reason: "..T.reason)
            local ap_info = wifi.sta.getapinfo()
            local ap_index = wifi.sta.getapindex() % ap_info.qty + 1
            wifi.sta.changeap(ap_index)
            print('Try connect to SSID: '..ap_info[ap_index].ssid)
        end)
        wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
            print("Station IP: "..T.IP)
            if on_connect then on_connect(); on_connect = nil end
        end)
        local ap_info = wifi.sta.getapinfo()
        for _, ap in ipairs(APS) do
            local ap_in_cache = false
            for _, cap in ipairs(ap_info) do
                if ap.ssid == cap.ssid then ap_in_cache = true end
            end
            if not ap_in_cache then
                wifi.sta.config({ ssid = ap.ssid, pwd = ap.pass, auto = false, save = false})
            end
        end
        wifi.sta.connect()
    end,
    stop = function(self)
        self.running = false
        wifi.eventmon.unregister(wifi.eventmon.STA_CONNECTED)
        wifi.eventmon.unregister(wifi.eventmon.STA_DISCONNECTED)
        wifi.eventmon.unregister(wifi.eventmon.STA_GOT_IP)
        wifi.sta.disconnect()
        wifi.setmode(wifi.NULLMODE)        
        print 'WiFi stoped'
    end
}
