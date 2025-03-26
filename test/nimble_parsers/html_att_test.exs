defmodule Test.NimbleParsers.HtmlAttTest do
  use Support.NimbleTestCase

  describe "empty att list" do
    test "returns an empty list if end char (>) is present" do
      parse_html_atts(">")
      |> parsed_ok([])
    end

    test "does not parse an empty string" do
      parse_html_atts("")
      |> parsed_error("expected ASCII character in the range \">\" to \">\"")
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
