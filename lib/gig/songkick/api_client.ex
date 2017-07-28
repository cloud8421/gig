defmodule Gig.Songkick.ApiClient do
  @moduledoc """
  This modules includes low-level functions to access the Songkick api
  and return raw data (in form of binary maps).
  """

  @base_url "http://api.songkick.com/api/3.0"

  alias HTTPotion.{Response,
                   ErrorResponse}

  @type lat :: float
  @type lng :: float

  @spec search_location(lat, lng) :: {:ok, [map]} | {:error, term}
  def search_location(lat, lng) do
    path = "/search/locations.json"
    params = default_params()
             |> Map.put(:location, "geo:#{lat},#{lng}")

    case HTTPotion.get(@base_url <> path, query: params) do
      %Response{status_code: 200, body: body} ->
        {:ok, Poison.decode!(body) |> extract_locations}
      %Response{status_code: status_code, body: body} ->
        {:error, {status_code, body}}
      %ErrorResponse{message: message} ->
        {:error, message}
    end
  end

  defp extract_locations(response_map) do
    get_in(response_map, ["resultsPage", "results", "location"])
  end

  defp default_params do
    %{apikey: System.get_env("SONGKICK_API_TOKEN")}
  end
end
