local WS = (ldfile('secrets.lua') or {}).WS

return {
    client = nil,
    running = false,
    connected = false,
    on_receive = nil,
    connect = function(self, on_connect)
        if not WS then return false end
        self.running = true
        self.client = websocket.createClient()
        self.client:on("connection", function()
            print(string.format('connected to %s', WS.url))
            self.connected = true
            if on_connect then on_connect(); on_connect = nil end
        end)
        self.client:on("receive", function(_, msg, opcode)
            if self.on_receive then
               node.task.post(function() self:on_receive(msg, opcode) end)
            end
        end)
        self.client:on("close", function(client, status)
            print('WebSocket closed', status)
            self.connected = false
            if self.running and status ~= 0 then
                local tt = tmr.create()
                tt:alarm(1000, tmr.ALARM_SINGLE, function()
                    if self.running then
                        print('Reconnecting')
                        self:connect(on_connect)
                    end
                end)
            end
            self.client:on("connection", f_stub)
            self.client:on("receive", f_stub)
            self.client:on("close", f_stub)
            self.client = nil
        end)
        self.client:connect(WS.url)
    end,
    send = function(self, message)
        if self.connected then self.client:send(message, 1) end
    end,
    fifo = fifo_new(),
    sender = nil,
    buffered_send = function (self, message)
        if fifo_empty(self.fifo) then
            self.sender = tmr.create()
            self.sender:alarm(25, tmr.ALARM_AUTO, function()
                local msg = fifo_pop(self.fifo)
                if msg then
                    if msg ~= '\n' then self:send(msg) end
                else
                    self.sender:unregister()
                end
            end)
        end
        fifo_push(self.fifo, message)
    end,
    close = function(self)
        self.running = false
        self.client:close()
    end
}
