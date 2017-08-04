defmodule Gig.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Registry, keys: :unique, name: Registry.Monitor},
      {Gig.Release.Throttle, 50},
      {Gig.Monitor.Supervisor, []},
      {Plug.Adapters.Cowboy, scheme: :http, plug: Gig.Router, options: [port: 4000]}
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
end
