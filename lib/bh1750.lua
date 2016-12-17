require 'commons'
local ADDR = 0x23
local CMD = 0x10
local i2c = i2c
local function read_data()
    i2c.start(0)
    i2c.address(0, ADDR, i2c.TRANSMITTER)
    i2c.write(0, CMD)
    i2c.stop(0)
    i2c.start(0)
    i2c.address(0, ADDR,i2c.RECEIVER)
    ftr.sleep(300)
    c = i2c.read(0, 2)
    i2c.stop(0)
    return c
end
return {
    init = function(sda, scl)
        i2c.setup(0, sda, scl, i2c.SLOW)
        i2c.start(0)
        local success = i2c.address(0, ADDR, i2c.TRANSMITTER)
        i2c.stop(0)
        if success then read_data() end
        return success
    end,
    lux = function()
        local dataT = read_data()
        local UT = dataT:byte(1) * 256 + dataT:byte(2)
        return UT*10/12
    end
}
