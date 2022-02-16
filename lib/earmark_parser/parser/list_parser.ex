defmodule EarmarkParser.Parser.ListParser do
  alias EarmarkParser.{Block, Enum.Ext, Line, LineScanner, Options}
  alias __MODULE__.State

  import EarmarkParser.Helpers.StringHelpers, only: [behead: 2]
  import EarmarkParser.Parser.Helper
  import EarmarkParser.Message, only: [add_message: 2]
  import EarmarkParser.Helpers.LookaheadHelpers, only: [update_inline_code: 2]

  @moduledoc false

  def parse_list(
        [%Line.ListItem{} = li | rest],
        result,
        options
      ) do
        # IO.inspect([li|rest])
    %{list: list, options: options1, rest_to_parse: rest1} =
      _parse_list(%State{
        list: Block.List.new(li),
        list_item: li,
        rest_to_parse: [li | rest],
        options: options
      })

    {[list | result], rest1, options1}
  end

  defp _inner_list?(state)
  defp _inner_list?(%State{has_body?: false}), do: false
  defp _inner_list?(%State{rest_to_parse: [%Line.ListItem{}|_]}), do: true
  defp _inner_list?(_state), do: false

  # Helper Parsers {{{
  # {{{{
  defp _parse_inner_list(state) do
    state_ =
      state
      |> State.reset_for_next_item
      |> _parse_list
    %{state|list: %{state.list|blocks: [state_.list|state.list.blocks]}}
  end

  defp _parse_list(%State{rest_to_parse: [li | rest]} = state) do
    new_state = %{
      state
      | header_content: [li.content],
        pending: update_inline_code(state.pending, li),
        options: %{state.options | line: li.lnb},
        rest_to_parse: rest
    }
    state1 = _parse_list_header(new_state) #|> State.dbg(:state1, 2)

    state2 =
      cond do
        _inner_list?(state1) -> state1 |> _parse_inner_list() |> State.dbg(:after_inner)
        state1.has_body? -> parse_up_to(state1, &_parse_body/1, &end_of_body?/1) # |> State.dbg(:state2, 2)
        true -> state1
      end

    state3 = _parse_list_body(state2)

    if state3.continues_list? do
      state3
      |> State.reset_for_next_item()
      |> _parse_list()
    else
      %{state3 | list: _reverse_list_items(state3.list)}
    end
  end

  # }}}}

  # {{{{
  defp _parse_list_body(
         %State{
           header_block: header_block,
           list: list,
           list_item: li,
           options: options,
           rest_to_parse: rest,
           result: result
         } = state
       ) do
    {body_blocks, _, _, options1} = EarmarkParser.Parser.parse_lines(result, options, :list)

    continues_list? = _continues_list?(li, rest)

    loose? = list.loose? || (state.spaced? && (!Enum.empty?(result) || continues_list?))
    # if loose? do
    # require IEx; IEx.pry
    # end

    list_item = Block.ListItem.new(list, header_block ++ body_blocks)
    list1 = %{list | blocks: [list_item | list.blocks], loose?: list.loose? || loose?}
    %{state | continues_list?: continues_list?, list: list1, options: options1}
  end

  # }}}}

  # {{{{
  defp _parse_list_header(state)

  defp _parse_list_header(%State{list_item: li, pending: pending} = state) do
    new_pending = update_inline_code(pending, li)

    state1 =
      parse_up_to(
        %{state | pending: new_pending},
        &_parse_header/1,
        &end_of_header?/1
      )

    {header_block, _, _, options} =
      EarmarkParser.Parser.parse(state1.header_content, state1.options, :list)

    # IO.inspect(options.messages, label: :after)

    %{state1 | header_block: header_block, options: options}
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
  def end_of_body?(state) do
    # State.dbg(state, :end_of_body?)
    _end_of_body?(state)
  end

  # {{{{
  defp _end_of_body?(state)

  defp _end_of_body?(
         %State{
           pending: {pending, lnb},
           options: options,
           rest_to_parse: input
         } = state
       )
       when pending != nil do
    case input do
      [] ->
        IO.inspect("error #{lnb}", label: :end_of_body?)

        _finish_body(%{
          state
          | options:
              add_message(
                options,
                {:warning, lnb, "Closing unclosed backquotes # at end of input"}
              ),
            rest_to_parse: []
        })

      _ ->
        {:continue, state}
    end
  end

  defp _end_of_body?(%State{rest_to_parse: []} = state) do
    _finish_body(state)
  end

  defp _end_of_body?(
         %State{
           rest_to_parse: {[%Line.Blank{} | _]}
         } = state
       ) do
    {:continue, state}
  end

  defp _end_of_body?(
         %State{
           rest_to_parse: [%Line.Heading{} | _]
         } = state
       ) do
    _finish_body(state)
  end

  defp _end_of_body?(
         %State{
           rest_to_parse: [%{indent: current_indent} | _],
           list: %Block.List{indent: list_indent}
         } = state
       )
       when current_indent < list_indent do
    _finish_body(state)
  end

  defp _end_of_body?(state) do
    {:continue, state}
  end

  # }}}}
  # {{{{
  defp _finish_body(%State{result: result} = state) do
    new_state = %{state | result: Enum.reverse(result) |> Enum.drop_while(&Line.blank?/1)} 
    # |> IO.inspect(label: :finish_body)
    {:halt, new_state}
  end

  # }}}}
  # {{{{
  defp _parse_body(
         %State{
           list: list,
           rest_to_parse: [line | rest],
           result: result
         } = state
       ) do
    text = behead(line.line, list.indent)
    line1 = EarmarkParser.LineScanner.type_of({text, line.lnb}, false)
    %{state | rest_to_parse: rest, result: [line1 | result]}
  end

  # }}}}
  # }}}

  defp end_of_header?(state) do
    # State.dbg(state, :end?, 1)
    _end_of_header?(state)
  end

  # _end_of_header? {{{{
  defp _end_of_header?(state)

  defp _end_of_header?(
         %State{
           options: options,
           pending: {pending, lnb},
           rest_to_parse: input
         } = state
       )
       when pending != nil do
    case input do
      [] ->
        _finish_header(%{
          state
          | has_body?: false,
            options:
              add_message(
                options,
                {:warning, lnb, "Closing unclosed backquotes #{pending} at end of input"}
              ),
            rest_to_parse: []
        })

      _ ->
        {:continue, state}
    end
  end

  defp _end_of_header?(%State{rest_to_parse: []} = state) do
    _finish_header(state)
  end

  defp _end_of_header?(%State{rest_to_parse: [%Line.Blank{} | rest]} = state) do
    _finish_header(%{state | has_body?: true, rest_to_parse: rest, spaced?: true})
  end

  defp _end_of_header?(
         %State{
           list: %{indent: list_indent},
           rest_to_parse: [%Line.ListItem{indent: current_indent} | _]
         } = state
       )
       when current_indent >= list_indent and current_indent < list_indent + 2 do
    _finish_header(%{state | has_body?: true})
  end

  defp _end_of_header?(
         %State{
           list: %{indent: list_indent},
           rest_to_parse: [%Line.ListItem{indent: current_indent} | _]
         } = state
       )
       when current_indent < list_indent do
    _finish_header(state)
  end

  defp _end_of_header?(
         %State{
           list: %{indent: list_indent},
           rest_to_parse: [%{indent: current_indent} | _]
         } = state
       )
       when current_indent >= list_indent do
    {:continue, state}
  end

  defp _end_of_header?(%State{rest_to_parse: [%Line.BlockQuote{} | _]} = state) do
    _finish_header(state)
  end

  defp _end_of_header?(%State{rest_to_parse: [%Line.Heading{} | _]} = state) do
    _finish_header(state)
  end

  defp _end_of_header?(%State{rest_to_parse: [%Line.Ruler{} | _]} = state) do
    require IEx
    IEx.pry()
    _finish_header(state)
  end

  defp _end_of_header?(%State{rest_to_parse: [%Line.ListItem{} | _]} = state) do
    _finish_header(state)
  end

  defp _end_of_header?(state) do
    {:continue, state}
  end

  # }}}}

  defp _finish_header(%State{list: %{indent: indent}, header_content: header_content} = state) do
    {new_header_content, _} =
      Ext.reverse_map_reduce(header_content, nil, &_maybe_indent(&1, &2, indent))

    new_state = %{state | header_content: new_header_content}
    {:halt, new_state}
  end

  # _parse_header {{{{
  defp _parse_header(
         %State{list: list, rest_to_parse: [line | rest], header_content: header_content} = state
       ) do
    new_header_content = [line.line | header_content]

    new_state = %{
      state
      | list: Block.List.update_pending_state(list, line),
        rest_to_parse: rest,
        header_content: new_header_content
    }

    new_state
  end

  # }}}}
  # }}}

  # Helpers {{{
  defp _behead_spaces(str, n)
  defp _behead_spaces(" " <> rst, n) when n > 0, do: _behead_spaces(rst, n - 1)
  defp _behead_spaces(str, _n), do: str

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
