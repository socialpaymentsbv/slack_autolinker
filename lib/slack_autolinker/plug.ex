defmodule SlackAutolinker.Plug do
  @moduledoc false

  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    {:ok, vsn} = :application.get_key(:slack_autolinker, :vsn)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{version: List.to_string(vsn)}))
  end
end
