return function(on_connect)
    local setup = function(ws)
        ws.on_receive = function(_, msg, _)
            node.input(msg)
        end
        node.output(function(result)
            if ws then ws:buffered_send(result) end
        end, 1)
        if on_connect then on_connect(); on_connect=nil end
        uart.write(0, 'console connected\n')
    end
    if (nt or {}).ws then 
        setup(nt.ws)
    else
        ldfile('wificon.lua'):start(function()
            local ws = ldfile('wscon.lua')
            ws:connect(function() setup(ws) end)
        end)
    end
end
