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

    def run(_lat, _lng) do
      GenServer.call(__MODULE__, :run)
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

    def run(_lat, _lng) do
      GenServer.call(__MODULE__, :run)
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

  test "tracks the metro area id" do
    {:ok, pid} = NewEvents.start_link(0.1, 0.1, recipe_module: SuccessRecipe)

    process_state = :sys.get_state(pid)

    assert Fixtures.metro_area() == process_state.metro_area
  end

  test "it refreshes every X seconds" do
    {:ok, _} = RefreshRecipe.start_link()

    {:ok, pid} = NewEvents.start_link(0.1, 0.1, recipe_module: RefreshRecipe,
                                                refresh_interval: 10)

    wait_for_data_storage()

    process_state = :sys.get_state(pid)

    assert Fixtures.metro_area() == process_state.metro_area
  end

  test "it retries in case of failure after X seconds" do
    {:ok, _} = RetryRecipe.start_link()

    {:ok, pid} = NewEvents.start_link(0.1, 0.1, recipe_module: RetryRecipe,
                                                retry_interval: 10)

    wait_for_data_storage()

    process_state = :sys.get_state(pid)

    assert Fixtures.metro_area() == process_state.metro_area
  end

  defp wait_for_data_storage, do: Process.sleep(30)
end
