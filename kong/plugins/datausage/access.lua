local constants = require "kong.constants"
local timestamp = require "kong.tools.timestamp"
local stringy = require "stringy"
local responses = require "kong.tools.responses"

local _M = {}

function _M.execute(conf)
  local current_timestamp = timestamp.get_utc()

  -- Consumer is identified by ip address or authenticated_entity id
  local identifier
  if ngx.ctx.authenticated_entity then
    identifier = ngx.ctx.authenticated_entity.id
  else
    identifier = ngx.var.remote_addr
  end

  local least_remaining_limit

  local current_metric, err = dao.datausage_metrics:find_one(ngx.ctx.api.id, identifier, current_timestamp, conf.period)
  if err then
    return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
  end

  local current_usage = current_metric and current_metric.value or 0
  local remaining = conf.limit - current_usage
  ngx.header[constants.HEADERS.DATAUSAGE_LIMIT] = conf.limit
  ngx.header[constants.HEADERS.DATAUSAGE_REMAINING] = math.max(0, remaining - 1) -- -1 for this current request

  if remaining == 0 then
    ngx.ctx.stop_phases = true -- interrupt other phases of this request
    return responses.send(429, "API rate limit exceeded")
  end

end

return _M
