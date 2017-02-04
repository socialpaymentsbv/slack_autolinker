defmodule SlackAutolinker do
  @doc """
  Scans `text` for link patterns and returns list of links.

  ## Examples

      iex> scan "Hello"
      []

      iex> scan "See: elixir#10.", %{"elixir" => "elixir-lang/elixir"}
      ["<https://github.com/elixir-lang/elixir/issues/10|elixir#10>"]

  """
  def scan(text, repo_aliases \\ %{}) do
    extract(text, repo_aliases)
    |> Enum.map(&github_link(&1))
  end

  @default_repo_aliases %{
    "elixir" => "elixir-lang/elixir",
    "ecto" => "elixir-ecto/ecto",
    "phoenixframework" => "phoenixframework/phoenix",
  }

  @doc false
  def extract(text, repo_aliases \\ %{}) do
    repo_aliases = Map.merge(@default_repo_aliases, repo_aliases)
    repo_pattern = "([a-z]+[a-z0-9-_\.]*[a-z0-9]*)"

    Regex.scan(~r/#{repo_pattern}#(\d+)/i, String.downcase(text))
    |> Enum.flat_map(fn [orig, repo_alias, number] ->
      case Map.fetch(repo_aliases, repo_alias) do
        {:ok, repo} -> [{orig, repo, number}]
        :error -> []
      end
    end)
  end

  defp github_link({orig, repo, number}),
    do: "<#{github_url(repo, number)}|#{orig}>"

  defp github_url(repo, number),
    do: "https://github.com/#{repo}/issues/#{number}"
end
