defmodule EarmarkParser.Ast.Emitter do
  @moduledoc false

  def emit(tag, content \\ [], atts \\ [], meta \\ %{})
  def emit(tag, content, atts, meta) when is_binary(content) or is_tuple(content) do
    {tag, _to_atts(atts), [content], meta}
  end
  def emit(tag, content, atts, meta) do
    {tag, _to_atts(atts), content, meta}
  end


  defp _to_atts(atts)
  defp _to_atts(nil), do: []
  defp _to_atts(atts) when is_map(atts) do
    atts
    |> Enum.into([])
    |> Enum.map(fn {name, value} -> {to_string(name), render(value)} end)
  end
  defp _to_atts(atts) do
    atts
    |> Enum.map(fn {name, value} -> {to_string(name), render(value)} end)
  end

  defp render(value)
  defp render(value) when is_binary(value), do: value
  # Print attr lists in source order
  defp render(value) when is_list(value), do: value |> rev() |> Enum.join(" ")
  defp render(value), do: to_string(value)

  # Efficient, linear, list reversal.
  defp rev(list, accum \\ [])
  defp rev([], ys), do: ys
  defp rev([x], ys), do: [x | ys]
  defp rev([x | xs], ys), do: rev(xs, [x | ys])
end
