defmodule Test.Debug.DebugListsTest do
  use Support.AcceptanceTestCase
  import Support.AstHelpers, only: [ast_from_md: 1]
  import Test.Debug.Support

  describe "debugging the list parser's structural problem" do
    test "ASAP" do
      markdown = """
      * Header

        Text 1

        * Inner

        Text 2
      """
      markdown |> ast_from_md |> IO.inspect
    end

    test "simple 2 levels, lose" do
      markdown = """
      * LI1

        * LI2

      Outer Text
      """
      expected = [
        ul(
          li([
            p("LI1"),
            p(ul("LI2")),
            p("Outer Text")]))
      ]
      assert ast_from_md(markdown) == expected
    end

    test "simple 2 levels, tight" do
      markdown = """
      * LI1
        * LI2
      Inner Text
      """
      expected = [
        ul(
          li([ "LI1", ul("LI2 Inner Text") ]))
      ]
      parse_list(markdown)
      # assert ast_from_md(markdown) == expected
    end
  end
end
#  SPDX-License-Identifier: Apache-2.0
