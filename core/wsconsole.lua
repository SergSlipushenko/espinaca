return function()
    nt.deploy({ws=true})
    local connected = false
    nt.ws.on_receive = function(_, msg, _)
        if connected and msg == ':q!\n' then 
            connected = false
            node.output(nil)
            print('console disconnected')
            return
        end
        if not connected then 
            connected = true
            node.output(function(result)
                nt.ws:buffered_send(result)
            end, 1)
            print('console connected')
        end
        if connected then
            --nt.ws:send(msg)
            node.input(msg) 
        end
    end
end
