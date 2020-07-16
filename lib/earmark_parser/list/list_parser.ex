defmodule EarmarkParser.List.ListParser do
  alias EarmarkParser.List.{ListInfo, ListReader}
  alias EarmarkParser.Block.{Blank, List, ListItem}

  @moduledoc false

  # @spec parse_list(Line.ts, Block.ts, Options.t) :: {Block.ts, Line.ts, Options.t}
  def parse_list(input, result, options) do
    list_info = ListInfo.new(input)
    {list, rest, options1} = parse_list_items(input, [], list_info, options)
    {[list|result], rest, options1}
  end

  # @spec parse_list_items(Lines, Blocks, ListInfo, Option) :: {%Block.List{}, Lines, Option}
  def parse_list_items(input, items, list_info, options) do
    {list_item, rest, options1} = parse_list_item(input, [], options)
    items1 = [list_item | items]
    if input_continues_list?(input, list_info) do
      parse_list_items(rest, items1, list_info, options1)
    else
      {make_list(items1), rest, options1}
    end
  end

  # @spec parse_list_item(Line.ts, [Line], ListInfo, Options.t) :: {%Block.ListItem{}, Lines, Option}
  def parse_list_item([line|_]=input, item_lines, list_info, options) do
    # Make a new list Item
    list_item = ListItem.new(line)
    {item_lines, rest, options1} = ListReader.read_list_item(input, input_lines, list_info, options)
    parse_list_item_lines(item_lines, list_item, options)
  end

  def parse

  defp parse_list_item_start(input, output, list_info, options)
  defp parse_list_item_start([], output, _list_info, options) do
    {Enum.reverse(output), [], options}
  end

  defp input_continues_list?(input, list_info)
  defp input_continues_list?([%ListItem{}=li|_], list_info), do: list_item_continues_list?(li, list_info)
  defp input_continues_list?(_, _), do: false

end
