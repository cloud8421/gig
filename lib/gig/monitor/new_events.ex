defmodule Gig.Monitor.NewEvents do
  @moduledoc """
  Given a starting lat/lng, a `Gig.Monitor` process
  regularly monitors the available events for the specified
  coordinates pair.
  """

  use GenServer

  @default_stop_after 1000 * 60 * 60 * 24 # 24 hours
  @default_running_opts [recipe_module: Gig.Recipe.RefreshEvents,
                         retry_interval: 1000 * 30, # 30 seconds
                         refresh_interval: 1000 * 60 * 60 * 3] # 3 hours

  defstruct running_opts: @default_running_opts,
            stop_ref: nil,
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
    stop_after = Keyword.get(running_opts, :stop_after, @default_stop_after)
    send(self(), :refresh)
    stop_ref = Process.send_after(self(), :stop, stop_after)

    {:ok, %__MODULE__{running_opts: running_opts,
                      stop_ref: stop_ref,
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

  def handle_info(:stop, state) do
    Process.cancel_timer(state.stop_ref)
    {:stop, :normal, state}
  end
end
