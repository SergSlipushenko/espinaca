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
    end,
    hsv2grb = function(h, s, v)
        local s = s or 255
        local v = v or 255
        if s == 0 then return v, v, v end
        local base = (255 - s)*v/256
        local i = h/60
        local r, g, b
        if i == 0 then r, g, b = v, (((v-base)*h)/60)+base, base
        elseif i == 1 then r, g, b = (((v-base)*(60-(h%60)))/60)+base, v, base
        elseif i == 2 then r, g, b = base, v, (((v-base)*(h%60))/60)+base
        elseif i == 3 then r, g, b = base, (((v-base)*(60-(h%60)))/60)+base, v
        elseif i == 4 then r, g, b = (((v-base)*(h%60))/60)+base, base, v
        elseif i == 5 then r, g, b = v, base, (((v-base)*(60-(h%60)))/60)+base end
        return g, r, b
    end    
}
return leds
