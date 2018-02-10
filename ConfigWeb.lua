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





function writeUserInfo()
    file.remove("user_info.lua")
    user_info = file.open("user_info.lua","w")
    user_info:writeline("ssid=\"".._ssid.."\"")
    user_info:writeline("passwd=\"".._passwd.."\"")
    user_info:writeline("gateway=\"".._gateway.."\"")
    user_info:writeline("userkey=\"".._userkey.."\"")
    user_info:close()
    user_info:flush()
    print("writeUserInfo")
    node.restart()
end    



srv=net.createServer(net.TCP) 

srv:listen(80,function(conn) 
    conn:on("receive", function(client,request)
            local buf = "<h1> Hello, NodeMcu.</h1>"
        
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
                _gateway = _GET.gateway
                _userkey = _GET.userkey
                writeUserInfo()
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
    end)
    conn:on("sent", function (c) c:close() end)
end)



