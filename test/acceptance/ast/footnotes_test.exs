defmodule Acceptance.Ast.FootnotesTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 2]
  import Support.FootnoteHelpers
  import EarmarkAstDsl

  describe "Correct Footnotes" do
    test "plain text" do
      markdown = "foo[^1] again\n\n[^1]: bar baz"

      ast = [
        p([
          "foo",
          footnote(1),
          " again"
        ]),
        footnotes([
          tag(
            "ol",
            [
              tag(
                "li",
                [
                  reverse_footnote(1),
                  p("bar baz")
                ],
                id: "fn:1"
              )
            ]
          )
        ])
      ]

      messages = []

      assert as_ast(markdown, footnotes: true) == {:ok, ast, messages}
    end

    test "plain text, but no footnotes" do
      markdown = "foo[^1] again\n\n[^1]: bar baz\ngoo"

      ast = [
        p("foo[^1] again"),
        p("[^1]: bar baz\ngoo")
      ]

      messages = []

      assert as_ast(markdown, footnotes: false) == {:ok, ast, messages}
    end

    test "A link inside the footnote" do
      markdown = """
      here is my footnote[^1]

      [^1]: which [is a link](http://to.some.site)
      """

      ast = [
        p([
          "here is my footnote",
          footnote(1)
        ]),
        footnotes([
          tag(
            "ol",
            tag(
              "li",
              [
                reverse_footnote(1),
                p([
                  "which ",
                  a("is a link", href: "http://to.some.site")
                ])
              ],
              id: "fn:1"
            )
          )
        ])
      ]

      messages = []

      # as_ast(markdown, footnotes: true, pure_links: true)
      assert as_ast(markdown, footnotes: true, pure_links: true) == {:ok, ast, messages}
    end

    test "A block inside the footnote" do
      markdown = """
      here is my footnote[^1]

      [^1]: which describes some
      code
      """

      ast = [
        p([
          "here is my footnote",
          footnote(1)
        ]),
        footnotes([
          tag("ol", [
            tag(
              "li",
              [
                reverse_footnote(1),
                p("which describes some\ncode")
              ],
              id: "fn:1"
            )
          ])
        ])
      ]

      messages = []

      # as_ast(markdown, footnotes: true, pure_links: true)
      assert as_ast(markdown, footnotes: true, pure_links: true) == {:ok, ast, messages}
    end
  end

  describe "Incorrect Footnotes" do
    test "undefined footnotes" do
      markdown = "foo[^1]\nhello\n\n[^2]: bar baz"
      ast = [p("foo[^1]\nhello")]
      messages = [{:error, 1, "footnote 1 undefined, reference to it ignored"}]

      assert as_ast(markdown, footnotes: true) == {:error, ast, messages}
    end

    test "undefined footnotes (none at all)" do
      markdown = "foo[^1]\nhello"
      ast = p("foo[^1]\nhello")
      messages = [{:error, 1, "footnote 1 undefined, reference to it ignored"}]

      assert as_ast(markdown, footnotes: true) == {:error, [ast], messages}
    end

    test "illdefined footnotes" do
      markdown = "foo[^1]\nhello\n\n[^1]:bar baz"
      ast = [p("foo[^1]\nhello"), p("[^1]:bar baz")]

      messages = [
        {:error, 1, "footnote 1 undefined, reference to it ignored"},
        {:error, 4, "footnote 1 undefined, reference to it ignored"}
      ]

      assert as_ast(markdown, footnotes: true) == {:error, ast, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
