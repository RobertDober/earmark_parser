defmodule Ear.Ast.Block do
  @moduledoc false

  defstruct atts: %{},
            content: [],
            meta: %{},
            open?: true,
            lnb: 0,
            tag: nil

  def add_text_to_block(%__MODULE__{open?: true} = block, state) do
    %{block | content: [{state.token.content, state.lnb} | block.content]}
  end

  def close_block(block)

  def close_block(%__MODULE__{open?: true, content: content} = block) do
    %{block | open?: false, content: Enum.reverse(content)}
  end

  def new(tag, content, opts \\ []) do
    lnb = Keyword.get(opts, :lnb, 0)
    %__MODULE__{tag: tag, content: content, lnb: lnb}
  end
end

#  SPDX-License-Identifier: Apache-2.0
