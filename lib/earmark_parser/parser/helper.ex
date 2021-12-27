defmodule EarmarkParser.Parser.Helper do
  @moduledoc ~S"""
  Implements HO parser functions
  """

  def parse_up_to(parse_state, parser_fn, terminator_fn) do
    case terminator_fn.(parse_state) do
      {:continue, state_} -> parse_up_to(parser_fn.(state_), parser_fn, terminator_fn)
      {:halt, state_} -> state_
      # {:error, message} -> raise message
    end
  end

end
#  SPDX-License-Identifier: Apache-2.0
