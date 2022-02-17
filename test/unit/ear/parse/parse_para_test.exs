defmodule Test.Unit.Ear.Parse.ParseParaTest do
  use Support.EarTestCase

  describe "parse text" do
    test "empty input" do
      result = parse("")
      assert result == ok([])
    end

    test "a single line" do
      result = parse("hello")
      expected = ok("p", "hello")
      assert result == expected
    end

    test "blank at end" do
      markdown = """
      hello
      """
      result = parse(markdown)
      expected = ok("p", "hello")
      assert result == expected
    end

    test "two blanks at end" do
      markdown = """
      hello

      """
      result = parse(markdown)
      expected = ok("p", "hello")
      assert result == expected
    end

    test "two lines" do
      result = parse("hello\nworld")
      expected = ok("p", tuples(~W[hello world]))
      assert result == expected
    end

    test "two paragraphs" do
      result = parse("hello\n\nworld")
      expected = ok([
        block("p", "hello", lnb: 1),
        block("p", "world", lnb: 3)
      ])
      assert result == expected
    end
  end

end
# SPDX-License-Identifier: Apache-2.0
