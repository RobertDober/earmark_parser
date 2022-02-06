defmodule Acceptance.Regressions.I064NoFunctionClauseMapSetUnionTest do
  use ExUnit.Case

  import EarmarkParser, only: [as_ast: 2]

  describe "can merge_messages" do
    test "prevent MapSet.union/2 error passing no MapSet.t()" do
      markdown = """
      ```
        content
      ```
      """

      options = %{messages: []}

      ast = [{"pre", [], [{"code", [], ["  content"], %{}}], %{}}]

      assert as_ast(markdown, options) == {:ok, ast, []}
    end
  end
end
