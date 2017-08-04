defmodule Gig.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Registry.Monitor},
      {Gig.Release.Throttle, 50},
      {Gig.Monitor.Supervisor, []},
      {Plug.Adapters.Cowboy, scheme: :http, plug: Gig.Router, options: [port: server_port()]}
      # Starts a worker by calling: Gig.Worker.start_link(arg)
      # {Gig.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gig.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_phase(:create_store_tables, _type, _args) do
    Gig.Store.create_table(Gig.Store.Event)
    Gig.Store.create_table(Gig.Store.Location)
    Gig.Store.create_table(Gig.Store.Release)
    :ok
  end

  defp server_port do
    case Application.get_env(:gig, :server_port) do
      port when is_binary(port) ->
        String.to_integer(port)
      port ->
        port
    end
  end
end
