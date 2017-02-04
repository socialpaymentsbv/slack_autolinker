defmodule SlackAutolinker.Plug do
  @moduledoc false

  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{version: "1.0.0-dev"}))
  end
end
