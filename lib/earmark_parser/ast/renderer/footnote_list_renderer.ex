defmodule EarmarkParser.Ast.Renderer.FootnoteListRenderer do

  alias EarmarkParser.Block
  import EarmarkParser.Ast.Emitter
  import EarmarkParser.Ast.Inline, only: [convert: 3]

  @moduledoc false

  def render_footnote_list(items, context) do
    emit("div", [
      emit("hr"),
      emit("ol", _render_footnote_list_items(items, context))], class: "footnotes")
  end


  defp _render_footnote_list_items(items, context) do
    items
    |> Enum.map(&_render_footnote_list_item(&1, context))
  end

  defp _render_footnote_list_item(%Block.ListItem{attrs: %{id: [id]}, blocks: paras}, context) do
    id1 = String.trim_leading(id, "#")
    inner_ast = paras |> Enum.map(&_render_footnote_content(&1, context)) |> IO.inspect() 
    emit("li", emit("p",  inner_ast ++ _render_footnote_backlink() |> IO.inspect() ), id: id1)
  end

  defp _render_footnote_content(%Block.Para{lines: lines, lnb: lnb}, context) do
    convert(lines, lnb, context).value |> Enum.reverse
  end

  defp _render_footnote_backlink() do
    [emit("a", "&#x21A9;")]
  end
end
#  SPDX-License-Identifier: Apache-2.0
