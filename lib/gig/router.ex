defmodule Gig.Router do
  use Plug.Router

  plug Plug.Logger
  plug CORSPlug, origin: ["http://localhost:3449",
                          "https://gig.fullyforged.com"]
  plug :match
  plug :dispatch

  get "/monitor/:lat/:lng" do
    body = get_data_for_coords(lat, lng)
           |> Poison.encode!

    send_resp(conn, 200, body)
  end

  get "/status" do
    monitor_count = Supervisor.count_children(Gig.Monitor.Supervisor).active
    body = %{stores: %{locations_count: Gig.Store.count(Gig.Store.Location),
                       events_count: Gig.Store.count(Gig.Store.Event),
                       releases_count: Gig.Store.count(Gig.Store.Release)},
             queues: %{releases: Gig.Release.Throttle.size},
             active_monitors_count: monitor_count}
           |> Poison.encode!

    send_resp(conn, 200, body)
  end

  defp get_data_for_coords(lat_string, lng_string) do
    coords = {lat, lng} = parse_coords(lat_string, lng_string)

    Gig.start_monitoring(lat, lng)

    case Gig.Store.find(Gig.Store.Location, coords) do
      {:ok, location} ->
        events = Gig.Store.Event
                 |> Gig.Store.find_many(location.event_ids)
                 |> Enum.map(&add_release_to_event/1)

        Gig.View.MonitorReport.monitored(location.metro_area, events)
      _notfound ->
        Gig.View.MonitorReport.started()
    end
  end

  defp parse_coords(lat_string, lng_string) do
    {parse_coord(lat_string), parse_coord(lng_string)}
  end

  defp parse_coord(coord) do
    coord
    |> String.to_float
    |> Float.round(5)
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
