use Mix.Config

config :slack_autolinker,
  port: (System.get_env("PORT") || "4000") |> String.to_integer,
  repo_aliases: (System.get_env("BOT_REPO_ALIASES") || "{}"),
  username: "autolinker",
  icon_emoji: ":anchor:"

import_config "#{Mix.env}.exs"
