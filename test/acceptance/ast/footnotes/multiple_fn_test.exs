defmodule Test.Acceptance.Ast.Footnotes.MultipleFnTest do
  use Support.AcceptanceTestCase

  import Support.FootnoteHelpers

  describe "two footnotes" do
    test "simple" do
      markdown = """
      A line with[^1] two references[^2]

      [^1]: Footnote **one**
      [^2]: - Footnote 2.1
      - Footnote 2.2
      """

      ast = [
        p([
          "A line with",
          footnote(1),
          " two references",
          footnote(2)
        ]),
        footnotes([
          footnote_def(1, p(["Footnote ", tag("strong", "one")])),
          footnote_def(2, [
            tag("ul", [
              tag("li", "Footnote 2.1"),
              tag("li", "Footnote 2.2")
            ])
          ])
        ])
      ]

      assert fn_ast(markdown) == ast
    end

    test "first is not referenced" do
      markdown = """
      A line with one reference[^2]

      [^1]: Footnote **one**
      [^2]: - Footnote 2.1
      - Footnote 2.2
      """

      ast = [
        p([
          "A line with one reference",
          footnote(2)
        ]),
        footnotes(
        footnote_def(
        2,
        tag("ul", [
          tag("li", "Footnote 2.1"),
          tag("li", "Footnote 2.2")
        ])
        )
        )
      ]

      assert fn_ast(markdown) == ast
    end

  end

  describe "three footnotes" do
    test "one unused" do
      markdown = """
      - A line with[^1]

      - two references[^3]

      [^1]: Footnote **one**
      [^2]: - Footnote 2.1
      - Footnote 2.2
      [^3]: ## Hello
      """

      ast = [
        tag("ul", [
          tag("li", p(["A line with", footnote(1)])),
          tag("li", p(["two references", footnote(3)]))
        ]),
        footnotes([
          footnote_def(1, p(["Footnote ", tag("strong", "one")])),
          footnote_def(3, tag("h2", "Hello"))
        ])
      ]

      assert fn_ast(markdown) == ast
    end

    test "one used twice -- still ambiguous" do
      markdown = """
      - A line with[^1]

      - two[^1] references[^3]

      [^1]: Footnote **one**
      [^2]: - Footnote 2.1
      - Footnote 2.2
      [^3]: ## Hello
      """

      ast = [
        tag("ul", [
          tag("li", p(["A line with", footnote(1)])),
          tag("li", p(["two", footnote(1), " references", footnote(3)]))
        ]),
        footnotes([
          footnote_def(1, p(["Footnote ", tag("strong", "one")])),
          footnote_def(3, tag("h2", "Hello"))
        ])
      ]

      assert fn_ast(markdown) == ast
    end
  end
end

#  SPDX-License-Identifier: Apache-2.0
