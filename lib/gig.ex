defmodule Gig do
  @moduledoc """
  This module exposes the top-level apis
  for the Gig application.
  """

  def start_monitoring(lat, lng) do
    Gig.Monitor.Supervisor.start_child(lat, lng)
  end

  def stop_monitoring(lat, lng) do
    Gig.Monitor.Supervisor.terminate_child(lat, lng)
    :ok
  end

  def get_metro_area(lat, lng) do
    case Gig.Monitor.Supervisor.find_monitor(lat, lng) do
      {:ok, pid} ->
        {:ok, Gig.Monitor.NewEvents.get_metro_area(pid)}
      error ->
        error
    end
  end
end
