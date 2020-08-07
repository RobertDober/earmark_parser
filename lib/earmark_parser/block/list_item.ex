defmodule EarmarkParser.Block.ListItem do
  @moduledoc false

  use EarmarkParser.Types

  defstruct attrs: nil,
            blocks: [],
            bullet: "",
            lnb: 0,
            loose?: false,
            spaced?: true,
            type: :ul

  @type t :: %__MODULE__{
          attrs: attr_ts(),
          blocks: EarmarkParser.Block.ts(),
          bullet: String.t(),
          lnb: non_neg_integer(),
          loose?: boolean(),
          spaced?: boolean(),
          type: :ul | :ol
        }
  def new(%EarmarkParser.Line.ListItem{bullet: bullet, type: type}, options \\ []) do
    blocks = Keyword.get(options, :blocks, [])
    %__MODULE__{blocks: blocks, bullet: bullet, type: type}
  end
end
