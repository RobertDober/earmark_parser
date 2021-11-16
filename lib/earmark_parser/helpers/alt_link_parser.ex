defmodule EarmarkParser.Helpers.AltLinkParser do
  @moduledoc false
  import EarmarkParser.Helpers.StringHelpers, only: [behead: 2]
  import EarmarkParser.Helpers.Parser

  @doc false
  def parse(src) do
    parser().(src)
  end
  defp parser() do
    sequence([
      optional("!"),
      "[",
      text_parser(),
      "](",
      url_title_parser(),
      ")"
    ])
  end


  defp text_parser() do
    empty()
  end

  defp url_title_parser() do
    empty()
  end
end

# SPDX-License-Identifier: Apache-2.0
