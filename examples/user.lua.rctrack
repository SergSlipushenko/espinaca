-- Application example
gpio.mode(3, gpio.OUTPUT) --green
gpio.mode(4, gpio.OUTPUT) --blue
gpio.mode(7, gpio.OUTPUT) --white
gpio.mode(8, gpio.OUTPUT) --yellow

function run()
    mq:subscribe('rc/track/move',0, function(msg)
        print('move ' .. msg)
        if msg == 'f' then
            gpio.write(3, gpio.HIGH)
            gpio.write(4, gpio.LOW)
        end
        if msg == 'b' then
            gpio.write(4, gpio.HIGH)
            gpio.write(3, gpio.LOW)
        end
        if msg == 's' then
            gpio.write(4, gpio.LOW)
            gpio.write(3, gpio.LOW)
        end
    end)
    mq:subscribe('rc/track/turn',0, function(msg)
        print('turn ' .. msg)
        if msg == 'r' then
            gpio.write(7, gpio.HIGH)
            gpio.write(8, gpio.LOW)
        end
        if msg == 'l' then
            gpio.write(8, gpio.HIGH)
            gpio.write(7, gpio.LOW)
        end
        if msg == 's' then
            gpio.write(8, gpio.LOW)
            gpio.write(7, gpio.LOW)
        end
    end)    
end
