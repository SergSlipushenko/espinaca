-- Application example
leds=dofile('leds.lua')
cfg=dofile('config.lua')
leds:init(cfg.led_intensity, 8)
function run()
    leds:write(string.rep(leds.g,2) .. string.rep(leds.y,2) .. string.rep(leds.r,2) .. string.rep(leds.w,2))
    mq:subscribe('actuators/led',0, function(msg)
        local iter = string.gmatch(msg, '%d+')
        local r, g, b = tonumber(iter()),tonumber(iter()),tonumber(iter())
        print(r, g, b)
        leds:write(string.rep(string.char(g,r,b),leds.total))
    end)
end
