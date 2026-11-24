defmodule Test.MetadataParser.ElementaryTest do
  use ExUnit.Case

  import EarmarkParser.Parser.MetadataParser, only: [parse: 1]

  describe "Parsing Numbers" do
    test "an unsigned integer" do
      assert parse([" 42"]) == {:ok, 42}
    end

    test "a positive integer (proton case)" do
      assert parse("+19") == {:ok, 19}
    end

    test "a negative integer (electron case)" do
      assert parse("-2") == {:ok, -2}
    end

    t
  end
  
end
# SPDX-License-Identifier: Apache-2.0
