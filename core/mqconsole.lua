if not mq then return end
local connected = false
local node_name = string.format('NODE-%x', node.chipid()):upper()
mq:subscribe('node/'..node_name..'/stdin', 0, function(msg)
    if connected and msg == ':q!\n' then 
        connected = false
        node.output(nil)
        return
    end
    if not connected then 
        connected = true
        node.output(function(msg) 
            if mq.running then
                mq:publish('node/'..node_name..'/stdout', msg)
            end
        end, 1)       
    end
    if connected then
        mq:publish('node/'..node_name..'/stdout', msg) 
        node.input(msg) 
    end
end)