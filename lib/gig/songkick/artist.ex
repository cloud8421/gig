defmodule Gig.Songkick.Artist do
  defmodule Short do
    @moduledoc """
    This module represents a Songkick artist (short representation).
    """

    defstruct id: nil,
              name: nil

    @type id :: pos_integer

    @type t :: %__MODULE__{id: nil | id,
                           name: nil | String.t}

    @doc """
    Takes a map with string keys of a short representation
    of an artist and converts it to a `Gig.Songkick.Artist.Short.t` struct.

    iex> artist_map = %{"id" => 2588971,
    ...>                "displayName" => "Public Service Broadcasting"}
    iex> Gig.Songkick.Artist.Short.from_api_response(artist_map)
    %Gig.Songkick.Artist.Short{id: 2588971, name: "Public Service Broadcasting"}
    """
    @spec from_api_response(map) :: t
    def from_api_response(artist_map) do
      %{"id" => id,
        "displayName" => name} = artist_map

      %__MODULE__{id: id, name: name}
    end
  end
end
