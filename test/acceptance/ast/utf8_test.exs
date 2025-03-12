defmodule Acceptance.Ast.Utf8Test do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1]
  import EarmarkAstDsl

  describe "valid rendering" do
    test "pure link" do
      markdown = " foo (http://test.com)… bar"
      ast = p([" foo (", a(["http://test.com)…"], href: "http://test.com)%E2%80%A6"), " bar"])
      messages = []
      assert as_ast(markdown) == {:ok, [ast], messages}
    end
  end
end

#  SPDX-License-Identifier: Apache-2.0
