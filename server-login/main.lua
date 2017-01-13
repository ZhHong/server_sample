local skynet = require "skynet"
local snax = require "snax"
local cluster = require "cluster"

-- config load data from database

local config = {
}

local user = {
}

local common = {
	{ name = "user_info", key = "uname", indexkey = "uid" },
}

skynet.start(function()
	-- start console
	local console = skynet.newservice("console")
	-- start debug console
	skynet.newservice("debug_console",tonumber(skynet.getenv("debug_port")))
	-- start unique service log
	local log = skynet.uniqueservice("log")
	skynet.call(log, "lua", "start")
	local dbmgr = skynet.uniqueservice("dbmgr")
	skynet.call(dbmgr, "lua", "start", config, user, common)

	skynet.uniqueservice("logind")		-- 启动登录服务器
	cluster.open("login")
end)

