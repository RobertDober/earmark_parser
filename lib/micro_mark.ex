defmodule MicroMark do
  @moduledoc ~S"""
  A POC parser using minipeg and line oriented parsing of a microscopic subset of Markdown
  """

  use MicroMark.Types
  alias MicroMark.{Input, Parser, State}

  @spec parse(binary(), positive(), positive()) :: result()
  def parse(input, lnb \\ 1, col  \\ 1) do
    input
    |> State.new(lnb, col)
    |> Parser.parse
    |> State.result
  end

  # @spec parse_emphasized(binary(), IO.chardata) :: binary()
  # defp parse_emphasized(input, result \\ []) do
  #   case input do
  #     "" -> _make_cont({:error, "missing end of emphasized"}, "")
  #     <<"_", rest::binary>> ->
  #       _make_ast_node(:emphasized, [_string_from_chardata(result)], [], rest) 
  #   end
  # end

  # @spec parse_section(binary(), ast()) :: continuation()
  # defp parse_section(input, result \\ []) do
  #   case input do
  #     "" ->
  #       _make_cont({:error, "empty section"}, "")

  #     _ ->
  #       {content, rest1} = parse_text(input)
  #       _make_ast_node(:section, content, result, rest1)
  #   end
  # end

  # @spec parse_text(binary(), list()) :: continuation()
  # defp parse_text(input, result \\ []) do
  #   case input do
  #     "" -> _make_cont(_string_from_chardata(result), "")
  #     <<"_", rest::binary>> -> _make_cont(_string_from_chardata(result), input)
  #       {emphasized, rest1} = parse_emphasized(rest)
  #       result1 = _string_from_chardata(result)
  #       result2 = _make_ast_node(:emph, emphasized, result1, rest1)
  #       parse_text(rest1, result2)
  #     <<"\n# ", rest::binary>> -> _make_cont(_string_from_chardata(result), "# " <> rest)
  #     <<char::utf8, rest::binary>> -> parse_text(rest, [char | result])
  #   end
  # end

  # @spec _make_ast_node(block_symbol(), binary()|ast(), ast(), binary()) :: continuation()
  # defp _make_ast_node(symbol, content, old_result, rest) do
  #   node = {symbol, List.wrap(content) ++ old_result |>  Enum.reverse}
  #   _make_cont(node, rest)
  # end

  # @spec _make_cont(maybe(ast_node()), binary()) :: continuation()
  # defp _make_cont(node, rest) do
  #   {List.wrap(node), rest}
  # end

  # defp _string_from_chardata(chardata) do
  #   chardata
  #   |> Enum.reverse
  #   |> IO.chardata_to_string
  # end

  # @spec parsep(binary(), ast()) :: continuation()
  # defp parsep(input, result) do
  #   IO.inspect({input, result}, label: :parsep)

  #   case input do
  #     "" ->
  #       {Enum.reverse(result), ""}
  #       |> IO.inspect(label: "<<< parsep")

  #     <<"# ", rest::binary>> ->
  #       {content, rest1} = parse_section(rest)
  #       parsep(rest1, [content | result])
  #       # |> IO.inspect(label: "<<< parsep")
  #   end
  # end

  # @spec parse_section(binary(), ast()) :: continuation()
  # defp parse_section(input, result \\ []) do
  #   {content, rest} = parse_text(input)
  #   parsep(rest, push_tag(:section, content, result))
  #   # |> IO.inspect(label: "<<< parse_section")
  # end

  # @spec parse_text(binary(), IO.chardata()) :: continuation()
  # defp parse_text(input, result \\ [])

  # defp parse_text("", result) do
  #   {result
  #    |> Enum.reverse()
  #    |> IO.chardata_to_string(), ""}
  # end

  # defp parse_text(<<"\n# ", rest::binary>>, result) do
  #   {result
  #    |> Enum.reverse()
  #    |> IO.chardata_to_string(), "# " <> rest}
  # end

  # defp parse_text(<<ch::utf8, rest::binary>>, result) do
  #   parse_text(rest, [ch | result])
  # end

  # @spec push_tag(atom(), binary(), ast()) :: ast()
  # defp push_tag(tag, content, result)

  # defp push_tag(tag, content, result) do
  #   # IO.inspect(content, label: :content)
  #   # |> IO.inspect() 
  #   [{tag, [content]} | result]
  #   # |> IO.inspect(label: "<<< push_tag")

  # end
end

# SPDX-License-Identifier: Apache-2.0
