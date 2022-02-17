defmodule Ear.Pending do
  @moduledoc false

  defstruct backtix: nil,
            lnb: 0

  def new, do: %__MODULE__{}
  def new(btx, lnb), do: %__MODULE__{backtix: btx, lnb: lnb}

  # Check if after the line of the current token we are still inside an inline code block
  # def inline_code_open?(state)
  # def inline_code_open?(%{token: %{line: line}, lnb: lnb, pending: %{backtix: nil}}), do: _opens_inline_code?(line, lnb)
  # def inline_code_open?(%{token: %{line: line}, lnb: lnb, pending: pending}), do: _still_inline_code?(line, lnb, pending)

  # defp _opens_inline_code?(line, lnb)  do
  #   case tokenize(line, with: :string_lexer) |> _has_still_opening_backtix?(nil) do
  #     nil -> new()
  #     {_, btx} -> new(btx, lnb)
  #   end
  # end

  # defp _still_inline_code(line, lnb, %__MODULE__{backtix: btx, lnb: pending_lnb}) do
  #   case tokenize(line, with: :string_lexer) |> _has_still_opening_backtix?({:old, btx}) do
  #     nil -> {nil, 0}
  #     {:new, btx} -> {btx, lnb}
  #     {:old, _} -> old
  #   end
  # end

  # defp _has_still_opening_backtix?(tokens, opened_so_far)

  # # Empty, done, but take care of tangeling escape (\)
  # defp _has_still_opening_backtix?([], :force_outside), do: nil
  # defp _has_still_opening_backtix?([], open), do: open

  # # Outside state, represented by nil
  # defp _has_still_opening_backtix?([{:other, _} | rest], nil),
  #   do: _has_still_opening_backtix?(rest, nil)

  # defp _has_still_opening_backtix?([{:backtix, btx} | rest], nil),
  #   do: _has_still_opening_backtix?(rest, {:new, btx})

  # defp _has_still_opening_backtix?([{:escape, _} | rest], nil),
  #   do: _has_still_opening_backtix?(rest, :force_outside)

  # # Next state forced outside, represented by :force_outside
  # defp _has_still_opening_backtix?([_ | rest], :force_outside),
  #   do: _has_still_opening_backtix?(rest, nil)

  # # Inside state, represented by { :old | :new, btx }
  # defp _has_still_opening_backtix?([{:backtix, btx} | rest], open = {_, openedbtx}) do
  #   if btx == openedbtx do
  #     _has_still_opening_backtix?(rest, nil)
  #   else
  #     _has_still_opening_backtix?(rest, open)
  #   end
  # end

  # defp _has_still_opening_backtix?([_ | rest], open = {_, _}),
  #   do: _has_still_opening_backtix?(rest, open)
end


#  SPDX-License-Identifier: Apache-2.0
