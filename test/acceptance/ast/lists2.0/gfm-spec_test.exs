defmodule  EarmarkParser.Ast.Lists20.GfmSpecTest do
  use ExUnit.Case, async: true

  import Support.Helpers, only: [as_ast: 1]

  describe "GFM Specs" do
    test "#232" do
      markdown =
"""
1.  A paragraph
    with two lines.

        indented code

    > A block quote.
"""
    IO.puts markdown
    ast =
[
  {"ol", [],
   [
     {"li", [],
      [
        {"p", [], ["A paragraph\nwith two lines."], %{}},
        {"pre", [], [{"code", [], ["indented code\n"], %{}}], %{}},
        {"blockquote", [], [{"p", [], ["A block quote."], %{}}], %{}}
      ], %{}}
   ], %{}}
]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  
end
