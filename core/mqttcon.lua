require 'utils'
local node_name = string.format('NODE-%x', node.chipid()):upper()
local routes = {}
local dispatch = function(_, topic, message)
    if routes[topic] then routes[topic].handler(message) end
end
local MQTT = (ldfile('secrets.lua') or {}).MQTT
local client = mqtt.Client(node_name, 120, MQTT.user, MQTT.pass)
return {
    node_name=node_name,
    routes = routes,
    running = false,
    client = client,
    connect = function(self)
        if not MQTT then return false end
        local ft = ftr.Future():timeout(20000)
        local cbk = ft:callbk()
        local errcbk = ft:errcallbk()
        self.client:connect(MQTT.server, MQTT.port, 0, function(c) cbk(c) end, function(c,r) errcbk(c,r) end)
        ok = ft:wait()
        cbk = nil
        errcbk = nil
        if ok then
            print('connected to MQTT as ' .. node_name)
            local ff = ftr.Future()
            for topic,v in pairs(routes) do
                local cbk = ff:callbk()
                if self.client:subscribe(topic, v.qos, function() cbk() end) then
                    ff:wait(); cbk = nil
                    print('subscribed to '..topic)
                end
            end
            self.client:on('message', dispatch)
            return true
        else
            local _,reason = ft:result()
            return false, reason
        end
    end,
    start = function(self, on_connect)
        if self.running and on_connect then 
            node.task.post(function() on_connect(ok,err); on_connect = nil end)
            return 
        end
        self.running = true
        self:try_to_connect(on_connect)
    end,   
    try_to_connect = function(self, on_connect)
        self.watchdog = tmr.create()
        self.watchdog:alarm(1000, tmr.ALARM_AUTO, function() self:_connect(on_connect) end)
        self:_connect(on_connect)
    end,
    _connect = function(self, on_connect)
        if self.connecting then return end
        ftr.spawn(function()
            self.connecting = true
            self.client:close()
            ftr.sleep(200)
            ok, err = self:connect()
            if ok then
                self.watchdog:unregister()
                self.watchdog = nil
                self.client:on('offline', function()
                    self.client:on('offline', function() end)
                    self:try_to_connect()
                end)
                if on_connect then on_connect(ok,err); on_connect = nil end
            else
                if err then print('failed to connect to MQTT. Reason: ' .. err)
                else print('failed to connect to MQTT. Reason: timeout') end                    
            end
            self.connecting = false
        end)
    end,
    stop = function(self)
        self.running = false
        self.connecting = false
        if self.watchdog then
            self.watchdog:unregister()
            self.watchdog = nil
        end
        self.client:on('offline', function() end)
        self:close()
    end,
    subscribe = function(self, topic, qos, handler)
        routes[topic] = {handler=handler, qos=qos}
        self:close()
    end,
    unsubscribe = function(self, topic)
        routes[topic] = nil
        self:close()
    end,
    publish = function(self,topic, payload, qos, retain, async)
        if async then self.client:publish(topic, payload, qos or 0, retain or 0);return end
        if not self.client then return end
        local ft = ftr.Future()
        local cbk = ft:callbk()
        ft:run(self.client.publish, self.client, topic, payload, qos or 0, retain or 0, function() cbk() end)
    end,
    close = function(self)
        if not self.connecting then
            self.client:on('message', f_stub)
            self.client:close()
        end
        if self.running then self:try_to_connect() end
    end
}
