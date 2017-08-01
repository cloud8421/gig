defmodule Gig.Recipe.GetLocations do
  @moduledoc """
  This recipe takes a latitude and longitude
  and returns a list of Songkick locations close to the
  specified coordinates.

  Songkick returns multiple locations that map to the same
  metro area id. This id is what's used to resolve gigs for
  a specific location, so this recipe dedupes the returned locations
  so that it returnes only one location per id.
  """
  use Recipe

  alias Gig.Songkick.{ApiClient,
                      Location}

  @type step :: :fetch_data | :parse_locations
  @type assigns :: %{coords: {Location.lat, Location.lng},
                     response: map,
                     locations: [Location.t]}
  @type state :: %Recipe{assigns: assigns}

  @doc false
  @spec steps :: [step]
  def steps, do: [:fetch_data,
                  :parse_locations]

  @doc false
  @spec handle_result(state) :: [Location.t]
  def handle_result(state) do
    Enum.uniq_by(state.assigns.locations, fn(l) -> l.id end)
  end

  @doc false
  @spec handle_error(step, term, state) :: term
  def handle_error(_step, error, _state), do: error

  @doc """
  Given lat and lng, returns a list of Songkick locations
  """
  @spec run(Location.lat, Location.lng) :: {:ok, [Location.t]}
                                         | {:error, term}
  def run(lat, lng) do
    Gig.Recipe.run(__MODULE__, initial_state(lat, lng))
  end

  @doc """
  Returns the initial state for the recipe.
  """
  @spec initial_state(Location.lat, Location.lng) :: state
  def initial_state(lat, lng) do
    Recipe.initial_state()
    |> Recipe.assign(:coords, {lat, lng})
  end

  @doc false
  @spec fetch_data(state) :: {:ok, state} | {:error, term}
  def fetch_data(state) do
    {lat, lng} = state.assigns.coords
    case ApiClient.search_locations(lat, lng) do
      {:ok, response} ->
        {:ok, Recipe.assign(state, :response, response)}
      error ->
        error
    end
  end

  @doc false
  @spec parse_locations(state) :: {:ok, state}
  def parse_locations(state) do
    locations = state.assigns.response
              |> get_in(["resultsPage", "results"])
              |> Map.get("location", [])
              |> Enum.map(&Location.from_api_response/1)
    {:ok, Recipe.assign(state, :locations, locations)}
  end
end
