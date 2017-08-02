defmodule Gig.Recipe.GetReleases do
  @moduledoc """
  This recipe takes an artist music brainz id
  and returns their releases.
  """
  use Recipe

  alias Gig.Songkick.Artist
  alias Gig.Mbrainz.{ApiClient,
                     Release}

  # Setup rate limit to 50 calls per minute, as per
  # MusicBrainz guidelines available at
  # <https://musicbrainz.org/doc/XML_Web_Service/Rate_Limiting#User-Agent>
  @rate_limit_scale 60_000
  @rate_limit 50

  @type step :: :check_rate_limit | :fetch_data | :parse_releases
  @type assigns :: %{id: Artist.mbid,
                     response: map,
                     releases: [Release.t]}
  @type state :: %Recipe{assigns: assigns}

  @doc false
  @spec steps :: [step]
  def steps, do: [:check_rate_limit,
                  :fetch_data,
                  :parse_releases]

  @doc false
  @spec handle_result(state) :: [Release.t]
  def handle_result(state), do: state.assigns.releases

  @doc false
  @spec handle_error(step, term, state) :: term
  def handle_error(_step, error, _state), do: error

  @doc """
  Given an artist MusicBrainz id, return their releases
  """
  @spec run(Artist.mbid) :: {:ok, [Release.t]}
                             | {:error, term}
  def run(artist_mbid) do
    Gig.Recipe.run(__MODULE__, initial_state(artist_mbid))
  end

  @doc """
  Returns the initial state for the recipe.
  """
  @spec initial_state(Artist.mbid) :: state
  def initial_state(artist_mbid) do
    Recipe.initial_state()
    |> Recipe.assign(:id, artist_mbid)
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
    artist_mbid = state.assigns.id
    case ApiClient.get_artist(artist_mbid) do
      {:ok, response} ->
        {:ok, Recipe.assign(state, :response, response)}
      error ->
        error
    end
  end

  @doc false
  @spec parse_releases(state) :: {:ok, state}
  def parse_releases(state) do
    releases = state.assigns.response
               |> Map.get("release-groups")
               |> Enum.map(&Release.from_api_response/1)
    {:ok, Recipe.assign(state, :releases, releases)}
  end
end
