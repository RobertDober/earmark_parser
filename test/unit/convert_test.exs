defmodule Test.Unit.ConvertTest do
  use ExUnit.Case

  describe "edge cases" do
    test "empty" do
      assert convert("") == []
    end
  end
  
  defp convert(content), do: EarmarkParser.Ast.Inline.convert(content, 42, %EarmarkParser.Context{}).value
end
