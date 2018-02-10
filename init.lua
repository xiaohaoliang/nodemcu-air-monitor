print(wifi.sta.getip())
--nil
wifi.setmode(wifi.STATION)
station_cfg={}
station_cfg.ssid="xiaorenren"
station_cfg.pwd="passwd"
wifi.sta.config(station_cfg)
print(wifi.sta.getip())
--192.168.18.110
-- a simple http server

require("telnet_srv")

local sensors_stat = "-1"
local send_count = 0
local recv_count = 0

local pm25 = -1
local hcho = -1
local co2 = -1
local Temp = -1
local Hum = -1

function resolveData(data)
    if(((string.byte(data,1)==0x42) and(string.byte(data,2)==0x4d))) then
         pm25 = (string.byte(data,5)*256+string.byte(data,6))
         hcho = (string.byte(data,10)*256+string.byte(data,11))/100
         co2 = (string.byte(data,13)*256+string.byte(data,14))
         Temp = (string.byte(data,15)*256+string.byte(data,16))/10
         Hum = (string.byte(data,17)*256+string.byte(data,18))/10
         res = ""
         res = res.."<p>dust:"..pm25.."</p>"
         res = res.."<p>CO2:"..co2.."</p>"
         res = res.."<p>HCHO:"..hcho.."</p>"
         res = res.."<p>H1:"..Hum.."</p>"
         res = res.."<p>T1:"..Temp.."</p>"
         sensors_stat = res 
    else
        recv_count = recv_count - 1
        sensors_stat = ""..recv_count      
    end
end

--require("SensorDetector")
--require("LeweiMqtt")
--require("run")


gpio.mode(4,gpio.OUTPUT)
gpio.write(4,gpio.HIGH)

uart.setup(0,9600,8,0,1,0)

tmr.alarm(0,5000, tmr.ALARM_AUTO, function()
    uart.write(0,0x42,0x4D,0xAB,0x00,0x00,0x01,0x3A);
    send_count = send_count + 1
end)

local uartTimer = tmr.create()
local rcv = ""

uart.on("data", 0,
     function(data)
        uartTimer:register(10, tmr.ALARM_SINGLE, function()
        resolveData(rcv)
        uartTimer:stop()
        rcv = ""
        end)
        rcv = rcv..data
        uartTimer:start()
      end, 0)

require("LeweiMqtt")

srv=net.createServer(net.TCP) 
srv:listen(80,function(conn) 
    conn:on("receive",function(conn,payload) 
    --print(payload) 
    --sensors = LeweiMqtt.getSensorValues()
    --sensors_str = ""
    --for i,v in pairs(sensors) do 
    --    sensors_str = sensors_str..i..":"..v.."\n"
    --end
    conn:send("<h1> This is xiaohao's 7 nodemcu!</h1><h2>"..sensors_stat.."</h2><h3>send_count="..send_count.."!</h3><p>res="..LeweiMqtt.logs().."</p>")
    end) 
end)


--LeweiMqtt.init("userKey","gateWay")
LeweiMqtt.connect()

sendTimer = tmr.create()
sendTimer:register(60000, tmr.ALARM_AUTO, function() 

LeweiMqtt.appendSensorValue("dust",pm25)
LeweiMqtt.appendSensorValue("CO2",co2)
LeweiMqtt.appendSensorValue("HCHO",hcho)
LeweiMqtt.appendSensorValue("H1",Hum)
LeweiMqtt.appendSensorValue("T1",Temp)

sensors = LeweiMqtt.getSensorValues()
count = 0
for i,v in pairs(sensors) do
          count = count + 1
end

index = 0
for i,v in pairs(sensors) do
     index = index + 1
     print(i,v,index,count)
     if(index == count) then
     --print("S")
          LeweiMqtt.sendSensorValue(i,v)
     else
     --print("A")
          LeweiMqtt.appendSensorValue(i,v)
     end
end
end)
sendTimer:start()
