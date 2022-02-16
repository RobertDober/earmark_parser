defmodule Support.EarTestCase do

  defmacro __using__(_options) do
    quote do
      use ExUnit.Case, async: true

      alias Ear.{Line, Parser, State}

      import Support.Helpers
      import EarmarkAstDsl
      import Support.EarHelpers

      def parse(line) when is_binary(line) do
        line
        |> String.split(~r{\r\n?|\n})
        |> parse()
      end

      def parse(lines) do
        lines
        |> Parser.parse([])
      end
    end
  end

end
# SPDX-License-Identifier: Apache-2.0
