defmodule Gig.Mbrainz.ApiClient do
  @moduledoc """
  This module includes low-level functions to access the MusicBrainz
  api and return raw data (in form of binary maps).
  """

  @base_url "https://musicbrainz.org/ws/2"
  @user_agent Application.get_env(:gig, :mbrainz_user_agent)
  @headers %{"User-Agent" => @user_agent}

  alias HTTPClient.{Response,
                    ErrorResponse}

  @type mbid :: String.t

  def get_artist(mbid) do
    path = "/artist/#{mbid}"
    params = %{inc: "release-groups", fmt: "json"}

    do_get(path, params)
  end

  def do_get(path, params) do
    case HTTPClient.get(@base_url <> path, params, @headers) do
      %Response{status_code: 200, body: body} ->
        Poison.decode(body)
      %Response{status_code: status_code, body: body} ->
        {:error, {status_code, body}}
      %ErrorResponse{message: message} ->
        message
    end
  end
end
