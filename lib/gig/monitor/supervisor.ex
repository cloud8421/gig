defmodule Gig.Monitor.Supervisor do
  @moduledoc """
  Controls starting and stopping of Monitor processes.
  """
  use Supervisor

  def start_child(lat, lng) do
    Supervisor.start_child(__MODULE__, [lat, lng])
  end

  def terminate_child(lat, lng) do
    case Registry.lookup(Registry.Monitor, {lat, lng}) do
      [] ->
        {:error, :not_found}
      [{pid, _meta}] ->
        terminate_child(pid)
    end
  end

  def terminate_child(pid) do
    Supervisor.terminate_child(__MODULE__, pid)
  end

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ignored, name: __MODULE__)
  end

  def init(_) do
    children = [
      Gig.Monitor
    ]

    Supervisor.init(children, strategy: :simple_one_for_one)
  end
end
