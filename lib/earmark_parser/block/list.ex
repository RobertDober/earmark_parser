defmodule EarmarkParser.Block.List do
  @moduledoc false
  import EarmarkParser.Helpers.LookaheadHelpers, only: [update_inline_code: 2]

  defstruct annotation: nil,
            attrs: nil,
            blocks: [],
            lines: [],
            bullet: "-",
            indent: 0,
            lnb: 0,
            loose?: false,
            pending: {nil, 0},
            spaced?: false,
            start: "",
            type: :ul

  def new(%EarmarkParser.Line.ListItem{} = li) do
    %__MODULE__{
      bullet: li.bullet,
      indent: li.list_indent,
      lnb: li.lnb,
      type: li.type
    }
  end

  def update_pending_state(%__MODULE__{pending: old_pending_state} = list, line) do
    new_pending_state = update_inline_code(old_pending_state, line)
    %{list | pending: new_pending_state}
  end
end

#  SPDX-License-Identifier: Apache-2.0
