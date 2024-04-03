defmodule EarmarkParser.Helpers.StringHelpers do

  @moduledoc false

  @doc """
  Remove the leading part of a string
  """
  def behead(str, ignore) when is_integer(ignore) do
    {_pre, post} = String.split_at(str, ignore)
    post
  end

  def behead(str, leading_string) do
    behead(str, String.length(leading_string))
  end

  # @doc ~S"""
  # Makes an IO object containing `number` repetitions of `str`
  # """
  # def repeat_to_iodata(str, number) do
  #   [str] 
  #   |> Stream.cycle 
  #   |> Enum.take(number)
  # end

  def tokenize(tokens, input)
  def tokenize([], _), do: nil
  def tokenize([{token, rgx}|rest], input) do
    case Regex.run(rgx, input) do
      [match] -> {token, match, behead(input, match)}
      nil -> tokenize(rest, input) 
    end
  end
end
# SPDX-License-Identifier: Apache-2.0
