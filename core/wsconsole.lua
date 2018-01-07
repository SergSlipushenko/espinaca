return function()
    local cfg = ldfile('main_cfg.lua') or {}
    service = cfg.service == nil and NODEID or cfg.service
    cfg = nil
    nt.deploy({ws=true})
    nt.ws:send('join '..service)
    nt.ws.on_reconnect = function()
        nt.ws:send('join '..service)
    end
    nt.ws.on_receive = function(_, msg, _)
        node.input(msg)
    end
    node.output(function(result)
        if nt.ws then nt.ws:buffered_send(result) end
    end, 1)
    print('console connected')
end
