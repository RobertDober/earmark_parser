defmodule Test.Debug.Support do
  alias EarmarkParser.{LineScanner, Options, Parser.ListParser}

  def parse_list(markdown, options \\ []) do
    with options_ <- Options.normalize(options), do:
      markdown
      |> String.split(~r{\r\n?|\n})
      |> LineScanner.scan_lines(options_, false)
      |> ListParser.parse_list([], options_)
  end

end
#  SPDX-License-Identifier: Apache-2.0
