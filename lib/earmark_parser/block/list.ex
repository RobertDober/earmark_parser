defmodule EarmarkParser.Block.List do
  @moduledoc false

  use EarmarkParser.Types

  alias EarmarkParser.List.ListInfo
  alias EarmarkParser.Block.ListItem

  defstruct attrs: nil,
            blocks: [],
            bullet: "-",
            lnb: 0,
            loose?: false,
            start: "",
            type: :ul

  @type t :: %__MODULE__{
      attrs: attr_ts(),
      blocks: EarmarkParser.Block.ts,
      bullet: binary(),
      lnb: non_neg_integer,
      loose?: boolean(),
      start: binary(),
      type: atom()
  }

  def new(
        [%ListItem{bullet: bullet, lnb: lnb, loose?: loose, spaced?: spaced1, type: type} | _] =
          items,
        %ListInfo{spaced: spaced}
      ) do
    %__MODULE__{
      blocks: items,
      bullet: bullet,
      lnb: lnb,
      loose?: loose || spaced || spaced1,
      start: _extract_start(bullet),
      type: type
    }
  end

  @start_number_rgx ~r{\A0*(\d+)[.)]}
  defp _extract_start(bullet) do
    case Regex.run(@start_number_rgx, bullet) do
      nil -> ""
      [_, "1"] -> ""
      [_, start] -> ~s{ start="#{start}"}
    end
  end
end
