ExUnit.start()

# Start the rpc requests counter ETS Table so we can use it in tests.
:ets.new(:rpc_requests_counter, [
  :set,
  :named_table,
  :public,
  write_concurrency: true
])

# And Finch
Finch.start_link(name: Ethereumex.Finch)

Application.ensure_started(:telemetry)
