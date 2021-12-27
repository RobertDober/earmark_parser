defmodule Test.Functional.Scanner.ParseListTest do
  use ExUnit.Case
  import EarmarkParser.Parser.ListParser

  describe "header" do
    test "one line" do
      ast = pl(["* xxx"])
      expected = [txt("xxx")]
      assert ast == expected
    end

    test "two lines" do
      ast = pl(["* xxx", "yyy"])
      expected = txt("xxx yyy")
      assert ast == expected
    end

    test "two lines and hr" do
      ast = pl(["* xxx", "yyy", "---"])

      expected = txt("xxx yyy")
      assert ast == expected
    end

    # TODO: Add test to check if line.content is the correct
    # way to extract text in the header
  end

  describe "body" do
    test "simple pimple" do
      ast = pl(["* xxx", "", "  yyy"])

      expected = [txt("xxx"), txt("yyy", 2)]
      assert ast == expected
    end
  end

  def pl(lines, opts \\ []) do
    lines
    |> EarmarkParser.LineScanner.scan_lines()
    |> parse_list([], EarmarkParser.Options.normalize(opts))
    |> IO.inspect()
  end

  defp txt(line, lnb \\ 0) do
    %EarmarkParser.Line.Text{line: line, lnb: lnb}
  end
end
