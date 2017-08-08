defmodule Gig.Mixfile do
  use Mix.Project

  def project do
    [
      app: :gig,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env == :prod,
      docs: [main: "readme", extras: ["README.md"]],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :inets, :ssl],
      mod: {Gig.Application, []},
      start_phases: [create_store_tables: []]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.1"},
      {:recipe, "~> 0.4.3"},
      {:ex_rated, "~> 1.3"},
      {:plug, "~> 1.4"},
      {:cors_plug, "~> 1.4"},
      {:cowboy, "~> 1.1.0"},
      {:graphiter, "~> 1.0", only: :prod},
      {:ex_doc, "~> 0.16.1", only: :dev, runtime: false},
      {:credo, "~> 0.8.1", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5.0", only: :dev, runtime: false}
    ]
  end
end
