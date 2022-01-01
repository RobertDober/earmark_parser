defmodule Test.Acceptance.Ast.Lists.ComplexBodyTest do
  use Support.AcceptanceTestCase
  import Support.AstHelpers, only: [ast_from_md: 1, ast_with_errors: 1]


  describe "Ending Bodies" do
    test "blank lines have no impact anymore" do
      markdown = """
      * Hello


        World
      """
      expected = [ul(li(tags("p", ["Hello", "World"])))]
      assert ast_from_md(markdown) == expected
    end
    test "blank lines and negative indent" do
      markdown = """
      * Hello


      World
      """
      expected = [ul("Hello"), p("World")]
      assert ast_from_md(markdown) == expected
    end
  end

  describe "pending inline code" do
    test "simplest possible case" do
      markdown = """
      * Hello

        ` World
      """
      expected = {[ul(li(tags("p", ["Hello", "` World"])))] ,[{:warning, 3, "Closing unclosed backquotes ` at end of input"}]}

      assert ast_with_errors(markdown) == expected
    end

    test "second item case" do
      markdown = """
      * Hello
      * Again
        ` World
      """
      expected = {
        [ul(["Hello", "Again\n` World"])],
        [{:warning, 3, "Closing unclosed backquotes ` at end of input"}]}

      assert ast_with_errors(markdown) == expected
    end
  end
end
#  SPDX-License-Identifier: Apache-2.0
