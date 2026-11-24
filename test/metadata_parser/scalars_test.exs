defmodule Test.MetadataParser.ElementaryTest do
  use Support.MetadataTestCase

  describe "Parsing Numbers" do
    test "an unsigned integer" do
      assert_parse([" 42"], 42)
    end

    test "a positive integer (proton case)" do
      assert_parse("+19", 19)
    end

    test "a negative_after integer (electron case)" do
      assert_parse("-2", -2)
    end

    test "an unsigned float" do
      assert_parse(["  ", " 3.1"], 3.1)
    end

    test "a negative float (down quark case)" do
      assert_parse("-1.5", -1.5)
    end

    test "a positive float (charm quarck case)" do
      assert_parse(" +0.666", 0.666)
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
