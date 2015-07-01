local BasePlugin = require "kong.plugins.base_plugin"
local access = require "kong.plugins.datausage.access"
local log = require "kong.plugins.datausage.log"
local basic_serializer = require "kong.plugins.log_serializers.basic"

local DataUsageHandler = BasePlugin:extend()

function DataUsageHandler:new()
  DataUsageHandler.super.new(self, "datausage")
end

function DataUsageHandler:access(conf)
  DataUsageHandler.super.access(self)
  access.execute(conf)
end

function DataUsageHandler:log(conf)
  DataUsageHandler.super.log(self)
  local message = basic_serializer.serialize(ngx)
  log.execute(conf, message)
end

return DataUsageHandler