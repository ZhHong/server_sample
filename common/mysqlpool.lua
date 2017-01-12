local skynet = require "skynet"
require "skynet.manager"
local mysql = require "mysql"

local CMD = {}
local pool = {}

local maxconn
local index = 2
local function getconn(sync)
	local db
	if sync then
		db = pool[1]
	else
		db = pool[index]
		assert(db)
		index = index + 1
		if index > maxconn then
			index = 2
		end
	end
	return db
end


local function loadSql()
	local path = "./common/dbproc.sql"
	local sql_str =""
	local file = assert(io.open(path,"r"))
	if file then
		local sql_line = file:read("*line")
		while(sql_line ~= nil) do
			-- only leave sql statement
			if string.find(sql_line,"%-%-") == nil then
				sql_line =string.gsub(sql_line,"\n"," ")
				sql_line =string.gsub(sql_line,"\t"," ")
				sql_str= sql_str..sql_line
			end
			sql_line = file:read("*line")
		end
	end
	file.close()
	return sql_str
end

local function splite(str,partner)
	if str == nil or partner == nil then
		return nil
	end
	local result = {}
	for match in (str..partner):gmatch("(.-)"..partner) do
		table.insert(result,match)
	end
	return result
end

--[[
	create default setting of mysql
	1,maxconn
	2,mysql_host
	3,mysql_port
	4,db_name
	5,user
	--TODO add create default database
]]
function CMD.start()
	-- create datbase must at the begain of connect
	local dBName = skynet.getenv("mysql_db")--"server_sample_pool"--skynet.getenv("mysql_db")
	local crdb = mysql.connect{
					 host = skynet.getenv("mysql_host"),
					 port = tonumber(skynet.getenv("mysql_port")),
					 database = "",
					 user = skynet.getenv("mysql_user"),
					 password = skynet.getenv("mysql_pwd"),
					 max_packet_size = 1024 *1024
				}
	if crdb then
		-- run creat database
		-- crdb.query("set charset utf8")
		crdb:query("CREATE DATABASE IF NOT EXISTS "..dBName)
		crdb:disconnect()
	else
		skynet.error("create database error")
	end
	local crtdb = mysql.connect{
						host = skynet.getenv("mysql_host"),
						port = tonumber(skynet.getenv("mysql_port")),
						database = dBName,
						user = skynet.getenv("mysql_user"),
						password = skynet.getenv("mysql_pwd"),
						max_packet_size = 1024 *1024
						}
	if crtdb then
		-- create connect over run default sql
		-- load create database sql
		local sql_str = loadSql()
		local sql_arr = {}
		sql_arr = splite(sql_str,"//")
		for i=1 ,#sql_arr do
			-- print(">>>sql_arr["..i.."]="..sql_arr[i])
			crtdb:query(sql_arr[i])
		end
		-- this sql will procdue
		-- crtdb:query("CREATE TABLE IF NOT EXISTS `user_info`(`uid` int(11) NOT NULL AUTO_INCREMENT,`uname` varchar(50) NOT NULL,PRIMARY KEY(uid)) ENGINE= InnoDD AUTO_INCREMENT =10000 DEFAULT CHARSET = UTF8;")
		-- crtdb:query("DROP PROCEDURE IF EXISTS get_user_info; CREATE PROCEDURE get_user_info(IN in_uid int(11)) BEGIN SET @result =0;SELECT uname FROM user_info WHERE uid = in_uid;SET @result =1;END;")
		crtdb:disconnect()
	else
		skynet.error("create database filed")
	end
	maxconn = tonumber(skynet.getenv("mysql_maxconn")) or 10
	assert(maxconn >= 2)
	for i = 1, maxconn do
		local db = mysql.connect{
			host = skynet.getenv("mysql_host"),
			port = tonumber(skynet.getenv("mysql_port")),
			database = skynet.getenv("mysql_db"),
			user = skynet.getenv("mysql_user"),
			password = skynet.getenv("mysql_pwd"),
			max_packet_size = 1024 * 1024
		}
		if db then
			table.insert(pool, db)
			db:query("set charset utf8")
		else
			skynet.error("mysql connect error")
		end
	end
	
end

-- sync为false或者nil，sql为读操作，如果sync为true用于数据变动时同步数据到mysql，sql为写操作
-- 写操作取连接池中的第一个连接进行操作
function CMD.execute(sql, sync)
	local db = getconn(sync)
	return db:query(sql)
end

-- call procedue
-- proc_name: string
-- args     : table
-- aync     : bool
function CMD.callProc(proc_name,args,sync)
	local db = getconn(sync)
	local args_str = "("
	for i=1,#args do
		if i ~= #args then
			if type(args[i]) == "string" then
				args_str = args_str .."'"..args[i].."',"
			else
				args_str = args_str .. args[i] ..','
			end
		else
			if type(args_str[i]) == "string" then
				args_str = args_str .."'"..args[i].."'"
			else
				args_str = args_str .. args[i]
			end
		end 
	end
	args_str = args_str .. ")"
	local format_sql = "call "..proc_name..args_str
	skynet.error(string.format("CALL Proc[%s] Args[%s]" ,proc_name,format_sql))

	return db:query(format_sql)
end


function CMD.stop()
	for _, db in pairs(pool) do
		db:disconnect()
	end
	pool = {}
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		skynet.retpack(f(...))
	end)

	skynet.register(SERVICE_NAME)
end)
