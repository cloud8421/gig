defmodule Gig.Location do
  @moduledoc """
  Represents a mapping between a pair of {lat, lng} coords
  and a metro area id.
  """

  defstruct coords: {0, 0},
            metro_area: nil,
            event_ids: []

  @type t :: %__MODULE__{coords: {float(), float()},
                         metro_area: nil | String.t,
                         event_ids: [Gig.Event.id]}

  def new(coords, metro_area, event_ids) do
    %__MODULE__{coords: coords,
                metro_area: metro_area,
                event_ids: event_ids}
  end
end
