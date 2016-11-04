local ftr=require('futures')
local secrets = require('secrets')
local node_name = string.format('NODE-%x', node.chipid()):upper()
local m = mqtt.Client(node_name, 120, secrets.MQTT.user, secrets.MQTT.pass)
local ftoff = ftr.Future()
local routes = {}

local dispatch = function(client, topic, message)
    if routes[topic] then routes[topic].handler(message) end
end

local close_connection = function()
    if ftoff.pending then 
        m:close()
        ftoff:resolve()
    end    
end

return {
    node_name=node_name,
    routes = routes,
    running = false,
    _start = function(self)
        local ff = ftr.Future()
        print('Try to connect to MQTT server ' .. secrets.MQTT.server)
        while self.running do
            m:close()
            ftr.sleep(2000)
            ft = ftr.Future()
            ft:timeout(3000)
            m:connect(secrets.MQTT.server, 1883, 0, ft:callbk())
            if ft:result() then
                print('connected to MQTT as ' .. node_name)
                for topic,v in pairs(routes) do
                    if m:subscribe(topic, v.qos, ff:callbk()) then
                        ff:result()
                        print('subscribed to '..topic)
                    end
                end
                m:on('message', dispatch)
                m:on('offline', ftoff:callbk())
                ftoff:result()
                print('MQTT connection went offline.')
                if self.running then print('reconnect...') end
            else
                print('failed to connect to MQTT. retry...')
            end
            ft = nil
            ftr.sleep(2000)
        end
        print('mqtt stopped')
    end,
    start = function(self)
        self.running = true
        ftr.spawn(function() self:_start() end)
    end,
    stop = function(self)
        self.running = false
        close_connection()    
    end,
    subscribe = function(self, topic, qos, handler)
        routes[topic] = {handler=handler, qos=qos}
        close_connection()
    end,
    unsubscribe = function(self, topic)
        routes[topic] = nil
        close_connection()
    end,
    publish = function(self,topic, payload)
        m:publish(topic, payload, qos or 0, retain or 0)
    end
}