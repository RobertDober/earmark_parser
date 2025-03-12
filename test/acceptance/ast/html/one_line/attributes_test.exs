defmodule Acceptance.Ast.Html.Oneline.AttributesTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1]
  import EarmarkAstDsl

  describe "strict tags syntax (non regression)" do
    test "really simple" do
      markdown = ~s{<p class="one" data-x="1" />}
      ast = [vtag("p", [], class: "one", "data-x": 1)]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "spaces around =" do
    test "still quite simple" do
      markdown = ~s{<p class ="one" data-x = "1" />}
      ast = [vtag("p", [], class: "one", "data-x": 1)]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "unquoted attribute values" do
    test "no special characters inside the value" do
      markdown = ~s{<p class=one data-x=1 />}
      ast = [vtag("p", [], class: "one", "data-x": 1)]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "and accepts spaces around the =" do
      markdown = ~s{<p class = one data-x= 1 />}
      ast = [vtag("p", [], class: "one", "data-x": 1)]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "without space before > in non-void element" do
      markdown = "Before\n\n<span class=test>inside</span>\n\nAfter"
      ast = [p(["Before"]), vtag("span", ["inside"], class: "test"), p(["After"])]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "without space before > in void element" do
      markdown = "Before\n\n<img src=image.png>\n\nAfter"
      ast = [p(["Before"]), vtag("img", [], src: "image.png"), p(["After"])]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "valueless attributes" do
    test "gets its name as a value" do
      markdown = ~s{<p class  data-x />}
      ast = [vtag("p", [], class: "class", "data-x": "data-x")]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
