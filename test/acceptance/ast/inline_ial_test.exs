defmodule Test.Acceptance.Ast.InlineIalTest do
  use ExUnit.Case

  describe "inline IAL enabled →" do
    data = [
      {"# A Header{:.classy}", [{"h1", [{"class", "classy"}], ["A Header"], %{}}]},
      {"###### Another Header{:.classy}", [{"h6", [{"class", "classy"}], ["Another Header"], %{}}]},
      {"> # Bq Header{:.classy-again}", [{"blockquote", [], [{"h1", [{"class", "classy-again"}], ["Bq Header"], %{}}], %{}}]},
      {"- # Bq in a list{:.class42 title=xxx}", [{"ul", [], [{"li", [], [{"h1", [{"class", "class42"}, {"title", "xxx"}], ["Bq in a list"], %{}}], %{}}], %{}}]},
      {"`42|>inspect()`{:.elixir}", [{"p", [], [{"code", [{"class", "inline elixir"}], ["42|>inspect()"], %{}}], %{}}]}
    ]
    data
    |> Enum.with_index
    |> Enum.each( fn {{markdown, expected}, nb} ->
      tag = "inline_ial_#{nb}" |> String.to_atom
      name = "for #{inspect markdown} (#{nb})"
      {:ok, ast, []} = EarmarkParser.as_ast(markdown)

      @tag tag
      test name do
        assert unquote(Macro.escape(ast)) == unquote(Macro.escape(expected))
      end
    end)
  end

  describe "inline IAL disabled →" do
    data = [
      {"######## Not Yet Another Header{:.classy}", [{"p", [], ["######## Not Yet Another Header{:.classy}"], %{}}]},
      {["> code {:.not-classy}", "> still code"], [{"blockquote", [], [{"p", [], ["code {:.not-classy}\nstill code"], %{}}], %{}}]},
      {"-- {:.hello}", [{"p", [], ["-- {:.hello}"], %{}}]},
      {"--- {:.hello}", [{"p", [], ["--- {:.hello}"], %{}}]},
    ]
    data
    |> Enum.with_index
    |> Enum.each( fn {{markdown, expected}, nb} ->
      tag = "not_inline_ial_#{nb}" |> String.to_atom
      name = "for #{inspect markdown} (#{nb})"
      {:ok, ast, []} = EarmarkParser.as_ast(markdown)

      @tag tag
      test name do
        assert unquote(Macro.escape(ast)) == unquote(Macro.escape(expected))
      end
    end)
  end
end
