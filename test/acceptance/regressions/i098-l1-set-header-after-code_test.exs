defmodule Test.Acceptance.Regressions.I098L1SetHeaderAfterCodeTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_ast: 1]
  import EarmarkAstDsl

  @ok_case """
        some code

  a para

  Header
  ====
  """
  test "should render correctly" do
    ast = [pre_code("  some code"), p("a para"), tag("h1", "Header")]
    messages = []

    assert as_ast(@ok_case) == {:ok, ast, messages}
  end

  @h1_case """
        some code
  Header
  ===
  """
  test "h1 should render correctly" do
    ast = [pre_code("  some code"), tag("h1", "Header")]
    messages = []

    assert as_ast(@h1_case) == {:ok, ast, messages}
  end

  @h2_case """
        some code
  Header
  ---
  """
  test "h2 should render correctly" do
    ast = [pre_code("  some code"), tag("h2", "Header")]
    messages = []

    assert as_ast(@h2_case) == {:ok, ast, messages}
  end

end
# SPDX-License-Identifier: Apache-2.0
