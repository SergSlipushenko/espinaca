# espinaca

Set of Lua modules for building simple IoT apps using ESP modules, NodeMCU
firmware, WiFi and MQTT

#### It provides:

* Non-blocking sleep. You can run ESP chip in 1 min sleep without negative
  side effects. Also it allow to now-blocking wait for async data,
  but how cares =)
* WiFi connection to set of access points with auto-reconnect
* MQTT connection with autoreconnect even after WiFi reconnect.
* Poorman cron. It can run set of tasks according to periodic schedule. Deep
  sleep between tasks is supported

#### How to use:

* Upload all modules from core/ folder into ESP flash
* Upload required hardware support modules from /lib forder
* Upload scripts of your app
* Update main_cfg.lua according to your application 
* Upload secrets.lua with WiFi AP names/passwords and MQTT credentials
* Run dofile('_init.lua') to make sure that everything is working and there no
  boot loop
* Rename _init.lua to init.lua
* PROFIT!!!

