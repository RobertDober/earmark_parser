defmodule Acceptance.Ast.MathTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, as_ast: 2, parse_html: 1]

  test "ignored when :math is disabled" do
    markdown = "foo $x = 1$ bar $$x = 1$$"
    html     = "<p>foo $x = 1$ bar $$x = 1$$</p>\n"
    ast      = parse_html(html)
    messages = []

    assert as_ast(markdown) == {:ok, ast, messages}
  end

  describe "math inline" do
    test "base case" do
      markdown = "foo $x = 1$"
      html     = "<p>foo <code class=\"math-inline\">x = 1</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, math: true) == {:ok, ast, messages}
    end

    test "with surrounding characters" do
      markdown = "foo$x = 1$bar"
      html     = "<p>foo<code class=\"math-inline\">x = 1</code>bar</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, math: true) == {:ok, ast, messages}
    end

    test "ignored when where are spaces" do
      markdown = "foo $ x = 1$ bar $x = 1 $ baz $ x = 1 $"
      html     = "<p>foo $ x = 1$ bar $x = 1 $ baz $ x = 1 $</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, math: true) == {:ok, ast, messages}
    end

    test "accepts inner newline" do
      markdown = "foo $x\ny$"
      html     = "<p>foo <code class=\"math-inline\">x\ny</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, math: true) == {:ok, ast, messages}
    end

    test "ignored when the first dollar is escaped" do
      markdown = "foo \\$x = 1$"
      html     = "<p>foo $x = 1$</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, math: true) == {:ok, ast, messages}
    end

    test "keeps escaped inner dollar" do
      markdown = "foo $x \\$ y$"
      html     = "<p>foo <code class=\"math-inline\">x \\$ y</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, math: true) == {:ok, ast, messages}
    end

    test "keeps backslash" do
      markdown = "foo $\\frac{1}{2}$"
      html     = "<p>foo <code class=\"math-inline\">\\frac{1}{2}</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, math: true) == {:ok, ast, messages}
    end

    test "ignores inner markdown syntax" do
      markdown = "foo $x *y* x$"
      html     = "<p>foo <code class=\"math-inline\">x *y* x</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, math: true) == {:ok, ast, messages}
    end

    test "ignores empty content" do
      markdown = "foo $$"
      html     = "<p>foo $$</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, math: true) == {:ok, ast, messages}
    end

    test "inside list" do
      markdown = "* $x = 1$"
      html     = "<ul><li><code class=\"math-inline\">x = 1</code></li></ul>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, math: true) == {:ok, ast, messages}
    end
  end

  describe "math display" do
    test "base case" do
      markdown = "foo $$x = 1$$"
      html     = "<p>foo <code class=\"math-display\">x = 1</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, math: true) == {:ok, ast, messages}
    end

    test "with surrounding characters" do
      markdown = "foo$$x = 1$$bar"
      html     = "<p>foo<code class=\"math-display\">x = 1</code>bar</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, math: true) == {:ok, ast, messages}
    end

    test "accepts spaces on delimiter boundaries" do
      markdown = "foo $$ x = 1 $$"
      html     = "<p>foo <code class=\"math-display\">x = 1</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, math: true) == {:ok, ast, messages}
    end

    test "accepts inner newlines" do
      markdown = "foo $$\nx\ny\n$$"
      html     = "<p>foo <code class=\"math-display\">x\ny</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, math: true) == {:ok, ast, messages}
    end

    test "ignored when the first dollars are escaped" do
      markdown = "foo \\$\\$x = 1$$"
      html     = "<p>foo $$x = 1$$</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, math: true) == {:ok, ast, messages}
    end

    test "keeps escaped inner dollar" do
      markdown = "foo $$x \\$ y$$"
      html     = "<p>foo <code class=\"math-display\">x \\$ y</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, math: true) == {:ok, ast, messages}
    end

    test "keeps backslash" do
      markdown = "foo $$\\frac{1}{2}$$"
      html     = "<p>foo <code class=\"math-display\">\\frac{1}{2}</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, math: true) == {:ok, ast, messages}
    end

    test "ignores inner markdown syntax" do
      markdown = "foo $$x *y* x$$"
      html     = "<p>foo <code class=\"math-display\">x *y* x</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, math: true) == {:ok, ast, messages}
    end

    test "ignores empty content" do
      markdown = "foo $$$$"
      html     = "<p>foo $$$$</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, math: true) == {:ok, ast, messages}
    end

    test "inside list" do
      markdown = "* $$x = 1$$"
      html     = "<ul><li><code class=\"math-display\">x = 1</code></li></ul>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, math: true) == {:ok, ast, messages}
    end

    test "standalone paragraph" do
      markdown = "$$\nx = 1\n$$"
      html     = "<p><code class=\"math-display\">x = 1</code></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, math: true) == {:ok, ast, messages}
    end

    test "ignored when there is an empty line (separate paragraphs)" do
      markdown = "$$x\n\ny$$"
      html     = "<p>$$x</p><p>y$$</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown, math: true) == {:ok, ast, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
