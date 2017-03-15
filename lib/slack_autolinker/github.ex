defmodule SlackAutolinker.GitHub do
  defmodule Issue do
    defstruct [:number, :title]
  end

  @type owner :: String.t
  @type repo  :: String.t

  @callback get_issue(owner, repo, number) :: {:ok, Issue.t} :: {:error, term}
end

defmodule SlackAutolinker.GitHub.Real do
  @behaviour SlackAutolinker.GitHub
  @github_url "https://api.github.com"
  alias SlackAutolinker.GitHub.Issue

  def get_issue(owner, repo, number) do
    case request("/repos/#{owner}/#{repo}/issues/#{number}") do
      {:ok, payload} ->
        %Issue{number: payload["number"], title: payload["title"]}
      other ->
        other
    end
  end

  defp request(path) do
    token = Application.fetch_env!(:slack_autolinker, :github_token)
    url = @github_url <> path
    headers = [{"Authorization", "token #{token}"}]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        {:ok, Poison.decode!(body)}

      {:ok, %HTTPoison.Response{} = response} ->
        {:error, response}

      {:error, %HTTPoison.Error{} = error} ->
        {:error, error}
    end
  end
end

defmodule SlackAutolinker.GitHub.Fake do
  @behaviour SlackAutolinker.GitHub
  alias SlackAutolinker.GitHub.Issue

  def get_issue(owner, repo, number) do
    {:ok, %Issue{number: number, title: "Test: #{owner}/#{repo}##{number}"}}
  end
end
