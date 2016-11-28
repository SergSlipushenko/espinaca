return {
    _start = -1,
    init = function (self, _pin)
        self._pin = _pin
    end,
    get_co2_level = function(self, on_done)
        gpio.trig(self._pin, "both", function(state) 
            if state==1 then 
                self._start = tmr.now() 
            else 
                if self._start<=0 then return end
                gpio.trig(self._pin, "none")
                local _end = tmr.now() 
                local ppm=(_end - self._start - 2000)*5/1000
                self._start=-1
                node.task.post(function() on_done(ppm) end)
            end
        end) 
    end
}
