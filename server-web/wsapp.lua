local skynet = require "skynet"
local websocket = require "websocket"


-- websocket回调方法
local handler = {}
local FD_TO_WEBSOCKET = {}

function handler.on_open(ws)
    skynet.error(string.format("Client connected: %s", ws.addr))
    local fd = ws.fd
    FD_TO_WEBSOCKET[fd] = ws
    ws:send_text("hello")
end

function handler.on_message(ws, msg)
    skynet.error(string.format("on_message fd = %s , msg = %s", ws.fd, msg))
    -- TODO:
    print(msg)
    if msg.event == 'login' then
        print("event_login-----data",msg.data)
    end
end

function handler.on_error(ws, msg)
    skynet.error(string.format("on_error fd = %s,msg = %s", ws.fd, msg))
    -- TODO:
 end

function handler.on_close(ws, fd, code, reason)
    fd = fd or ws
    FD_TO_WEBSOCKET[fd] = nil
    ws:close()
    -- TODO:
end 

local root = {}

--- http升级协议成websocket协议
function root.process(req, res)
    local fd = req.fd 
    local ws, err  = websocket.new(req.fd, req.addr, req.headers, handler)
    if not ws then
        res.body = err
        return false
    end
    ws:start()
    return false
end

return root