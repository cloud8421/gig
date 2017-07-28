defmodule Gig.Mixfile do
  use Mix.Project

  def project do
    [
      app: :gig,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      docs: [main: "readme", extras: ["README.md"]],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Gig.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpotion, "~> 3.0"},
      {:poison, "~> 3.1"},
      {:ex_doc, "~> 0.16.1", only: :docs, runtime: false},
      {:credo, "~> 0.8.1", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5.0", only: :dev, runtime: false}
    ]
  end
end
