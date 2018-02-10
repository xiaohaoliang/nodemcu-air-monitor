

-- remove user_info.txt
local flashButton = 3
gpio.mode(flashButton,gpio.INT)

function pin3cb(level)
    print("remove user_info")
    file.remove("user_info.lua")
    if level == 1 then 
        gpio.trig(1, "down", pin3cb) 
    else 
        gpio.trig(1, "up", pin3cb) 
    end
end
gpio.trig(flashButton, "down",pin3cb)


if( file.open("user_info.lua") ~= nil) then

    require("user_info")

    print("ssid:"..ssid)
    print("passwd:"..passwd)
    print("gateway:"..gateway)
    print("userkey:"..userkey)


    require("telnet_srv")
    require("LeweiMqtt")
    require("Sensor")

    wifi.setmode(wifi.STATION)
    station_cfg={}
    station_cfg.ssid=ssid
    station_cfg.pwd=passwd
    wifi.sta.config(station_cfg)


    srv=net.createServer(net.TCP) 
    srv:listen(80,function(conn) 
        conn:on("receive", function(client,request)
            conn:send("<h1> Hello, NodeMcu.</h1> <h2>"..Sensor.getSensorsStat().."</h2>")
        end)
        conn:on("sent", function (c) c:close() end)
    end)

    Sensor.setGateWayAndUserKey(gateway,userkey)
    Sensor.run()

else
    dofile("ConfigWeb.lua")
end    
 





