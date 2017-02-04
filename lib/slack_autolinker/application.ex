defmodule SlackAutolinker.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    port = Application.get_env(:slack_autolinker, :port)
    slack_token = Application.get_env(:slack, :api_token)

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, SlackAutolinker.Plug, [], [port: port]),
      worker(Slack.Bot, [SlackAutolinker.Bot, [], slack_token]),
    ]

    opts = [strategy: :one_for_one, name: SlackAutolinker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
