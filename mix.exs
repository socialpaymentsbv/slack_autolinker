defmodule SlackAutolinker.Mixfile do
  use Mix.Project

  def project do
    [app: :slack_autolinker,
     version: "1.0.0-dev",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {SlackAutolinker.Application, []}]
  end

  defp deps do
    [
      {:cowboy, "~> 1.0.0"},
      {:httpoison, "~> 0.9"},
      {:plug, "~> 1.0"},
      {:poison, "~> 3.0"},
      {:slack, "~> 0.9.3"},
    ]
  end

  defp aliases do
    ["test": ["test --no-start"]]
  end
end
