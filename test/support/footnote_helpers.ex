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
      title: "see footnote",
      href: "#fn:#{number}",
      class: "footnote",
      id: "fnref:#{number}"
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

  def has_verbatim?(ast) do
    case ast do
      [
        _,
        {"div", [{"class", "footnotes"}],
         [
           _,
           {"ol", [],
            [
              {"li", [_],
               [
                 {"a", [_, _, {"href", _}], ["&#x21A9;"], %{verbatim: true}},
                 _
               ], %{}}
            ], %{}}
         ], %{}}
      ] ->
        true

      _ ->
        false
    end
  end
end

#  SPDX-License-Identifier: Apache-2.0
