local constants = require "kong.constants"
local timestamp = require "kong.tools.timestamp"
local responses = require "kong.tools.responses"
local inspect = require('inspect')

local _M = {}

local function log(premature, conf, message)
    local current_timestamp = timestamp.get_utc()
    -- Consumer is identified by ip address or authenticated_entity id
    local identifier
    if message["authenticated_entity"] then
        identifier = message["authenticated_entity"].id
    else
        identifier = message["client_ip"]
    end

    ngx.log(ngx.ERR, "msg", inspect(message))
    ngx.log(ngx.ERR, "msg", conf.metric_counter_variable)

    -- Increment metrics for all periods if the request goes through
    local count = tonumber(message["response"]["headers"][conf.metric_counter_variable])
    ngx.log(ngx.ERR, "product count", count)

    local _, stmt_err = dao.datausage_metrics:increment(message["api"].id, identifier, current_timestamp, count)
    if stmt_err then
        return responses.send_HTTP_INTERNAL_SERVER_ERROR(stmt_err)
    end
end

function _M.execute(conf, message)
  local ok, err = ngx.timer.at(0, log, conf, message)
  if not ok then
    ngx.log(ngx.ERR, "[datausage] failed to create timer: ", err)
  end
end

return _M