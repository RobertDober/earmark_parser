defmodule Acceptance.Ast.Lists.SpacedPendingTest do
  use ExUnit.Case
  use Support.AcceptanceTestCase
  import Support.Helpers, only: [as_ast: 1]

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

    assert as_ast(markdown) == {:ok, ast, []}
  end

end
# SPDX-License-Identifier: Apache-2.0
