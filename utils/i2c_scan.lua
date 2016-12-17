require 'commons'
pins = require 'pins'
id=0
sda=pins.IO5
scl=pins.IO4
i2c.setup(id,sda,scl,i2c.SLOW)
for i=0,127 do
  i2c.start(id)
  resCode = i2c.address(id, i, i2c.TRANSMITTER)
  i2c.stop(id)
  if resCode == true then print("We have a device on address 0x" .. string.format("%02x", i) .. " (" .. i ..")") end
end
