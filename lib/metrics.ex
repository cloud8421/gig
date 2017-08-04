defmodule Metrics do
  @moduledoc false

  @adapter Application.get_env(:gig,
                               :metrics_adapter,
                               Metrics.Adapter.Memory)

  defdelegate inc(name, value), to: @adapter
  defdelegate counter(name, value), to: @adapter

  def gauge(name, value) do
    @adapter.gauge(name, value, Gig.Store.get_now())
  end
end
