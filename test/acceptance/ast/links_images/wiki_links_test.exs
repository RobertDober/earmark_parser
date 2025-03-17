defmodule Acceptance.Ast.LinkImages.WikiLinksTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 2]
  import EarmarkAstDsl

  @wikilink %{wikilink: true}

  describe "Wiki links" do
    test "basic wiki-style link" do
      markdown = "[[page]]"
      ast = [p(a("page", [href: "page"], @wikilink))]
      messages = []

      assert as_ast(markdown, wikilinks: true) == {:ok, ast, messages}
    end

    test "wikilink parsing is optional" do
      markdown = "[[page]]"
      ast = [p("[[page]]")]
      messages = []

      assert as_ast(markdown, wikilinks: false) == {:ok, ast, messages}
    end

    test "misleading non-wiki link" do
      markdown = "[[page]](actual_link)"
      ast = [p(a("[page]", href: "actual_link"))]
      messages = []

      assert as_ast(markdown, wikilinks: true) == {:ok, ast, messages}
    end

    test "illegal urls are not Earmark's responsibility" do
      markdown = "[[A long & complex title]]"
      ast = [p(a("A long & complex title", [href: "A long & complex title"], @wikilink))]
      messages = []

      assert as_ast(markdown, wikilinks: true) == {:ok, ast, messages}
    end
  end

  describe "i112 <p> around labelled wikilinks" do
    test "links in a list do not get wrapped in a p tag" do
      markdown = "* Test: [[page | My Label]]"
      ast = [tag("ul", li(["Test: ", a("My Label", [href: "page"], %{wikilink: true})]))]
      messages = []

      assert as_ast(markdown, wikilinks: true) == {:ok, ast, messages}
    end

    test "links in a list do not get wrapped in a p tag when using GFM" do
      markdown = "* Test: [[page | My Label]]"
      ast = [tag("ul", li(["Test: ", a("My Label", [href: "page"], %{wikilink: true})]))]
      messages = []

      assert as_ast(markdown, wikilinks: true, gfm_tables: true) == {:ok, ast, messages}
    end

    test "links in a list do not get wrapped in a p tag when using GFM (via all: true)" do
      markdown = "* Test: [[page | My Label]]"
      ast = [tag("ul", li(["Test: ", a("My Label", [href: "page"], %{wikilink: true})]))]
      messages = []

      assert as_ast(markdown, all: true) == {:ok, ast, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
