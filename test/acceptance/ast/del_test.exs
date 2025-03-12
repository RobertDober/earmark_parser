defmodule Acceptance.Ast.DelTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, as_ast: 2]
  import EarmarkAstDsl

  describe "single occurrence" do
    test "alone" do
      markdown = "~~stroken through~~"
      ast = [p(tag("del", "stroken through"))]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "with leading spaces" do
      markdown = " ~~stroken through~~"
      ast = [p([" ", tag("del", "stroken through")])]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "in the middle of some text" do
      markdown = "Some deleted ~~text~~ here"
      ast = [p(["Some deleted ", tag("del", "text"), " here"])]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "in the middle of some text, with `breaks: true`" do
      markdown = "Some deleted ~~old text~~ here"
      ast = [p(["Some deleted ", tag("del", "old text"), " here"])]
      messages = []

      assert as_ast(markdown, breaks: true) == {:ok, ast, messages}
    end

    test "and finally, at the end" do
      markdown = "And in the ~~end~~"
      ast = [p(["And in the ", tag("del", "end")])]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "more than one" do
    test "just the two of them" do
      markdown = "~~alpha~~ ~~beta~~"
      ast = [p([tag("del", "alpha"), " ", tag("del", "beta")])]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "full of tildes" do
      markdown = "~Not ~~yes~~ ~~a trap~ this one~~ what ~else~?  ~~!~~"

      ast = [
        p([
          "~Not ",
          tag("del", "yes"),
          " ",
          tag("del", "a trap~ this one"),
          " what ~else~?  ",
          tag("del", "!")
        ])
      ]

      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
