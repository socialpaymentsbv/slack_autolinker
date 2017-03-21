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
    reply = SlackAutolinker.reply(normalize_text(text), config.repo_aliases)

    if reply do
      opts = %{parse: "none", username: config.username, icon_emoji: config.icon_emoji}
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
    %{repo_aliases: Application.get_env(:slack_autolinker, :repo_aliases) |> Poison.decode!(),
      username: Application.get_env(:slack_autolinker, :username),
      icon_emoji: Application.get_env(:slack_autolinker, :icon_emoji)}
  end
end
