defmodule Acceptance.Ast.Lists.MoreIndentTest do
  use Support.AcceptanceTestCase

  import Support.AstHelpers, only: [ast_from_md: 1]

  describe "different levels of indent" do

    test "ordered two levels, indented by two" do
      markdown = "1. One\n  2. two"
      ast = [ol(["One", "two"])]

      assert ast_from_md(markdown) == ast
    end

    test "mixed two levels (by 2)" do
      markdown = """
      1. One
        - two
        - three
      """
      ast = [ol("One"), ul(["two", "three"])]

      assert ast_from_md(markdown) == ast
    end

    test "mixed two levels (by 4)" do
      markdown = """
      1. One
          - two
          - three
      """
      ast = [ol(li(["One", ul(["two", "three"])]))]

      assert ast_from_md(markdown) == ast
    end

    test "tightness" do
      markdown = """
      - 1
        - 2
      """
      ast = [ul(li(["1", ul("2")]))]

      assert ast_from_md(markdown) == ast
    end

    test "2 level correct pop up" do
      markdown = """
      -1
        - 1.1
          - 1.1.1
        - 1.2
      """
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
end

# SPDX-License-Identifier: Apache-2.0
