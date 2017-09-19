defmodule SlackAutolinker do
  @default_repo_aliases %{
    "elixir" => "elixir-lang/elixir",
    "ecto" => "elixir-ecto/ecto",
    "phoenix" => "phoenixframework/phoenix",
  }

  alias SlackAutolinker.ClubHouse
  alias SlackAutolinker.GitHub

  @github Application.get_env(:slack_autolinker, :github_adapter)
  @clubhouse Application.get_env(:slack_autolinker, :clubhouse_adapter)

  @project_pattern "([a-z]+[a-z0-9-_\.]*[a-z0-9]*)"

  require Logger

  def reply(text, aliases) do
    case extract(text, aliases) do
      {[], []} ->
        nil
      {github_links, clubhouse_links} ->
        github_links_with_titles(github_links)
        |> Enum.concat(clubhouse_links_with_titles(clubhouse_links))
        |> Enum.join("\n")
    end
  end

  defp github_links_with_titles(links) do
    issues =
      for {_, repo, number} <- links do
        [owner, repo] = String.split(repo, "/", trim: true)
        {owner, repo, number}
      end

    for {owner, repo, number} <- issues do
      Task.async(fn -> @github.get_issue(owner, repo, number) end)
    end
    |> to_slack_links(links, &GitHub.to_link/1)
  end

  defp clubhouse_links_with_titles(links) do
    for {_orig, _project, token, number} <- links do
      Task.async(fn -> @clubhouse.get_issue(token, number) end)
    end
    |> to_slack_links(links, &ClubHouse.to_link/1)
  end

  defp to_slack_links(pids, links, link_fn) do
    for {link, pid} <- Enum.zip(links, pids) do
      Task.await(pid) |> to_slack_link(link, link_fn)
    end
  end

  defp to_slack_link({:ok, %{title: title}}, link, link_fn) do
    link_fn.(link) <> " - " <> title
  end
  defp to_slack_link({:error, reason}, link, link_fn) do
    Logger.warn("error: #{inspect reason}")
    link_fn.(link) <> " (error: couldn't fetch title)"
  end

  @doc false
  def extract(text, %{} = config \\ %{}) do
    github_repo_aliases = Map.get(config, :github_repo_aliases, %{})
    clubhouse_project_aliases = Map.get(config, :clubhouse_project_aliases, %{})
    {extract_github(text, github_repo_aliases), extract_clubhouse(text, clubhouse_project_aliases)}
  end

  defp extract_github(text, repo_aliases) do
    repo_aliases = Map.merge(@default_repo_aliases, repo_aliases)
    pattern = ~r/#{@project_pattern}#(\d+)/i
    do_extract(text, repo_aliases, pattern, fn(orig, repo, number) ->
      {orig, repo, number}
    end)
  end

  defp extract_clubhouse(text, project_aliases) do
    pattern = ~r/#{@project_pattern}!(\d+)/i
    do_extract(text, project_aliases, pattern, fn(orig, {project, token}, number) ->
      {orig, project, token, number}
    end)
  end

  defp do_extract(text, aliases, pattern, to_result_fn) do
    Regex.scan(pattern, String.downcase(text))
    |> Enum.flat_map(fn [orig, alias, number] ->
      case Map.fetch(aliases, alias) do
        {:ok, repo} -> [to_result_fn.(orig, repo, String.to_integer(number))]
        :error -> []
      end
    end)
    |> Enum.uniq
  end
end
