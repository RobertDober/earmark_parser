defmodule Test.Unit.Ear.Parse.ParseParaTest do
  use Support.EarTestCase

  describe "parse text" do
    test "empty input" do
      result = parse("")
      assert result == ok_result([])
    end

    test "a single line" do
      result = parse("hello")
      assert result == ok_result(p("hello"))
    end
    test "two lines" do
      result = parse("hello\nworld")
      assert result == ok_result(p(~W[hello world]))
    end
    test "two paragraphs" do
      result = parse("hello\n\nworld")
      assert result == [tags("p",~W[hello world])]
    end
  end

end
# SPDX-License-Identifier: Apache-2.0
