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
    option_combinator([&number_parser/1]).(content)
  end

  @spec number_parser(String.t()) :: result_t()
  defp number_parser(content) do
    case Regex.run(~r{\A\s*([-+]?)(\d+)(\.\d+)?\s*(.*)}, content) do
      nil -> {:error, "not a number"}
      [_matched, sign, int_part, "", rest] -> {:ok, String.to_integer(sign <> int_part), rest}
      [_matched, sign, int_part, dec_part, rest] -> {:ok, String.to_float(sign <> int_part <> dec_part), rest}
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
