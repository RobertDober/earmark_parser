defmodule Test.Acceptance.Ast.Lists.ComplexHeadTest do
  use Support.AcceptanceTestCase
  import Support.AstHelpers, only: [ast_from_md: 1]
  import EarmarkAstDsl

  describe "Headers become one junk of text" do
    test "at end of input" do
      markdown = """
      * First
                Second
      """
      expected = [ul(li(["First", pre_code("    Second")]))]
      assert ast_from_md(markdown) == expected
    end
    test "before end of list" do
      markdown = """
      * Primo
                Secondo
      # Ciao
      """
      expected = [ul(li(["Primo", pre_code("    Secondo")])), tag("h1", "Ciao")]
      assert ast_from_md(markdown) == expected
    end
    test "before and of list item" do
      markdown = """
      * первый
                второй
      * Привет
      """
      expected = [ul([li(["первый", pre_code("    второй")]), li("Привет")])]
      assert ast_from_md(markdown) == expected
    end
    test "before body" do
      markdown = """
      * uma
           duas

        Olá
      """
      expected = [ul(li([p("uma\n   duas"), p("Olá")]))]
      assert ast_from_md(markdown) == expected
    end
  end

  describe "Headers contain block data" do
    test "blockquote at the beginning" do
      markdown = """
      * > σπουδαίος
      """
      expected = [ul(blockquote("σπουδαίος"))]
      assert ast_from_md(markdown) == expected
    end
    test "blockquote in the middle" do
      markdown = """
      * banale
        > important
      """
      expected = [ul(li(["banale", blockquote("important")]))]
      assert ast_from_md(markdown) == expected
    end
  end

  describe "Ending Headers" do
    test "by a blank line" do
      markdown = """
      * Rien à voir, circulez

      Text
      """
      expected = [ul(["Rien à voir, circulez"]), p("Text")]
      assert ast_from_md(markdown) == expected
    end
  end

  describe "cmark-gfm compliance" do
    test "parse blocks in headers if they are indented _correctly_" do
      markdown = """
      - a
            > b
        > c
      """
      expected = [ul(li(["a", pre_code("> b"), blockquote("c")]))]

      assert ast_from_md(markdown) == expected
    end
    test "parse headlines in headers if they are indented _correctly_" do
      markdown = """
      - a
            # b
        # c
      """
      expected = [ul(li(["a", pre_code("# b"), tag("h1", "c")]))]
      assert ast_from_md(markdown) == expected
    end
    test "blocks with negative indent stop the list/item, but text does not" do
      markdown = """
      - a
          > b
      c
       > d
      """
      expected = [
        ul(li(["a", blockquote("b\nc")])),
        blockquote("d")]
      assert ast_from_md(markdown) == expected
    end
    test "headline with negative indent stop the list/item definitely, but we need to aligne correctly" do
      markdown = """
      - a
          ## b
      c
       # d
      """
      expected = [
        ul(li(["a\n  ## b\nc", tag("h1", "d")]))]
      assert ast_from_md(markdown) == expected
    end
    test "headline with negative indent stop the list/item definitely, if aligned correctly" do
      markdown = """
      - a
          ## b
      c
      # d
      """
      expected = [
        ul("a\n  ## b\nc"), tag("h1", "d")]
      assert ast_from_md(markdown) == expected
    end
    test "negatively indexed outside of a block element is still part of the item" do
      markdown = """
      - a
      c
      """
      expected = [
        ul(li("a\nc"))]
      assert ast_from_md(markdown) == expected
    end
    test "negatively indexed outside of a block element is not part of the item after a header" do
      markdown = """
      - a
        # b
      c
      """
      expected = [
        ul(li(["a", tag("h1", "b"), "c"]))]
      assert ast_from_md(markdown) == expected
    end
    test "negatively indexed outside of a block element is not part of the item after text" do
      markdown = """
      - a
        # b
      c
      """
      expected = [
        ul(li(["a", tag("h1", "b"), "c"]))]
      assert ast_from_md(markdown) == expected
    end
    test "negatively indexed outside of a block element is again part of the item after an indented header" do
      markdown = """
      - a
            # b
      c
      """
      expected = [ul(li(["a", pre_code("# b"), "c"]))]
      assert ast_from_md(markdown) == expected
    end
    test "block element negatively indexed ends the list" do
      markdown = """
      - a
      > b
      """
      expected = [ ul("a"), blockquote("b")]
      assert ast_from_md(markdown) == expected
    end
    test "header element negatively indexed ends the list" do
      markdown = """
      - a
      # b
      """
      expected = [ ul("a"), tag("h1", "b")]
      assert ast_from_md(markdown) == expected
    end
    test "code element negatively indexed ends the list, but not for us" do
      markdown = """
      - a
      ```
      b
      ```
      """
      expected = [ ul(li(["a", pre_code("b")])) ]
      assert ast_from_md(markdown) == expected
    end
  end
end
#  SPDX-License-Identifier: Apache-2.0
