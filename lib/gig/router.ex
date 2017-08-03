defmodule Gig.Router do
  use Plug.Router

  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/monitor/:lat/:lng" do
    body = get_data_for_coords(lat, lng)
           |> Poison.encode!

    send_resp(conn, 200, body)
  end

  defp get_data_for_coords(lat_string, lng_string) do
    {lat, lng} = parse_coords(lat_string, lng_string)

    with {:ok, pid}  <- Gig.find_monitor(lat, lng),
         {:ok, area} <- Gig.get_metro_area(pid)
    do
      events = pid
               |> get_events
               |> Enum.map(&add_release_to_event/1)
      Gig.View.MonitorReport.monitored(area, events)
    else
      {:error, :not_found} ->
        Gig.start_monitoring(lat, lng)
        Gig.View.MonitorReport.started()
    end
  end

  defp parse_coords(lat_string, lng_string) do
    {String.to_float(lat_string), String.to_float(lng_string)}
  end

  defp get_events(pid) do
    event_ids = Gig.Monitor.NewEvents.get_event_ids(pid)

    Gig.Store.find_many(Gig.Store.Event, event_ids)
  end

  defp add_release_to_event(event) do
    new_artists = Enum.map(event.artists, fn(artist) ->
      add_release_to_artist(artist)
    end)

    %{event | artists: new_artists}
  end

  defp add_release_to_artist(artist = %Gig.Artist{mbid: nil}) do
    release = %{status: "not_available"}
    Map.put(artist, :last_release, release)
  end
  defp add_release_to_artist(artist) do
    case Gig.Store.find(Gig.Store.Release, artist.mbid) do
      {:ok, data} ->
        release = %{status: "fetched",
                    data: data}
        Map.put(artist, :last_release, release)
      _error ->
        release = %{status: "fetching"}
        Map.put(artist, :last_release, release)
    end
  end
end