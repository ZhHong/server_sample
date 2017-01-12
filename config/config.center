skynetroot = "./common/skynet/"
thread = 8
logger = nil
logpath = "."
harbor = 0
start = "main"	-- main script
bootstrap = "snlua bootstrap"	-- The service for bootstrap

debug_port = 8103

-- 集群名称配置文件
cluster = "./cluster/clustername.lua"
nodename = "center"

log_dirname = "log"
log_basename = "center"

gameservice = "./server-center/?.lua;" ..
			  "./common/?.lua;" ..
			  "./cluster/?.lua"

-- LUA服务所在位置
luaservice = skynetroot .. "service/?.lua;" .. gameservice
snax = gameservice

-- 用于加载LUA服务的LUA代码
lualoader = skynetroot .. "lualib/loader.lua"
preload = "./common/global/preload.lua"	-- run preload.lua before every lua service run

-- C编写的服务模块路径
cpath = skynetroot .. "cservice/?.so"

-- 将添加到 package.path 中的路径，供 require 调用。
lua_path = skynetroot .. "lualib/?.lua;" ..
		   "./common/lualib/?.lua;" ..
		   "./common/global/?.lua" 

-- 将添加到 package.cpath 中的路径，供 require 调用。
lua_cpath = skynetroot .. "luaclib/?.so;" .. "./common/luaclib/?.so"

-- 后台模式
--daemon = "./center.pid"

port = 5190					-- 监听端口
maxclient = 100				-- 最大连接数

mysql_maxconn = 10					-- mysql数据库最大连接数
mysql_host = "127.0.0.1"	-- mysql数据库主机
mysql_port = 3306			-- mysql数据库端口
mysql_db = "sever_sample"	-- mysql数据库库名
mysql_user = "root"			-- mysql数据库帐号
mysql_pwd = "root"			-- mysql数据库密码

redis_maxinst = 4			-- redis最大实例数

redis_host1 = "127.0.0.1"	-- redis数据库IP
redis_port1 = 6380			-- redis数据库端口
redis_auth1 = "123456"		-- redis数据库密码

redis_host2 = "127.0.0.1"	-- redis数据库IP
redis_port2 = 6381			-- redis数据库端口
redis_auth2 = "123456"		-- redis数据库密码

redis_host3 = "127.0.0.1"	-- redis数据库IP
redis_port3 = 6382			-- redis数据库端口
redis_auth3 = "123456"		-- redis数据库密码

redis_host4 = "127.0.0.1"	-- redis数据库IP
redis_port4 = 6383			-- redis数据库端口
redis_auth4 = "123456"		-- redis数据库密码


mongo_maxconn =10
mongo_host ="127.0.0.1"
mongo_port = 27017
mongo_db =""
mongo_user =""
mongo_pwd =""