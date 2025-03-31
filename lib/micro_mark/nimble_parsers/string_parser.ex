defmodule MicroMark.NimbleParsers.StringParser do
  @moduledoc ~S"""
  String combinator
  """

  import NimbleParsec

  inner_string = fn combinator, ch ->
    combinator
    |> repeat(
      lookahead_not(ascii_char([ch]))
      |> choice([
        IO.chardata_to_string(["\\", ch])
        |> string()
        |> replace(ch),
        utf8_char([])
      ])
    )
  end

  quoted_string = fn ch ->
    empty()
    |> ascii_char([ch])
    |> ignore()
    |> inner_string.(ch)
    |> ignore(ascii_char([ch]))
  end

  defcombinator(
    :string_value,
    choice([
      quoted_string.(?"),
      quoted_string.(?')
    ])
  )
end

# SPDX-License-Identifier: AGPL-3.0-or-later
