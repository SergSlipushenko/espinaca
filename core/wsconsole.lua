return function(service_name)
    nt.deploy({ws=true})
    nt.ws:send('join '..service_name)
    nt.ws.on_reconnect = function()
        nt.ws:send('join '..service_name)
        print('console connected')
    end
    nt.ws.on_receive = function(_, msg, _)
        node.input(msg)
    end
    node.output(function(result)
        if nt.ws then nt.ws:buffered_send(result) end
    end, 1)
    print('console connected')
end
