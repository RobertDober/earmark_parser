defmodule Test.Functional.Scanner.DeprecationTest do
  use ExUnit.Case

  import Support.Helpers, only: [as_ast: 2]

  describe "Deprecations to be removed in 1.5.0" do
    test "pedantic" do
      markdown = ""
      ast = []

      messages = [
        {:deprecated, 0, "The pedantic option has no effect anymore and will be removed in EarmarkParser 1.5"}
      ]

      assert as_ast(markdown, pedantic: true) == {:ok, ast, messages}
    end

    test "smartypants" do
      markdown = ""
      ast = []

      messages = [
        {:deprecated, 0, "The smartypants option has no effect anymore and will be removed in EarmarkParser 1.5"}
      ]

      assert as_ast(markdown, smartypants: true) == {:ok, ast, messages}
    end

    test "timeout" do
      markdown = ""
      ast = []
      messages = [{:deprecated, 0, "The timeout option has no effect anymore and will be removed in EarmarkParser 1.5"}]

      assert as_ast(markdown, timeout: 42) == {:ok, ast, messages}
    end
  end
end

#  SPDX-License-Identifier: Apache-2.0
