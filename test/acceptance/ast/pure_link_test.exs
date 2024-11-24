defmodule Test.Acceptance.Ast.PureLinkTest do
  use Support.AcceptanceTestCase

    test "closing parens can match opening parens at the end" do
      link     = "http://www.google.com/search?q=business"
      markdown = "(#{link})"
      ast = p(["(", a(link, href: link), ")"])

      result   = as_ast(markdown)
      assert result == {:ok, [ast], []}
    end

    test "not a link" do
      ast = p("(")

      result = as_ast("(")
      assert result == {:ok, [ast], []}
    end

end
#  SPDX-License-Identifier: Apache-2.0
