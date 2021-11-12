defmodule Test.EarmarkHelpersTests.ParserTest do
  use ExUnit.Case

  doctest EarmarkParser.Helpers.Parser, import: true

  import EarmarkParser.Helpers.Parser

  describe "debugging tests" do
    test "fails" do
      assert count_parens().("(((()))") == {:error, "unexpected end of input in char_parser"}
    end
    test "ranges?" do
      no_spaces = up_to("\n ")
      assert no_spaces.("a b") == {:ok, "a", " b"}
    end
    # test "escaped" do
    #   string_parser = sequence([
    #     ignore(?"),
    #     up_to(?", escaped_by: ?"),
    #     ignore(?")])
    #   assert string_parser.(~s{"al""pha"}) == {:ok, ~s{al"pha}, ""}
    # end
  end

  defp count_parens do
    sequence([
      char_range_parser([?(]),
      optional(lazy(fn -> count_parens() end)),
      char_range_parser([?)])
    ])
  end
end
#  SPDX-License-Identifier: Apache-2.0
