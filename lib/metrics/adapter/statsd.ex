defmodule Metrics.Adapter.Statsd do
  @moduledoc false

  @behaviour Metrics.Adapter

  def inc(name) do
    ExStatsD.increment(name)
  end

  def counter(name, value) do
    ExStatsD.counter(value, name)
  end

  def gauge(name, value) do
    ExStatsD.gauge(value, name)
  end
end
