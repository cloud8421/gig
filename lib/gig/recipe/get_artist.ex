defmodule Gig.Recipe.GetArtist do
  @moduledoc """
  This recipe takes an artist id
  and returns its complete data representation.
  """
  use Recipe

  alias Gig.Songkick.{ApiClient,
                      Artist}

  @type step :: :fetch_data | :parse_artist
  @type assigns :: %{id: Artist.id,
                     response: map,
                     artist: Artist.Long.t}
  @type state :: %Recipe{assigns: assigns}

  @doc false
  @spec steps :: [step]
  def steps, do: [:fetch_data,
                  :parse_artist]

  @doc false
  @spec handle_result(state) :: Artist.Long.t
  def handle_result(state), do: state.assigns.artist

  @doc false
  @spec handle_error(step, term, state) :: term
  def handle_error(_step, error, _state), do: error

  @doc """
  Given an artist id, return its long representation
  """
  @spec run(Artist.id) :: {:ok, Artist.Long.t}
                        | {:error, term}
  def run(artist_id) do
    state = Recipe.initial_state()
            |> Recipe.assign(:id, artist_id)

    Recipe.run(__MODULE__, state)
  end

  @doc false
  @spec fetch_data(state) :: {:ok, state} | {:error, term}
  def fetch_data(state) do
    artist_id = state.assigns.id
    case ApiClient.get_artist(artist_id) do
      {:ok, response} ->
        {:ok, Recipe.assign(state, :response, response)}
      error ->
        error
    end
  end

  @doc false
  @spec parse_artist(state) :: {:ok, state}
  def parse_artist(state) do
    artist = state.assigns.response
           |> get_in(["resultsPage", "results", "artist"])
           |> Artist.Long.from_api_response
    {:ok, Recipe.assign(state, :artist, artist)}
  end
end
