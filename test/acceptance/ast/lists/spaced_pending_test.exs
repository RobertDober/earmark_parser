defmodule Acceptance.Ast.Lists.SpacedPendingTest do
  use Support.AcceptanceTestCase

  test "when pending occurs in spaced part" do
    markdown = """
    * Item 1

      This is `
      pending`
    """
    ast = [
      ul(li([
        p("Item 1"),
        p(["This is ", inline_code("pending")])]))
    ]

    assert ast_from_md(markdown) == ast
  end

  test "when pending occurs in indented" do
    markdown = """
    * Item 1

      This is `
      pending`
    """
    ast = [
      ul(li([
        p("Item 1"),
        p(["This is ", inline_code("pending")])]))
    ]

    assert ast_from_md(markdown) == ast
  end

  describe "looseness" do
    test "loose as should" do
      markdown = """
      - Item 1

        Line 1
      """
      ast = [
        ul(li([p("Item 1"), p("Line 1")]))
      ]

      assert ast_from_md(markdown) == ast
    end

    test "fixed now \o/" do
      markdown = """
      - Item 1

        `Line 
        1`
      """
      ast = [
        ul(li([p("Item 1"), p(inline_code("Line 1"))]))
      ]

      assert ast_from_md(markdown) == ast
    end
  end
end
# SPDX-License-Identifier: Apache-2.0
