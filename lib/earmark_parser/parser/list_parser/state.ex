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
            label: nil,
            list: nil,
            list_item: nil,
            loose?: false,
            pending: {nil, 0},
            options: %Options{},
            rest_to_parse: [],
            result: []

  def tag(%__MODULE__{}=obj, with_tag), do: %{obj|label: with_tag}
end

#  SPDX-License-Identifier: Apache-2.0
