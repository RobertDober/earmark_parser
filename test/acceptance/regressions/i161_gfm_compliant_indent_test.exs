defmodule I161GfmCompliantIndentTest do
  use Support.AcceptanceTestCase

  describe "Indent of content of fenced code blocks inside a list (#161)" do
    test "code block aligned exactly as necessary" do
      markdown = """
      1. Test

         ```elixir
         def foo
         ```
      """
      expected = [
        ol(
          li([
            p("Test"),
            tag("pre", tag("code", "def foo", class: "elixir"))
          ]))
      ]
      assert ast_from_md(markdown) == expected
    end

    test "code block aligned 1 space more than necessary" do
      markdown = """
      1. Test

          ```elixir
          def foo
          ```
      """
      expected = [
        ol(
          li([
            p("Test"),
            tag("pre", tag("code", "def foo", class: "elixir"))
          ]))
      ]
      assert ast_from_md(markdown) == expected
    end
  end

  describe "Indent of headlines" do
    test "headlines are still headlines" do
      markdown = """
      # Hello
       # World
      """
      expected = [
        tag("hl1", "Hello"),
        tag("hl2", "World")
      ]
      assert ast_from_md(markdown) == expected
    end
  end
end
# SPDX-License-Identifier: Apache-2.0
