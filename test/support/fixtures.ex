defmodule Gig.Support.Fixtures do
  @moduledoc """
  This module includes fixtures that can be used in tests.
  """

  def event do
    %Gig.Event{id: 29280759,
                        name: "Yngwie Malmsteen with Immension",
                        artists: [artist_one(), artist_two()],
                        starts_at: ~D[2017-08-02],
                        venue: %Gig.Songkick.Venue{id: 37414,
                                                   lat: 51.5521427,
                                                   lng: -0.1422245,
                                                   name: "O2 Forum Kentish Town"}}
  end

  def artist_one do
    %Gig.Artist{id: 214430,
                         mbid: "8fa5d80d-37e8-4133-9d5c-6bad446c63f0",
                         name: "Yngwie Malmsteen"}
  end

  def artist_two do
    %Gig.Artist{id: 981795,
                         mbid: nil,
                         name: "Immension"}
  end

  def metro_area, do: 12345
end
