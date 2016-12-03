return {
    init = function(self, pins)
        spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 8, 16, spi.FULLDUPLEX)
        self.disp = u8g.pcd8544_84x48_hw_spi(pins.cs or 8, pins.dc or 6, pins.res)
        self:set_font()
    end,

    get_fonts = function(self)
        local fonts = {}
        for key,val in pairs(u8g) do 
            if key:sub(1,4)=='font' then 
                table.insert(fonts, key)
            end
        end
        return fonts
    end,

    set_font = function(self, font)
        self.disp:setFont(font or u8g[dsp:get_fonts()[1]])
        self.disp:setDefaultForegroundColor()
        self.disp:setFontPosTop()
    end,

    draw = function(self, content)
        self.disp:firstPage()
        repeat content(self.disp) 
        until self.disp:nextPage() == false
    end
}
