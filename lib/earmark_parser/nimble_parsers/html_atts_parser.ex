defmodule EarmarkParser.NimbleParsers.HtmlAttsParser do
  @moduledoc ~S"""
  Parses an HTML tag
  """
  import NimbleParsec

  end_html_att =
    ignore(ascii_char([?>..?>]))

  defparsec(:parse_html_atts, end_html_att)
end

# SPDX-License-Identifier: AGPL-3.0-or-later
