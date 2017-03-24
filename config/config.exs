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
  username: (System.get_env("BOT_USERNAME") || "autolinker"),
  icon_emoji: (System.get_env("BOT_ICON_EMOJI") || ":anchor:"),
  icon_url: System.get_env("BOT_ICON_URL"), # if present, overwrites icon_emoji
  github_adapter: github_adapter,
  github_token: (System.get_env("GITHUB_TOKEN") || raise "GITHUB_TOKEN missing")

import_config "#{Mix.env}.exs"
