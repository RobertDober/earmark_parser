defmodule Support.EarTestCase do
  defmacro __using__(_options) do
    quote do
      use ExUnit.Case, async: true

      alias Ear.{Line, Parser, State}
      alias Ear.Ast.Block

      import Support.Helpers
      import EarmarkAstDsl

      def block(tag, content, opts \\ [])

      def block(tag, content, opts) when is_binary(content) do
        lnb = Keyword.get(opts, :lnb, 1)
        block(tag, [{content, lnb}], opts)
      end

      def block(tag, content, opts) do
        lnb = Keyword.get(opts, :lnb, 1)
        atts = Keyword.delete(opts, :lnb)
        %Block{tag: tag, atts: atts, content: content, open?: false, lnb: lnb}
      end

      def ok(blocks) do
        {:ok, blocks, []}
      end

      def ok(tag, content, opts \\ []) do
        {:ok, [block(tag, content, opts)], []}
      end

      def parse(line) when is_binary(line) do
        line
        |> String.split(~r{\r\n?|\n})
        |> parse()
      end

      def parse(lines) do
        lines
        |> Parser.parse([])
      end

      def tuples(lines, from \\ 1) do
        lines
        |> Enum.reduce({[], from}, fn line, {result, count} ->
          {[{line, count}|result], count + 1}
        end)
        |> Tuple.to_list
        |> List.first
        |> Enum.reverse
      end
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
