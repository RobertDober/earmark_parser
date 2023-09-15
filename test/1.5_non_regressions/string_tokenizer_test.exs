defmodule NonRegressions.StringTokenizerTest do
  use ExUnit.Case

  describe "old behavior" do
    test "empty" do
      assert old_tokenize("") == []
    end
    test "no backtix, no escape" do
      assert old_tokenize("hello world") == [other: "hello world"]
    end
  end

  def old_tokenize(string) do
    EarmarkParser.Helpers.LeexHelpers.tokenize(string, with: :string_lexer)
  end

  
end
# SPDX-License-Identifier: Apache-2.0
