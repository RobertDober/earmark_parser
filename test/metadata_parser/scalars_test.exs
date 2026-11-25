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

  describe "strings" do
    test "an empty string" do
      assert_parse(~S{""}, "")
    end

    test "a standard string" do
      assert_parse(~S{"alpha and beta"}, "alpha and beta")
    end

    test "multiple lines (N.B. Metadata is considered to be one long line, \\n -> \" \")" do
      assert_parse([~S{"a}, "and", ~S{b"}], "a and b")
    end

    test "escaped quote" do
      assert_parse(~S{" a \"& b"  }, ~S{ a "& b})
    end

    test "must be closed" do
      refute_parse(~S{ " })
    end
  end

  describe "atoms" do
    test "just alpha" do
      assert_parse(":a", :a)
    end

    test "can be longer" do
      assert_parse(":abc", :abc)
    end

    test "can contain digits and underscores" do
      assert_parse(":x_42_", :x_42_)
    end

    test "can start with an underscore" do
      assert_parse(":_hello_1", :_hello_1)
    end

    test "must not start with a digit" do
      refute_parse(":2_x", "no option parsed")
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
