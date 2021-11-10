defmodule Test.EarmarkHelpersTests.ParserTest do
  use ExUnit.Case

  doctest EarmarkParser.Helpers.Parser, import: true

  import EarmarkParser.Helpers.Parser

  describe "debugging tests" do
    test "fails" do
      assert count_parens().("(((()))") == nil

    end
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
