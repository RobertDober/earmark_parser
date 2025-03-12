defmodule Test.Unit.ConvertTest do
  use ExUnit.Case
  alias EarmarkParser.{Ast.Inline, Block.IdDef, Context}

  describe "edge cases" do
    test "empty" do
      assert convert("") == []
    end
  end

  describe "reflink" do
    test "strong inside" do
      markdown = "[**strong**][lnk1]"
      ctxt = "lnk1" |> with_link()

      assert convert(markdown, ctxt) == [
               {"a", [{"href", "lnk1_url"}, {"title", "title"}], [{"strong", [], ["strong"], %{}}], %{}}
             ]
    end

    test "just an image" do
      markdown = "![Img1][img1]"
      ctxt = "img1" |> with_link()

      assert convert(markdown, ctxt) == [{"img", [{"src", "lnk1_url"}, {"alt", "Img1"}, {"title", "title"}], [], %{}}]
    end

    test "image inside" do
      markdown = "[![Img1][img1]][lnk1]"

      expected = [
        {"a", [{"href", "lnk1_url"}, {"title", "title"}],
         [{"img", [{"src", "lnk1_url"}, {"alt", "Img1"}, {"title", "title"}], [], %{}}], %{}}
      ]

      ctxt = "lnk1" |> with_link() |> with_link("img1")
      assert convert(markdown, ctxt) == expected
    end
  end

  defp convert(content, context \\ %Context{}) do
    Inline.convert(content, 42, context).value
  end

  defp with_link(id) do
    with_link(Context.update_context(%Context{}), id)
  end

  defp with_link(ctxt, id) do
    id_def = %IdDef{
      annotation: nil,
      attrs: nil,
      id: id,
      lnb: 3,
      title: "title",
      url: "lnk1_url"
    }

    %{ctxt | links: Map.put(ctxt.links, id, id_def)}
  end
end
