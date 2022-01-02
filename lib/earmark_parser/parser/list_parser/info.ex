defmodule EarmarkParser.Parser.ListParser.Info do
  alias EarmarkParser.Options

  @moduledoc ~S"""
  Internal state while parsing list items
  """

  defstruct header_block: nil,
    has_body?: false,
    list: nil,
    list_item: nil,
    loose?: false,
    pending: {nil, 0},
    options: %Options{},
    rest_to_parse: []

end
#  SPDX-License-Identifier: Apache-2.0
