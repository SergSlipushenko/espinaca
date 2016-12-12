return function()
    next_color = string.char(leds.hsv2grb(math.random(0,11)*30, sat, val))
end
