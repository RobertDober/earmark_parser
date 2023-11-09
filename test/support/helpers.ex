defmodule Support.Helpers do

  alias EarmarkParser.Block.IdDef
  alias EarmarkParser.Context

  ###############
  # Helpers.... #
  ###############

  def context do
    %EarmarkParser.Context{}
  end

  def annotated(meta, annotation), do: Map.put(meta, :annotation, annotation)

  def as_ast(markdown, options \\ []) do
    EarmarkParser.as_ast(markdown, options)
  end

  def parse_html(html, metadata_fun \\ &default_metadata_fun/1) do
    if System.get_env("DEBUG") do
      _parse_html(html) |> _add_4th(metadata_fun) |> IO.inspect
    else
      _parse_html(html) |> _add_4th(metadata_fun)
    end
  end

  # Floki does not keep track of lines so let's pretend it does for code spans
  defp default_metadata_fun({"code", attrs, _}) do
    case List.keyfind(attrs, "class", 0) do
      {"class", "inline" <> _} ->
        %{line: 1}

      _ ->
        %{}
    end
  end

  defp default_metadata_fun(_other) do
    %{}
  end

  def test_links do
    [
     {"id1", %IdDef{url: "url 1", title: "title 1"}},
     {"id2", %IdDef{url: "url 2"}},

     {"img1", %IdDef{url: "img 1", title: "image 1"}},
     {"img2", %IdDef{url: "img 2"}},
    ]
    |> Enum.into(Map.new)
  end

  def pedantic_context do
    ctx = put_in(context().options.gfm, false)
    ctx = put_in(ctx.options.pedantic, true)
    ctx = put_in(ctx.links, test_links())
    Context.update_context(ctx)
  end

  def gfm_context do
    Context.update_context(context())
  end

  defp _add_4th(node, metadata_fun)
  defp _add_4th(nodes, metadata_fun) when is_list(nodes) do
    nodes
    |> Enum.map(&_add_4th(&1, metadata_fun))
  end
  defp _add_4th({t, a, c}, metadata_fun) do
    c = _add_4th(c, metadata_fun)
    {t, a, c, metadata_fun.({t, a, c})}
  end
  defp _add_4th({:comment, content}, _) do
    {:comment, [], content, %{comment: true}}
  end
  defp _add_4th(other, _), do: other

  defp _parse_html(html) do
    with {_, ast} = Floki.parse_fragment(html), do: ast
  end
end

# SPDX-License-Identifier: Apache-2.0
