defmodule Gig.Songkick.Location do
  @moduledoc """
  This module represents a Songkick location, used as a basis to find events. 
  """

  defstruct id: nil,
            name: nil,
            area: nil,
            lat: 0.0,
            lng: 0.0,
            country: nil

  @type lat :: float
  @type lng :: float

  @type t :: %__MODULE__{id: nil | pos_integer,
                         name: nil | String.t,
                         area: nil | String.t,
                         lat: lat,
                         lng: lng,
                         country: nil | String.t}


  @doc """
  Takes a location map with string keys obtained via the Songkick api
  and converts it to a `Location.t` struct.

  iex> location_map = %{"city" => %{"country" => %{"displayName" => "UK"},
  ...>                  "displayName" => "Islington",
  ...>                          "lat" => 51.5333,
  ...>                          "lng" => -0.1},
  ...>                  "metroArea" => %{"country" => %{"displayName" => "UK"},
  ...>                                   "displayName" => "London",
  ...>                                   "id" => 24426,
  ...>                                   "lat" => 51.5078,
  ...>                                   "lng" => -0.128,
  ...>                                    "uri" => "<omitted>"}}
  iex> Gig.Songkick.Location.from_api_response(location_map)
  %Gig.Songkick.Location{area: "London", country: "UK", id: 24426,
                         lat: 51.5333, lng: -0.1, name: "Islington"}
  """
  @spec from_api_response(map) :: t
  def from_api_response(location_map) do
    %{"lat" => lat,
      "lng" => lng,
      "displayName" => name} = Map.get(location_map, "city")
    %{"id" => id,
      "displayName" => area} = Map.get(location_map, "metroArea")
    country = get_in(location_map, ["metroArea", "country", "displayName"])

    %__MODULE__{id: id,
                name: name,
                area: area,
                lat: lat,
                lng: lng,
                country: country}
  end
end
