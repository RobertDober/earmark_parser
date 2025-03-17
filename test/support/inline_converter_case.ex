defmodule Support.InlineConverterCase do
  defmacro __using__(_opts) do
    quote do
      use ExUnit.Case
      import EarmarkAstDsl

      def convert(src, options \\ [], lnb \\ 74) do
        options = EarmarkParser.Options.normalize(options)
        context = %EarmarkParser.Context{options: options} |> EarmarkParser.Context.update_context()

        EarmarkParser.Ast.Inline.convert(src, lnb, context).value
      end

      def convert_with_footnotes(src, fnids)

      def convert_with_footnotes(src, fnids) when is_list(fnids) do
        footnotes = fnids |> Enum.zip(Stream.cycle([true])) |> Enum.into(%{})
        options = EarmarkParser.Options.normalize(footnotes: true)

        context =
          %EarmarkParser.Context{options: options, footnotes: footnotes} |> EarmarkParser.Context.update_context()

        EarmarkParser.Ast.Inline.convert(src, 1, context).value
      end

      def convert_with_footnotes(src, fnid) do
        convert_with_footnotes(src, [fnid])
      end

      def convert_with_reflink(src, link_id, url, title, options \\ []) do
        links = %{link_id => %{url: url, title: title}}
        options = EarmarkParser.Options.normalize(options)
        context = %EarmarkParser.Context{options: options, links: links} |> EarmarkParser.Context.update_context()

        EarmarkParser.Ast.Inline.convert(src, 1, context).value
      end
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
