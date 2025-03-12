defmodule Acceptance.Ast.Footnotes.ErrorCasesTest do
  use ExUnit.Case

  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 2]
  import EarmarkAstDsl

  describe "Incorrect Footnotes" do
    test "undefined footnotes" do
      markdown = "foo[^1]\nhello\n\n[^2]: bar baz"
      ast = [p("foo[^1]\nhello")]
      messages = [{:error, 1, "footnote 1 undefined, reference to it ignored"}]

      assert as_ast(markdown, footnotes: true) == {:error, ast, messages}
    end

    test "undefined footnotes (none at all)" do
      markdown = "foo[^1]\nhello"
      ast = p("foo[^1]\nhello")
      messages = [{:error, 1, "footnote 1 undefined, reference to it ignored"}]

      assert as_ast(markdown, footnotes: true) == {:error, [ast], messages}
    end

    test "illdefined footnotes" do
      markdown = "foo[^1]\nhello\n\n[^1]:bar baz"
      ast = [p("foo[^1]\nhello"), p("[^1]:bar baz")]

      messages = [
        {:error, 1, "footnote 1 undefined, reference to it ignored"},
        {:error, 4, "footnote 1 undefined, reference to it ignored"}
      ]

      assert as_ast(markdown, footnotes: true) == {:error, ast, messages}
    end
  end
end

#  SPDX-License-Identifier: Apache-2.0
