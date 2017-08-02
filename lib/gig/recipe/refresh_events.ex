defmodule Gig.Recipe.RefreshEvents do
  @moduledoc """
  This recipe takes a location id
  and returns a list of Songkick events close to the
  specified location.
  """
  use Recipe

  alias Gig.Songkick.{ApiClient,
                      Event}

  # Setup rate limit to 60 calls per minute
  @rate_limit_scale 60_000
  @rate_limit 60

  @type metro_area :: pos_integer
  @type step :: :check_rate_limit
              | :fetch_data
              | :parse_metro_area
              | :parse_events
              | :parse_artists
              | :queue_releases
              | :store_events

  @type assigns :: %{coords: {ApiClient.lat, ApiClient.lng},
                     response: map,
                     metro_area: metro_area,
                     events: []}
  @type state :: %Recipe{assigns: assigns}
  @type success :: {metro_area, [Event.t]}

  @doc false
  @spec steps :: [step]
  def steps, do: [:check_rate_limit,
                  :fetch_data,
                  :parse_metro_area,
                  :parse_events,
                  :parse_artists,
                  :queue_releases,
                  :store_events]

  @doc false
  @spec handle_result(state) :: success
  def handle_result(state) do
    {state.assigns.metro_area, state.assigns.events}
  end

  @doc false
  @spec handle_error(step, term, state) :: term
  def handle_error(_step, error, _state), do: error

  @doc """
  Given lat and lng, returns a list of Songkick events
  """
  @spec run(ApiClient.lat, ApiClient.lng) :: {:ok, success}
                                           | {:error, term}
  def run(lat, lng) do
    Gig.Recipe.run(__MODULE__, initial_state(lat, lng))
  end

  @doc """
  Returns the initial state for the recipe.
  """
  @spec initial_state(ApiClient.lat, ApiClient.lng) :: state
  def initial_state(lat, lng) do
    Recipe.initial_state()
    |> Recipe.assign(:coords, {lat, lng})
  end

  @doc false
  @spec check_rate_limit(state) :: {:ok, state} | {:error, {:rate_limit_reached, pos_integer}}
  def check_rate_limit(state) do
    case ExRated.check_rate(__MODULE__, @rate_limit_scale, @rate_limit) do
      {:ok, _} ->
        {:ok, state}
      {:error, limit} ->
        {:error, {:rate_limit_reached, limit}}
    end
  end

  @doc false
  @spec fetch_data(state) :: {:ok, state} | {:error, term}
  def fetch_data(state) do
    {lat, lng} = state.assigns.coords
    case ApiClient.get_events(lat, lng) do
      {:ok, response} ->
        {:ok, Recipe.assign(state, :response, response)}
      error ->
        error
    end
  end

  @doc false
  @spec parse_metro_area(state) :: {:ok, state}
  def parse_metro_area(state) do
    metro_area = get_in(state.assigns.response, ["resultsPage",
                                                 "clientLocation",
                                                 "metroAreaId"])
    {:ok, Recipe.assign(state, :metro_area, metro_area)}
  end

  @doc false
  @spec parse_events(state) :: {:ok, state}
  def parse_events(state) do
    events = state.assigns.response
           |> get_in(["resultsPage", "results"])
           |> Map.get("event", [])
           |> Enum.map(&Event.from_api_response/1)
    {:ok, Recipe.assign(state, :events, events)}
  end

  @doc false
  @spec parse_artists(state) :: {:ok, state}
  def parse_artists(state) do
    artists = state.assigns.events
              |> Enum.flat_map(fn(e) -> e.artists end)
              |> Enum.uniq
    {:ok, Recipe.assign(state, :artists, artists)}
  end

  @doc false
  @spec queue_releases(state) :: {:ok, state}
  def queue_releases(state) do
    state.assigns.artists
    |> Enum.filter(fn(a) -> a.mbid end)
    |> Enum.each(fn(a) ->
      case Gig.Store.find(Gig.Store.Release, a.mbid) do
        {:ok, _artist} ->
          Gig.Store.extend(Gig.Store.Release, a.mbid)
        _error ->
          Gig.Release.Throttle.queue(a.mbid)
      end
    end)

    {:ok, state}
  end

  @doc false
  @spec store_events(state) :: {:ok, state}
  def store_events(state) do
    true = Gig.Store.save(Gig.Store.Event, state.assigns.events)

    {:ok, state}
  end
end
