defmodule Acceptance.Ast.LinksImages.PureLinksTest do
  use Support.AcceptanceTestCase
  import Support.Helpers, only: [as_ast: 1, as_ast: 2, parse_html: 1]
  import EarmarkAstDsl

  describe "simple pure links not yet enabled" do
    test "issue deprecation warning suppressed" do
      markdown = "https://github.com/pragdave/earmark"
      html = "<p>https://github.com/pragdave/earmark</p>\n"
      ast = parse_html(html)
      messages = []

      assert as_ast(markdown, pure_links: false) == {:ok, ast, messages}
    end
  end

  describe "enabled pure links" do
    test "two in a row" do
      markdown = "https://github.com/pragdave/earmark https://github.com/RobertDober/extractly"

      html =
        "<p><a href=\"https://github.com/pragdave/earmark\">https://github.com/pragdave/earmark</a>&#x20;<a href=\"https://github.com/RobertDober/extractly\">https://github.com/RobertDober/extractly</a></p>\n"

      ast = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "more text" do
      markdown = "Header http://wikipedia.org in between <http://hex.pm> Trailer"

      html =
        "<p>Header <a href=\"http://wikipedia.org\">http://wikipedia.org</a> in between <a href=\"http://hex.pm\">http://hex.pm</a> Trailer</p>\n"

      ast = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "more links" do
      markdown = "[Erlang](https://erlang.org) & https://elixirforum.com"

      html =
        "<p><a href=\"https://erlang.org\">Erlang</a> &amp; <a href=\"https://elixirforum.com\">https://elixirforum.com</a></p>\n"

      ast = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "be aware of the double up" do
      markdown = "[https://erlang.org](https://erlang.org)"
      html = "<p><a href=\"https://erlang.org\">https://erlang.org</a></p>\n"
      ast = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "correct mix" do
      markdown = "[https://erlang.org](https://erlang.org) https://elixir.lang"

      html =
        "<p><a href=\"https://erlang.org\">https://erlang.org</a>&#x20;<a href=\"https://elixir.lang\">https://elixir.lang</a></p>\n"

      ast = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "leading whitespace is preserved" do
      markdown = "**Test**     https://www.google.com"
      # This needs to be `&#x20;` instead of ` ` because Floki strips out blank text nodes
      html =
        "<p><strong>Test</strong>&#x20;&#x20;&#x20;&#x20;&#x20;<a href=\"https://www.google.com\">https://www.google.com</a></p>\n"

      ast = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "parenthesis (was: regression #342)" do
    test "simplest error case" do
      markdown = "http://my.org/robert(is_best)"
      ast = p(tag("a", ["http://my.org/robert(is_best)"], [{"href", "http://my.org/robert(is_best)"}]))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "imbrication" do
      markdown = "(http://my.org/robert(is_best)"
      ast = p(["(", tag("a", ["http://my.org/robert(is_best)"], [{"href", "http://my.org/robert(is_best)"}])])
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "enough imbrication" do
      markdown = "(http://my.org/robert(is_best))"
      ast = p(["(", tag("a", ["http://my.org/robert(is_best)"], [{"href", "http://my.org/robert(is_best)"}]), ")"])
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "most imbricated" do
      markdown = "((http://my.org/robert(c'estça)))"

      ast =
        p(["((", tag("a", ["http://my.org/robert(c'estça)"], [{"href", "http://my.org/robert(c'est%C3%A7a)"}]), "))"])

      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "recoding is cool" do
      markdown = "((http://github.com(c'est%C3%A7a)))"

      ast =
        p(["((", tag("a", ["http://github.com(c'est%C3%A7a)"], [{"href", "http://github.com(c'est%C3%A7a)"}]), "))"])

      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "trailing parens are not part of it, at least not all" do
      markdown = "(https://a.link.com))"
      ast = p(["(", tag("a", "https://a.link.com", href: "https://a.link.com"), "))"])
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "closing parens can match opening parens at the end" do
      markdown = "(http://www.google.com/search?q=business)"

      ast =
        p([
          "(",
          tag("a", "http://www.google.com/search?q=business", href: "http://www.google.com/search?q=business"),
          ")"
        ])

      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "opening parens w/o closing parens do not match" do
      markdown = "(http://www.google.com/search?q=business"

      ast =
        p(["(", tag("a", "http://www.google.com/search?q=business", href: "http://www.google.com/search?q=business")])

      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end

  describe "more acceptable characters (was: regression #350)" do
    test "a Github link" do
      markdown = "https://mydomain.org/user_or_team/repo_name/blob/master/%{path}#L%{line}"
      # Cannot use Floki (c.f. https://github.com/philss/floki/issues/370)
      ast =
        tag(
          "a",
          ["https://mydomain.org/user_or_team/repo_name/blob/master/%{path}#L%{line}"],
          [{"href", "https://mydomain.org/user_or_team/repo_name/blob/master/%25%7Bpath%7D#L%25%7Bline%7D"}]
        )
        |> p()

      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "a recursive link" do
      markdown =
        "https://babelmark.github.io/?text=*+List+item%0A%0A++Text%0A%0A++++*+List+item%0A%0A++Text%0A%0A++++++https%3A%2F%2Fmydomain.org%2Fuser_or_team%2Frepo_name%2Fblob%2Fmaster%2F%25%7Bpath%7D%23L%25%7Bline%7D%0"

      href =
        "https://babelmark.github.io/?text=*+List+item%0A%0A++Text%0A%0A++++*+List+item%0A%0A++Text%0A%0A++++++https%3A%2F%2Fmydomain.org%2Fuser_or_team%2Frepo_name%2Fblob%2Fmaster%2F%25%7Bpath%7D%23L%25%7Bline%7D%250"

      ast = tag("a", markdown, href: href) |> p()
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end

  describe "multiple params (was: regression #044)" do
    test "one query param" do
      markdown = "https://example.com?foo=1"
      ast = p(tag("a", markdown, [{"href", markdown}]))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "two query params" do
      markdown = "https://example.com?foo=1&bar=2"
      ast = p(tag("a", markdown, [{"href", markdown}]))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end

  describe "matching parenthesis" do
    test "match trailing closing parenthesis with the opening parenthesis in the link" do
      markdown = "(http://github.com/(foo)"
      ast = p(["(", tag("a", ["http://github.com/(foo)"], [{"href", "http://github.com/(foo)"}])])
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end

  describe "unicode characters" do
    test "support non alphanumeric unicode characters" do
      markdown = "http://github.com?foo=😀"
      ast = p([tag("a", ["http://github.com?foo=😀"], [{"href", "http://github.com?foo=#{URI.encode("😀")}"}])])
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
