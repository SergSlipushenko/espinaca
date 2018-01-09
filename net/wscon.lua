return {
    client = nil,
    running = false,
    connected = false,
    on_receive = nil,
    on_reconnect = nil,
    fifo_send = {},
    connect = function(self, on_connect)
        local WS = (ldfile('secrets.lua') or {}).WS
        if not WS then return false end
        self.sender = tmr.create()
        self.sender:register(50, tmr.ALARM_AUTO, function(_sender)
            local msg = table.remove(self.fifo_send, 1)
            if msg then
                if msg ~= '\n' then self:send(msg) end
            else
                _sender:stop()
            end
        end)
        self.running = true
        self.client = websocket.createClient()
        self.client:on("connection", function()
            self.connected = true
            if on_connect then on_connect(); on_connect = nil end
            uart.write(0, 'connected to ', WS.url, '\n')
        end)
        self.client:on("receive", function(_, msg, opcode)
            if self.on_receive then
                node.task.post(function()
                    self:on_receive(msg, opcode)
                end)
            end
        end)
        self.client:on("close", function(client, status)
            uart.write(0, 'WebSocket closed: '..status..'\n')
            self.connected = false
            if self.running and status ~= 0 then
                local tt = tmr.create()
                tt:alarm(1000, tmr.ALARM_SINGLE, function()
                    if self.running then
                        uart.write(0, 'Reconnecting\n')
                        local on_reconnect = self.on_reconnect
                        self:connect(on_reconnect)
                    end
                end)
            end
            client:on("connection", f_stub)
            client:on("receive", f_stub)
            client:on("close", f_stub)
            client = nil
        end)
        self.client:connect(WS.url)
    end,
    send = function(self, message)
        if self.connected then self.client:send(message, 1) end
    end,
    buffered_send = function (self, message)
        if next(self.fifo_send) == nil then
            self.sender:start()
        end
        table.insert(self.fifo_send, message)
    end,
    close = function(self)
        self.sender:register(1, tmr.ALARM_SINGLE, f_stub)
        self.sender:unregister()
        self.sender = nil
        self.running = false
        self.client:close()
    end
}
