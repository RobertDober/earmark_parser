defmodule Acceptance.Ast.LinkImages.WikiLinksTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 2, parse_html: 1, parse_html: 2]

  describe "Wiki links" do
    test "basic wiki-style link" do
      markdown = "[[page]]"
      html = "<p><a href=\"page\">page</a></p>\n"
      ast      = parse_html(html, &add_wikilinks_metadata/1)
      messages = []

      assert as_ast(markdown, wikilinks: true) == {:ok, ast, messages}
    end

    test "wikilink parsing is optional" do
      markdown = "[[page]]"
      html = "<p>[[page]]</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, wikilinks: false) == {:ok, ast, messages}
    end

    test "misleading non-wiki link" do
      markdown = "[[page]](actual_link)"
      html = "<p><a href=\"actual_link\">[page]</a></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, wikilinks: true) == {:ok, ast, messages}
    end

    test "alternate text" do
      markdown = "[[page | My Label]]"
      html = "<p><a href=\"page\">My Label</a></p>\n"
      ast      = parse_html(html, &add_wikilinks_metadata/1)
      messages = []

      assert as_ast(markdown, wikilinks: true) == {:ok, ast, messages}
    end

    test "illegal urls are not Earmark's responsibility" do
      markdown = "[[A long & complex title]]"
      html = "<p><a href=\"A long & complex title\">A long &amp; complex title</a></p>\n"
      ast      = parse_html(html, &add_wikilinks_metadata/1)
      messages = []

      assert as_ast(markdown, wikilinks: true) == {:ok, ast, messages}
    end

    test "links in a list don't get wrapped in a p tag" do
      markdown = "* Test: [[page | My Label]]"
      html = "<ul><li>Test: <a href=\"page\">My Label</a></li></ul>\n"
      ast      = parse_html(html, &add_wikilinks_metadata/1)
      messages = []

      assert as_ast(markdown, wikilinks: true) == {:ok, ast, messages}
    end

    test "links in a list don't get wrapped in a p tag when using GFM" do
      markdown = "* Test: [[page | My Label]]"
      html = "<ul><li>Test: <a href=\"page\">My Label</a></li></ul>\n"
      ast      = parse_html(html, &add_wikilinks_metadata/1)
      messages = []

      assert as_ast(markdown, wikilinks: true, gfm_tables: true) == {:ok, ast, messages}
    end
  end

  def add_wikilinks_metadata({"a", _, _}), do: %{wikilink: true}
  def add_wikilinks_metadata(_), do: %{}
end
