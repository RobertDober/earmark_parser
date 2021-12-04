defmodule EarmarkParser.Helpers.FootnoteHandler do
  @moduledoc false

  alias EarmarkParser.Block
  import EarmarkParser.Message, only: [add_messages: 2]

  def handle_footnotes(blocks, options) do
    {footnotes, blocks} = Enum.split_with(blocks, &footnote_def?/1)

    {footnotes, undefined_footnotes} =
      Enum.map(blocks, &find_footnote_links/1)
      |> List.flatten()
      |> get_footnote_numbers(footnotes, options)

    blocks = create_footnote_blocks(blocks, footnotes)
    footnotes = Enum.map(footnotes, &{&1.id, &1}) |> Enum.into(Map.new())
    options1 = add_messages(options, undefined_footnotes)
    {blocks, footnotes, options1}
  end

  defp create_footnote_blocks(blocks, []), do: blocks

  defp create_footnote_blocks(blocks, footnotes) do
    lnb =
      footnotes
      |> Stream.map(& &1.lnb)
      |> Enum.min()

    footnote_block = %Block.FnList{blocks: Enum.sort_by(footnotes, & &1.number), lnb: lnb}
    Enum.concat(blocks, [footnote_block])
  end

  defp extract_footnote_links({line, lnb}) do
    Regex.scan(~r{\[\^([^\]]+)\]}, line)
    |> Enum.map(&tl/1)
    |> Enum.zip(Stream.cycle([lnb]))
  end

  defp footnote_def?(%Block.FnDef{}), do: true
  defp footnote_def?(_block), do: false

  defp find_footnote_links(%Block.Para{lines: lines, lnb: lnb}) do
    find_footnote_links_in_blocks(lines, lnb)
  end

  defp find_footnote_links(%Block.Text{line: lines, lnb: lnb}) do
    find_footnote_links_in_blocks(lines, lnb)
  end

  defp find_footnote_links(%{blocks: blocks}) do
    Enum.flat_map(blocks, &find_footnote_links/1)
  end

  defp find_footnote_links(_), do: []

  defp find_footnote_links_in_blocks(lines, lnb) do
    lines
    |> Enum.zip(Stream.iterate(lnb, &(&1 + 1)))
    |> Enum.flat_map(&extract_footnote_links/1)
  end

  def get_footnote_numbers(refs, footnotes, options) do
    Enum.reduce(refs, {[], []}, fn {ref, lnb}, {defined, undefined} ->
      r = hd(ref)

      case Enum.find(footnotes, &(&1.id == r)) do
        note = %Block.FnDef{} ->
          number = length(defined) + options.footnote_offset
          note = %Block.FnDef{note | number: number}
          {[note | defined], undefined}

        _ ->
          {defined,
           [{:error, lnb, "footnote #{r} undefined, reference to it ignored"} | undefined]}
      end
    end)
  end
end
#  SPDX-License-Identifier: Apache-2.0
