return function()
    if nt.wifi and nt.wifi.running then
        local api_key = (ldfile('secrets.lua') or {}).api_key
        if api_key then
            local url=URL:format(api_key,ppm, temp,hum,press,heap)
            print(url)
            http.get(url, nil, function(c,d) print(c) end)
        end
    end
end