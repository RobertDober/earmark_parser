defmodule EarmarkParser.Helpers.LeexHelpers do
  @moduledoc false
  @doc """
    Allows to lex an Elixir string with a leex lexer and returns
    the tokens as needed for a yecc parser.
  """
  def lex(text, with: lexer) do
    case text
         |> String.to_charlist()
         |> lexer.string() do
      {:ok, tokens, _} -> tokens
    end
  end

  def elex(text, options)

  def elex(text, lnb: lnb, with: lexer) do
    lex(text, with: lexer)
    |> Enum.map(&triple_elixirize(&1, lnb: lnb))
  end

  def tokenize(line, with: lexer) do
    {:ok, tokens, _} =
      line
      |> to_charlist()
      |> lexer.string()

    elixirize_tokens(tokens, [])
    |> Enum.reverse()
  end

  defp elixirize_tokens(tokens, rest)

  defp elixirize_tokens([], result) do
    result
  end

  defp elixirize_tokens([{token, _, text} | rest], result) do
    elixirize_tokens(rest, [{token, to_string(text)} | result])
  end

  defp triple_elixirize({token, content, len}, lnb: lnb) do
    {token, to_string(content), len: len, lnb: lnb}
  end
end

# SPDX-License-Identifier: Apache-2.0
