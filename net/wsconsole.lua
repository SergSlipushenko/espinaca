return function(on_connect)
    local cfg = ldfile('main_cfg.lua') or {}
    local service = cfg.service == nil and NODEID or cfg.service
    cfg = nil
    ldfile('wificon.lua'):start(function()
        local ws = ldfile('wscon.lua')
        ws:connect(function()   
            ws.on_receive = function(_, msg, _)
                node.input(msg)
            end
            node.output(function(result)
                if ws then ws:buffered_send(result) end
            end, 1)
            if on_connect then on_connect(); on_connect=nil end
            uart.write(0, 'console connected\n')
        end)
    end)
end
