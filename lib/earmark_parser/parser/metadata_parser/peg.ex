defmodule EarmarkParser.Parser.MetadataParser.Peg do
  @moduledoc false

  @typep result_t :: {:ok, any(), String.t()} | {:error, String.t()}
  @typep parser_t :: (String.t() -> result_t())
  @typep parsers_t :: [(String.t() -> result_t())]

  @doc false
  @spec parse(String.t(), parser_t() | nil) :: result_t()
  def parse(content, parser \\ nil) do
    (parser || (&exp_parser/1)).(content)
  end

  @spec exp_parser(String.t()) :: result_t()
  defp exp_parser(content) do
    option_combinator([
      &number_parser/1,
      &string_parser/1,
      &atom_parser/1,
      &list_parser/1
    ]).(content)
  end

  @spec atom_parser(String.t()) :: result_t()
  defp atom_parser(content) do
    case Regex.run(~r{\A\s*:([[:alpha:]_][[:alnum:]_]*)\s*(.*)}, content) do
      nil -> {:error, "not an atom"}
      [_matched, identifier, rest] -> {:ok, String.to_atom(identifier), rest}
    end
  end

  @spec list_parser(String.t()) :: result_t()
  defp list_parser(content) do
    case Regex.run(~r{\A\s*\[\s*(.*)}, content) do
      nil -> {:error, "not a list"}
      [_matched, rest] -> list_combinator(rest, &exp_parser/1, &ignore_rgx(&1, ~r{\A\s*[[:blank:],](.*)}), &ignore_rgx(&1, ~r{\A\s*\](.*)}))
    end
  end

  @spec number_parser(String.t()) :: result_t()
  defp number_parser(content) do
    case Regex.run(~r{\A\s*([-+]?)(\d+)(\.\d+)?\s*(.*)}, content) do
      nil -> {:error, "not a number"}
      [_matched, sign, int_part, "", rest] -> {:ok, String.to_integer(sign <> int_part), rest}
      [_matched, sign, int_part, dec_part, rest] -> {:ok, String.to_float(sign <> int_part <> dec_part), rest}
    end
  end

  @spec string_parser(String.t()) :: result_t()
  defp string_parser(content) do
    case Regex.run(~r{\A\s*"(.*)}, content) do
      nil -> {:error, "not a string"}
      [_, rest] -> _parse_string(rest, [])
    end
  end

  @spec _parse_string(String.t(), list()) :: result_t()
  defp _parse_string(content, result)

  defp _parse_string("", _) do
    {:error, "incomplete string (EOI)"}
  end

  defp _parse_string(~S{\"} <> rest, result) do
    _parse_string(rest, [result, ?"])
  end

  defp _parse_string(~S{"} <> rest, result) do
    {:ok, IO.chardata_to_string(result), rest}
  end

  defp _parse_string(<<head::utf8, rest::binary>>, result) do
    _parse_string(rest, [result, head])
  end

  defp list_combinator(content, element_parser, separator_parser, end_parser, result  \\ [])
  defp list_combinator("", _, _, _, _), do: {:error, "missing end_parser"}
  defp list_combinator(content, element_parser, separator_parser, end_parser, result) do
    case end_parser.(content) do
      {:ok, _, rest} -> {:ok, Enum.reverse(result), rest}
      _ -> _parse_list_element(content, element_parser, separator_parser, end_parser, result)
    end
  end

  defp _parse_list_element(content, element_parser, separator_parser, end_parser, result) do
    case element_parser.(content) do
      {:ok, ast, rest} -> _parse_list_rest(rest, element_parser, separator_parser, end_parser, [ast|result])
      error -> error
    end
  end

  @spec option_combinator(parsers_t()) :: parser_t()
  defp option_combinator(parsers) do
    fn content ->
      parsers
      |> Enum.reduce_while(nil, fn parser, _ ->
        case parser.(content) do
          {:error, _} -> {:cont, {:error, "no option parsed"}}
          result -> {:halt, result}
        end
      end)
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
