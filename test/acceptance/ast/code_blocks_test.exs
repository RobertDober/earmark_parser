defmodule Test.Acceptance.Ast.CodeBlocksTest do
  use Support.AcceptanceTestCase

  describe "Code Blocks near List Items (#9) https://github.com/RobertDober/earmark_parser/issues/9" do
    test "use case" do
      markdown = """
      * List item

        Text

          * List item

        Text

            https://mydomain.org/user_or_team/repo_name/blob/master/%{path}#L%{line}
      """
      IO.inspect as_ast(markdown)
    end

    test "simple example" do
      markdown = """
      * Outer

        Outer Content

        * Inner

        Still Outer
      """
      expected_html = """
      <ul>
        <li>
          <p>
            Outer
          </p>
          <p>
            Outer Content
          </p>
          <ul>
            <li>
              Inner
            </li>
          </ul>
          <p>
            Still Outer
          </p>
        </li>
      </ul>
      """
      expected = parse_html(expected_html)
      assert as_ast(markdown) == {:ok, expected, []}
    end
  end
end
