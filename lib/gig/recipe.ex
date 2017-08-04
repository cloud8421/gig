defmodule Gig.Recipe do
  def run(recipe_module, initial_state, run_opts \\ []) do
    final_run_opts = run_opts
                     |> Keyword.put_new(:enable_telemetry, telemetry_enabled?())
                     |> Keyword.put_new(:telemetry_module, Gig.Recipe.Metrics)

    Recipe.run(recipe_module, initial_state, final_run_opts)
  end

  def telemetry_on! do
    Application.put_env(:recipe, :enable_telemetry, true)
  end

  def telemetry_off! do
    Application.put_env(:recipe, :enable_telemetry, false)
  end

  defp telemetry_enabled? do
    Application.get_env(:recipe, :enable_telemetry, false)
  end
end
