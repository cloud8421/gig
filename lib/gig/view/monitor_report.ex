defmodule Gig.View.MonitorReport do
  @moduledoc """
  Takes data about a monitor and renders maps ready
  to be encoded to JSON.
  """

  def started do
    %{status: "started"}
  end

  def monitored(area, events) do
    %{status: "monitored",
      metro_area: area,
      events: events}
  end
end
