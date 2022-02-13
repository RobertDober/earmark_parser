defmodule EarmarkParser.Parser.Helper do
  alias EarmarkParser.{Line, LineScanner}

  @moduledoc ~S"""
  Implements HO parser functions
  """

  def parse_up_to(parse_state, parser_fn, terminator_fn, remove_indent \\ 0) do
    # IO.inspect(parse_state)
    parse_state_ = _remove_indent(parse_state, remove_indent)
    case terminator_fn.(parse_state) do
      {:continue, state_} -> parse_up_to(parser_fn.(state_), parser_fn, terminator_fn)
      {:halt, state_} -> state_
      # {:error, message} -> raise message
    end
  end

  defp _behead_spaces(line, indent)
  defp _behead_spaces(line, 0), do: line
  defp _behead_spaces(" " <> line, indent), do: _behead_spaces(line, indent - 1)
  defp _behead_spaces(line, _indent), do: line

  defp _behead_spaces(line, indent) do
  end
  defp _remove_indent(parse_state, indent)
  defp _remove_indent(%{rest_to_parse: []}=state, _indent), do: state
  defp _remove_indent(%{rest_to_parse: [%{line: line, lnb: lnb}|rest]}=state, indent) do
    line_ = _behead_spaces(line, indent)
    token = LineScanner.type_of({line_, lnb}, true)
    %{state|rest_to_parse: [token|rest]}
  end

end
#  SPDX-License-Identifier: Apache-2.0
