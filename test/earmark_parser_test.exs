defmodule EarmarkParserTest do
  use ExUnit.Case

  doctest EarmarkParser, import: true

  describe "some basic functions" do
    test "version" do
      assert Regex.match?(~r{\A\d+\.\d+}, to_string(EarmarkParser.version()))
    end
  end
end
