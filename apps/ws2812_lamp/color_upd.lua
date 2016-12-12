return function()
    local g, r, b = color:byte(1,3)
    local next_g, next_r, next_b = next_color:byte(1,3)
    g= g + (next_g-g)*20/100 + ((next_g-g)>0 and 1 or ((next_g-g)<0 and -1 or 0))
    r= r + (next_r-r)*20/100 +((next_r-r)>0 and 1 or ((next_r-r)<0 and -1 or 0))
    b= b + (next_b-b)*20/100 +((next_b-b)>0 and 1 or ((next_b-b)<0 and -1 or 0))
    if g < 0 then g = 0 end
    if r < 0 then r = 0 end
    if b < 0 then b = 0 end
    color = string.char(g, r, b)
    buf:shift(1)
    buf:set(1, color)
    leds:write(buf)
end