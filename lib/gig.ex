defmodule Gig do
  @moduledoc """
  This module exposes the top-level apis
  for the Gig application.
  """

  defdelegate find_monitor(lat, lng), to: Gig.Monitor.Supervisor

  def start_monitoring(lat, lng) do
    Gig.Monitor.Supervisor.start_child(lat, lng)
  end

  def stop_monitoring(lat, lng) do
    Gig.Monitor.Supervisor.terminate_child(lat, lng)
    :ok
  end

  def get_metro_area(lat, lng) do
    case find_monitor(lat, lng) do
      {:ok, pid} ->
        get_metro_area(pid)
      error ->
        error
    end
  end
  def get_metro_area(pid), do: {:ok, Gig.Monitor.NewEvents.get_metro_area(pid)}
end
