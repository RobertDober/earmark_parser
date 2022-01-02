defmodule Test.Acceptance.Ast.Lists.IndentTest do
  use Support.AcceptanceTestCase
  import Support.AstHelpers, only: [ast_from_md: 1]

  describe "Code Blocks near List Items (#9) https://github.com/RobertDober/earmark_parser/issues/9" do
    test "use case" do

      markdown = """
      * Header

        Text1

          * Inner

        Text2

        https://mydomain.org/user_or_team/repo_name/blob/master/%{path}#L%{line}
      """
      expected = [
        ul(
          li([
            p("Header"),
            p("Text1"),
            ul(
              li([
                "Inner"])),
            p("Text2"),
            p(a("https://mydomain.org/user_or_team/repo_name/blob/master/%{path}#L%{line}",
              href: "https://mydomain.org/user_or_team/repo_name/blob/master/%25%7Bpath%7D#L%25%7Bline%7D"))
            ]))]
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

    test "loose example" do
      markdown = """
      - One

      - Two
      """
      expected = [
        ul([li(p("One")), li(p("Two"))])
      ]
      assert ast_from_md(markdown) == expected
    end

    test "tight example" do
      markdown = """
      - One
      - Two
      """
      expected = [
        ul([li("One"), li("Two")])
      ]
      assert ast_from_md(markdown) == expected
    end
    test "debugging" do
      markdown = """
      * Head

        Content
      """
      expected = [
        ul(li([p("Head"), p("Content")]))
      ]
      assert ast_from_md(markdown) == expected
    end
  end
end
