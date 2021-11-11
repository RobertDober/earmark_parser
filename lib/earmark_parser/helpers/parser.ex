defmodule EarmarkParser.Helpers.Parser do
  @moduledoc ~S"""
  A simple parser combinator

  inspired by Saša Jurić's talk [Parsing from first principles](https://www.youtube.com/watch?v=xNzoerDljjo)

  A general observation, all combinators, that is all functions that take a parser or list of parsers
  as their first argument accept shortcuts for the char_range_parser, meaning that
  instead of

  ```iex
      sequence([
        optional(char_range_parser([?+, ?-])),
        many(char_range_parser([?0..?9]),
        choice([char_range_parser([?a]), char_range_parser([?b])])
  ```

  one can write

  ```iex
      sequence([
        optional([?+, ?-]),
        many([?0..?9]),
        choice([?a, ?b])])
  ```
  """

  @doc ~S"""
  A parser that succeeds in parsing the next character

      iex(1)> char_parser().("a")
      {:ok, ?a, ""}

      iex(2)> char_parser().("an")
      {:ok, ?a, "n"}

      iex(3)> char_parser().("")
      {:error, "unexpected end of input in char_parser"}

  We can name the parser to get a little bit better error messages

      iex(4)> char_parser("identifier").("")
      {:error, "unexpected end of input in char_parser identifier"}
  """
  def char_parser(name \\ "") do
    fn input ->
      case input do
        <<char::utf8, rest::binary>> -> {:ok, char, rest}
        _ -> _error_message("unexpected end of input in char_parser", name)
      end
    end
  end

  @doc ~S"""
  Parser that succeeds only if the first char of the input is in the indicated
  char_range

        iex(5)> parser = char_range_parser([?1..?9, ?a, [?b, ?c]])
        ...(5)> parser.("b")
        {:ok, ?b, ""}
        ...(5)> parser.("9a")
        {:ok, ?9, "a"}
        ...(5)> parser.("d")
        {:error, "expected a char in the range [49..57, 97, 'bc']"}

  The `char_range_parser` can also be called with a string which is transformed to
  a charlist with `String.to_charlist`

        iex(6)> bin_parser = char_range_parser("01")
        ...(6)> bin_parser.("10a")
        {:ok, ?1, "a"}
        ...(6)> bin_parser.("a")
        {:error, "expected a char in the range '01'"}

        iex(7)> greek_letter_parser = char_range_parser("αβγδεζηθικλμνξοπρςστυφχψω")
        ...(7)> greek_letter_parser.("σπίτι")
        {:ok, 963, "πίτι"}

  The last example is of course better written as

        iex(8)> greek_letter_parser = char_range_parser(?α..?ω)
        ...(8)> greek_letter_parser.("σπίτι")
        {:ok, 963, "πίτι"}

  for which reason you can also just pass a range

  Be aware of a trap in the utf8 code here `?ί(943)` is not in the specified range

        iex(9)> greek_letter_parser = char_range_parser(?α..?ω)
        ...(9)> greek_letter_parser.("ίτι")
        {:error, "expected a char in the range 945..969"}

  """
  def char_range_parser(char_range, name \\ "")

  def char_range_parser(string, name) when is_binary(string) do
    string
    |> String.to_charlist()
    |> char_range_parser(name)
  end

  def char_range_parser(char_range, name) do
    char_parser()
    |> satisfy(
      &_in_range?(&1, char_range),
      "expected a char in the range #{inspect(char_range)}",
      name
    )
  end

  @doc ~S"""
  A parser that combines a list of parsers in a way to parse the input string
  with first succeeding parser

      iex(10)> choice([char_parser(), empty()]).("")
      {:ok, "", ""}

      iex(11)> choice([char_parser(), empty()]).("a")
      {:ok, ?a, ""}

  As this is a combinator we can take shortcuts for the usage of `char_range_parser`

      iex(12)> az_parser = choice(["a", "z"])
      ...(12)> az_parser.("a")
      {:ok, ?a, ""}
      ...(12)> az_parser.("b")
      {:error, ""}
      ...(12)> az_parser.("z")
      {:ok, ?z, ""}

  """
  def choice(parsers, name \\ "") do
    parsers
    |> Enum.map(&_make_parser/1)
    |> _choice(name)
  end

  @doc ~S"""
  Parser that only succeeds when a digit is the first char of the input

      iex(13)> digit_parser().("a")
      {:error, "expected a char in the range #{?0}..#{?9}"}

      iex(14)> digit_parser().("42")
      {:ok, ?4, "2"}

  """
  def digit_parser(name \\ "") do
    char_range_parser(?0..?9, name)
  end

  @doc ~S"""
  Always succeedes (be careful when combining this parser)

        iex(15)> empty().("")
        {:ok, "", ""}

        iex(16)> empty().("1")
        {:ok, "", "1"}
  """
  def empty() do
    fn input ->
      {:ok, "", input}
    end
  end

  @doc ~S"""
  lazy is a parser delaying the execution of a different parser, this is needed to implement
  recursive parsing

  Let us assume that we want to parse this grammar

        S ← "(" S ")" | ε

  and that we want to count the number of opening "(" in the parsed expression
  A naive approach would be

  ```elixir
      def parser do
        sequence([
          parse_range_char([?(]),
          optional(parser()),
          parse_range_char([?)])
        ])
      end
  ```

  but this would create an endless loop as we call parser() immediately
  however we can remedy this with the lazy combinator

  ```elixir
      def parser do
        sequence([
          parse_range_char([?(]),
          optional(lazy(fn -> parser() end),
          parse_range_char([?)])
        ])
      end
  ```

  Will work just fine as can be seen in this [test](test/earmark_helpers_tests/parser_test.exs)
  """
  def lazy(parser) do
    fn input -> parser.().(input) end
  end

  # def lookahead(string, parser, name \\ "") do
  #   fn input ->
  #     if String.starts_with?(input, string),
  #       do: parser.(input),
  #       else: {:error, "lookahead #{string} failed #{name}"}
  #   end
  # end

  @doc ~S"""
  Parses the input with the given parser as many times it succeeds, it never fails when count == 0
  (which it always is in this version), so be careful when combining it

      iex(17)> parser = many(digit_parser())
      ...(17)> parser.("12")
      {:ok, "12", ""}
      ...(17)> parser.("2b")
      {:ok, "2", "b"}
      ...(17)> parser.("a")
      {:ok, [], "a"}

  **N.B.** that it **always** succeeds
  if you need at least n > 0 parsing steps to succeed use `many!`

  As many is a combinator we can also use the `char_range_parser` shortcut
  again

      iex(18)> many("01").("01a")
      {:ok, '01', "a"}
  """
  def many(parser) do
    parser |> _make_parser |> _many()
  end

  @doc ~S"""
  same as many but a given number of parser runs must succeed

        iex(19)> two_chars = char_parser() |> many!(2, "need two for tea")
        ...(19)> two_chars.("")
        {:error, "need two for tea"}
        ...(19)> two_chars.("a")
        {:error, "need two for tea"}
        ...(19)> two_chars.("ab")
        {:ok, 'ab', ""}

  Same shortcut as for `many` is available

      iex(20)> many!("01", 2).("01a")
      {:ok, '01', "a"}
      ...(20)> many!("01", 2).("1a")
      {:error, "many! failed with 1 parser steps missing"}
  """
  def many!(parser, n, name \\ "") do
    parser
    |> _make_parser()
    |> _many!(n, name)
  end

  @doc ~S"""
  This implemnts the functor interface for parse results

      iex(21)> number_parser = digit_parser()
      ...(21)> |> many()
      ...(21)> |> map(fn digits -> digits |> IO.chardata_to_string |> String.to_integer end)
      ...(21)> number_parser.("42a")
      {:ok, 42, "a"}

  Let us show that the functor treats the error case correctly

      iex(22)> parser = char_parser("my_parser") |> map(fn _ -> raise "That will not happen here" end)
      ...(22)> parser.("")
      {:error, "unexpected end of input in char_parser my_parser"}

  we can use the shortcut specification for a parser here too

      iex(23)> parser = map("01", fn x -> if x==?1, do: true end) 
      ...(23)> parser.("1")
      {:ok, true, ""}
  """
  def map(parser, fun) do
    parser_ = _make_parser(parser)
    fn input ->
      with {:ok, term, rest} <- parser_.(input),
           do: {:ok, fun.(term), rest}
    end
  end

  @doc ~S"""
  optional(parser) is just a shortcut for choice([parser, empty()]) and therefore always succeeds

      iex(24)> optional(digit_parser()).("2")
      {:ok, ?2, ""}

      iex(25)> optional(digit_parser()).("")
      {:ok, "", ""}

  again shortcuts are supported

      iex(26)> optional(?a).("a")
      {:ok, ?a, ""}

      iex(27)> optional(?a).("b")
      {:ok, "", "b"}
  """
  def optional(parser) do
    parser_ = _make_parser(parser)
    fn input ->
      case parser_.(input) do
        {:ok, _ast, _rest} = result -> result
        {:error, _message} -> {:ok, "", input}
      end
    end
  end

  @doc ~S"""
  satisfy is a general purpose filtering refinement of a parser
  it takes a perser, a function, an optional error message and an optional name

  it creates a parser that parses the input with the passed in parser, if it fails
  nothing changes, however if it succeeds the function is called on the result of
  the parse and the thusly created parser only succeeds if the function call returns
  a truthy value

  Here is an example how digit_parser could be implemented (in reality it is implemented
  using char_range_parser, which then uses satisfy in a more general way, too long to
  be a good doctest)

      iex(28)> dparser = char_parser() |> satisfy(&Enum.member?(?0..?9, &1), "not a digit")
      ...(28)> dparser.("1")
      {:ok, ?1, ""}
      ...(28)> dparser.("a")
      {:error, "not a digit"}

  as satisfy is a combinator we can use shortcuts too

      iex(29)> voyel_parser = "abcdefghijklmnopqrstuvwxyz"
      ...(29)> |> satisfy(&Enum.member?([?a, ?e, ?i, ?o, ?u], &1), "expected a voyel")
      ...(29)> voyel_parser.("a")
      {:ok, ?a, ""}
      ...(29)> voyel_parser.("b")
      {:error, "expected a voyel"}

  """
  def satisfy(parser, fun, error_message \\ nil, name \\ "") do
    parser_ = _make_parser(parser)
    fn input ->
      with {:ok, result, rest} <- parser_.(input) do
        if fun.(result),
          do: {:ok, result, rest},
          else: _error_message(error_message || "unsatisified parser", name)
      end
    end
  end

  @doc ~S"""
  sequence combines a list of parser to a parser that succeeds only if all parsers
  in the list succeed one after each other

      iex(30)> char_range = [?a..?z, ?A..?Z, ?_]
      ...(30)> initial_char_parser = char_range_parser(char_range, "leading identifier char")
      ...(30)> ident_parser = sequence(
      ...(30)>   [ initial_char_parser,
      ...(30)>     choice([initial_char_parser, digit_parser()]) |> many() ])
      ...(30)> ident_parser.("a42-")
      {:ok, [?a, ?4, ?2], "-"}
      ...(30)> ident_parser.("2a42-")
      {:error, ""}
      ...(30)> ident_parser.("_-")
      {:ok, [?_, []], "-"}

  The result of the last doctest above also shows how many might return an empty list which combines
  badly that is why the built in identifier parser maps the result with `&IO.chardata_to_string`

      iex(31)> pwd_parser = sequence(["s", "e", "c", "r", "e", "t"])
      ...(31)> pwd_parser.("secret")
      {:ok, 'secret', ""}
      ...(31)> pwd_parser.("secre")
      {:error, "unexpected end of input in char_parser"}

  """
  def sequence(parsers) do
    parsers |> Enum.map(&_make_parser/1) |> _sequence()
  end

  @doc ~S"""
  skip parses over a range of characters but ignoring them in the result
  a typical use case is to skip whitespace
  **N.B.** that it never fails, if you need to assure the presence of a
  character but ignoring it use `skip!`

      iex(32)> skip_ws = skip([9, 10, 32])
      ...(32)> skip_ws.("a b")
      {:ok, "", "a b"}
      ...(32)> skip_ws.(" \t\na b")
      {:ok, "", "a b"}
      ...(32)> skip_ws.("  ")
      {:ok, "", ""}

  the more convient form is to use shortcut strings here too

      iex(33)> skip_ws = skip(" \t\n")
      ...(33)> skip_ws.("a b")
      {:ok, "", "a b"}
      ...(33)> skip_ws.(" \t\na b")
      {:ok, "", "a b"}
      ...(33)> skip_ws.("  ")
      {:ok, "", ""}
  """
  def skip(char_range) do
    char_range
    |> char_range_parser()
    |> many()
    |> map(fn _ -> "" end)
  end

  @doc ~S"""
  like skip but returns an error if no char in the range was found

      iex(34)> skip_ws = skip!([9, 10, 32], "need ws here")
      ...(34)> skip_ws.("a b")
      {:error, "need ws here"}
      ...(34)> skip_ws.(" \t\na b")
      {:ok, "", "a b"}
      ...(34)> skip_ws.("  ")
      {:ok, "", ""}

  and again...

      iex(35)> skip_ws = skip!(" \t\n", "need ws here")
      ...(35)> skip_ws.("a b")
      {:error, "need ws here"}
      ...(35)> skip_ws.(" \t\na b")
      {:ok, "", "a b"}
      ...(35)> skip_ws.("  ")
      {:ok, "", ""}
  """
  def skip!(char_range, name \\ "") do
    char_range
    |> char_range_parser()
    |> many!(1, name)
    |> map(fn _ -> "" end)
  end

  @doc ~S"""
  up_to is somehow the contrary to char_range |> many it never fails, because of the many and
  parses all characters up to the terminations char sets

        iex(36)> no_spaces = up_to([32, 10])
        ...(36)> no_spaces.("a b")
        {:ok, "a", " b"}
        ...(36)> no_spaces.(" b")
        {:ok, "", " b"}
        ...(36)> no_spaces.("ab")
        {:ok, "ab", ""}

  and the more convenient

        iex(37)> no_spaces = up_to("\n ")
        ...(37)> no_spaces.("a b")
        {:ok, "a", " b"}
        ...(37)> no_spaces.(" b")
        {:ok, "", " b"}
        ...(37)> no_spaces.("ab")
        {:ok, "ab", ""}
  """
  def up_to(terminations)
  def up_to(terminations) when is_binary(terminations) do
    terminations
    |> String.to_charlist
    |> up_to()
  end

  def up_to(terminations) do
    char_parser()
    |> satisfy(fn char -> !_in_range?(char, terminations) end)
    |> many()
    |> map(&to_string/1)
  end

  #
  # Private Functions
  # =================

  defp _choice(parsers, name) do
    fn input ->
      case parsers do
        [] ->
          {:error, "no choice succeeded #{name}"}

        [hd_parser | tl_parsers] ->
          case hd_parser.(input) do
            {:ok, _, _} = result -> result
            _ -> _choice(tl_parsers, name).(input)
          end
      end
    end
  end

  defp _error_message(message, name) do
    {:error,
     "#{message} #{name}"
     |> String.trim_trailing()}
  end

  defp _in_range?(element, ranges) do
    ranges
    |> Enum.any?(fn
      %Range{} = r -> Enum.member?(r, element)
      [_ | _] = l -> _in_range?(element, l)
      x -> element == x
    end)
  end

  defp _make_parser(string_or_fun)

  defp _make_parser(number) when is_number(number),
    do: [number] |> char_range_parser()

  defp _make_parser(string) when is_binary(string),
    do: string |> String.to_charlist() |> char_range_parser()

  defp _make_parser(fun) when is_function(fun),
    do: fun

  defp _many(parser) do
    fn input ->
      case parser.(input) do
        {:error, _reason} ->
          {:ok, [], input}

        {:ok, first_term, rest} ->
          {:ok, rest_terms, rest1} = _many(parser).(rest)
          {:ok, [first_term | rest_terms], rest1}
      end
    end
  end

  defp _many!(parser, n, name) do
    fn input ->
      case parser.(input) do
        {:error, _reason} ->
          if n > 0 do
            _error_message("many! failed with #{n} parser steps missing", name)
          else
            {:ok, [], input}
          end

        {:ok, first_term, rest} ->
          with {:ok, rest_terms, rest1} <- _many!(parser, n - 1, name).(rest),
               do: {:ok, [first_term | rest_terms], rest1}
      end
    end
  end

  defp _sequence(parsers) do
    fn input ->
      case parsers do
        [] ->
          {:ok, [], input}

        [fst_parser | rst_parsers] ->
          with {:ok, ast, rest} <- fst_parser.(input),
               {:ok, ast1, rest1} <- sequence(rst_parsers).(rest),
               do: {:ok, [ast | ast1], rest1}
      end
    end
  end
end
#  SPDX-License-Identifier: Apache-2.0
