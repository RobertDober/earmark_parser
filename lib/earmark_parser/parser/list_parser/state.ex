defmodule EarmarkParser.Parser.ListParser.State do
  alias EarmarkParser.Options

  @moduledoc ~S"""
  Internal state while parsing list items
  """

  defstruct body_lines: [],
            continues_list?: false,
            has_body?: false,
            header_block: nil,
            header_content: [],
            list: nil,
            list_item: nil,
            pending: {nil, 0},
            options: %Options{},
            rest_to_parse: [],
            result: [],
            spaced?: false

  def reset_for_next_item(%__MODULE__{} = state) do
    %{state | continues_list?: false, has_body?: false, header_block: nil, result: [], spaced?: false}
  end

  def dbg(%__MODULE__{}=state, verb \\ 0) do
    result = %{body_lines: state.body_lines, continues_list: state.continues_list?, has_body?: state.has_body?, header_block: state.header_block,
     header_content: state.header_content}
   result_ = if verb > 0 do
     Map.merge(result, %{list: state.list, list_item: state.list_item, rest_to_parse: state.rest_to_parse})
   else
     result
   end

    IO.inspect result_
    state
  end

end
#  SPDX-License-Identifier: Apache-2.0
