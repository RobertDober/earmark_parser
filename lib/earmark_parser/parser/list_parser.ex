defmodule EarmarkParser.Parser.ListParser do
  alias EarmarkParser.{Block, Line, Options, Parser.ListInfo}

  import EarmarkParser.Helpers.StringHelpers, only: [behead: 2]
  import EarmarkParser.Helpers.LookaheadHelpers
  import EarmarkParser.Parser.Helper
  import EarmarkParser.Message, only: [add_message: 2]

  @moduledoc false

  # @not_pending {nil, 0}

  # TODO: Heavy Refactoring Needed
  def parse_list(
        [%Line.ListItem{} = li | rest],
        result,
        options \\ %Options{},
        continue_list \\ nil
      ) do
    list = continue_list || Block.List.new(li)

    # IO.inspect(list.indent)
    # IO.inspect(rest)
    {rest1, has_body?, header_content, options1} =
      parse_up_to({rest, list, [li.content], options}, &_parse_header/1, &end_of_header?/1)

    # IO.inspect(header_content)
    {header_block, _, _, options1_} = EarmarkParser.Parser.parse(header_content, options1, :list)

    {rest2, list2, body_lines, options2} =
      if has_body? do
        parse_up_to({rest1, list, [], options1_}, &_parse_body/1, &_end_of_body?/1)
      else
        {rest1, list, [], options1}
      end


    # TODO: Update footnotes and links
    {body_blocks, _, _, options3} = EarmarkParser.Parser.parse_lines(body_lines, options2, :list)

    continues_list? = _continues_list?(li, rest2)
    loose? = has_body? && (!Enum.empty?(body_lines) || continues_list?)
    list_item = Block.ListItem.new(list, header_block ++ body_blocks)


    list3 = %{list2 | blocks: [list_item | list.blocks], loose?: list2.loose? || loose?}

    if continues_list? do
      parse_list(rest2, result, options3, list3)
    else
      {[_reverse_list_items(list3) | result], rest2, options3}
    end
  end

  # Continues List? {{{
  defp _continues_list?(list, lines) # {{{{
  defp _continues_list?(%Line.ListItem{}, []), do: false

  defp _continues_list?(%Line.ListItem{} = li_before, [%Line.ListItem{} = li | _]),
    do: _continues_list_li?(li_before, li)

  defp _continues_list?(%Line.ListItem{}, _), do: false
  # }}}}

  defp _continues_list_li?(list, li) # {{{{

  defp _continues_list_li?(%{indent: before_indent}, %{indent: item_indent})
       when before_indent > item_indent,
       do: false

  defp _continues_list_li?(%{bullet: before_bullet}, %{bullet: item_bullet})
       when before_bullet != item_bullet,
       do: false

  defp _continues_list_li?(_, _), do: true
  # }}}}
  # }}}

  # Parsing body {{{
  defp _end_of_body?(state) # {{{{

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
        # TODO: Need to update state for pending:
        {:continue, state}
    end
  end

  defp _end_of_body?({[], _, _, _} = state) do
    _finish_body(state)
  end

  defp _end_of_body?({[%Line.Blank{}|_], _list, _result, _options} = state) do
     {:continue, state}
  end
  defp _end_of_body?({[%Line.Heading{}|_], _list, _result, _options} = state) do
    _finish_body(state)
  end

  defp _end_of_body?(
         {[%{indent: current_indent}| _] = input, %Block.List{indent: list_indent}, _result,
          _options} = state
       )
       when current_indent < list_indent do
    _finish_body(state)
  end

  defp _end_of_body?(state) do
    # TODO: Need to update state for pending:
    {:continue, state}
  end
  # }}}}
  defp _finish_body({rest, list, result, options}) do # {{{{
    {:halt, {rest, list, Enum.reverse(result), options}}
  end
  # }}}}
  defp _parse_body({[line | rest], list, result, options}) do # {{{{
    # TODO: Check for pending
    # TODO: Add loose? ?
    text = behead(line.line, list.indent)
    line1 = EarmarkParser.LineScanner.type_of({text, line.lnb}, false)
    {rest, list, [line1 | result], options}
  end
  # }}}}

  # }}}

  # Parsing header {{{
  # _end_of_header? {{{{
  defp _end_of_header?(state)

  defp _end_of_header?({input, %{pending: {pending, lnb}} = list, result, options} = state)
       when pending != nil do
    case input do
      [] ->
        _finish_header(
          [],
          false,
          list,
          result,
          add_message(
            options,
            {:warning, lnb, "Closing unclosed backquotes #{pending} at end of input"}
          )
        )

      _ ->
        # TODO: Need to update state with potential new pending meaning we need to
        # call still_inline_code
        {:continue, state}
    end
  end

  # TODO: Remove me
  defp end_of_header?(state) do
    # IO.inspect(state)
    _end_of_header?(state)
  end

  defp _end_of_header?({[], list, result, options}) do
    _finish_header([], false, list.indent, result, options)
  end

  defp _end_of_header?({[%Line.Blank{}|rest], list, result, options}) do
    _finish_header(rest, true, list.indent, result, options)
  end
  defp _end_of_header?({[%{indent: current_indent}|_], %{indent: list_indent}, _, _}=state)
    when current_indent >= list_indent do
      {:continue, state}
    end
  defp _end_of_header?({[%Line.BlockQuote{}|_]=rest, list, result, options}) do
    _finish_header(rest, false, list.indent, result, options)
  end
  defp _end_of_header?({[%Line.Heading{}|_]=rest, list, result, options}) do
    _finish_header(rest, false, list.indent, result, options)
  end
  defp _end_of_header?({[%Line.Ruler{}|_]=rest, list, result, options}) do
    _finish_header(rest, false, list.indent, result, options)
  end
  defp _end_of_header?({[%Line.ListItem{}|_]=rest, list, result, options}) do
    _finish_header(rest, false, list.indent, result, options)
  end

  defp _end_of_header?({input, list, result, options} = state) do
    # TODO: Need to update state with potential new pending meaning we need to
    # call opens_inline_code
    {:continue, state}
  end
  # }}}}

  defp _finish_header(rest, has_body?, indent, result, options) do
    result_ = _indent_and_reverse(result, [], indent)
    {:halt, {rest, has_body?, result_, options}}
  end

  # TODO: Replace with reverse_map
  defp _indent_and_reverse(input, result, indent)
  defp _indent_and_reverse([], result, _indent), do: result
  defp _indent_and_reverse([fst|rst], result, indent), do: _indent_and_reverse(rst, [_behead_spaces(fst, indent)|result], indent)

  # _parse_header {{{{
  defp _parse_header({[line | rest], list, result, options}) do
    # TODO: Check for pending
    new_result = [line.line | result]
    {rest, list, new_result, options}
  end
  # }}}}
  # }}}

  # Helpers {{{
  defp _behead_spaces(str, n)
  defp _behead_spaces(" " <> rst, n) when n > 0, do: _behead_spaces(rst, n-1)
  defp _behead_spaces(str, _n), do: str

  defp _reverse_list_items(%Block.List{blocks: list_items}=list) do
    %{list|blocks: _reverse_list_items_and_losen(list_items, [], list.loose?)}
  end

  # _reverse_list_items_and_losen
  defp _reverse_list_items_and_losen(list_items, result, list_loose?)
  defp _reverse_list_items_and_losen([], result, _list_loose?), do: result
  defp _reverse_list_items_and_losen([li|rest], result, list_loose?) do
    _reverse_list_items_and_losen(rest, [%{li|loose?: li.loose? || list_loose?}|result], list_loose?)
  end

  # @start_number_rgx ~r{\A0*(\d+)\.}
  # defp _extract_start(%{bullet: bullet}) do
  #   case Regex.run(@start_number_rgx, bullet) do
  #     nil -> ""
  #     [_, "1"] -> ""
  #     [_, start] -> ~s{ start="#{start}"}
  #   end
  # end
  #}}}
end
#  SPDX-License-Identifier: Apache-2.0
