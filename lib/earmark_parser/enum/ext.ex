defmodule EarmarkParser.Enum.Ext do
  @moduledoc ~S"""
    Some extensions of Enum functions
  """

  @doc ~S"""
  `reduce_with_end` is like `Enum.reduce` for lists, but the reducer function is called for
  each element of the list with the tuple `{:element, element}` and the accumulator and once
  more at the end with `:end` and the accumulator

      iex(1)> reducer =
      ...(1)>   fn {:element, nil}, {partial, result} -> {[], [Enum.sum(partial)|result]}
      ...(1)>      {:element, val}, {partial, result} -> {[val|partial], result}
      ...(1)>      :end,            {partial, result} -> [Enum.sum(partial)|result] |> Enum.reverse
      ...(1)>   end
      ...(1)> [1, 2, nil, 4, 1, 0, nil, 3, 2, 2]
      ...(1)> |> reduce_with_end({[], []}, reducer)
      [3, 5, 7]

  **N.B.** that in the treatment of `:end` we can change the shape of the accumulator w/o any
  penalty concerning the complexity of the reducer function
  """
  def reduce_with_end(collection, initial_acc, reducer_fn)
  def reduce_with_end([], acc, reducer_fn) do
    reducer_fn.(:end, acc)
  end
  def reduce_with_end([ele|rest], acc, reducer_fn) do
    reduce_with_end(rest, reducer_fn.({:element, ele}, acc), reducer_fn)
  end

  @doc ~S"""
  `split_reduce_while` is like `Enum.split_while` but also reduces the first
  part of what `split_while` would return. The reducer function is called with
  the same protocol as in `reduce_with_end`, meaning with `{:element, ele}` and
  the accumulator.

  The reducer function however needs to obey the same return protocol as in
  `Enum.reduce_while` meaning to return tuples of the form `{:cont, accumulator}`
  or `{:halt, accumulator}`

  If and only if the `include_end?` switch is set to true the reducer function is
  also called with `{:end, rest}` and the accumulator after it has returned {:halt, accumulator}

      iex(2)> reducer =
      ...(2)>   fn {:element, :sub}, acc -> {:halt, acc}
      ...(2)>      {:element, :add}, acc -> {:cont, acc}
      ...(2)>      {:element, val}, acc -> {:cont, acc + val} end
      ...(2)> [1, :add, 2, :sub, 3]
      ...(2)> |> split_reduce_while(0, reducer)
      {[:sub, 3], 3}

  And now with `include_end?`

      iex(2)> reducer =
      ...(2)>   fn {:element, :sub}, acc -> {:halt, acc}
      ...(2)>      {:element, :add}, acc -> {:cont, acc}
      ...(2)>      {:element, val},  acc -> {:cont, acc + val}
      ...(2)>      {:end, [_|vals]}, acc -> {vals, acc} end
      ...(2)> [1, :add, 2, :sub, 3]
      ...(2)> |> split_reduce_while(0, reducer, true)
      {[3], 3}
  """
  def split_reduce_while(collection, initial_acc, reducer_fn, include_end? \\ false)
  def split_reduce_while([], acc, reducer_fn, include_end?) do
    if include_end? do
      { [], reducer_fn.(:end, acc) }
    else
      { [], acc }
    end
  end
  def split_reduce_while([h|t] =  l, acc, reducer_fn, include_end?) do
    case reducer_fn.({:element, h}, acc) do
      {:cont, acc1} -> split_reduce_while(t, acc1, reducer_fn, include_end?)
      {:halt, acc2} ->
        if include_end? do
          reducer_fn.({:end, l}, acc)
        else
          {l, acc2}
        end
    end
  end
end
#  SPDX-License-Identifier: Apache-2.0
