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
        p(["This is ", inline_code("pending", [], %{line: 3})])]))
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
        p(["This is ", inline_code("pending", [], %{line: 3})])]))
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
        ul(li([p("Item 1"), p(inline_code("Line 1", [], %{line: 3}))]))
      ]

      assert ast_from_md(markdown) == ast
    end
  end

  test "Ruler after Body" do
    markdown = """
    1. Alpha

       Beta
    -------
    """
    ast = [
      ol(li(tags("p", ["Alpha", "Beta"]))),
      void_tag("hr", class: "thin")
    ]

    assert ast_from_md(markdown) == ast
  end

  test "Different List Type after Body" do
    markdown = """
    1. Alpha

       Beta
    - Gamma
    """
    ast = [
      ol(li(tags("p", ["Alpha", "Beta"]))),
      ul(li("Gamma"))
    ]

    assert ast_from_md(markdown) == ast
  end

  # remove after upgrading earmark_ast_dsl
  defp inline_code(content, attrs, new_meta) do
    {tag, attrs, content, meta} = inline_code(content, attrs)
    {tag, attrs, content, Map.merge(meta, new_meta)}
  end
end
# SPDX-License-Identifier: Apache-2.0
