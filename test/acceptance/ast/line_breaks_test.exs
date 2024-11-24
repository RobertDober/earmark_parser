defmodule Acceptance.Ast.LineBreaksTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, parse_html: 1]
  import EarmarkAstDsl

  describe "Forced Line Breaks" do
    test "with two spaces" do
      markdown = "The  \nquick"
      html     = "<p>The<br />quick</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
    test "or more spaces" do
      markdown = "The   \nquick"
      html     = "<p>The<br />quick</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
    test "or in some lines" do
      markdown = "The   \nquick  \nbrown"
      html     = "<p>The<br />quick<br />brown</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
    test "and in list items" do
      markdown = "* The  \nquick"
      html     = "<ul>\n<li>The<br />quick</li>\n</ul>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
    test "only one line" do
      markdown = "* The lonly  "
      ast      = [
        ul(li("The lonly  "))
      ]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end


  describe "No Forced Line Breaks" do
    test "with only one space" do
      markdown = "The \nquick"
      html     = "<p>The \nquick</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
    test "or whitespace lines" do
      markdown = "The\n  \nquick"
      html     = "<p>The</p>\n<p>quick</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
    test "or inside the line" do
      markdown = "The  quick\nbrown"
      html     = "<p>The  quick\nbrown</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
    test "or at the end of input" do
      markdown = "The\nquick  "
      html     = "<p>The\nquick  </p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
    test "or in code blocks" do
      markdown = "```\nThe \nquick\n```"
      html     = "<pre><code>The \nquick</code></pre>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
