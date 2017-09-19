use Mix.Config

github_adapter =
  if Mix.env == :prod do
    SlackAutolinker.GitHub.Real
  else
    SlackAutolinker.GitHub.Fake
  end

clubhouse_adapter =
  if Mix.env == :prod do
    SlackAutolinker.ClubHouse.Real
  else
    SlackAutolinker.ClubHouse.Fake
  end

config :slack_autolinker,
  port: (System.get_env("PORT") || "4000") |> String.to_integer,
  github_repo_aliases: (System.get_env("GITHUB_REPO_ALIASES") || "{}"),
  clubhouse_project_aliases: (System.get_env("CLUBHOUSE_PROJECT_ALIASES") || "{}"),
  username: (System.get_env("BOT_USERNAME") || "autolinker"),
  icon_emoji: (System.get_env("BOT_ICON_EMOJI") || ":anchor:"),
  icon_url: System.get_env("BOT_ICON_URL"), # if present, overwrites icon_emoji
  github_adapter: github_adapter,
  github_token: (System.get_env("GITHUB_TOKEN") || raise "GITHUB_TOKEN missing"),
  clubhouse_adapter: clubhouse_adapter

import_config "#{Mix.env}.exs"
