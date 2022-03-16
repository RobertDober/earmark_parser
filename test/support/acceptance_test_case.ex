defmodule Support.AcceptanceTestCase do

  defmacro __using__(_options) do
    quote do
      use ExUnit.Case, async: true

      alias EarmarkParser.Options

      import Support.Helpers
      import EarmarkAstDsl
      import Support.AstHelpers, only: [ast_from_md: 1]
    end
  end

end
# SPDX-License-Identifier: Apache-2.0
