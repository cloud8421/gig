defmodule Gig.Recipe do
  def run(recipe_module, initial_state, run_opts \\ []) do
    final_run_opts = Keyword.put_new(run_opts,
                                     :enable_telemetry,
                                     telemetry_enabled?())

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
