defmodule Test.Acceptance.Ast.ReplaceUtf8ZeroCpTest do
  use Support.AcceptanceTestCase
  @moduledoc false

  @zero "\u0000"
  @repl "\ufffd"

  describe "in simple paragraphs" do
    test "one line, one occurance" do
      markdown = "#{@zero}should not be here"
      expected = "#{@repl}should not be here"
      ast = p(expected)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "inside inline markup" do
      markdown = "emphasized _#{@zero}_!"
      expected = ["emphasized ", tag(:em, @repl), "!"]
      ast = p(expected)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "in headline and para" do
      markdown = "## I have #{@zero} confidence\nand #{@zero} hope"
      headline = "I have #{@repl} confidence"
      para = "and #{@repl} hope"
      ast = [tag(:h2, headline), p(para)]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "in code blocks" do
    test "in indented code" do
      markdown = "    #{@zero}"
      ast = pre_code(@repl)
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "in fenced code multiple times" do
      markdown = "~~~elixir\nIO.puts#{@zero}\na#{@zero}#{@zero}\n~~~"
      expected = "IO.puts#{@repl}\na#{@repl}#{@repl}"
      ast = tag("pre", tag("code", expected, class: "elixir"))
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "in and outside inline code over multiple lines" do
      markdown = "#{@zero}`hello#{@zero}\n#{@zero}` and #{@zero}"
      expected = "hello#{@repl} #{@repl}"
      ast = p([@repl, {"code", [{"class", "inline"}], [expected], %{line: 1}}, " and #{@repl}"])
      messages = []

      assert as_ast(markdown) == {:ok, [ast], messages}
    end

    test "missing end of quotes still removes the zero from output and error message" do
      markdown = "`error with #{@zero}"
      expected = "`error with #{@repl}"
      ast = p(expected)
      messages = [{:warning, 1, "Closing unclosed backquotes ` at end of input"}]

      assert as_ast(markdown) == {:error, [ast], messages}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
