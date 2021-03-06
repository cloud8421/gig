defmodule HTTPClient do
  defmodule Response do
    @moduledoc false
    defstruct status_code: 100,
              headers: [],
              body: <<>>
  end

  defmodule ErrorResponse do
    @moduledoc false
    defstruct message: nil
  end

  @moduledoc """
  Simple http client based on httpc.
  """
  def get(url, qs_params, headers) do
    headers = Enum.map(headers, fn({k, v}) ->
      {String.to_charlist(k), String.to_charlist(v)}
    end)
    url_with_qs = url <> "?" <> URI.encode_query(qs_params)

    :httpc.request(:get, {String.to_charlist(url_with_qs), headers}, [], [])
    |> process_response
  end

  def process_response({:ok, result}) do
    {{_, status, _}, headers, body} = result

    headers = Enum.map(headers, fn({k, v}) ->
      {List.to_string(k), List.to_string(v)}
    end)

    %Response{status_code: status,
              headers: headers,
              body: body}
  end

  def process_response({:error, reason}) do
    %ErrorResponse{message: reason}
  end
end
