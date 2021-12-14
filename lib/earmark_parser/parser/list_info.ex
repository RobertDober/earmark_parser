defmodule EarmarkParser.Parser.ListInfo do
  import EarmarkParser.Helpers.LookaheadHelpers, only: [opens_inline_code: 1]

  @moduledoc false

  @not_pending {nil, 0}

  defstruct(
    indent: 0,
    pending: @not_pending,
    spaced: false,
    width: 0)

  # INLINE CANDIDATE
  def new(%EarmarkParser.Line.ListItem{initial_indent: ii, list_indent: width}=item) do
    pending = opens_inline_code(item)
    %__MODULE__{indent: ii, pending: pending, width: width}
  end

end
#  SPDX-License-Identifier: Apache-2.0
