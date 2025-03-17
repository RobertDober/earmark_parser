defmodule Test.Acceptance.Regressions.I154pArserCrashSymbolicInputTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_ast: 1]
  import EarmarkAstDsl

  test "this should not crash" do
    ast = [p("[{:}")]
    messages = []
    assert as_ast("\\[{:}") == {:ok, ast, messages}
  end

  test "this does not crash" do
    ast = [p("[{:")]
    messages = []
    assert as_ast("\\[{:") == {:ok, ast, messages}
  end

  test "nor does this" do
    ast = [p("[{:}")]
    messages = []
    assert as_ast("[{:}") == {:ok, ast, messages}
  end

  test "nor this" do
    ast = [{"p", [], [{"em", [], ["a"], %{}}], %{}}]
    messages = []
    assert as_ast("*a*{:}") == {:ok, ast, messages}
  end
end

# SPDX-License-Identifier: Apache-2.0
