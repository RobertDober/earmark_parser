defmodule EarmarkParser.NimbleParsers.HtmlAttsParser do
  @moduledoc ~S"""
  Parses an HTML tag
  """
  import NimbleParsec

  string_value =
    ascii_char([?"])
    |> ignore()
    |> repeat(
      lookahead_not(ascii_char([?"]))
      |> choice([
        ~S(\") |> string() |> replace(?"),
        utf8_char([])
      ])
    )
    |> ignore(ascii_char([?"]))

  html_att_name =
    ascii_string([?a..?z, ?A..?z, ?-..?-], min: 1)

  html_att =
    html_att_name
    |> choice([
      "=" |> string() |> ignore() |> concat(string_value),
      empty()
    ])
    |> reduce(:reduce_att)

  html_att_end =
    string(">")

  html_atts =
    html_att
    |> repeat(" " |> string() |> times(min: 1) |> ignore() |> concat(html_att))

  defparsec(:parse_html_atts, html_atts |> optional() |> ignore(html_att_end))

  @doc false
  def reduce_att(att_ast)

  def reduce_att([name]) do
    {name, true}
  end

  def reduce_att([name | values]) do
    {name, IO.chardata_to_string(values)}
  end
end

# SPDX-License-Identifier: AGPL-3.0-or-later
