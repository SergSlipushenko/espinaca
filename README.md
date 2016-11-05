# espcore
Core for building simple Lua apps on top of NodeMcu/MQTT.

It provides Wifi and MQTT connections with autoreconnect out-of-the-box.
Also it introduces Future object for retrieving async data in sync way.

User app should be placed in user.lua. It is executed after connections
to Wifi and MQTT are established.
