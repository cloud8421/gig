defmodule Metrics.Adapter.Graphite do
  @moduledoc false

  @behaviour Metrics.Adapter

  def inc(name) do
    :graphiter.incr_cast(:heroku, name, 1)
  end

  def counter(name, value) do
    :graphiter.cast(:heroku, name, value)
  end

  def gauge(name, value) do
    :graphiter.cast(:heroku, name, value)
  end
end
