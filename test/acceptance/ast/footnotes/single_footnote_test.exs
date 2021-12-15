defmodule Acceptance.Ast.Footnotes.SingleFootnoteTest do
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
          footnote_def(1, p("bar baz"))
        ])
      ]

      messages = []

      assert as_ast(markdown, footnotes: true) == {:ok, ast, messages}
    end

    test "not numeric" do
      markdown = "alpha[^first]\n\n[^first]: First letter of greek alphabet\n[^second]: not used"

      ast = [
        p([
          "alpha",
          footnote("first")
        ]),
        footnotes([
          footnote_def("first", p("First letter of greek alphabet"))
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
        footnotes(
          footnote_def(
            1,
            p([
              "which ",
              a("is a link", href: "http://to.some.site")
            ])
          )
        )
      ]

      messages = []

      # as_ast(markdown, footnotes: true, pure_links: true)
      assert as_ast(markdown, footnotes: true, pure_links: true) == {:ok, ast, messages}
    end

    test "A two line footnote" do
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
        footnotes(footnote_def(1, p("which describes some\ncode")))
      ]

      messages = []

      assert as_ast(markdown, footnotes: true, pure_links: true) == {:ok, ast, messages}
    end

    test "A block inside the footnote" do
      markdown = """
      here is my footnote[^1]

      [^1]: which describes some
      ```
        code
      ```
      """

      ast = [
        p([
          "here is my footnote",
          footnote(1)
        ]),
        footnotes(
          footnote_def(1, [
            p("which describes some"),
            pre_code("  code")
          ])
        )
      ]

      messages = []

      assert as_ast(markdown, footnotes: true, pure_links: true) == {:ok, ast, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
