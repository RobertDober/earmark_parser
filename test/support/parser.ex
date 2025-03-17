defmodule Support.Parser do
  def parse_lines(lines) do
    EarmarkParser.Parser.parse(%EarmarkParser.Options{}, lines, false)
  end
end

# SPDX-License-Identifier: Apache-2.0
