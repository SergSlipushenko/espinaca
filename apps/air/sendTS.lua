return function()
    if nt.wifi and nt.wifi.running then
        local api_key = ((ldfile('secrets.lua') or {}).TS or {}).api_key
        if api_key and ppm and temp and hum and press then
            local url=URL:format(api_key,ppm, temp,hum,press,heap)
            print(url)
            http.get(url, nil, function(c,d) print(c,d) end)
        end
    end
end
