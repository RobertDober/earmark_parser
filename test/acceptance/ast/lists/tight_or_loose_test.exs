defmodule Acceptance.Ast.Lists.TightOrLooseTest do
  use Support.AcceptanceTestCase

  import Support.AstHelpers, only: [ast_from_md: 1]

  describe "tight" do
    test "unique list - unique item" do
      markdown = """
      1. Hello
      """
      ast = [
        ol("Hello")
      ]

      assert ast_from_md(markdown) == ast
    end
    test "unique list - two items" do
      markdown = """
      1. Hello
      2. World
      """
      ast = [
        ol(["Hello", "World"])
      ]

      assert ast_from_md(markdown) == ast
    end
  end
end
#  SPDX-License-Identifier: Apache-2.0
