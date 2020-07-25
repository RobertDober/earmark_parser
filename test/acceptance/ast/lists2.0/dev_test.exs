defmodule Acceptance.Ast.Lists20.DevTest do
  # TODO: Once the gfm-spec test passes, remove me
  use ExUnit.Case
  import Support.Helpers, only: [as_ast: 1]

  describe "lists v2.0 as going on" do
    test "simple as can be" do
      markdown = """
      1.  A list
      """

      # IO.puts markdown
      ast = [
        {"ol", [],
         [
           {"li", [], ["A list"], %{}}
         ], %{}}
      ]

      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "with two lines in the header" do
      markdown = """
      - Another
      List
      """

      ast = [
        {"ul", [],
         [
           {"li", [], ["Another\nList"], %{}}
         ], %{}}
      ]

      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "All good lists have to come to an end" do
      markdown =
"""
2. A good list

  The End
"""
      ast = [
        {"ol", [{"start", "2"}],
         [
           {"li", [], ["A good list"], %{}}
         ], %{}},
         {"p", [], ["  The End"]}
      ]

      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end
end
