defmodule EarmarkParser.List.ListReader do
  use EarmarkParser.Types

  alias EarmarkParser.Line
  alias EarmarkParser.List.{ListInfo}
  @moduledoc false

  @not_pending {nil, 0}

  def read_list_item(input, item_lines, list_info, options)

  def read_list_item([], item_lines, _list_info, options) do
    # TODO: Add check if pending_inline_code and add potential error to options
    {Enum.reverse(item_lines), [], options}
  end

  def read_list_item([line | rest] = input, item_lines, list_info, options) do
    case _still_in_list?(line, list_info) do
      {true, list_info1} -> read_list_item(rest, [line | item_lines], list_info1, options)
      _ -> {Enum.reverse(item_lines), input, options}
    end
  end

  @spec _still_in_list?(Line.t(), ListInfo.t()) :: maybe({true, ListInfo.t()})
  defp _still_in_list?(line, list_info)

  defp _still_in_list?(line, %ListInfo{pending: @not_pending} = list_info) do
    list_info1 = ListInfo.update_pending(list_info, line)

    if ListInfo.pending?(list_info1) do
      {true, list_info1}
    else
      _still_in_np_list?(line, list_info)
    end
  end

  defp _still_in_list?(line, list_info) do
    {true, ListInfo.update_pending(list_info, line)}
  end

  @spec _still_in_np_list?(Line.t(), ListInfo.t()) :: maybe({true, ListInfo.t()})
  defp _still_in_np_list?(line, list_info)

  defp _still_in_np_list?(%Line.Ruler{}, _list_info) do
    nil
  end

  defp _still_in_np_list?(%Line.Blank{}, list_info) do
    {true, %{list_info | spaced: true}}
  end

  defp _still_in_np_list?(_, %ListInfo{spaced: false} = list_info) do
    {true, list_info}
  end

  # # All following patterns match spaced: true

  defp _still_in_np_list?(%{indent: indent}, %ListInfo{width: width} = list_info) do
    if indent >= width do
      {true, list_info}
    end
  end

  # defp _still_in_np_list?(_, _), do: false
end
