defmodule Acceptance.Ast.Lists.ListAndencedCodeTest do
  use Support.AcceptanceTestCase

  describe "many fences" do
    test "two levels" do
      markdown = """
      ```elixir
        before
      ```
      - Header 1
        ```erlang
           inner
        ```

        - Inner List

          ```
            innerer
          ```
      """
      level2_list =
        ul(li([p("Inner List"), pre_code("  innerer")]))
      ast = [
        code("  before", class: "elixir"),
        ul(li([p("Header 1"),
          code("   inner", class: "erlang"),
          level2_list]))]

      assert ast_from_md(markdown) == ast
    end
  end

  # TODO: Fix this in EarmarkAstDsl
  defp code(content, class: class) do
    tag("pre", [tag("code", content, class: class)])
  end
end
# SPDX-License-Identifier: Apache-2.0
