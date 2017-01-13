local skynet = require "skynet"
require "skynet.manager"
local mongo = require "mongo"

local CMD ={}
local pool={}

local maxconn
local index =2

local function getconn(sync)
	local db
	if sync then
		db = pool[1]
	else
		db = pool[index]
		assert(db)
		index = index+1
		if index > maxconn then
			index =2
		end
	end
	return db
end

function CMD.start()
	maxconn = tonumber(skynet.getenv("mongo_maxconn")) or 10
	assert(maxconn >=2)
	for i=1,maxconn do
		local db = mongo.client{
			host = skynet.getenv("mongo_host"),
			port = tonumber(skynet.getenv("mongo_port")),
			database = skynet.getenv("mongo_db"),
			user = skynet.getenv("mongo_user"),
			password = skynet.getenv("mongo_pwd"),
			max_packet_size = 1024*1024
		}
		if db then
			table.insert(pool,db)
			-- if need set charset?
		else
			skynet.error("mongo db connect error")
		end
	end
end

function CMD.excute(state,sync)
	local db = getconn(sync)
	return 
end

function CMD.stop()
	for _,db in pairs(pool) do
		db:logout()
	end
	pool ={}
end

skynet.start(function()
	skynet.dispatch("lua",function(session,source,cmd,...)
		local f = assert(CMD[cmd],cmd.."not found")
		skynet.retpack(f(...))
	end)
	skynet.register(SERVICE_NAME)
end)