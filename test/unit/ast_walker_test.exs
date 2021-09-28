defmodule Test.Unit.AstWalkerTest do
  use ExUnit.Case

  import EarmarkParser.Ast.Renderer.AstWalker, only: [walk: 2, walk: 3]

  describe "walk a list" do
    test "empty" do
      assert walk([], & &1) == []
    end
    test "one element" do
      str = "do not use a palindrome here"
      assert walk([str], &String.reverse/1) == [String.reverse(str)]
    end
  end

  describe "walk a map" do
    test "empty" do
      assert walk(%{}, & &1) == %{}
    end
    test "one element" do
      str = "do not use a palindrome here"
      assert walk(%{str: str}, &String.reverse/1, true) == %{str: String.reverse(str)}
    end
  end

  describe "walk a tuple" do
    test "empty" do
      assert walk({}, & &1) == {}
    end
    test "one element" do
      str = "do not use a palindrome here"
      assert walk({str}, &String.reverse/1, true) == {String.reverse(str)}
    end
    
  end
end
