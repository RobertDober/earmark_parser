defmodule Test.Acceptance.Ast.Footnotes.FnInListsTest do
  use Support.AcceptanceTestCase

  import Support.FootnoteHelpers

  describe "two footnotes" do
    test "in list header" do
      markdown = """
      - A line with[^1] two references[^2]

      [^1]: Footnote **one**
      [^2]: - Footnote 2.1
      - Footnote 2.2
      """

      ast = [
        ul(
          (li([
          "A line with",
          footnote(1),
          " two references",
          footnote(2)
        ]))),
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

    test "list body, first is not referenced" do
      markdown = """
      - N.B.

        A line with one reference[^2]

      [^1]: Footnote **one**
      [^2]: - Footnote 2.1
      - Footnote 2.2
      """

      ast = [
        (ul(li(tags("p",[
          "N.B.",
          ["A line with one reference",
          footnote(2)]
        ])))),

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

end
#  SPDX-License-Identifier: Apache-2.0
