defmodule Gig.Artist do
  @moduledoc """
  This module represents a Songkick artist.
  """

  defstruct id: nil,
            mbid: nil,
            name: nil

  @type id :: pos_integer
  @type mbid :: String.t

  @type t :: %__MODULE__{id: nil | Gig.Artist.id,
                         mbid: nil | mbid,
                         name: nil | String.t}

  @doc """
  Takes a map with string keys of a short representation
  of an artist and converts it to a `t:Gig.Artist.t/0` struct.

      iex> artist_map = %{"id" => 2588971,
      ...>                "identifier" => [%{"eventsHref" => "http://api.songkick.com/api/3.0/artists/mbid:93834e82-3a0b-4ec2-a2e4-6eca0a497e6d/calendar.json",
      ...>                   "href" => "http://api.songkick.com/api/3.0/artists/mbid:93834e82-3a0b-4ec2-a2e4-6eca0a497e6d.json",
      ...>                   "mbid" => "93834e82-3a0b-4ec2-a2e4-6eca0a497e6d",
      ...>                   "setlistsHref" => "http://api.songkick.com/api/3.0/artists/mbid:93834e82-3a0b-4ec2-a2e4-6eca0a497e6d/setlists.json"}],
      ...>                "displayName" => "Public Service Broadcasting"}
      iex> Gig.Artist.from_api_response(artist_map)
      %Gig.Artist{id: 2588971,
                           mbid: "93834e82-3a0b-4ec2-a2e4-6eca0a497e6d",
                           name: "Public Service Broadcasting"}
  """
  @spec from_api_response(map) :: t
  def from_api_response(artist_map) do
    mbid = get_in(artist_map, ["identifier", Access.at(0), "mbid"])
    %{"id" => id,
      "displayName" => name} = artist_map

    %__MODULE__{id: id,
                mbid: mbid,
                name: name}
  end
end
