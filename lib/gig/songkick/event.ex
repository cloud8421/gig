defmodule Gig.Songkick.Event do
  @moduledoc """
  This module represents a Songkick event.
  """

  alias Gig.Songkick.{Artist,
                      Venue}

  defstruct id: nil,
            name: nil,
            artists: [],
            venue: nil,
            starts_at: :not_available

  @type id :: pos_integer

  @type t :: %__MODULE__{id: nil | id,
                         name: nil | String.t,
                         artists: [Artist.Short.t],
                         venue: Venue.t,
                         starts_at: :not_available | DateTime.t | Date.t}

  def from_api_response(event_map) do
    %{"id" => id,
      "displayName" => name} = event_map
    starts_at = get_starts_at(event_map)
    artists = get_artists(event_map)
    venue = get_venue(event_map)

    %__MODULE__{id: id,
                name: name,
                artists: artists,
                venue: venue,
                starts_at: starts_at}
  end

  defp get_artists(event_map) do
    artists_data = get_in(event_map, ["performance",
                                      Access.all(),
                                      "artist"])
    Enum.map(artists_data, &Artist.Short.from_api_response/1)
  end

  defp get_venue(event_map) do
    event_map
    |> Map.get("venue")
    |> Venue.from_api_response
  end

  defp get_starts_at(event_map) do
    %{"date" => date,
      "datetime" => datetime} = Map.get(event_map, "start")

    cond do
      datetime ->
        {:ok, starts_at, _offset} = DateTime.from_iso8601(datetime)
        starts_at
      date ->
        {:ok, starts_at} = Date.from_iso8601(date)
        starts_at
      true ->
        :not_available
    end
  end
end
