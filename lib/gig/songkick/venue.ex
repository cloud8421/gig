defmodule Gig.Songkick.Venue do
  @moduledoc """
  This module represents a Songkick venue where a gig
  takes place.
  """

  alias Gig.Songkick.Location

  defstruct id: nil,
            name: nil,
            lat: 0.0,
            lng: 0.0

  @type id :: pos_integer

  @type t :: %__MODULE__{id: nil | id,
                         name: nil | String.t,
                         lat: Location.lat,
                         lng: Location.lng}

    @doc """
    Takes a map with string keys of a venue
    and converts it to a `Gig.Songkick.Venue.t` struct.

    iex> venue_map = %{"id" => 4114,
    ...>               "displayName" => "Nambucca",
    ...>               "lat" => 51.5609729,
    ...>               "lng" => -0.1236348}
    iex> Gig.Songkick.Venue.from_api_response(venue_map)
    %Gig.Songkick.Venue{id: 4114, lat: 51.5609729, lng: -0.1236348,
    name: "Nambucca"}
    """
    @spec from_api_response(map) :: t
  def from_api_response(venue_map) do
    %{"id" => id,
      "displayName" => name,
      "lat" => lat,
      "lng" => lng} = venue_map

    %__MODULE__{id: id,
                name: name,
                lat: lat,
                lng: lng}
  end
end
