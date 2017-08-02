defmodule Gig.Release.Throttle do
  @moduledoc """
  This module fetches release information with a naive
  throttling mechanism.

  Note that it doesn't provide any back pressure mechanism.
  """
  use GenServer

  @minute 60_000

  defstruct max_per_minute: 50,
            queue: :queue.new()

  def start_link(max_per_minute \\ 50) do
    GenServer.start_link(__MODULE__, max_per_minute, name: __MODULE__)
  end

  def init(max_per_minute) do
    send(self(), :fetch)
    {:ok, %__MODULE__{max_per_minute: max_per_minute}}
  end

  def queue(artist_mbid) do
    GenServer.cast(__MODULE__, {:queue, artist_mbid})
  end

  def handle_cast({:queue, mbid}, state) do
    new_queue = :queue.in(mbid, state.queue)
    if :queue.is_empty(state.queue) do
      send(self(), :fetch)
    end
    {:noreply, %{state | queue: new_queue}}
  end

  def handle_info(:fetch, state) do
    case :queue.out(state.queue) do
      {{:value, mbid}, new_queue} ->
        case fetch_and_save(mbid) do
          true -> :ok
          _error -> GenServer.cast(self(), {:queue, mbid})
        end
        reschedule_interval = div(@minute, state.max_per_minute)
        Process.send_after(self(), :fetch, reschedule_interval)
        {:noreply, %{state | queue: new_queue}}
      {:empty, _} ->
        {:noreply, state}
    end
  end

  defp fetch_and_save(mbid) do
    case Gig.Recipe.GetLastRelease.run(mbid) do
      {:ok, _corr_id, release} ->
        Gig.Store.save(Gig.Store.Release, release, mbid)
      error ->
        error
    end
  end
end
