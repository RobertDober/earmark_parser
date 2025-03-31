defmodule Support.MicroMarkCase do
  defmacro __using__(_options \\ []) do
    quote do
      use ExUnit.Case, async: true

      alias MicroMark.{Parser, State}

      def parse_ok(input) do
        with {true, ast, _, _} <- parse(input) do
          ast
        end
      end

      def parse(input, lnb \\ 1, col \\ 1) do
        with result <-
               input
               |> State.new()
               |> Parser.parse() do
          {Enum.empty?(result.errors), result.ast, result.input.lnb, result.input.col}
        end
      end

      defmacro assert_parsed(input, ast_or_error, errors \\ [], col \\ nil, lnb \\ nil) do
        if Enum.empty?(errors) do
          assert_parsed_ok(input, ast_or_error, col, lnb)
        else
          raise "Not Yet Implemented"
        end
      end

      defp assert_parsed_ok(input, ast, col, lnb) do
        {true, ^ast, rlnb, rcol} = parse(input)

        cond do
          col && lnb ->
            quote do
              assert unquote(rcol) == unquote(col)
              assert unquote(rlnb) == unquote(lnb)
            end

          col ->
            quote do
              assert unquote(rcol) == unquote(col)
            end

          lnb ->
            quote do
              assert unquote(rlnb) == unquote(lnb)
            end

          true ->
            quote do
              assert true
            end
        end
      end
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
