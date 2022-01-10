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

end
#  SPDX-License-Identifier: Apache-2.0
