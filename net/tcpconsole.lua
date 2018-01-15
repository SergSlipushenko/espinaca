return function()
    ldfile('wificon.lua'):start(function()
        local srv = net.createServer(net.TCP, 180)
        srv:listen(2323, function(sckt)
            local fifo = {}
            local fifo_drained = true
            local function sender(sckt)
                if #fifo > 0 then
                    sckt:send(table.remove(fifo, 1))
                else
                    fifo_drained = true
                end
            end
            local function s_output(str)
                table.insert(fifo, str)
                if sckt ~= nil and fifo_drained then
                    fifo_drained = false
                    sender(sckt)
                end
            end
            node.output(s_output, 1)    
            sckt:on("receive", function(_, l)
                s_output(l)
                uart.write(0, l)
                node.input(l)
            end)
            sckt:on("disconnection", function()
                node.output(nil)
                uart.write(0, 'disconnected')
            end)
            sckt:on("sent", sender)
        end)
        local service = (ldfile('main_cfg.lua') or {}).service
        local service = service or NODEID
        mdns.register(service, {hardware='NodeMCU', port=2323})    
    end)
end
