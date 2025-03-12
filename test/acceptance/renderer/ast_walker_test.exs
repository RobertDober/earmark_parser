defmodule Acceptance.Renderer.AstWalkerTest do
  use Support.AcceptanceTestCase
  import EarmarkParser.Ast.Renderer.AstWalker

  describe "replace with empty" do
    test "prunes some nodes" do
      ast = tags("p", ["alpha", "empty"])
      expected = tags("p", ["alpha", []])

      assert walk_ast(ast, &replace_empty/1) == expected
    end

    test "can descend" do
      ast = [tags("p", ["alpha", "empty"])]
      expected = [tags("p", ["alpha", []])]

      assert walk_ast(ast, &replace_empty/1) == expected
    end
  end

  def replace_empty("empty") do
    []
  end

  def replace_empty(str) do
    str
  end
end

# SPDX-License-Identifier: Apache-2.0
