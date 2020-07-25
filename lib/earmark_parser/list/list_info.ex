defmodule EarmarkParser.List.ListInfo do
  use EarmarkParser.Types
  import EarmarkParser.Helpers.LookaheadHelpers,
    only: [opens_inline_code: 1, still_inline_code: 2]

  @moduledoc false

  @not_pending {nil, 0}

  defstruct(
    header: true,
    indent: 0,
    pending: @not_pending,
    spaced: false,
    width: 0
  )

  @type t :: %__MODULE__{
          header: boolean(),
          indent: non_neg_integer(),
          pending: pending_t(),
          spaced: boolean(),
          width: non_neg_integer()
        }

  # INLINE CANDIDATE
  def new(%EarmarkParser.Line.ListItem{initial_indent: ii, list_indent: width} = item) do
    pending = opens_inline_code(item)
    %__MODULE__{indent: ii, pending: pending, width: width}
  end

  def pending?(list_info)
  def pending?(%__MODULE__{pending: @not_pending}), do: true
  def pending?(%__MODULE__{}), do: false

  # INLINE CANDIDATE
  def update_pending(list_info, line)

  def update_pending(%{pending: @not_pending} = info, line) do
    pending = opens_inline_code(line)
    %{info | pending: pending}
  end

  def update_pending(%{pending: pending} = info, line) do
    pending1 = still_inline_code(line, pending)
    %{info | pending: pending1}
  end
end
