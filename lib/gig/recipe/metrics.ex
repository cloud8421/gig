defmodule Gig.Recipe.Metrics do
  use Recipe.Telemetry

  @error_steps [:check_rate_limit, :fetch_data]

  def on_start(_state), do: :ok
  def on_finish(_state), do: :ok

  def on_success(:fetch_data, state, duration) do
    metric_name = recipe_module_to_metric_name(state.recipe_module)
    Metrics.counter("fetch_data.#{metric_name}", duration / 1000)
    :ok
  end
  def on_success(_step, _state, _duration), do: :ok

  def on_error(step, error, _state, _duration) when step in @error_steps do
    Metrics.inc("error.#{step}")
    :ok
  end
  def on_error(_step, _error, _state, _duration), do: :ok

  defp recipe_module_to_metric_name(recipe_module) do
    case Module.split(recipe_module) do
      [name] ->
        Macro.underscore(name)
      names ->
        [name | _rest] = Enum.reverse(names)
        Macro.underscore(name)
    end
  end
end
