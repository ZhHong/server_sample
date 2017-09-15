skynetroot = "./common/skynet/"
thread = 8
logger = nil
logpath = "."
harbor = 0
start = "main"	-- main script
bootstrap = "snlua bootstrap"	-- The service for bootstrap

-- 集群名称配置文件
cluster = "./cluster/clustername.lua"

log_dirname = "log"
log_basename = "server-web"

webservice = "./server-web/?.lua;" ..
			   "./common/?.lua;" ..
                     "./server-web/?.lua"..
			   "./cluster/?.lua"

-- LUA服务所在位置
luaservice = skynetroot .. "service/?.lua;" .. webservice
snax = webservice

-- 用于加载LUA服务的LUA代码
lualoader = skynetroot .. "lualib/loader.lua"
preload = "./server-web/preload.lua"	-- run preload.lua before every lua service run

-- C编写的服务模块路径
cpath = skynetroot .. "cservice/?.so"

-- 将添加到 package.path 中的路径，供 require 调用。
lua_path = skynetroot .. "lualib/?.lua;" ..
		   "./common/lualib/?.lua;" ..
		   "./common/global/?.lua"..
               "./common/?.lua"..
               "./server-web/?.lua"

-- 将添加到 package.cpath 中的路径，供 require 调用。
lua_cpath = skynetroot .. "luaclib/?.so;" .. "./common/luaclib/?.so"

-- 后台模式
--daemon = "./login.pid"

port = 5188				-- 监听端口
debug_port = 8101       -- debug端口