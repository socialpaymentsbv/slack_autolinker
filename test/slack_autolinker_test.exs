defmodule SlackAutolinkerTest do
  use ExUnit.Case
  doctest SlackAutolinker, import: true
  import SlackAutolinker

  test "reply" do
    repo_aliases = %{"bb" => "aa/bb"}

    assert reply("", %{}) == nil


    assert reply("See: bb#1, bb#2.", repo_aliases) ==
      "<https://github.com/aa/bb/issues/1|bb#1> - Test: aa/bb#1\n" <>
      "<https://github.com/aa/bb/issues/2|bb#2> - Test: aa/bb#2"

    assert reply("See: bb#404.", repo_aliases) ==
      "<https://github.com/aa/bb/issues/404|bb#404> (error: couldn't fetch title)"
  end

  test "extract" do
    assert extract("See: bb#10.") == []

    repo_aliases = %{"bb" => "aa/bb"}
    assert extract("See: bb#10.", repo_aliases) == [{"bb#10", "aa/bb", 10}]

    # uniqueness
    repo_aliases = %{"bb" => "aa/bb"}
    assert extract("See: bb#10, bb#10.", repo_aliases) == [{"bb#10", "aa/bb", 10}]
  end
end
