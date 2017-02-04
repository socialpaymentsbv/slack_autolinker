use Mix.Config

config :slack_autolinker,
  port: (System.get_env("PORT") || "4000") |> String.to_integer,
  repo_aliases: (System.get_env("BOT_REPO_ALIASES") || "{}"),
  username: "autolinker",
  icon_emoji: ":anchor:"

config :slack, api_token: (System.get_env("SLACK_TOKEN") || raise "SLACK_TOKEN missing")
