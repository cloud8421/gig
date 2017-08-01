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

  @doc """
  Takes a map with string keys of a representation
  of an event and converts it to a `t:Gig.Songkick.Event/0` struct.

      iex> event_response = %{"ageRestriction" => "Standing: 14+ / Balcony: 8+ (U14s must be with adult)",
      ...>                    "displayName" => "Yngwie Malmsteen with Immension at O2 Forum Kentish Town (August 2, 2017)",
      ...>                    "id" => 29280759,
      ...>                    "location" => %{"city" => "London, UK",
      ...>                                    "lat" => 51.5521427,
      ...>                                    "lng" => -0.1422245},
      ...>                    "performance" => [%{"artist" => %{"displayName" => "Yngwie Malmsteen",
      ...>                                        "id" => 214430,
      ...>                                        "identifier" => [%{"href" => "http://api.songkick.com/api/3.0/artists/mbid:8fa5d80d-37e8-4133-9d5c-6bad446c63f0.json",
      ...>                                                           "mbid" => "8fa5d80d-37e8-4133-9d5c-6bad446c63f0"}],
      ...>                                        "uri" => "http://www.songkick.com/artists/214430-yngwie-malmsteen?utm_source=41376&utm_medium=partner"},
      ...>                                        "billing" => "headline",
      ...>                                        "billingIndex" => 1,
      ...>                                        "displayName" => "Yngwie Malmsteen",
      ...>                                        "id" => 56764574},
      ...>                                      %{"artist" => %{"displayName" => "Immension", "id" => 981795,
      ...>                                        "identifier" => [],
      ...>                                        "uri" => "http://www.songkick.com/artists/981795-immension?utm_source=41376&utm_medium=partner"},
      ...>                                        "billing" => "support", "billingIndex" => 2, "displayName" => "Immension",
      ...>                                        "id" => 57231254}],
      ...>                    "popularity" => 0.012545,
      ...>                    "start" => %{"date" => "2017-08-02",
      ...>                                 "datetime" => "2017-08-02T19:00:00+0100",
      ...>                                 "time" => "19:00:00"},
      ...>                    "status" => "ok",
      ...>                    "type" => "Concert",
      ...>                    "uri" => "http://www.songkick.com/concerts/29280759-yngwie-malmsteen-at-o2-forum-kentish-town?utm_source=41376&utm_medium=partner",
      ...>                    "venue" => %{"displayName" => "O2 Forum Kentish Town",
      ...>                      "id" => 37414,
      ...>                      "lat" => 51.5521427,
      ...>                      "lng" => -0.1422245,
      ...>                      "metroArea" => %{"country" => %{"displayName" => "UK"},
      ...>                        "displayName" => "London",
      ...>                        "id" => 24426,
      ...>                        "uri" => "http://www.songkick.com/metro_areas/24426-uk-london?utm_source=41376&utm_medium=partner"},
      ...>                      "uri" => "http://www.songkick.com/venues/37414-o2-forum-kentish-town?utm_source=41376&utm_medium=partner"}}
      iex> Gig.Songkick.Event.from_api_response(event_response)
      %Gig.Songkick.Event{artists: [%Gig.Songkick.Artist.Short{id: 214430,
                                                               name: "Yngwie Malmsteen"},
                                    %Gig.Songkick.Artist.Short{id: 981795,
                                                               name: "Immension"}],
                          id: 29280759,
                          name: "Yngwie Malmsteen with Immension at O2 Forum Kentish Town (August 2, 2017)",
                          starts_at: %DateTime{calendar: Calendar.ISO, day: 2, hour: 18, microsecond: {0, 0}, minute: 0,
                                               month: 8, second: 0, std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0,
                                               year: 2017, zone_abbr: "UTC"},
                          venue: %Gig.Songkick.Venue{id: 37414,
                                                     lat: 51.5521427,
                                                     lng: -0.1422245,
                                                     name: "O2 Forum Kentish Town"}}
  """
  @spec from_api_response(map) :: t
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
