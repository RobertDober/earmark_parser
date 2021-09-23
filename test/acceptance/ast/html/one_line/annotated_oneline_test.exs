defmodule Acceptance.Ast.Html.Oneline.AnnotatedOnelineTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 2]
  import EarmarkAstDsl

  describe "oneline tags" do
    test "really simple -- non-regression" do
      markdown = "<h1>Headline</h1>"
      ast      = [vtag("h1", "Headline")]
      messages = []

      assert as_ast(markdown, annotations: "//") == {:ok, ast, messages}
    end
    test "really simple" do
      markdown = "<h1>Headline</h1> :- main"
      ast      = [vtag_annotated("h1", "Headline", ":- main")]
      messages = []

      assert as_ast(markdown, annotations: ":-") == {:ok, ast, messages}
    end

    test "a little bit more complicated -- non-regression" do
      markdown = ~s{<p align="center"><img src="image.svg"/></p>}
      ast      = [vtag("p", ["<img src=\"image.svg\"/>"], align: "center")]
      messages = []

      assert as_ast(markdown, annotations: "%%%") == {:ok, ast, messages}
    end
    test "a little bit more complicated" do
      markdown = ~s{<p align="center"><img src="image.svg"/></p> %%% 42}
      ast      = [vtag_annotated("p", ["<img src=\"image.svg\"/>"], "%%% 42", align: "center")]
      messages = []

      assert as_ast(markdown, annotations: "%%%") == {:ok, ast, messages}
    end
  end

end

