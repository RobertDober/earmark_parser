defmodule EarmarkParser.Block.ListItem do
  @moduledoc false
  defstruct attrs: nil,
            blocks: [],
            bullet: "",
            lnb: 0,
            loose?: false,
            spaced: true,
            type: :ul

  def new(%EarmarkParser.Line.ListItem{bullet: bullet, type: type}, options \\ []) do
    blocks = Keyword.get(options, :blocks, [])
    %__MODULE__{blocks: blocks, bullet: bullet, type: type}
  end
end
