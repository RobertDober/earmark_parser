defmodule Acceptance.Ast.Footnotes.SingleFootnoteTest do
  use Support.AcceptanceTestCase
  import Support.FootnoteHelpers

  describe "Correct Footnotes" do
    test "single word" do
      markdown = """
      foo[^1] again

      [^1]: bar
      """

      ast = [
        p([
          "foo",
          footnote(1),
          " again"
        ]),
        footnotes([
          footnote_def(1, p("bar"))
        ])
      ]

      {:ok, result_ast, []} = as_ast(markdown, footnotes: true)
      assert_asts_are_equal(result_ast, ast)
    end

    test "plain text" do
      markdown = "foo[^1] again\n\n[^1]: bar baz"

      expected_ast = [
        p([
          "foo",
          footnote(1),
          " again"
        ]),
        footnotes([
          footnote_def(1, p("bar baz"))
        ])
      ]

      {:ok, result_ast, []} = as_ast(markdown, footnotes: true)
      assert_asts_are_equal(result_ast, expected_ast)
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


      {:ok, result_ast, []} = as_ast(markdown, footnotes: true)
      assert_asts_are_equal(result_ast, ast)
    end

    test "plain text, but no footnotes" do
      markdown = "foo[^1] again\n\n[^1]: bar baz\ngoo"

      ast = [
        p("foo[^1] again"),
        p("[^1]: bar baz\ngoo")
      ]


      {:ok, result_ast, []} = as_ast(markdown, footnotes: true)
      assert_asts_are_equal(result_ast, ast)
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

      {:ok, result_ast, []} = as_ast(markdown, footnotes: true, pure_links: true)
      assert_asts_are_equal(result_ast, ast)
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

      {:ok, result_ast, []} = as_ast(markdown, footnotes: true, pure_links: true)
      assert_asts_are_equal(result_ast, ast)
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

      {:ok, result_ast, []} = as_ast(markdown, footnotes: true, pure_links: true)
      assert_asts_are_equal(result_ast, ast)
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
