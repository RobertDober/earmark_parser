defmodule Test.Functional.Scanner.Inline.Converters.CodeConverterTest do
  use ExUnit.Case
  import EarmarkParser.Ast.Inline.Converters.CodeConverter

  describe("illegal code, → nil") do
    test("no opening backquotes") do
      assert convert_code(" `hello`") == nil
    end

    test("no closing backquotes") do
      assert convert_code("`ab") == nil
    end

    test("closing sequence too short") do
      assert convert_code("``ab`") == nil
    end

    test("closing sequence too long") do
      assert convert_code("``ab`c```") == nil
    end
  end

  describe("correct code") do
    test("simple empty case") do
      code = "` `"
      assert convert_code(code) == {" ", ""}
    end

    test("2 bts no inner, no rest") do
      code = "``angel`daemon``"
      assert convert_code(code) == {"angel`daemon", ""}
    end
  end

  [
    {"`", " ", ""},
    {"``", "angel", ""},
    {"```", "barney", "fred"},
    {"`", "Toulon``Nice", ""},
    {"``", "Marseille`Carcassonne", "Bordeaux"}
  ]
  |> Enum.each(fn {bts, inner, rest} ->
    input = bts <> inner <> bts <> rest
    result = convert_code(input)

    test("convert_code #{input}") do
      assert unquote(result) == {unquote(inner), unquote(rest)}
    end
  end)
end

# SPDX-License-Identifier: Apache-2.0
