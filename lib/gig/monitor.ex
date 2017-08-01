defmodule Gig.Monitor do
  @moduledoc """
  Given a starting lat/lng, a `Gig.Monitor` process
  regularly monitors the available events for the specified
  coordinates pair.
  """

  use GenServer

  @retry_interval   1000 * 30 # 30 seconds
  @refresh_interval 1000 * 60 * 60 * 12 # 12 hours

  defmodule State do
    @moduledoc false

    defstruct coords: {0, 0},
              metro_area: nil
  end

  def child_spec(_) do
    %{id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      restart: :transient,
      shutdown: 5000,
      type: :worker}
  end

  def via(lat, lng) do
    {:via, Registry, {Registry.Monitor, {lat, lng}}}
  end

  def start_link(lat, lng) do
    GenServer.start_link(__MODULE__, {lat, lng}, name: via(lat, lng))
  end

  def init(coords) do
    send(self(), :refresh)

    {:ok, %State{coords: coords}}
  end

  def handle_info(:refresh, state) do
    {lat, lng} = state.coords
    case Gig.Recipe.GetEvents.run(lat, lng) do
      {:ok, _correlation_id, {metro_area, events}} ->
        save_refresh_data(events)
        Process.send_after(self(), :refresh, @refresh_interval)
        {:noreply, %{state | metro_area: metro_area}}
      _error ->
        Process.send_after(self(), :refresh, @retry_interval)
        {:noreply, state}
    end
  end

  defp save_refresh_data(events) do
    artists = events
              |> Enum.flat_map(fn(e) -> e.artists end)
              |> Enum.filter(fn(a) -> a.mbid end)
              |> Enum.uniq

    true = Gig.Store.save(Gig.Store.Event, events)
    true = Gig.Store.save(Gig.Store.Artist, artists)
  end
end
