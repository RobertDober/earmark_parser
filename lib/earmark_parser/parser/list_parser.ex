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
    new_input = [EarmarkParser.LineScanner.type_of({li.content, li.lnb}, false) | rest]

    {rest1, has_body?, header_block, options1} =
      parse_up_to({new_input, list, [], options}, &_parse_header/1, &_end_of_header?/1)

    {rest2, list2, body_lines, options2} =
      if has_body? do
        parse_up_to({rest1, list, [], options1}, &_parse_body/1, &_end_of_body?/1)
      else
        {rest1, list, [], options1}
      end

    # TODO: Update footnotes and links
    {body_blocks, _, _, options3} = EarmarkParser.Parser.parse_lines(body_lines, options2, :list)

    continues_list? = _continues_list?(list2, rest2)
    loose? = has_body? && (!Enum.empty?(body_lines) || continues_list?)
    list_item = Block.ListItem.new(%{list|loose?: loose?}, [header_block | body_blocks])


    list3 = %{list2 | blocks: [list_item | list.blocks], loose?: loose?}

    if continues_list? do
      parse_list(rest2, result, options3, list3)
    else
      {[list3 | result], rest2, options3}
    end
  end

  # _continues_list?
  defp _continues_list?(list, lines)
  defp _continues_list?(%Block.List{}, []), do: false

  defp _continues_list?(%Block.List{} = list, [%Line.ListItem{} = li | _]),
    do: _continues_list_li?(list, li)

  defp _continues_list?(%Block.List{}, _), do: false

  defp _continues_list_li?(list, li)

  defp _continues_list_li?(%{indent: list_indent}, %{indent: item_indent})
       when list_indent > item_indent,
       do: false

  defp _continues_list_li?(%{bullet: list_bullet}, %{bullet: item_bullet})
       when list_bullet != item_bullet,
       do: false

  defp _continues_list_li?(_, _), do: true

  # _end_of_body?
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

  defp _end_of_header?(state)

  defp _end_of_header?({input, %{pending: {pending, lnb}} = list, result, options} = state)
       when pending != nil do
    case input do
      [] ->
        _finish_header(
          [],
          false,
          list.lnb,
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

  defp _end_of_header?({[], list, result, options}) do
    _finish_header([], false, list.lnb, result, options)
  end

  defp _end_of_header?({[%Line.Blank{}|rest], list, result, options}) do
    _finish_header(rest, true, list.lnb, result, options)
  end
  defp _end_of_header?({[%Line.Ruler{}|_]=rest, list, result, options}) do
    _finish_header(rest, false, list.lnb, result, options)
  end
  defp _end_of_header?({[%Line.ListItem{}|_]=rest, list, result, options}) do
    _finish_header(rest, false, list.lnb, result, options)
  end

  defp _end_of_header?({input, list, result, options} = state) do
    # TODO: Need to update state with potential new pending meaning we need to
    # call opens_inline_code
    {:continue, state}
  end

  defp _finish_header(rest, has_body?, lnb, result, options) do
    result_ = result |> Enum.reverse()
    text = %Block.Text{line: result_, lnb: lnb}
    {:halt, {rest, has_body?, text, options}}
  end

  defp _finish_body({rest, list, result, options}) do
    {:halt, {rest, list, Enum.reverse(result), options}}
  end

  defp _parse_body({[line | rest], list, result, options}) do
    # TODO: Check for pending
    # TODO: Add loose? ?
    text = behead(line.line, list.indent)
    line1 = EarmarkParser.LineScanner.type_of({text, line.lnb}, false)
    {rest, list, [line1 | result], options}
  end

  defp _parse_header({[line | rest], list, result, options}) do
    # TODO: Check for pending
    new_result = [line.content | result]
    {rest, list, new_result, options}
  end

  # INLINE CANDIDATE
  @start_number_rgx ~r{\A0*(\d+)\.}
  defp _extract_start(%{bullet: bullet}) do
    case Regex.run(@start_number_rgx, bullet) do
      nil -> ""
      [_, "1"] -> ""
      [_, start] -> ~s{ start="#{start}"}
    end
  end
end

#  SPDX-License-Identifier: Apache-2.0
