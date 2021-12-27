              defmodule EarmarkParser.Parser.ListParser do
  alias EarmarkParser.{Block, Line, Options, Parser.ListInfo}

  import EarmarkParser.Helpers.StringHelpers, only: [behead: 2]
  import EarmarkParser.Helpers.LookaheadHelpers
  import EarmarkParser.Parser.Helper
  import EarmarkParser.Message, only: [add_message: 2]

  @moduledoc false

  # @not_pending {nil, 0}

  def parse_list([%Line.ListItem{} = li | rest], result, options \\ %Options{}, continue_list \\ nil) do
    list = continue_list || Block.List.new(li)
    new_input = [EarmarkParser.LineScanner.type_of({li.content, li.lnb}, false) | rest]

    {rest1, header_block, options1} =
      parse_up_to({new_input, list, [], options}, &_parse_header/1, &_end_of_header?/1)
      |> IO.inspect(label: :header)

    {rest2, list, lines, options2} =
      parse_up_to({rest1, list, [], options1}, &_parse_body/1, &_end_of_body?/1)

    # TODO: Update footnotes and links
    {blocks, _, _, options3} = EarmarkParser.Parser.parse_lines(lines, options2, :list)

    # IO.inspect(blocks, label: :parsed_body_blocks)
    # IO.inspect((list2.blocks |> hd).blocks, label: :old_blocks)
    # TODO: Return old_blocks above so that we do not need to extract them here!!!
    list_item = Block.ListItem.new(list, [header_block|blocks])
    list_ = %{list | blocks: [list_item|list.blocks]}

    if _continues_list?(list_, rest2) do
      parse_list(rest2, result, options3, list_)
    else
      {[list_ | result], rest2, options3}
    end

    # # Now I want {list, rest, options}
    # {header, list1, rest, options1} = parse_list_item_header(new_input, list, options)
    # {list_, rest_, options_} = parse_list_items( |> IO.inspect(), options )

    # {items, rest, options1} = parse_list_items(lines |> IO.inspect() , options)

    # list                    = _make_list(items, _empty_list(items) )
    # {[list|result], rest, options1}
  end

  defp _continues_list?(list, lines)
  defp _continues_list?(%Block.List{}, []), do: false
  defp _continues_list?(%Block.List{}=list, [%Line.ListItem{}=li|_]), do: _continues_list_li?(list, li)
  defp _continues_list?(%Block.List{}, _), do: false

  defp _continues_list_li?(list, li)
  defp _continues_list_li?(%{indent: list_indent}, %{indent: item_indent})
    when list_indent > item_indent, do: false
  defp _continues_list_li?(%{bullet: list_bullet}, %{bullet: item_bullet})
    when list_bullet != item_bullet, do: false
  defp _continues_list_li?(_, _), do: true

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
          )}
        )

      _ ->
        # TODO: Need to update state for pending:
        {:continue, state}
    end
  end

  defp _end_of_body?({[], _, _, _} = state) do
    _finish_body(state)
  end

  defp _end_of_body?(
         {[%{indent: current_indent} | _] = input, %Block.List{indent: list_indent}, _result,
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

    {:continue, state}
  end

  defp _end_of_header?({input, list, result, options} = state) do
    rest =
      case input do
        [] -> []
        [%Line.Blank{} | rest] -> rest
        [%Line.Ruler{} | rest] -> rest
        _ -> nil
      end

    if rest do
      _finish_header(rest, list, result, options)
    else
        # TODO: Need to update state with potential new pending meaning we need to
        # call opens_inline_code
      {:continue, state}
    end
  end

  defp _finish_header(rest, list, result, options) do
    result_ = result |> Enum.reverse()
    text = %Block.Text{line: result_, lnb: list.lnb}
    {:halt, {rest, text, options}}
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

  # def parse_list_item_header(input, list, options) do
  #   _parse_list_item_header(input, list, [], options)
  # end

  # defp _parse_list_item_header(input, list, result, options)
  # defp _parse_list_item_header([], list, result, options) do
  #   {result, list, [], options}
  # end
  # defp _parse_list_item_header([line|rest], list, result, options) do
  # end

  # def parse_list_items(input, options) do
  #   parse_list_items(:init, input, [], options)
  # end

  # # TODO: Rename `ctxt` into `options`
  # defp parse_list_items(state, input, output, ctxt) do
  #   _parse_list_items(state, input, output, ctxt)
  # end

  # defp _parse_list_items(state, input, output, ctxt)
  # defp _parse_list_items(:init, [item|rest], list_items, options) do
  #   options1 = %{options|line: item.lnb}
  #   parse_list_items(:start, rest, _make_and_prepend_list_item(item, list_items), %Ctxt{lines: [item.content], list_info: ListInfo.new(item), options: options1})
  # end
  # defp _parse_list_items(:end, rest, items, ctxt), do: {items, rest, ctxt.options}
  # defp _parse_list_items(:start, rest, items, ctxt), do: _parse_list_items_start(rest, items, ctxt)
  # defp _parse_list_items(:spaced?, rest, items, ctxt), do: _parse_list_items_spaced?(rest, items, ctxt)

  # defp _parse_list_items_spaced?(input, items, ctxt)
  # defp _parse_list_items_spaced?(input, items, %{list_info: %{pending: @not_pending}}=ctxt) do
  #   _parse_list_items_spaced_np(input, items, ctxt)
  # end
  # defp _parse_list_items_spaced?(input, items, ctxt) do
  #   _parse_list_items_spaced_pdg(input, items, ctxt)
  # end

  # defp _parse_list_items_spaced_np([%Line.Blank{}|rest], items, ctxt) do
  #   parse_list_items(:spaced?, rest, items, ctxt)
  # end
  # defp _parse_list_items_spaced_np([%Line.Ruler{}|_]=lines, items, ctxt) do
  #   _finish_list_items(lines, items, false, ctxt)
  # end
  # defp _parse_list_items_spaced_np([%Line.ListItem{indent: ii}=item|_]=input, list_items, %{list_info: %{width: w}}=ctxt)
  #   when ii < w do
  #     if _starts_list?(item, list_items) do
  #       _finish_list_items(input, list_items, false, ctxt)
  #     else
  #       {items1, options1} = _finish_list_item(list_items, false, _loose(ctxt))
  #       parse_list_items(:init, input, items1, options1)
  #     end
  # end
  # defp _parse_list_items_spaced_np([%Line.Indent{indent: ii}=item|rest], list_items, %{list_info: %{width: w}}=ctxt)
  #   when ii >= w do
  #     indented = _behead_spaces(item.line, w)
  #     parse_list_items(:spaced?, rest, list_items, _update_ctxt(ctxt, indented, item, true))
  # end
  # defp _parse_list_items_spaced_np([%Line.ListItem{}=line|rest], items, ctxt) do
  #   indented = _behead_spaces(line.line, ctxt.list_info.width)
  #   parse_list_items(:spaced?, rest, items, _update_ctxt(ctxt, indented, line))
  # end
  # # BUG: Still do not know how much to indent here???
  # defp _parse_list_items_spaced_np([%{indent: indent, line: str_line}=line|rest], items, %{list_info: %{width: width}}=ctxt) when
  #   indent >= width
  # do
  #   parse_list_items(:spaced?, rest, items, _update_ctxt(ctxt, behead(str_line, width), line, true))
  # end
  # defp _parse_list_items_spaced_np(input, items, ctxt) do
  #   _finish_list_items(input ,items, false, ctxt)
  # end

  # defp _parse_list_items_spaced_pdg(input, items, ctxt)
  # defp _parse_list_items_spaced_pdg([], items, %{list_info: %{pending: {pending, lnb}}}=ctxt) do
  #   options1 =
  #     add_message(ctxt.options, {:warning, lnb, "Closing unclosed backquotes #{pending} at end of input"})
  #   _finish_list_items([], items, false, %{ctxt| options: options1})
  # end
  # defp _parse_list_items_spaced_pdg([line|rest], items, ctxt) do
  #   indented = _behead_spaces(line.line, ctxt.list_info.width)
  #   parse_list_items(:spaced?, rest, items, _update_ctxt(ctxt, indented, line))
  # end

  # defp _parse_list_items_start(input, list_items, ctxt)
  # defp _parse_list_items_start(input, list_items, %{list_info: %{pending: @not_pending}}=ctxt) do
  #   _parse_list_items_start_np(input, list_items, ctxt)
  # end
  # defp _parse_list_items_start(input, list_items, ctxt) do
  #   _parse_list_items_start_pdg(input, list_items, ctxt)
  # end

  # defp _parse_list_items_start_np(input, list_items, ctxt)
  # defp _parse_list_items_start_np([%Line.Blank{}|input], items, ctxt) do
  #   parse_list_items(:spaced?, input, items, _prepend_line(ctxt, ""))
  # end
  # defp _parse_list_items_start_np([], list_items, ctxt) do
  #   _finish_list_items([], list_items, true, ctxt)
  # end
  # defp _parse_list_items_start_np([%Line.Ruler{}|_]=input, list_items, ctxt) do
  #   _finish_list_items(input, list_items, true, ctxt)
  # end
  # defp _parse_list_items_start_np([%Line.ListItem{indent: ii}=item|_]=input, list_items, %{list_info: %{ width: w}}=ctxt)
  #   when ii < w do
  #     if _starts_list?(item, list_items) do
  #       _finish_list_items(input, list_items, true, ctxt)
  #     else
  #       {items1, options1} = _finish_list_item(list_items, true, ctxt)
  #       parse_list_items(:init, input, items1, options1)
  #     end
  # end
  # # Slurp in everything else before a first blank line
  # defp _parse_list_items_start_np([%{line: str_line}=line|rest], items, ctxt) do
  #   indented = _behead_spaces(str_line, ctxt.list_info.width)
  #   parse_list_items(:start, rest, items, _update_ctxt(ctxt, indented, line))
  # end

  # defp _parse_list_items_start_pdg(input, items, ctxt)
  # defp _parse_list_items_start_pdg([], items, ctxt) do
  #   _finish_list_items([], items, true, ctxt)
  # end
  # defp _parse_list_items_start_pdg([line|rest], items, ctxt) do
  #   parse_list_items(:start, rest, items, _update_ctxt(ctxt, line.line, line))
  # end

  # defp _behead_spaces(str, len) do
  #   Regex.replace(~r/\A\s{1,#{len}}/, str, "")
  # end

  # INLINE CANDIDATE
  defp _empty_list([%Block.ListItem{loose?: loose?, type: type} | _]) do
    %Block.List{loose?: loose?, type: type}
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

  # INLINE CANDIDATE
  # defp _finish_list_item([%Block.ListItem{}=item|items], _at_start?, ctxt) do
  #   {blocks, _, _, options1} = ctxt.lines
  #                           |> Enum.reverse
  #                           |> EarmarkParser.Parser.parse(ctxt.options, :list)
  #   loose1? = _already_loose?(items) || ctxt.loose?
  #   {[%{item | blocks: blocks, loose?: loose1?}|items], options1}
  # end

  # defp _finish_list_items(input, items, at_start?, ctxt) do
  #   {items1, options1} = _finish_list_item(items, at_start?, ctxt)
  #   parse_list_items(:end, input, items1, %{ctxt|options: options1})
  # end

  # # INLINE CANDIDATE
  # defp _make_and_prepend_list_item(%Line.ListItem{bullet: bullet, lnb: lnb, type: type}, list_items) do
  #   [%Block.ListItem{bullet: bullet, lnb: lnb, spaced?: false, type: type}|list_items]
  # end

  # defp _make_list(items, list)
  # defp _make_list([%Block.ListItem{bullet: bullet, lnb: lnb}=item], %Block.List{loose?: loose?}=list) do
  #   %{list | blocks: [%{item | loose?: loose?}|list.blocks],
  #     bullet: bullet,
  #     lnb: lnb,
  #     start: _extract_start(item)}
  # end
  # defp _make_list([%Block.ListItem{}=item|rest], %Block.List{loose?: loose?}=list) do
  #  _make_list(rest, %{list | blocks: [%{item | loose?: loose?}|list.blocks]})
  # end

  # # INLINE CANDIDATE
  # defp _already_loose?(items)
  # defp _already_loose?([]), do: false # Can this happen?
  # defp _already_loose?([%{loose?: loose?}|_]), do: loose?

  # # INLINE CANDIDATE
  # defp _loose(ctxt), do: %{ctxt| loose?: true}

  # # INLINE CANDIDATE
  # defp _prepend_line(%Ctxt{lines: lines}=ctxt, line) do
  #   %{ctxt|lines: [line|lines]}
  # end

  # defp _starts_list?(line_list_item, list_items)
  # defp _starts_list?(_item, []), do: true
  # defp _starts_list?(%{bullet: bullet1}, [%Block.ListItem{bullet: bullet2}|_]) do
  #   String.last(bullet1) != String.last(bullet2)
  # end

  # defp _update_ctxt(ctxt, line, pending_line, loose? \\ false)
  # defp _update_ctxt(ctxt, nil, pending_line, loose?), do: %{ctxt | list_info: _update_list_info(ctxt.list_info, pending_line), loose?: loose?}
  # defp _update_ctxt(ctxt, line, pending_line, loose?) do
  #   %{_prepend_line(ctxt, line) | list_info: _update_list_info(ctxt.list_info, pending_line), loose?: loose?}
  # end

  # # INLINE CANDIDATE
  # defp _update_list_info(%{pending: pending}=list_info, line) do
  #   pending1 = still_inline_code(line, pending)
  #   %{list_info | pending: pending1}
  # end
end
