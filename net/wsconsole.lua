return function()
    local cfg = ldfile('main_cfg.lua') or {}
    local service = cfg.service == nil and NODEID or cfg.service
    cfg = nil
    ldfile('wificon.lua'):start(function()
        local ws = ldfile('wscon.lua')
        ws:connect(function()   
            ws:send('join '..service)
            ws.on_reconnect = function()
                ws:send('join '..service)
            end
            ws.on_receive = function(_, msg, _)
                node.input(msg)
            end
            node.output(function(result)
                if ws then ws:buffered_send(result) end
            end, 1)
            uart.write(0, 'console connected')
        end)
    end)
end
