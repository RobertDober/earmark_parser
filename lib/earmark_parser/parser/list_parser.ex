defmodule EarmarkParser.Parser.ListParser do
  alias EarmarkParser.{Block, Enum.Ext, Line, LineScanner, Options}

  import EarmarkParser.Helpers.StringHelpers, only: [behead: 2]
  import EarmarkParser.Parser.Helper
  import EarmarkParser.Message, only: [add_message: 2]

  @moduledoc false

  def parse_list(
        [%Line.ListItem{} = li | rest],
        result,
        options \\ %Options{},
        continue_list \\ nil
      ) do
    {rest1, header_block, has_body?, list, options1} =
      _parse_list_header(rest, li, continue_list, options)

    {rest2, list1, body_lines, options2} =
      if has_body? do
        parse_up_to({rest1, list, [], options1}, &_parse_body/1, &_end_of_body?/1)
      else
        {rest1, list, [], options1}
      end

    {continues_list?, list2, options3} =
      _parse_list_body(rest2, body_lines, header_block, has_body?, li, list1, options2)

    if continues_list? do
      parse_list(rest2, result, options3, list2)
    else
      {[_reverse_list_items(list2) | result], rest2, options3}
    end
  end

  # Helper Parsers {{{
  # {{{{
  defp _parse_list_body(rest, body_lines, header_block, has_body?, li, list, options) do
    {body_blocks, _, _, options1} = EarmarkParser.Parser.parse_lines(body_lines, options, :list)

    continues_list? = _continues_list?(li, rest)
    loose? = has_body? && (!Enum.empty?(body_lines) || continues_list?)
    list_item = Block.ListItem.new(list, header_block ++ body_blocks)
    IO.inspect(list)

    list1 = %{list | blocks: [list_item | list.blocks], loose?: list.loose? || loose?}
    {continues_list?, list1, options1}
  end
  # }}}}

  # {{{{
  defp _parse_list_header(rest, li, continue_list, options) do
    list = continue_list || Block.List.new(li)

    {rest1, has_body?, header_content, options1} =
      parse_up_to(
        {rest, Block.List.update_pending_state(list, li), [li.content], options},
        &_parse_header/1,
        &end_of_header?/1
      )

    {header_block, _, _, _options} = EarmarkParser.Parser.parse(header_content, options1, :list)
    {rest1, header_block, has_body?, list, options1}
  end

  # }}}}
  # }}}

  # Continues List? {{{
  # {{{{
  defp _continues_list?(list, lines)
  defp _continues_list?(%Line.ListItem{}, []), do: false

  defp _continues_list?(%Line.ListItem{} = li_before, [%Line.ListItem{} = li | _]),
    do: _continues_list_li?(li_before, li)

  defp _continues_list?(%Line.ListItem{}, _), do: false
  # }}}}

  # {{{{
  defp _continues_list_li?(list, li)

  defp _continues_list_li?(%{indent: before_indent}, %{indent: item_indent})
       when before_indent > item_indent,
       do: false

  @numbered_bullet_rgx ~r{\A0*(\d+)[\.)]}
  defp _continues_list_li?(%{bullet: before_bullet}, %{bullet: item_bullet}) do
    if Regex.match?(@numbered_bullet_rgx, before_bullet) do
      Regex.match?(@numbered_bullet_rgx, item_bullet)
    else
      before_bullet == item_bullet
    end
  end

  # }}}}
  # }}}

  # Parsing body {{{
  # {{{{
  defp _end_of_body?(state)

  defp _end_of_body?({input, %{pending: {pending, lnb}} = list, result, options} = state)
       when pending != nil do
    case input do
      [] ->
        _finish_body({
          [],
          list,
          result,
          add_message(
            options,
            {:warning, lnb, "Closing unclosed backquotes #{pending} at end of input"}
          )
        })

      _ ->
        {:continue, state}
    end
  end

  defp _end_of_body?({[], _, _, _} = state) do
    _finish_body(state)
  end

  defp _end_of_body?({[%Line.Blank{} | _], _list, _result, _options} = state) do
    {:continue, state}
  end

  defp _end_of_body?({[%Line.Heading{} | _], _list, _result, _options} = state) do
    _finish_body(state)
  end

  defp _end_of_body?(
         {[%{indent: current_indent} | _], %Block.List{indent: list_indent}, _result, _options} =
           state
       )
       when current_indent < list_indent do
    _finish_body(state)
  end

  defp _end_of_body?(state) do
    {:continue, state}
  end

  # }}}}
  # {{{{
  defp _finish_body({rest, list, result, options}) do
    {:halt, {rest, list, Enum.reverse(result) |> Enum.drop_while(&Line.blank?/1), options}}
  end

  # }}}}
  # {{{{
  defp _parse_body({[line | rest], list, result, options}) do
    text = behead(line.line, list.indent)
    line1 = EarmarkParser.LineScanner.type_of({text, line.lnb}, false)
    {rest, list, [line1 | result], options}
  end

  # }}}}
  # }}}

  defp end_of_header?(state) do
    # IO.inspect(state)
    _end_of_header?(state)
  end

  # _end_of_header? {{{{
  defp _end_of_header?(state)

  defp _end_of_header?({input, %{pending: {pending, lnb}} = list, result, options} = state)
       when pending != nil do
    case input do
      [] ->
        _finish_header(
          [],
          false,
          list.indent,
          result,
          add_message(
            options,
            {:warning, lnb, "Closing unclosed backquotes #{pending} at end of input"}
          )
        )

      _ ->
        {:continue, state}
    end
  end

  defp _end_of_header?({[], list, result, options}) do
    _finish_header([], false, list.indent, result, options)
  end

  defp _end_of_header?({[%Line.Blank{} | rest], list, result, options}) do
    _finish_header(rest, true, list.indent, result, options)
  end

  defp _end_of_header?({[%Line.ListItem{indent: current_indent}|_]=input, %{indent: list_indent}, result, options})
    when current_indent >= list_indent and current_indent < list_indent + 4 do
      _finish_header(input, true, list_indent, result, options)
  end

  defp _end_of_header?({[%{indent: current_indent} | _], %{indent: list_indent}, _, _} = state)
       when current_indent >= list_indent do
    {:continue, state}
  end

  defp _end_of_header?({[%Line.BlockQuote{} | _] = rest, list, result, options}) do
    _finish_header(rest, false, list.indent, result, options)
  end

  defp _end_of_header?({[%Line.Heading{} | _] = rest, list, result, options}) do
    _finish_header(rest, false, list.indent, result, options)
  end

  defp _end_of_header?({[%Line.Ruler{} | _] = rest, list, result, options}) do
    _finish_header(rest, false, list.indent, result, options)
  end

  defp _end_of_header?({[%Line.ListItem{} | _] = rest, list, result, options}) do
    _finish_header(rest, false, list.indent, result, options)
  end

  defp _end_of_header?(state) do
    {:continue, state}
  end

  # }}}}

  defp _finish_header(rest, has_body?, indent, result, options) do
    {result_, _} = Ext.reverse_map_reduce(result, nil, &_maybe_indent(&1, &2, indent))
    {:halt, {rest, has_body?, result_, options}}
  end

  defp _maybe_indent(line, fence_delimiter, indent) do
    if fence_delimiter do
      # check if we have matching delimiter  -> {beheaded, nil}
      if LineScanner.fence_delimiter(line) == fence_delimiter do
        {_behead_spaces(line, indent), nil}
      else
        {line, fence_delimiter}
      end
    else
      case LineScanner.fence_delimiter(line) do
        nil -> {_behead_spaces(line, indent), nil}
        fence_delimiter -> {_behead_spaces(line, indent), fence_delimiter}
      end
    end
  end

  # _parse_header {{{{
  defp _parse_header({[line | rest], list, result, options}) do
    new_result = [line.line | result]
    {rest, Block.List.update_pending_state(list, line), new_result, options}
  end

  # }}}}
  # }}}

  # Helpers {{{
  defp _behead_spaces(str, n)
  defp _behead_spaces(" " <> rst, n) when n > 0, do: _behead_spaces(rst, n - 1)
  defp _behead_spaces(str, _n), do: str

  defp _reverse_list_items(%Block.List{blocks: list_items} = list) do
    %{list | blocks: _reverse_list_items_and_losen(list_items, [], list.loose?)}
  end

  # _reverse_list_items_and_losen
  defp _reverse_list_items_and_losen(list_items, result, list_loose?)
  defp _reverse_list_items_and_losen([], result, _list_loose?), do: result

  defp _reverse_list_items_and_losen([li | rest], result, list_loose?) do
    _reverse_list_items_and_losen(
      rest,
      [%{li | loose?: li.loose? || list_loose?} | result],
      list_loose?
    )
  end
end

#  SPDX-License-Identifier: Apache-2.0
