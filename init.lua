--init
wifi.setmode(wifi.SOFTAP)
--set ap ssid and pwd
cfg={}
cfg.ssid="ESP8266_".. node.chipid()
cfg.pwd="12345678"
wifi.ap.config(cfg)
print(wifi.ap.getip())
--  http server

local _ssid,_passwd
local _gateway,_userkey

require("telnet_srv")
require("LeweiMqtt")
require("Sensor")

function connectWIFI()
    wifi.setmode(wifi.STATION)
    station_cfg={}
    station_cfg.ssid=_ssid
    station_cfg.pwd=_passwd
    wifi.sta.config(station_cfg)
    tmr.create():register(5000, tmr.ALARM_SINGLE, function()
        Sensor.setGateWayAndUserKey(_gateway,_userkey)
        Sensor.run()
      end)
end    



srv=net.createServer(net.TCP) 

srv:listen(80,function(conn) 
    conn:on("receive", function(client,request)
        local buf = "<h1> Hello, NodeMcu.</h1>"
        
        if(wifi.getmode() == wifi.STATION)then
            -- conneted wifi
            conn:send("<h1> This is xiaohao's 7 nodemcu!</h1><h2>"..Sensor.getSensorsStat().."</h2>")

        else
            buf = buf.."<h2> Configuration WIFI.</h2>"
            local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP")
            if(method == nil)then
                _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP")
            end
            local _GET = {}
            if (vars ~= nil)then
                for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                    _GET[k] = v
                end
            end
            buf = buf.."<form>"

            if(_GET.ssid ~= nil )then
                _ssid = _GET.ssid
                _passwd = _GET.passwd
            end
            if(_GET.gateway ~= nil )then
                _gateway = _GET.gateway
                _userkey = _GET.userkey
            end
            buf = buf.."<br>wifi.ssd:<br><input type=\"text\" name=\"ssid\""
            if(_ssid ~= nil)then
                buf = buf.."value=\"".._ssid
            end    
            buf = buf.."\"> <br>wifi.passwd:<br><input type=\"text\" name=\"passwd\""
            if(_passwd ~= nil)then
                buf = buf.."value=\"".._passwd
            end   
            buf = buf.."\"> <br>lewei.gateway:<br><input type=\"text\" name=\"gateway\""
            if(_gateway ~= nil)then
                buf = buf.."value=\"".._gateway
            end 
            buf = buf.."\"> <br>lewei.userkey:<br><input type=\"text\" name=\"userkey\""
            if(_userkey ~= nil)then
                buf = buf.."value=\"".._userkey
            end 
            buf = buf.."\"> <br><input type=\"submit\" value=\"Submit\"> </form>"
            
            client:send(buf)
            if(_GET.ssid ~= nil )then
                connectWIFI()
            end
        end    
    end)
    conn:on("sent", function (c) c:close() end)
end)



