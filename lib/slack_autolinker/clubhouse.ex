defmodule SlackAutolinker.ClubHouse do
  defmodule Issue do
    defstruct [:number, :title]
  end

  @type token :: String.t
  @type num   :: integer

  @callback get_issue(token, num) :: {:ok, Issue.t} :: {:error, term}

  def to_link({orig, project, _token, number}), do: "<#{clubhouse_url(project, number)}|#{orig}>"

  defp clubhouse_url(project, number), do: "https://app.clubhouse.io/#{project}/story/#{number}"
end

defmodule SlackAutolinker.ClubHouse.Real do
  @behaviour SlackAutolinker.ClubHouse
  @api_url "https://api.clubhouse.io/api/v2"
  alias SlackAutolinker.ClubHouse.Issue

  # TODO search among epics too !!!
  def get_issue(token, number) do
    case request(token, "/stories/#{number}") do
      {:ok, payload} ->
        {:ok, %Issue{number: payload["id"], title: payload["name"]}}
      other ->
        other
    end
  end

  defp request(token, path) do
    url = @api_url <> path <> "?token=" <> token

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        {:ok, Poison.decode!(body)}

      {:ok, %HTTPoison.Response{} = response} ->
        {:error, response}

      {:error, %HTTPoison.Error{} = error} ->
        {:error, error}
    end
  end
end

defmodule SlackAutolinker.ClubHouse.Fake do
  @behaviour SlackAutolinker.ClubHouse
  alias SlackAutolinker.ClubHouse.Issue

  def get_issue(_token, 404) do
    {:error, :fake_reason}
  end

  def get_issue(_token, number) do
    {:ok, %Issue{number: number, title: "Test: #{number}"}}
  end
end
