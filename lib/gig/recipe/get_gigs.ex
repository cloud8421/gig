defmodule Gig.Recipe.GetGigs do
  @moduledoc """
  This recipe takes a location id
  and returns a list of Songkick gigs close to the
  specified location.
  """
  use Recipe

  alias Gig.Songkick.{ApiClient,
                      Event}

  @type step :: :fetch_data | :parse_gigs
  @type assigns :: %{location_id: Location.id,
                     response: map,
                     gigs: []}
  @type state :: %Recipe{assigns: assigns}

  @doc false
  @spec steps :: [step]
  def steps, do: [:fetch_data,
                  :parse_gigs]

  @doc false
  @spec handle_result(state) :: [Location.t]
  def handle_result(state), do: state.assigns.gigs

  @doc false
  @spec handle_error(step, term, state) :: term
  def handle_error(_step, error, _state), do: error

  @doc """
  Given lat and lng, returns a list of Songkick locations
  """
  @spec run(Location.id) :: {:ok, [Location.t]}
                                         | {:error, term}
  def run(location_id) do
    state = Recipe.initial_state()
            |> Recipe.assign(:location_id, location_id)

    Gig.Recipe.run(__MODULE__, state)
  end

  @doc false
  @spec fetch_data(state) :: {:ok, state} | {:error, term}
  def fetch_data(state) do
    location_id = state.assigns.location_id
    case ApiClient.get_gigs(location_id) do
      {:ok, response} ->
        {:ok, Recipe.assign(state, :response, response)}
      error ->
        error
    end
  end

  @doc false
  @spec parse_gigs(state) :: {:ok, state}
  def parse_gigs(state) do
    gigs = state.assigns.response
           |> get_in(["resultsPage", "results"])
           |> Map.get("event", [])
           |> Enum.map(&Event.from_api_response/1)
    {:ok, Recipe.assign(state, :gigs, gigs)}
  end
end
