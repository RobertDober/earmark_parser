defmodule Support.MetadataTestCase do
  defmacro __using__(_options) do
    quote do
      use ExUnit.Case, async: true
      import EarmarkParser.Parser.MetadataParser, only: [parse: 1]

      defp assert_parse(input, expected_ast) do
        assert parse(input) == {:ok, expected_ast}
      end
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
