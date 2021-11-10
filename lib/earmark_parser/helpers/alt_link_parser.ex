defmodule EarmarkParser.Helpers.AltLinkParser do

  @moduledoc false
  import EarmarkParser.Helpers.StringHelpers, only: [behead: 2]
  import EarmarkParser.Helpers.Parser
  alias EarmarkParser.Helpers.LinkAst

  @doc false
  def parse(src) do
    link_or_img_parser.(src)
  end


  defp parse_link() do
    ~W< [ ] ( ) >
    |> Enum.map(&string_parser/1)
    |> sequence()
  end

  defp link_or_img_parser() do
    sequence([
      choice([
        string_parser("!"), empty()
      ]),
      rest_parser()]) |> map(&LinkAst.finalize/1)
      # sequence([
      #   "!"
      #   |> string_parser()
      #   |> ignore_ws()
      #   |> optional(),
      #   parse_link()])
  end

  defp rest_parser() do
    empty()
  end

  defp string_parser(string) do
    fn input ->
      if String.starts_with?(input, string),
        do: {:ok, {:lit, string}, behead(input, string)},
        else: {:error, "did not find #{string}"}
    end
  end

  defp text_parser() do
    sequence([
      string_parser("["),
      string_parser("]")
    ])
  end

  defp url_parser() do
    empty()
  end
end
# SPDX-License-Identifier: Apache-2.0
