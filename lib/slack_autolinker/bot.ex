defmodule SlackAutolinker.Bot do
  @moduledoc false

  use Slack
  require Logger
  
  def handle_connect(slack, state) do
    Logger.info "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(%{subtype: "bot_message"}, _, state), do: {:ok, state}
  def handle_event(message = %{type: "message", text: text}, _slack, state) do
    config = config()
    reply = SlackAutolinker.reply(normalize_text(text), config)

    if reply do
      icon = if config.icon_url, do: %{icon_url: config.icon_url}, else: %{icon_emoji: config.icon_emoji}
      opts = Map.merge(icon, %{parse: "none", username: config.username})

      Slack.Web.Chat.post_message(message.channel, reply, opts)
    end

    {:ok, state}
  end
  def handle_event(_, _, state), do: {:ok, state}

  def handle_info(_, _, state), do: {:ok, state}

  defp normalize_text(text) when is_binary(text) do
    Regex.replace(~r/<(http.*)\|(.*?)>/, text, "\\2")
  end

  defp config do
    %{github_repo_aliases: Application.get_env(:slack_autolinker, :github_repo_aliases) |> Poison.decode!(),
      clubhouse_project_aliases: Application.get_env(:slack_autolinker, :clubhouse_project_aliases) |> Poison.decode!() |> to_clubhouse_aliases(),
      username: Application.get_env(:slack_autolinker, :username),
      icon_emoji: Application.get_env(:slack_autolinker, :icon_emoji),
      icon_url: Application.get_env(:slack_autolinker, :icon_url)}
  end

  defp to_clubhouse_aliases(aliases) do
    aliases
    |> Enum.map(fn({alias, %{"project" => project, "token" => token}}) ->
      %{alias => {project, token}}
    end)
  end
end
