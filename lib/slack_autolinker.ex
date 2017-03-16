defmodule SlackAutolinker do
  @default_repo_aliases %{
    "elixir" => "elixir-lang/elixir",
    "ecto" => "elixir-ecto/ecto",
    "phoenix" => "phoenixframework/phoenix",
  }
  @link_separator ", "
  @github Application.get_env(:slack_autolinker, :github_adapter)

  alias SlackAutolinker.GitHub.Issue
  require Logger

  def reply(text, repo_aliases) do
    case extract(text, repo_aliases) do
      [] ->
        nil
      links ->
        if String.contains?(text, "!new") do
          links_with_titles(links)
        else
          Enum.map_join(links, @link_separator, &github_link/1)
        end
    end
  end

  defp links_with_titles(links) do
    issues =
      for {_, repo, number} <- links do
        [owner, repo] = String.split(repo, "/", trim: true)
        {owner, repo, number}
      end

    pids =
      for {owner, repo, number} <- issues do
        Task.async(fn -> @github.get_issue(owner, repo, number) end)
      end

    for {link, pid} <- Enum.zip(links, pids) do
      case Task.await(pid) do
        {:ok, %Issue{title: title}} ->
          github_link(link) <> " - " <> title
        {:error, reason} ->
          Logger.warn("error: #{inspect reason}")
          github_link(link) <> " (error: couldn't fetch title)"
      end
    end
    |> Enum.join("\n")
  end

  @doc false
  def extract(text, repo_aliases \\ %{}) do
    repo_aliases = Map.merge(@default_repo_aliases, repo_aliases)
    repo_pattern = "([a-z]+[a-z0-9-_\.]*[a-z0-9]*)"

    Regex.scan(~r/#{repo_pattern}#(\d+)/i, String.downcase(text))
    |> Enum.flat_map(fn [orig, repo_alias, number] ->
      case Map.fetch(repo_aliases, repo_alias) do
        {:ok, repo} -> [{orig, repo, String.to_integer(number)}]
        :error -> []
      end
    end)
    |> Enum.uniq
  end

  defp github_link({orig, repo, number}),
    do: "<#{github_url(repo, number)}|#{orig}>"

  defp github_url(repo, number),
    do: "https://github.com/#{repo}/issues/#{number}"
end
