require 'utils'
local node_name = string.format('NODE-%x', node.chipid()):upper()
local routes = {}
local dispatch = function(_, topic, message)
    if routes[topic] then routes[topic].handler(message) end
end
return {
    node_name=node_name,
    routes = routes,
    running = false,
    _start = function(self, on_connect)
        self.ftoff = ftr.Future()
        local MQTT = dofile('secrets.lua').MQTT
        local m = mqtt.Client(node_name, 120, MQTT.user, MQTT.pass)
        self.client = m
        local ff = ftr.Future()
        print('Try to connect to MQTT server ' .. MQTT.server)
        while self.running do
            ftr.sleep(200)
            local ft = ftr.Future()
            ft:timeout(20000)
            m:close()            
            ftr.sleep(200)
            m:connect(MQTT.server, MQTT.port, 0, ft:callbk(), ft:errcallbk())
            if ft:wait() then
                print('connected to MQTT as ' .. node_name)
                for topic,v in pairs(routes) do
                    if m:subscribe(topic, v.qos, ff:callbk()) then
                        ff:result()
                        print('subscribed to '..topic)
                    end
                end
                m:on('message', dispatch)
                if on_connect then on_connect(); on_connect = nil end
                m:on('offline', self.ftoff:callbk())
                self.ftoff:wait()
                print('MQTT connection went offline.')
            else
                local _, reason = ft:result()
                if reason then print('failed to connect to MQTT. Reason: ' .. reason)
                else print('failed to connect to MQTT. Reason: timeout') end                    
            end
            if self.running then print('reconnect...') end
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
    publish = function(self,topic, payload, qos, retain)
        if not self.client then return end
        local ft = ftr.Future()
        ft:run(self.client.publish, self.client, topic, payload, qos or 0, retain or 0, ft:callbk())
    end,
    close_connection = function(self)
        if self.client and ftoff.pending then 
            self.client:close()
            self.ftoff:resolve()
        end    
    end
}
