require 'utils'
local wifi_connect=function(aps)
    if not aps then aps = dofile('secrets.lua').APS end
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
            local cdata = ft:result()
            if cdata then
                print('connected as '..cdata.IP)
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
    start = function(self, on_connect)
        if not file.exists('secrets.lua') then return end
        local APS = loadfile('secrets.lua').APS
        if self.running or not(APS) then return end
        self.running = true
        ftr.spawn(function()
            while self.running do
                if not wifi.sta.getrssi() then
                    print('connection lost.')
                    wifi_connect(APS)
                end
                if wifi.sta.getrssi() and on_connect then
                    on_connect(); on_connect = nil
                end
                ftr.sleep(7000)
            end
        end)
    end,
    stop = function(self)
        wifi.sta.disconnect()
        self.running = false
        print 'wifi disconnected'
    end
}
