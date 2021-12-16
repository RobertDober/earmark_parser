defmodule Test.Acceptance.Ast.Lists.IndentTest do
  use Support.AcceptanceTestCase
  import Support.AstHelpers, only: [ast_from_md: 1]
  import EarmarkAstDsl

  describe "Code Blocks near List Items (#9) https://github.com/RobertDober/earmark_parser/issues/9" do
    test "use case" do
      markdown = """
      * List item

        Text

          * List item

        Text

            https://mydomain.org/user_or_team/repo_name/blob/master/%{path}#L%{line}
      """
      expected = [
        ul(
          li([
            p("List item"),
            p("Text"),
            ul(
              li([
                "List item\nText\n",
              a("https://mydomain.org/user_or_team/repo_name/blob/master/%{path}#L%{line}",
              href: "https://mydomain.org/user_or_team/repo_name/blob/master/%25%7Bpath%7D#L%25%7Bline%7D")
            ]))]))
      ]
      # IO.inspect as_ast(markdown)
      assert ast_from_md(markdown) == expected
    end

    test "simple example" do
      markdown = """
      * Outer

        Outer Content

        * Inner

        Still Outer
      """
      expected = [
        ul(li([p("Outer"), p("Outer Content"), ul("Inner"), p("Still Outer")]))
      ]
      assert ast_from_md(markdown) == expected
    end
  end
end
