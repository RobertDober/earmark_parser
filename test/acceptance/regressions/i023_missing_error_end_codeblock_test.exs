defmodule Test.Acceptance.Regressions.I023MissingErrorEndCodeblockTest do
  use Support.AcceptanceTestCase

  describe "bad end" do
    test "error message" do
      markdown = """
      ```
        content
      ````
      """
      ast = [pre_code("  content\n````")]
      expected = {:error, ast, [{:error, 1, "Fenced Code Block opened with ``` not closed at end of input"}]}

      assert as_ast(markdown) == expected
    end
    test "no error message" do
      markdown = """
      ```
        content
      ```
      """
      ast = [pre_code("  content")]
      expected = {:ok, ast, []}

      assert as_ast(markdown) == expected
    end
  end
end
#  SPDX-License-Identifier: Apache-2.0
