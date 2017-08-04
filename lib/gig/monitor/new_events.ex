defmodule Gig.Monitor.NewEvents do
  @moduledoc """
  Given a starting lat/lng, a `Gig.Monitor` process
  regularly monitors the available events for the specified
  coordinates pair.
  """

  use GenServer

  @default_running_opts [recipe_module: Gig.Recipe.RefreshEvents,
                         retry_interval: 1000 * 30, # 30 seconds
                         refresh_interval: 1000 * 60 * 60 * 12] # 12 hours

  defstruct running_opts: @default_running_opts,
            coords: {0, 0}

  def child_spec(_) do
    %{id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      restart: :transient,
      shutdown: 5000,
      type: :worker}
  end

  def via(lat, lng) do
    {:via, Registry, {Registry.Monitor, {lat, lng}}}
  end

  def start_link(lat, lng, opts \\ []) do
    running_opts = Keyword.merge(@default_running_opts, opts)
    GenServer.start_link(__MODULE__, {{lat, lng}, running_opts}, name: via(lat, lng))
  end

  def init({coords, running_opts}) do
    send(self(), :refresh)

    {:ok, %__MODULE__{running_opts: running_opts,
                      coords: coords}}
  end

  def handle_info(:refresh, state) do
    {lat, lng} = state.coords
    recipe_module = Keyword.get(state.running_opts, :recipe_module)
    refresh_interval = Keyword.get(state.running_opts, :refresh_interval)
    retry_interval = Keyword.get(state.running_opts, :retry_interval)

    case recipe_module.run(lat, lng) do
      {:ok, _correlation_id, _result} ->
        Process.send_after(self(), :refresh, refresh_interval)
        {:noreply, state}
      _error ->
        Process.send_after(self(), :refresh, retry_interval)
        {:noreply, state}
    end
  end
end
