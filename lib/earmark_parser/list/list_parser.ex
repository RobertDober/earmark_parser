defmodule EarmarkParser.List.ListParser do
  use EarmarkParser.Types
  alias EarmarkParser.Line
  alias EarmarkParser.List.{ListInfo, ListReader}
  alias EarmarkParser.Block.{Blank, List, ListItem}

  import EarmarkParser.Helpers.StringHelpers, only: [behead_indent: 2]

  @moduledoc false

  # @spec parse_list(Lines, Blocks, Option) :: {[List|Blocks], Lines, Option}
  def parse_list([%Line.ListItem{} = line | _] = input, result, options) do
    list_info = ListInfo.new(line)
    {list, rest, options1} = parse_list_items(input, [], list_info, options)
    {[list | result], rest, options1}
  end

  # @spec parse_list_items(Lines, Blocks, ListInfo, Option) :: {List, Lines, Option}
  def parse_list_items(input, items, list_info, options) do
    {list_item, rest, options1} = parse_list_item(input, list_info, options)
    items1 = [list_item | items]

    case input_continues_list?(input, list_info) do
      {true, list_info1} -> parse_list_items(rest, items1, list_info1, options1)
      _ -> {List.new(items1, list_info), rest, options1}
    end
  end

  # @spec parse_list_item(Lines, [Line], ListInfo, Options.t) :: {ListItem, Lines, Option}
  def parse_list_item([%Line.ListItem{} = line | _] = input, list_info, options) do
    # Make a new list Item
    {item_lines, rest, options1} = ListReader.read_list_item(input, [], list_info, options)
    {list_item_blocks, options2} = parse_list_item_lines(item_lines, list_info, options1)

    {ListItem.new(line, blocks: list_item_blocks), rest, options2}
  end

  defp parse_list_item_lines(lines, list_info, options)

  defp parse_list_item_lines(lines, %ListInfo{width: width}, options) do
    {blocks, context} =
      lines
      |> Enum.map(&behead_ws_content(&1, width))
      |> EarmarkParser.Parser.parse_markdown(options)

    {blocks, context.options}
  end

  @spec input_continues_list?( Line.ts, ListInfo.t ) :: maybe({true, ListInfo.t})
  defp input_continues_list?(input, list_info)

  defp input_continues_list?([%Line.ListItem{}|_], list_info), do: {true, list_info}

  defp input_continues_list?(_, _), do: nil

  defp behead_ws_content(%{content: content}, width) do
    behead_indent(content, width)
  end

end
