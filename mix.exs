defmodule Aoc2018.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc_2018,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nimble_parsec, "~> 0.4.0"},
      {:benchee, "~> 0.13"},
    ]
  end
end
