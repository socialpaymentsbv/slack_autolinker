use Mix.Config

github_adapter =
  if Mix.env == :prod do
    SlackAutolinker.GitHub.Real
  else
    SlackAutolinker.GitHub.Fake
  end

config :slack_autolinker,
  port: (System.get_env("PORT") || "4000") |> String.to_integer,
  repo_aliases: (System.get_env("BOT_REPO_ALIASES") || "{}"),
  username: "autolinker",
  icon_emoji: ":anchor:",
  github_adapter: github_adapter,
  github_token: (System.get_env("GITHUB_TOKEN") || raise "GITHUB_TOKEN missing")

config :slack, api_token: (System.get_env("SLACK_TOKEN") || raise "SLACK_TOKEN missing")
