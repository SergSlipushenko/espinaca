-- Application example
ftr = require 'futures'
leds = require 'leds'
cfg = dofile 'config.lua'
mhz19 = require 'mhz19' 

leds:init(cfg.led_intensity, 8)
mhz19:init(cfg.mhz19_pin)

local _connected = false

function run()
    leds:write(string.rep(leds.g,2) .. string.rep(leds.y,2) .. string.rep(leds.r,2) .. string.rep(leds.w,2))
    mq:subscribe('actuators/led',0, function(msg)
        local iter = string.gmatch(msg, '%d+')
        local r, g, b = tonumber(iter()),tonumber(iter()),tonumber(iter())
        print(r, g, b)
        leds:write(string.rep(string.char(g,r,b),leds.total))
    end)
    
    mq:subscribe('node/stdin', 0, function(msg)
        if _connected and msg == ':q!' then 
            _connected = false
            node.output(nil)
            return
        end
        if not _connected then 
            _connected = true
            node.output(function(msg) 
                if mq.running then
                    mq:publish('node/stdout', msg)
                end
            end, 1)       
        end
        if _connected then node.input(msg) end
    end)
      
    while true do
        mhz19:get_co2_level(function(ppm) 
            mq:publish('sensors/mhz19', '{"co2":'..ppm..'}') 
        end)
        ftr.sleep(10000)
    end
end
