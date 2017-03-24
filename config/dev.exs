use Mix.Config

config :slack, api_token: (System.get_env("SLACK_TOKEN") || "dummy")
