defmodule Gig.Recipe.GetLastRelease do
  @moduledoc """
  This recipe returns only the most recent release
  for the given artist. Note that as per MusicBrainz
  guidelines, it's not possible to sort results at api
  query time. Instead we need to get all data and sort
  it on this side.

  See: <https://musicbrainz.org/doc/Development/XML_Web_Service/Version_2#Browse>
  """
  def run(artist_mbid) do
    case Gig.Recipe.GetReleases.run(artist_mbid) do
      {:ok, _correlation_id, []} ->
        {:error, :not_found}
      {:ok, correlation_id, releases} ->
        last_release = Enum.max_by(releases, fn(release) -> release.release_date end)
        {:ok, correlation_id, last_release}
      error ->
        error
    end
  end
end
