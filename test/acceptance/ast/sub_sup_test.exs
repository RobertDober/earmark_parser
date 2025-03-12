defmodule Acceptance.Ast.SubSupTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1, as_ast: 2]
  import EarmarkAstDsl

  describe "without option set" do
    test "sub" do
      markdown = "This is H~2~O, only water"
      ast = [p("This is H~2~O, only water")]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

    test "super" do
      markdown = "we get O(n^2^)"
      ast = [p("we get O(n^2^)")]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "with option set" do
    test "sub" do
      markdown = "This is H~2~O, only water"
      ast = [p(["This is H", tag("sub", "2"), "O, only water"])]
      messages = []

      assert as_ast(markdown, sub_sup: true) == {:ok, ast, messages}
    end

    test "super" do
      markdown = "we get O(n^2^)"
      ast = [p(["we get O(n", tag("sup", "2"), ")"])]
      messages = []

      assert as_ast(markdown, sub_sup: true) == {:ok, ast, messages}
    end
  end

  describe "regression with all" do
    test "with all" do
      markdown = "n^2^"
      ast = [p(["n", tag("sup", "2")])]
      messages = []

      assert as_ast(markdown, all: true) == {:ok, ast, messages}
    end

    test "with sub_sup" do
      markdown = "n^2^"
      ast = [p(["n", tag("sup", "2")])]
      messages = []

      assert as_ast(markdown, all: true) == {:ok, ast, messages}
    end

    test "with sub_sup and all" do
      markdown = "n^2^"
      ast = [p(["n", tag("sup", "2")])]
      messages = []

      assert as_ast(markdown, sub_sup: true, all: true) == {:ok, ast, messages}
    end
  end

  describe "works with sub" do
    test "with all" do
      markdown = "n~2~"
      ast = [p(["n", tag("sub", "2")])]
      messages = []

      assert as_ast(markdown, all: true) == {:ok, ast, messages}
    end

    test "with sub_sub" do
      markdown = "n~2~"
      ast = [p(["n", tag("sub", "2")])]
      messages = []

      assert as_ast(markdown, all: true) == {:ok, ast, messages}
    end

    test "with sub_sub and all" do
      markdown = "n~2~"
      ast = [p(["n", tag("sub", "2")])]
      messages = []

      assert as_ast(markdown, sub_sup: true, all: true) == {:ok, ast, messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
