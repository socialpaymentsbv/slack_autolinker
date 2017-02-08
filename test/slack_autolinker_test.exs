defmodule SlackAutolinkerTest do
  use ExUnit.Case
  doctest SlackAutolinker, import: true
  import SlackAutolinker

  test "extract" do
    assert extract("See: bb#10.") == []

    repo_aliases = %{"bb" => "aa/bb"}
    assert extract("See: bb#10.", repo_aliases) == [{"bb#10", "aa/bb", "10"}]

    # uniqueness
    repo_aliases = %{"bb" => "aa/bb"}
    assert extract("See: bb#10, bb#10.", repo_aliases) == [{"bb#10", "aa/bb", "10"}]
  end
end
