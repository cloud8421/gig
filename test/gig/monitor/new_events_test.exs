defmodule Gig.Monitor.NewEventsTest do
  use ExUnit.Case, async: false

  alias Gig.{Monitor.NewEvents,
             Support.Fixtures}

  defmodule SuccessRecipe do
    def run(_lat, _lng) do
      {:ok, "correlation-id", {Fixtures.metro_area(), [Fixtures.event()]}}
    end
  end

  defmodule RefreshRecipe do
    use GenServer

    def start_link do
      GenServer.start_link(__MODULE__, 0, name: __MODULE__)
    end

    def call_count(pid) do
      GenServer.call(pid, :call_count)
    end

    def run(_lat, _lng) do
      GenServer.call(__MODULE__, :run)
    end

    def handle_call(:call_count, _from, count) do
      {:reply, count, count}
    end

    def handle_call(:run, _from, 0) do
      reply = {:ok, "correlation-id", {nil, []}}
      {:reply, reply, 1}
    end
    def handle_call(:run, _from, count) do
      reply = {:ok, "correlation-id", {Fixtures.metro_area(), [Fixtures.event()]}}
      {:reply, reply, count + 1}
    end
  end

  defmodule RetryRecipe do
    use GenServer

    def start_link do
      GenServer.start_link(__MODULE__, 0, name: __MODULE__)
    end

    def call_count(pid) do
      GenServer.call(pid, :call_count)
    end

    def run(_lat, _lng) do
      GenServer.call(__MODULE__, :run)
    end

    def handle_call(:call_count, _from, count) do
      {:reply, count, count}
    end

    def handle_call(:run, _from, 0) do
      reply = {:error, :rate_limit_reached}
      {:reply, reply, 1}
    end
    def handle_call(:run, _from, count) do
      reply = {:ok, "correlation-id", {Fixtures.metro_area(), [Fixtures.event()]}}
      {:reply, reply, count + 1}
    end
  end

  test "it refreshes every X seconds" do
    {:ok, refresh_pid} = RefreshRecipe.start_link()

    {:ok, _pid} = NewEvents.start_link(0.1, 0.1, recipe_module: RefreshRecipe,
                                                 refresh_interval: 10)

    assert 1 == RefreshRecipe.call_count(refresh_pid)

    Process.sleep(20)

    assert 2 == RefreshRecipe.call_count(refresh_pid)
  end

  test "it retries in case of failure after X seconds" do
    {:ok, retry_pid} = RetryRecipe.start_link()

    {:ok, _pid} = NewEvents.start_link(0.1, 0.1, recipe_module: RetryRecipe,
                                                 retry_interval: 10)

    assert 1 == RetryRecipe.call_count(retry_pid)

    Process.sleep(20)

    assert 2 == RetryRecipe.call_count(retry_pid)
  end
end
