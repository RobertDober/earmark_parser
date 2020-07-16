defmodule EarmarkParser.List.ListReader do
  @moduledoc false

  @not_pending {nil, 0}

  def read_list_item(input, item_lines, list_info, options)
  def read_list_item([], item_lines, _list_info, options) do
    # TODO: Add check if pending_inline_code and add potential error to options
    {Enum.reverse(item_lines), [], options}
  end
  def read_list_item([line|rest]=input, item_lines, list_info, options) do
    case _still_in_list?(line, list_info) do
      {true, list_info1} -> read_list_item(rest, [line|item_lines], list_info1, options)
      {false, options1}  -> {Enum.reverse(item_lines), input, options1)
    end
  end


  defp _still_in_list?(line, list_info)
  defp _still_in_list?(line, {pending: @not_pending}=list_info) do
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

  defp _still_in_np_list?(line, list_info)

end
