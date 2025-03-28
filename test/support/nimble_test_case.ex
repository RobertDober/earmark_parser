defmodule Support.NimbleTestCase do
  defmacro __using__(_options) do
    quote do
      use ExUnit.Case, async: true

      import EarmarkParser.NimbleParsers
      import Support.NimbleTests
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
