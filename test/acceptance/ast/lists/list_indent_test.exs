defmodule Acceptance.Ast.Lists.ListIndentTest do
  use ExUnit.Case, async: true

  import Support.Helpers, only: [as_ast: 1, parse_html: 1]
  import Support.AstHelpers
  import EarmarkAstDsl

  describe "different levels of indent" do
    test "ordered two levels, indented by two" do
      markdown = "1. One\n  2. two"
      html = "<ol>\n<li>One</li><li>two</li></ol>"
      ast = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "mixed two levels (by 2)" do
      markdown = "1. One\n  - two\n  - three"
      html = "<ol>\n<li>One</li></ol><ul>\n<li>two</li>\n<li>three</li>\n</ul>"
      ast = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "mixed two levels (by 4)" do
      markdown = "1. One\n    - two\n    - three"
      html = "<ol>\n<li>One<ul>\n<li>two</li>\n<li>three</li>\n</ul>\n</li>\n</ol>\n"
      ast = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "2 level correct pop up" do
      markdown = "- 1\n  - 1.1\n    - 1.1.1\n  - 1.2"

      html =
        "<ul> <li>1<ul> <li>1.1<ul> <li>1.1.1</li> </ul> </li> <li>1.2</li> </ul> </li> </ul>"

      ast = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "mixed level correct pop up" do
      markdown = "- 1\n  - 1.1\n      - 1.1.1\n  - 1.2"

      html =
        "<ul> <li>1<ul> <li>1.1<ul> <li>1.1.1</li> </ul> </li> <li>1.2</li> </ul> </li> </ul>"

      ast = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "4 level correct pop up" do
      markdown = "- 1\n    - 1.1\n        - 1.1.1\n    - 1.2"

      html =
        "<ul>\n<li>1<ul>\n<li>1.1<ul>\n<li>1.1.1</li>\n</ul>\n</li>\n<li>1.2</li>\n</ul>\n</li>\n</ul>\n"

      ast = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "indent into code blocks" do
    test "1st regression reported in #9" do
      markdown = """
      * Item 1

        Text 1

          * Item 2

        Text 2

           https://mydomain.org/user_or_team/repo_name/blob/master/%{path}#L%{line}
      """

      ast = [
        {"ul", [],
         [
           {"li", [],
            [
              {"p", [], ["Item 1"], %{}},
              {"p", [], ["Text 1"], %{}},
              {"ul", [], [{"li", [], ["Item 2"], %{}}], %{}},
              {"p", [], ["Text 2"], %{}},
              {"p", [],
               ["https://mydomain.org/user_or_team/repo_name/blob/master/%{path}#L%{line}"], %{}}
            ], %{}}
         ], %{}}
      ]

      messages = []

      as_ast(markdown)
      # assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "non regression, level 1" do
      markdown = """
      * item 1
        * item 2

        text 1
      """

      ast = [
        {"ul", [],
         [
           {"li", [],
            [
              {"p", [], ["item 1"], %{}},
              {"ul", [], [{"li", [], ["item 2"], %{}}], %{}},
              {"p", [], ["text 1"], %{}}
            ], %{}}
         ], %{}}
      ]

      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "non regression, level 2" do
      markdown = """
      * item 1
        * item 2
          * item 3
               
          text 2
      """

      ast = [
        {"ul", [],
         [
           {"li", [],
            [
              {"p", [], ["item 1"], %{}},
              {"ul", [],
               [
                 {"li", [],
                  [
                    {"p", [], ["item 2"], %{}},
                    {"ul", [], [{"li", [], ["item 3"], %{}}], %{}},
                    {"p", [], ["text 2"], %{}}
                  ], %{}}
               ], %{}}
            ], %{}}
         ], %{}}
      ]

      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
