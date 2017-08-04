defmodule Metrics.Adapter.Memory do
  @moduledoc false

  @behaviour Metrics.Adapter

  def state do
    Agent.get(__MODULE__, fn(s) -> s end)
  end

  def start_link(state) do
    Agent.start_link(fn() -> state end, name: __MODULE__)
  end

  def child_spec(state) do
    %{id: __MODULE__,
      start: {__MODULE__, :start_link, [state]}}
  end

  def inc(name, value) do
    Agent.update(__MODULE__, fn(state) ->
      Map.update(state,
                 name,
                 value,
                 fn(current) -> current + value end)
    end)
  end

  def counter(name, value) do
    Agent.update(__MODULE__, fn(state) ->
      Map.put(state,
              name,
              value)
    end)
  end

  def gauge(name, value, timestamp) do
    Agent.update(__MODULE__, fn(state) ->
      Map.update(state,
                 name,
                 [{timestamp, value}],
                 fn(current) -> [{timestamp, value} | current] end)
    end)
  end
end
