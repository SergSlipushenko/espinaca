--[[
The module introduces cooperative multithreading for Nodemcu platform.
It works on top of callbacks and reuses system scheduler. Basically, it is
nothing more then converter callbacks to async/await-like interface. With this
module it is possible to do not-blocking sleeps `futures.sleep(1000)` and run 
a few io-waiting jobs in parallel:
`futures.spawn(dns_resovle); futures.spawn(send_http_req)`

Future class represents asynchronously getting data. Instead of callbacks
it allows to get async result in the same thread without blocking of internal 
system processes. Future.callbk set up callback function for retriving data 
and then Future.result waits for this callback and returns retrieved data from 
callback call.
IMPORTANT NOTE: Future.result will work properly only if function where it was
used was runned with future.spawn.
]]

local Future = function()
    -- IMPORTANT: Futures with timeout CAN NOT be reused due to prevent side effects
    return {
        callbk = function(self)
            self.co = coroutine.running()
            self._result = nil
            self.done = false
            self.pending = true
            if self.tmr and (self.tmr:state() ~= nil) then
                self.tmr:start()
            end    
            return function(...)
                if self.tmr and (self.tmr:state() ~= nil) then 
                    self.tmr:unregister() 
                end
                self:resolve(unpack(arg))
            end
        end,
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
        result = function(self)
            if not(self.pending) then error('Callback not set') end
            coroutine.yield()
            if self._result then 
                return unpack(self._result) 
            end
        end
    }
end

return {
    spawn = function(f)
        node.task.post(function() 
            coroutine.wrap(f)() 
        end)
    end,
    sleep = function(ms)
        local tt = tmr.create()
        local ff = Future()
        tt:alarm(ms,tmr.ALARM_SINGLE, ff:callbk())
        ff:result()
    end,
    Future = Future
}
