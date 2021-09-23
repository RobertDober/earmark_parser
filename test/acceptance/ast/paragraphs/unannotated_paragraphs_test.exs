defmodule Acceptance.Ast.Paragraphs.UnannotatedParagraphsTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, as_ast: 2, parse_html: 1]
  import EarmarkAstDsl

  describe "Paragraphs" do
    test "a para" do
      markdown = "aaa\n\nbbb\n"
      html     = "<p>aaa</p>\n<p>bbb</p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "and another one" do
      markdown = "aaa\n\n\nbbb\n"
      html     = "<p>aaa</p>\n<p>bbb</p>\n"
      ast      = parse_html(html)
      messages = []

      assert EarmarkParser.as_ast(markdown) == {:ok, ast, messages}
    end

    test "strong" do
      markdown = "**inside**"
      html     = "<p><strong>inside</strong></p>"
      ast      = parse_html(html)
      messages = []

      assert EarmarkParser.as_ast(markdown) == {:ok, ast, messages}
    end

    test "striketrhough" do
      markdown = "~~or maybe not?~~"
      html     = "<p><del>or maybe not?</del></p>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "keeps paragraph source as AST content when :parse_inline is false" do
      markdown = "this *should* stay [unchanged]()"
      ast      = [p([markdown])]
      messages = []

      assert as_ast(markdown, parse_inline: false) == {:ok, ast, messages}
    end
  end

  describe "WS Separation (issue #10)" do
    test "simplest case" do
      markdown = "_primo_ _secondo_"
      ast      = [ p([tag("em", "primo"), " ", tag("em", "secondo")])]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "what about two links" do
      markdown = "[link one](aaa) [link two](bbb)"
      ast      = [ p([tag("a", "link one", href: "aaa"), " ", tag("a", "link two", href: "bbb")])]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "before a link" do
      markdown = "hi [link](http://example.com)"
      ast      = [p(["hi ", tag("a", "link", href: "http://example.com")])]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "still before a link" do
      markdown = "**hi** [link](http://example.com)"
      ast      = [p([tag("strong", "hi"), " ", tag("a", "link", href: "http://example.com")])]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "after an image" do
      markdown = "![look](http://an_image) hello"
      messages = []
      ast      = [p([void_tag("img", src: "http://an_image", alt: "look"), " hello"])]

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "still after an image" do
      markdown = "![look](http://an_image) _hello_"
      messages = []
      ast      = [p([void_tag("img", src: "http://an_image", alt: "look"), " ", tag("em", "hello")])]

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "still after a link" do
      markdown = "[look](http://a_link) _hello_"
      messages = []
      ast      = [p([tag("a", "look", href: "http://a_link"), " ", tag("em", "hello")])]

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "there must not be one" do
      markdown = "[look](http://a_link)_hello_"
      messages = []
      ast      = [p([tag("a", "look", href: "http://a_link"), tag("em", "hello")])]

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
