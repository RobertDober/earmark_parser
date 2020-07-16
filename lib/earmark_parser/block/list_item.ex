defmodule EarmarkParser.Block.ListItem do
  @moduledoc false
  defstruct attrs: nil,
            blocks: [],
            bullet: "",
            lnb: 0,
            loose?: false,
            spaced: true,
            type: :ul

  def new(%EarmarkParser.Line.ListItem{bullet: bullet, type: type}) do
    %__MODULE__{bullet: bullet, type: type}
  end
end
