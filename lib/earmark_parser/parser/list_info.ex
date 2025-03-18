defmodule EarmarkParser.Parser.ListInfo do

  alias EarmarkParser.{Options, Line}

  import EarmarkParser.Helpers.LookaheadHelpers, only: [opens_inline_code: 1, still_inline_code: 2]

  @moduledoc false

  @not_pending {nil, 0}

  defstruct(
    indent: 0,
    lines: [],
    loose?: false,
    pending: @not_pending,
    options: %EarmarkParser.Options{},
    width: 0
  )
  @type t :: %__MODULE__{
    indent: non_neg_integer(),
    lines: list(),
    loose?: boolean(),
    pending: {nil | String.t(), non_neg_integer()},
    options: Options.t(),
    width: non_neg_integer()
  }

  @spec new(Line.ListItem.t(), Options.t()) :: t()
  def new(%Line.ListItem{initial_indent: ii, list_indent: width} = item, options) do
    pending = opens_inline_code(item)
    %__MODULE__{indent: ii, lines: [item.content], options: options, pending: pending, width: width}
  end

  def update_list_info(list_info, line, pending_line, loose? \\ false) do
    prepend_line(list_info, line) |> _update_rest(pending_line, loose?)
  end

  def prepend_line(%__MODULE__{lines: lines} = list_info, line) do
    %{list_info | lines: [line | lines]}
  end

  defp _update_rest(%{pending: @not_pending} = list_info, line, loose?) do
    pending = opens_inline_code(line)
    %{list_info | pending: pending, loose?: loose?}
  end

  defp _update_rest(%{pending: pending} = list_info, line, loose?) do
    pending1 = still_inline_code(line, pending)
    %{list_info | pending: pending1, loose?: loose?}
  end
end

# SPDX-License-Identifier: Apache-2.0
