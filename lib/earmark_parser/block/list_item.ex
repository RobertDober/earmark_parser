defmodule EarmarkParser.Block.ListItem do
  @moduledoc false
  defstruct attrs: nil,
            blocks: [],
            bullet: "",
            lnb: 0,
            annotation: nil,
            loose?: false,
            spaced?: true,
            type: :ul

  def new(list, blocks \\ []) do
    %__MODULE__{
      blocks: blocks,
      bullet: list.bullet,
      lnb: list.lnb,
      annotation: list.annotation,
      loose?: list.loose?,
      spaced?: list.spaced?,
      type: list.type
    }
  end
end
#  SPDX-License-Identifier: Apache-2.0
