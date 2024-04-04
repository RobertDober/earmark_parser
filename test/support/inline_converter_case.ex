defmodule Support.InlineConverterCase do

  defmacro __using__(_opts) do
    quote do
      use ExUnit.Case

      def convert(src, options \\ [], lnb \\ 74) do
        options = EarmarkParser.Options.normalize(options)
        context = %EarmarkParser.Context{options: options} |> EarmarkParser.Context.update_context 

        EarmarkParser.Ast.Inline.convert(src, lnb, context).value
      end
    end
  end

end
# SPDX-License-Identifier: Apache-2.0
