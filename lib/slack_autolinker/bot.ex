defmodule SlackAutolinker.Bot do
  @moduledoc false

  use Slack
  require Logger
  
  @link_separator ", "

  def handle_connect(slack, state) do
    Logger.info "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(%{subtype: "bot_message"}, _, state), do: {:ok, state}
  def handle_event(message = %{type: "message"}, _slack, state) do
    repo_aliases = Application.get_env(:slack_autolinker, :repo_aliases) |> Poison.decode!
    username = Application.get_env(:slack_autolinker, :username)
    icon_emoji = Application.get_env(:slack_autolinker, :icon_emoji)

    text = normalize_text(message.text)
    links = SlackAutolinker.scan(text, repo_aliases)

    if links != [] do
      text = Enum.join(links, @link_separator)
      opts = %{parse: "none", username: username, icon_emoji: icon_emoji}
      Slack.Web.Chat.post_message(message.channel, text, opts)
    end

    {:ok, state}
  end
  def handle_event(_, _, state), do: {:ok, state}

  def handle_info(_, _, state), do: {:ok, state}

  defp normalize_text(text) when is_binary(text) do
    Regex.replace(~r/<(http.*)\|(.*?)>/, text, "\\2")
  end
end
