defmodule Acceptance.Ast.Lists.ListIndentTest do
  use ExUnit.Case, async: true

  import Support.Helpers, only: [as_ast: 1, parse_html: 1]
  import Support.AstHelpers
  import EarmarkAstDsl

  describe "different levels of indent" do

    test "ordered two levels, indented by two" do
      markdown = "1. One\n  2. two"
      html     = "<ol>\n<li>One</li><li>two</li></ol>"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "mixed two levels (by 2)" do
      markdown = "1. One\n  - two\n  - three"
      html     = "<ol>\n<li>One</li></ol><ul>\n<li>two</li>\n<li>three</li>\n</ul>"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "mixed two levels (by 4)" do
      markdown = "1. One\n    - two\n    - three"
      html     = "<ol>\n<li>One<ul>\n<li>two</li>\n<li>three</li>\n</ul>\n</li>\n</ol>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "2 level correct pop up" do
      markdown = "- 1\n  - 1.1\n    - 1.1.1\n  - 1.2"
      html     = "<ul> <li>1<ul> <li>1.1<ul> <li>1.1.1</li> </ul> </li> <li>1.2</li> </ul> </li> </ul>"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "mixed level correct pop up" do
      markdown = "- 1\n  - 1.1\n      - 1.1.1\n  - 1.2"
      html     = "<ul> <li>1<ul> <li>1.1<ul> <li>1.1.1</li> </ul> </li> <li>1.2</li> </ul> </li> </ul>"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "4 level correct pop up" do
      markdown = "- 1\n    - 1.1\n        - 1.1.1\n    - 1.2"
      html     = "<ul>\n<li>1<ul>\n<li>1.1<ul>\n<li>1.1.1</li>\n</ul>\n</li>\n<li>1.2</li>\n</ul>\n</li>\n</ul>\n"
      ast      = parse_html(html)
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "indent into code blocks" do
    test "1st regression reported in #9" do
      markdown = """
      * List item1

        Text1

          * List item2

        Text2

            https://mydomain.org/user_or_team/repo_name/blob/master/%{path}#L%{line}

      """
      ast = [
        ul([li([p("List item1"), p("Text1"), ul(li(["List item2\nText2"])), pre_code("https://mydomain.org/user_or_team/repo_name/blob/master/%{path}#L%{line}")])])
      # ast = [
      # {"ul", [], [{"li", [], [{"p", [], ["List item1"], %{}}, {"p", [], ["Text1"], %{}}, {"ul", [], [{"li", [], ["List item2\nText\n", {"a", [{"href", "https://mydomain.org/user_or_team/repo_name/blob/master/%{path}#L%{line}"}], ["https://mydomain.org/user_or_team/repo_name/blob/master/%{path}#L%{line}"], %{}}], %{}}], %{}}], %{}}], %{}}
      ]

      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
