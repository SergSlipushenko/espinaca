local ftr=require('futures')
local node_name = string.format('NODE-%x', node.chipid()):upper()
local ftoff = ftr.Future()
local routes = {}
local dispatch = function(client, topic, message)
    if routes[topic] then routes[topic].handler(message) end
end

return {
    node_name=node_name,
    routes = routes,
    running = false,
    _start = function(self, on_connect)
        local secrets = dofile('secrets.lua')
        local m = mqtt.Client(node_name, 120, secrets.MQTT.user, secrets.MQTT.pass)
        self.mq_client = m
        local ff = ftr.Future()
        print('Try to connect to MQTT server ' .. secrets.MQTT.server)
        while self.running do
            m:close()
            ftr.sleep(500)
            ft = ftr.Future()
            ft:timeout(3000)
            m:connect(secrets.MQTT.server, secrets.MQTT.port, 0, ft:callbk())
            if ft:result() then
                print('connected to MQTT as ' .. node_name)
                for topic,v in pairs(routes) do
                    if m:subscribe(topic, v.qos, ff:callbk()) then
                        ff:result()
                        print('subscribed to '..topic)
                    end
                end
                m:on('message', dispatch)
                if on_connect then on_connect(); on_connect = nil end
                m:on('offline', ftoff:callbk())
                ftoff:result()
                print('MQTT connection went offline.')
                if self.running then print('reconnect...') end
            else
                print('failed to connect to MQTT. retry...')
            end
            ft = nil
            ftr.sleep(500)
        end
        print('mqtt stopped')
    end,
    start = function(self, on_connect)
        self.running = true
        ftr.spawn(function() self:_start(on_connect) end)
    end,
    stop = function(self)
        self.running = false
        self:close_connection()    
    end,
    subscribe = function(self, topic, qos, handler)
        routes[topic] = {handler=handler, qos=qos}
        self:close_connection()
    end,
    unsubscribe = function(self, topic)
        routes[topic] = nil
        self:close_connection()
    end,
    publish = function(self,topic, payload)
        if not self.mq_client then return end
        self.mq_client:publish(topic, payload, qos or 0, retain or 0)
    end,
    close_connection = function(self)
        if not self.mq_client then return end
        if ftoff.pending then 
            self.mq_client:close()
            ftoff:resolve()
        end    
    end
}
