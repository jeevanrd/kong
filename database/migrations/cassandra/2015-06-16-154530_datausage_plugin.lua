local Migration = {
  name = "2015-06-16-154530_datausage_plugin",

  up = function(options)
    return [[
      CREATE TABLE IF NOT EXISTS datausage_metrics(
        api_id uuid,
        identifier text,
        period text,
        period_date timestamp,
        value counter,
        PRIMARY KEY ((api_id, identifier, period_date, period))
      );
    ]]
  end,

  down = function(options)
    return [[
      DROP TABLE datausage_metrics;
    ]]
  end
}

return Migration