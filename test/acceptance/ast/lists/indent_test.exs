defmodule Test.Acceptance.Ast.Lists.IndentTest do
  use Support.AcceptanceTestCase

  describe "Code Blocks near List Items (#9) https://github.com/RobertDober/earmark_parser/issues/9" do
    test "simple imbrication, unspaced" do
      markdown = """
      * One

        Text1
          * Inner

        Text2
      """

      expected = [
        ul(li([p("One"), p("Text1"), ul("Inner"), p("Text2")]))
      ]

      assert ast_from_md(markdown) == expected
    end

    test "simple imbrication, spaced" do
      markdown = """
      * One

        Text1

          * Inner

        Text2
      """

      expected = [
        ul(li([p("One"), p("Text1"), ul("Inner"), p("Text2")]))
      ]

      assert ast_from_md(markdown) == expected
    end

    test "use case" do
      markdown = """
      * Header

        Text1

          * Inner

        Text2

        https://mydomain.org/user_or_team/repo_name/blob/master/%{path}#L%{line}
      """

      expected = [
        ul(
          li([
            p("Header"),
            p("Text1"),
            ul(
              li([
                "Inner"
              ])
            ),
            p("Text2"),
            p(
              a("https://mydomain.org/user_or_team/repo_name/blob/master/%{path}#L%{line}",
                href: "https://mydomain.org/user_or_team/repo_name/blob/master/%25%7Bpath%7D#L%25%7Bline%7D"
              )
            )
          ])
        )
      ]

      # IO.inspect as_ast(markdown)
      assert ast_from_md(markdown) == expected
    end

    test "simple example" do
      markdown = """
      * Outer

        Outer Content

        * Inner

        Still Outer
      """

      expected = [
        ul(li([p("Outer"), p("Outer Content"), ul("Inner"), p("Still Outer")]))
      ]

      assert ast_from_md(markdown) == expected
    end

    test "min problem with spaced sublist" do
      markdown = """
      * Outer

        * Inner

        Outer Para
      """

      expected = [
        ul(li([p("Outer"), ul("Inner"), p("Outer Para")]))
      ]

      assert ast_from_md(markdown) == expected
    end

    test "min problem with unspaced sublist" do
      markdown = """
      * Outer
        * Inner

        Outer Para
      """

      expected = [
        ul(li([p("Outer"), ul("Inner"), p("Outer Para")]))
      ]

      assert ast_from_md(markdown) == expected
    end

    test "mixed level correct pop up" do
      markdown = """
      - 1
        - 1.1
            - 1.1.1
        - 1.2
      """

      ast = [
        ul(li(["1", ul([li(["1.1", ul(li("1.1.1"))]), li("1.2")])]))
      ]

      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "loose example" do
      markdown = """
      - One

      - Two
      """

      expected = [
        ul([li(p("One")), li(p("Two"))])
      ]

      assert ast_from_md(markdown) == expected
    end

    test "tight example" do
      markdown = """
      - One
      - Two
      """

      expected = [
        ul([li("One"), li("Two")])
      ]

      assert ast_from_md(markdown) == expected
    end

    test "debugging" do
      markdown = """
      * Head

        Content
      """

      expected = [
        ul(li([p("Head"), p("Content")]))
      ]

      assert ast_from_md(markdown) == expected
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
