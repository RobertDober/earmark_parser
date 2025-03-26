defmodule Test.NimbleParsers.HtmlAttTest do
  use Support.NimbleTestCase

  describe "empty att list" do
    test "returns an empty list if end char (>) is present" do
      parse_html_atts(">")
      |> parsed_ok([])
    end

    test "does not parse an empty string" do
      parse_html_atts("")
      |> parsed_error("expected string \">\"")
    end
  end

  describe "boolean attribute" do
    test "just it's presence" do
      parse_html_atts("hidden>")
      |> parsed_ok([{"hidden", true}])
    end

    test "two boolean attributes" do
      parse_html_atts("hidden and-visible>")
      |> parsed_ok([{"hidden", true}, {"and-visible", true}])
    end
  end

  describe "a string attribute" do
    test "elixir, what else?" do
      parse_html_atts(~S{lang="elixir">})
      |> parsed_ok([{"lang", "elixir"}])
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
