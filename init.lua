print(wifi.sta.getip())
--nil
wifi.setmode(wifi.STATION)
station_cfg={}
station_cfg.ssid="xiaorenren"
station_cfg.pwd="***"
wifi.sta.config(station_cfg)
print(wifi.sta.getip())
--192.168.18.110
-- a simple http server

require("telnet_srv")
require("LeweiMqtt")
require("Sensor")


srv=net.createServer(net.TCP) 
srv:listen(80,function(conn) 
    conn:on("receive",function(conn,payload) 
    --print(payload) 
    --sensors = LeweiMqtt.getSensorValues()
    --sensors_str = ""
    --for i,v in pairs(sensors) do 
    --    sensors_str = sensors_str..i..":"..v.."\n"
    --end
    conn:send("<h1> This is xiaohao's 7 nodemcu!</h1><h2>"..Sensor.getSensorsStat().."</h2>")
    --conn:send("<h1> This is xiaohao's 1 nodemcu!</h1>")
    end) 
end)

Sensor.setGateWayAndUserKey("02","f1af**")
Sensor.run()

