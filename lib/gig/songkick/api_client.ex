defmodule Gig.Songkick.ApiClient do
  @moduledoc """
  This modules includes low-level functions to access the Songkick api
  and return raw data (in form of binary maps).
  """

  @base_url "http://api.songkick.com/api/3.0"

  alias HTTPotion.{Response,
                   ErrorResponse}

  @type location_id :: pos_integer
  @type artist_id :: pos_integer
  @type lat :: float
  @type lng :: float

  @spec search_locations(lat, lng) :: {:ok, map} | {:error, term}
  def search_locations(lat, lng) do
    path = "/search/locations.json"
    params = default_params()
             |> Map.put(:location, "geo:#{lat},#{lng}")

    do_get(path, params)
  end

  @spec get_gigs(location_id) :: {:ok, map} | {:error, term}
  def get_gigs(location_id) do
    path = "/metro_areas/#{location_id}/calendar.json"

    do_get(path, default_params())
  end

  @spec get_artist(artist_id) :: {:ok, map} | {:error, term}
  def get_artist(artist_id) do
    path = "/artists/#{artist_id}.json"

    do_get(path, default_params())
  end

  def do_get(path, params) do
    case HTTPotion.get(@base_url <> path, query: params) do
      %Response{status_code: 200, body: body} ->
        Poison.decode(body)
      %Response{status_code: status_code, body: body} ->
        {:error, {status_code, body}}
      %ErrorResponse{message: message} ->
        message
    end
  end

  defp default_params do
    %{apikey: System.get_env("SONGKICK_API_TOKEN")}
  end
end
