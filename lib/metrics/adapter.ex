defmodule Metrics.Adapter do
  @moduledoc false

  @type name :: String.t
  @type value :: integer | float
  @type timestamp :: integer

  @callback inc(name) :: :ok
  @callback counter(name, value) :: :ok
  @callback gauge(name, value) :: :ok
end
