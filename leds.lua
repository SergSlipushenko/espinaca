local leds = {
    init = function(self, intn, total)
        self.g = string.char(intn,0,0)
        self.r = string.char(0,intn,0)
        self.b = string.char(0,0,intn)
        self.y = string.char(intn/2,intn/2,0)
        self.m = string.char(0,intn/2,intn/2)
        self.c = string.char(intn/2,0,intn/2)
        self.z = string.char(0,0,0)
        self.w = string.char(intn/3,intn/3,intn/3)
        self.total = total
        ws2812.init()
        ws2812.write(string.rep(self.z,total))
    end,
    write = function(self, ...)
        ws2812.write(unpack(arg))
    end,
    show = function(self, led, back, n)
        ws2812.write(string.rep(led,n) .. string.rep(back,self.total-n))
    end
}
return leds