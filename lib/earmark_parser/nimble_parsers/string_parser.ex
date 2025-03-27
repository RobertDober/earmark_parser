defmodule EarmarkParser.NimbleParsers.StringParser do
  @moduledoc ~S"""
  String combinator
  """

  import NimbleParsec

  defcombinator(
    :string_value,
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
  )
end

# SPDX-License-Identifier: AGPL-3.0-or-later
