defmodule Gig.Songkick.ApiClient do
  @moduledoc """
  This modules includes low-level functions to access the Songkick api
  and return raw data (in form of binary maps).
  """

  @base_url "http://api.songkick.com/api/3.0"

  alias HTTPClient.{Response,
                    ErrorResponse}

  @type lat :: float
  @type lng :: float

  @spec get_events(lat, lng) :: {:ok, map} | {:error, term}
  def get_events(lat, lng) do
    path = "/events.json"

    params = default_params()
             |> Map.put(:location, "geo:#{lat},#{lng}")

    do_get(path, params)
  end

  def do_get(path, params) do
    case HTTPClient.get(@base_url <> path, params, []) do
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
