defmodule Gig.Sweep do
  @moduledoc """
  The sweep process runs every 4 hours and deletes data which is older than 48 hours.

  As event monitors expire after 24 hours, we can safely assume that data
  older than 48 hours is not needed.
  """

  use GenServer

  @threshold 1000 * 60 * 60 * 48 # 48 hours
  @sweep_every 1000 * 60 * 60 * 3 # 3 hours
  @tables [Gig.Store.Event,
           Gig.Store.Location,
           Gig.Store.Release]

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ignored, name: __MODULE__)
  end

  def init(:ignored) do
    send(self(), :prepare_sweep)
    {:ok, :ignored}
  end

  def handle_info(:prepare_sweep, state) do
    if Enum.all?(@tables, &is_table_ready?/1) do
      send(self(), :sweep)
    else
      Process.sleep(100)
      send(self(), :prepare_sweep)
    end

    {:noreply, state}
  end

  def handle_info(:sweep, state) do
    now = Gig.Store.get_now()
    threshold_timestamp = now - @threshold

    Enum.each(@tables, fn(table) ->
      Gig.Store.delete_earlier_than(table, threshold_timestamp)
    end)

    Process.send_after(self(), :sweep, @sweep_every)

    {:noreply, state}
  end

  defp is_table_ready?(table) do
    case :ets.info(table) do
      :undefined -> false
      _info -> true
    end
  end
end
