return function()
    require 'commons'
    nt.deploy({mqtt=true})
    local connected = false
    local node_name = string.format('NODE-%x', node.chipid()):upper()
    nt.mqtt:subscribe('node/'..node_name..'/stdin', 0, function(msg)
        if connected and msg == ':q!\n' then 
            connected = false
            node.output(nil)
            print('MQTT console disconnected')
            return
        end
        if not connected then 
            connected = true
            node.output(function(msg) 
                if nt.mqtt.running then
                    nt.mqtt:publish('node/'..node_name..'/stdout', msg, 0, 0, true)
                end
            end, 1)
            print('MQTT console connected')        
        end
        if connected then
            nt.mqtt:publish('node/'..node_name..'/stdout', msg, 0, 0, true) 
            node.input(msg) 
        end
    end)
    print('Publish discovery')
    nt.mqtt:publish('node/discover/'..node_name, node_name, 0, 1, true)    
end
