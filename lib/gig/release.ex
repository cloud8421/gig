defmodule Gig.Release do
  @moduledoc """
  This module represents a MusicBrainz release-group. As we're not dealing with specific artifacts, this application uses "release" where on MusicBrainz it would use "release-group".
  """

  defstruct id: nil,
            title: nil,
            type: "Album",
            release_date: nil

  @type id :: String.t

  @type t :: %__MODULE__{id: nil | id,
                         title: nil | String.t,
                         type: String.t,
                         release_date: nil | String.t}

  @doc """
  Takes a map with string keys of a release and converts it to
  a `t:Gig.Release/0` struct.

      iex> release_map = %{"disambiguation" => "",
      ...>                 "first-release-date" => "2015-02-23",
      ...>                 "id" => "38d7dd30-0b1c-45f5-bde4-a0794dc0ec7c",
      ...>                 "primary-type" => "Album",
      ...>                 "primary-type-id" => "f529b476-6e62-324f-b0aa-1f3e33d313fc",
      ...>                 "secondary-type-ids" => [],
      ...>                 "secondary-types" => [],
      ...>                 "title" => "The Race for Space"}
      iex> Gig.Release.from_api_response(release_map)
      %Gig.Release{id: "38d7dd30-0b1c-45f5-bde4-a0794dc0ec7c",
                           title: "The Race for Space",
                           type: "Album",
                           release_date: "2015-02-23"}
  """
  def from_api_response(release_map) do
    %{"id" => id,
      "title" => title,
      "primary-type" => type,
      "first-release-date"=> release_date} = release_map

    %__MODULE__{id: id,
                title: title,
                type: type,
                release_date: release_date}
  end
end
