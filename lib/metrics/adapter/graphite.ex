defmodule Metrics.Adapter.Graphite do
  @moduledoc false

  @behaviour Metrics.Adapter

  def inc(name, value) do
    :graphiter.incr_cast(:heroku, name, value)
  end

  def counter(name, value) do
    :graphiter.cast(:heroku, name, value)
  end

  def gauge(name, value, timestamp) do
    :graphiter.cast(:heroku, name, value, timestamp)
  end
end
