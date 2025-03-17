defmodule Acceptance.ErrorHandling.BadArgumentsTest do
  use ExUnit.Case, async: true

  import EarmarkParser, only: [as_ast: 1, as_ast: 2]

  describe "monary as_ast" do
    test "raise Argument error for keyword input" do
      assert_raise(ArgumentError, "line number 1 {:hello, \"world\"} is not a binary", fn -> as_ast(hello: "world") end)
    end

    test "raise ArgumentError for a map" do
      assert_raise(ArgumentError, "%{a: 1} not a binary, nor a list of binaries", fn -> as_ast(%{a: 1}) end)
    end
  end

  describe "binary as_ast" do
    test "raise ArgumentError for keyword input" do
      assert_raise(ArgumentError, "line number 1 {:hello, 42} is not a binary", fn -> as_ast([hello: 42], []) end)
    end

    test "raise ArgumentError for numbers" do
      assert_raise(ArgumentError, "42 not a binary, nor a list of binaries", fn -> as_ast(42, %{}) end)
    end
  end

  describe "bad second argument" do
    test "raise ArgumentError for an integer" do
      assert_raise(ArgumentError, "42 not a legal options map or keyword list", fn -> as_ast([], 42) end)
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
