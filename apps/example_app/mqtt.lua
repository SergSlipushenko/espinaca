return function()
    nt.deploy({wifi=true,mqtt=true})
    nt.mqtt:publish('node/'..nt.mqtt.node_name..'/heap', node.heap())
    nt.mqtt:publish('node/'..nt.mqtt.node_name..'/vdd', adc.readvdd33())
    --turn off WIFI gracefully
    nt.deploy({wifi=false})
end
