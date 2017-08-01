defmodule Gig.Recipe.GetEvents do
  @moduledoc """
  This recipe takes a location id
  and returns a list of Songkick events close to the
  specified location.
  """
  use Recipe

  alias Gig.Songkick.{ApiClient,
                      Event}

  @type step :: :fetch_data | :parse_events
  @type assigns :: %{coords: {ApiClient.lat, ApiClient.lng},
                     response: map,
                     events: []}
  @type state :: %Recipe{assigns: assigns}

  @doc false
  @spec steps :: [step]
  def steps, do: [:fetch_data,
                  :parse_events]

  @doc false
  @spec handle_result(state) :: [Event.t]
  def handle_result(state), do: state.assigns.events

  @doc false
  @spec handle_error(step, term, state) :: term
  def handle_error(_step, error, _state), do: error

  @doc """
  Given lat and lng, returns a list of Songkick events
  """
  @spec run(ApiClient.lat, ApiClient.lng) :: {:ok, [Event.t]}
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
  @spec parse_events(state) :: {:ok, state}
  def parse_events(state) do
    events = state.assigns.response
           |> get_in(["resultsPage", "results"])
           |> Map.get("event", [])
           |> Enum.map(&Event.from_api_response/1)
    {:ok, Recipe.assign(state, :events, events)}
  end
end
