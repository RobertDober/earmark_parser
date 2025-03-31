defmodule Test.MicroMark.ParserTest do
  use Support.MicroMarkCase

  describe "empty input" do
    test "parse empty" do
      assert parse_ok("") == []
    end
  end

  describe "some text" do
    test "parse a char" do
      assert parse_ok("a") == ["a"]
    end

    test "pase more chars" do
      assert parse_ok("abc") == ["abc"]
    end

    test "check position" do
      # state = parse("defg")
      # IO.inspect(state)
      assert_parsed("defg", ["defg"], [], 5) 
    end

    test "ove a line?" do
      assert_parsed("hij\nk", ["hij\nk"], [], 2, 2)
    end
  end
end
# SPDX-License-Identifier: Apache-2.0
