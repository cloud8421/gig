defmodule Metrics do
  @moduledoc false

  @adapter Application.get_env(:gig,
                               :metrics_adapter,
                               Metrics.Adapter.Memory)

  defdelegate inc(name), to: @adapter
  defdelegate counter(name, value), to: @adapter
  defdelegate gauge(name, value), to: @adapter
end
