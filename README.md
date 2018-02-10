
# TODO 未完成

# AirMonitor
该项目用于NodeMCU和攀藤的PTQS1005传感器(PM2.5，TVOC，甲醛，CO2，温度和湿度)网页显示和连接乐为物联显示的简单实例

## 使用教程

- 上电后打开手机或者带wifi的pc 搜索 wifi；ssid为 `ESP8266_*`,password是`12345678`
- 连接后，网页代开`192.168.123.4.1` 
- 网页上配置本地要连接的wifi的ssid和passwd，乐为物联的gateWay和uesrKey(如果不需要乐为物联可以不填)
- 手机或者带wifi的pc切换到本地wifi。可以直接网页打开nodemcu的IP地址(可以通过路由器网页获得)查看AirMonitor的状态， 也可以直接登录乐为物联来查看AirMonitor的状态(有图表统计还优化手机网页端)
- [乐为物联教程](https://www.kancloud.cn/lewei50/lewei50-usermanual/380598)


## 未实现的功能

- 掉电重启后能保存住配置好的wifi的ssid和passwd，乐为物联的gateWay和uesrKey，不需要重新配置，既可以继续工作   

- 长按reset键，能重置

## 文件列表

- `init.lua`  nodemcu入口
- `LeweiMqtt.lua`  连接乐为物联上传传感器信息 [参考github工程](https://github.com/lewei50/NodeMCU-AirMonitor) 
- `telent_srv.lua` 可以通过`luatool.py`上传`lua`代码到`nodemcu`
- `luatool.py` 使用TCP/IP的方式上传代码到nodeMCU: [github原工程](https://github.com/4refr0nt/luatool) 
`wget https://raw.githubusercontent.com/4refr0nt/luatool/master/luatool/luatool.py` 使用该命令下载`luatool.py`到本地

## [nodemcu的简易介绍与使用]((https://xiaohaoliang.github.io/2018/01/29/nodemcu%E5%B0%9D%E8%AF%95/))
