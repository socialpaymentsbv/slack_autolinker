defmodule SlackAutolinkerTest do
  use ExUnit.Case
  doctest SlackAutolinker, import: true
  import SlackAutolinker

  describe "reply" do
    test "common" do
      assert reply("", %{}) == nil
    end

    test "github" do
      repo_aliases = %{"bb" => "aa/bb"}

      assert reply("See: bb#1, bb#2.", %{github_repo_aliases: repo_aliases}) ==
               "<https://github.com/aa/bb/issues/1|bb#1> - Test: aa/bb#1\n" <>
               "<https://github.com/aa/bb/issues/2|bb#2> - Test: aa/bb#2"

      assert reply("See: bb#404.", %{github_repo_aliases: repo_aliases}) ==
               "<https://github.com/aa/bb/issues/404|bb#404> (error: couldn't fetch title)"
    end

    test "clubhouse" do
      project_aliases = %{"cb" => {"clubbase", "token"}}

      assert reply("See: cb!1, cb!2.", %{clubhouse_project_aliases: project_aliases}) ==
               "<https://app.clubhouse.io/clubbase/story/1|cb!1> - Test: 1\n" <>
               "<https://app.clubhouse.io/clubbase/story/2|cb!2> - Test: 2"

      assert reply("See: cb!404.", %{clubhouse_project_aliases: project_aliases}) ==
               "<https://app.clubhouse.io/clubbase/story/404|cb!404> (error: couldn't fetch title)"
    end
  end

  describe "extract" do
    test "common" do
      assert extract("See: bb#10.") == {[], []}
    end

    test "github" do
      repo_aliases = %{"bb" => "aa/bb"}

      assert extract("See: bb#10.", %{github_repo_aliases: repo_aliases}) == {[{"bb#10", "aa/bb", 10}], []}
      assert extract("See: bb#10, bb#10.", %{github_repo_aliases: repo_aliases}) == {[{"bb#10", "aa/bb", 10}], []} # uniqueness
    end

    test "clubhouse" do
      project_aliases = %{"cb" => {"clubbase", "token"}}

      assert extract("See: cb!10.", %{clubhouse_project_aliases: project_aliases}) == {[], [{"cb!10", "clubbase", "token", 10}]}
      assert extract("See: cb!10, cb!10.", %{clubhouse_project_aliases: project_aliases}) == {[], [{"cb!10", "clubbase", "token", 10}]} # uniqueness
    end
  end
end
