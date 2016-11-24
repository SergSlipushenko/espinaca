local Future = function()
    -- IMPORTANT: Futures with timeout CAN NOT be reused due to prevent side effects
    return {
        _callbk = function(self, success)
            self.co = coroutine.running()
            self._result = nil
            self.done = false
            self.pending = true
            self.success = nil
            if self.tmr and (self.tmr:state() == false) then
                self.tmr:start()
            end
            return function(...)
                self.success = success
                if self.tmr and (self.tmr:state() ~= nil) then 
                    self.tmr:unregister()
                end
                self:resolve(unpack(arg))
            end
        end,
        callbk = function(self) return self:_callbk(true) end,
        errcallbk = function(self) return self:_callbk() end,
        resolve = function(self, ...)
            if not(self.done) then
                self._result = arg
                self.done = true
                self.pending = false
                self.tmr = nil
                node.task.post(function() 
                    coroutine.resume(self.co)
                end)
            end
        end,
        timeout = function(self, _timeout)
            self.tmr = tmr.create()
            self.tmr:register(_timeout, tmr.ALARM_SINGLE, function()
                self:resolve()
            end)
            return self
        end,
        wait = function(self)
            if not(self.pending) then error('Callback not set') end
            coroutine.yield()
            return self.success
        end,        
        result = function(self)
            if not self.done then self:wait() end
            if self._result then 
                return unpack(self._result) 
            end
        end,
        run = function(self, f, ...)
            f(unpack(arg))
            return self:result()
        end
    }
end

return {
    spawn = function(f, ...)
        node.task.post(function() 
            coroutine.wrap(function() f(unpack(arg)) end)() 
        end)
    end,
    sleep = function(ms)
        local tt = tmr.create()
        local ff = Future()
        ff:run(tt.alarm, tt, ms,tmr.ALARM_SINGLE, ff:callbk())
    end,
    switch = function()
        local ff = Future()
        local _callbk = ff:callbk()
        node.task.post(_callbk)
        ff:wait()
    end,
    Future = Future
}
