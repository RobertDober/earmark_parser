defmodule Ear.Ast do
  @moduledoc false

  alias __MODULE__.Block

  def add_text(ast, state)
  def add_text([%{open?: true}=block|rest], state), do: [Block.add_text_to_block(block, state)|rest]
  def add_text(ast, state), do: [Block.new("p", [{state.token.content, state.lnb}], lnb: state.lnb)|ast]

  def close_ast(ast)
  def close_ast([%Block{open?: true}=block|rest]), do: [Block.close_block(block)|rest]
  def close_ast(ast), do: ast

  # def add_quad_to_content({pt, pa, pc, pm}, tag, content, atts \\ []) do
  #   {pt, pa, [make_quad(tag, content, atts)|pc], pm}
  # end

  # def make_quad(tag, content, atts \\ [])
  # def make_quad(tag, content, atts) when is_list(content) do
  #   {atts_, meta_} = _extract_meta(atts)
  #   {tag, atts_, content, meta_}
  # end
  # def make_quad(tag, content, atts), do: make_quad(tag, [content], atts)

  # def normalize(quads) when is_list(quads) do
  #   quads
  #   |> Enum.map(&normalize/1)
  # end

  # def normalize({tag, atts, content, meta}) do
  #   {tag, _normalize_atts(atts), content, meta}
  # end

  # defp _extract_meta(atts) do
  #   atts_ = atts |> Enum.into(%{})
  #   meta_ = Map.get(atts_, :meta, %{})
  #   {Map.delete(atts_, :meta), meta_}
  # end

  # defp _normalize_atts(atts) do
  #   atts
  #   |> Enum.into([])
  #   |> Enum.map(fn {k, v} -> {to_string(k), v} end)
  # end
end
# SPDX-License-Identifier: Apache-2.0
