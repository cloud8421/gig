defmodule Gig.Recipe.GetClosestLocation do
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

  @type step :: :fetch_data | :get_closest | :parse_location
  @type assigns :: %{coords: {Location.lat, Location.lng},
                     response: map,
                     location: Location.t}
  @type state :: %Recipe{assigns: assigns}

  @doc false
  @spec steps :: [step]
  def steps, do: [:fetch_data,
                  :get_closest,
                  :parse_location]

  @doc false
  @spec handle_result(state) :: Location.t
  def handle_result(state), do: state.assigns.location

  @doc false
  @spec handle_error(step, term, state) :: term
  def handle_error(_step, error, _state), do: error

  @doc """
  Given lat and lng, returns the closest Songkick location
  """
  @spec run(Location.lat, Location.lng) :: {:ok, Location.t}
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

  defdelegate fetch_data(state), to: Gig.Recipe.GetLocations

  @doc false
  @spec get_closest(state) :: {:ok, state} | {:error, :no_locations}
  def get_closest(state) do
    raw_data = state.assigns.response
               |> get_in(["resultsPage", "results"])
               |> Map.get("location", [])

    case raw_data do
      [] ->
        {:error, :no_locations}
      [match | _rest] ->
        {:ok, Recipe.assign(state, :response, match)}
    end
  end

  @doc false
  @spec parse_location(state) :: {:ok, state}
  def parse_location(state) do
    location = Location.from_api_response(state.assigns.response)
    {:ok, Recipe.assign(state, :location, location)}
  end
end
