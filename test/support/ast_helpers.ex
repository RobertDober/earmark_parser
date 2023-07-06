defmodule Support.AstHelpers do

   def assert_asts_are_equal(result, expected) do
     quote do
      assert _delta_between(unquote(result), unquote(expected)) == []
     end
   end

   def ast_from_md(md, opts \\ []) do
    with {:ok, ast, []} <- EarmarkParser.as_ast(md, opts), do: ast
  end

  def ast_with_errors(md) do
    with {:error, ast, messages} <- EarmarkParser.as_ast(md), do: {ast, messages}
  end

  def p(content, atts \\ [])
  def p(content, atts) when is_binary(content) or is_tuple(content),
    do: {"p", atts, [content]}
  def p(content, atts),
    do: {"p", atts, content}

  def tag(name, content \\ nil, atts \\ []) do
    {to_string(name), _atts(atts), _content(content)}
  end

  def void_tag(tag, atts \\ []) do
    {to_string(tag), atts, []}
  end


  defp _atts(atts) do
    atts |> Enum.into(Keyword.new) |> Enum.map(fn {x, y} -> {to_string(x), to_string(y)} end)
  end

  defp _content(c)
  defp _content(nil), do: []
  defp _content(s) when is_binary(s), do: [s]
  defp _content(c), do: c

  defp _delta_between(result_ast, expected_ast, delta \\ [])
  defp _delta_between([], [], delta), do: delta |> List.flatten
  defp _delta_between([result|result_rest], [expected|expected_rest], delta) do
    delta1 = _delta_between(result, expected)
    _delta_between(result_rest, expected_rest, [delta1, delta])
  end
  defp _delta_between({rtag, ratts, rcont, rmeta}, {etag, eatts, econt, emeta}, _delta) do
    inner_delta = _delta_between(rcont, econt)
    outer_delta = [{rtag, etag}, {rmeta, emeta}, {ratts|>Enum.into(%{}), eatts|>Enum.into(%{})}]
                  |> Enum.reduce([], fn {a, b}, d ->
                    if a == b do
                      d
                    else
                      [{a,b}, d]
                    end
                  end)
    [outer_delta, inner_delta]
  end
  defp _delta_between(result, expected, delta) do
    if result == expected do
      delta 
    else
      [{result, expected}, delta]
    end
  end


end
# SPDX-License-Identifier: Apache-2.0
