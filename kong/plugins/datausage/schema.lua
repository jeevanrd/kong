local constants = require "kong.constants"
local utils = require "kong.tools.utils"

return {
  fields = {
	   limit = { required = true, type = "number" },
	   period = { required = true, type = "string", enum = constants.DATAUSAGE.PERIODS },
	   metric_counter_variable = { required = true, type = "string" }
	}
}

