defmodule Test.Acceptance.Ast.Lists.ComplexListTest do
  use Support.AcceptanceTestCase
  import Support.AstHelpers, only: [ast_from_md: 1, ast_with_errors: 1]


  describe "Nested Lists" do

    test "two levels" do
      markdown = """
      * Outer
        - Inner 1

        - Inner 2
      """

      inner = ul([li(p("Inner 1")), li(p("Inner 2"))])
      expected = [
        ul(
          li([
            p("Outer"), 
            inner]))]

      assert ast_from_md(markdown) == expected
    end

    test "three levels and block elements" do
      markdown = """
      * Hello
        - 1.1

        - # 1.2

            - i
            - ii
              ```
                42
              43
              ```
      * World
      """
      level3 = ul([li("i"), li(["ii", pre_code("  42\n43")])])
      level2 = ul([li(p("1.1")), li([tag("h1", "1.2"), level3])])
      expected = [
        ul([
          li([p("Hello"), level2]),
          li(p("World"))
        ])
      ]
      assert ast_from_md(markdown) == expected
    end
  end

end
#  SPDX-License-Identifier: Apache-2.0
