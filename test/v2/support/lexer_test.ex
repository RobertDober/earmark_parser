defmodule V2.Support.LexerTest do
  alias EarmarkParser.Lexer

  defmacro __using__(_options) do
    quote do
      use ExUnit.Case, async: true
      import unquote(__MODULE__)
    end
  end

  defmacro assert_multiple(token, number, input) do
    quote do
      input1 = Stream.cycle([unquote(input)]) |> Enum.take(unquote(number)) |> Enum.join
      expected = Stream.cycle([{unquote(token), unquote(input), len: String.length(unquote(input))}])
      |>  Enum.take(unquote(number)) |> Enum.to_list
      assert tokenize(input1) == expected
    end
    # quote do
    #   test "multilple #{unquote(input)} * #{unquote(number)}" do
    #     input = 
    #     expected = Stream.cycle([{unquote(token), unquote(input), len: String.length(unquote(input))-1}])
    #     |>  Enum.take(unquote(number)) |> Enum.to_list
    #     assert tokenize(input) == expected 
    #   end
    # end
  end
  def tokenize(input, lnb \\ 0) do
    Lexer.tokenize(input, lnb: lnb)
    |> Enum.map(&_remove_lnb(&1, lnb))
  end

  defp _remove_lnb(tuple, lnb) do
    {token, content, len: len, lnb: ^lnb} = tuple
    {token, content, len: len}
  end
end
