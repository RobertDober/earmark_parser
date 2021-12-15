defmodule Support.FootnoteHelpers do
  import EarmarkAstDsl
  @moduledoc false

  def fn_ast(markdown) do
    {:ok, ast, []} = EarmarkParser.as_ast(markdown, footnotes: true)
    ast
  end

  def footnote_def(number, content)
  def footnote_def(number, content) when is_tuple(content) do
    footnote_def(number, [content])
  end
  def footnote_def(number, content) do
    tag("li", [reverse_footnote(number) | content], id: "fn:#{number}")
  end

  def footnote(number) do
    a("#{number}",
      href: "#fn:#{number}",
      id: "fnref:#{number}",
      class: "footnote",
      title: "see footnote"
    )
  end

  def footnotes(content) do
    tag("div", [tag("hr"), tag("ol", content)], class: "footnotes")
  end

  defp reverse_footnote(number) do
    a("&#x21A9;",
      class: "reversefootnote",
      href: "#fnref:#{number}",
      title: "return to article"
    )
  end
end

#  SPDX-License-Identifier: Apache-2.0
