defmodule EarmarkParser.Peg do
  @moduledoc ~S"""
  A PEG implementation
  """

  defstruct input: [], ast: nil, parse_stack: []

  @typep numbered_lines_t :: list({non_neg_integer, String.t()})
  @type t :: %__MODULE__{
          input: numbered_lines_t(),
          ast: any(),
          parse_stack: list(atom)
        }

  @spec new([String.t()]) :: t()
  def new(lines) do
    %__MODULE__{input: lines |> _number_lines()}
  end

  @spec _number_lines([String.t()], non_neg_integer()) :: numbered_lines_t()
  defp _number_lines(lines, from_start \\ 1) do
    Stream.iterate(from_start, &(&1 + 1))
    |> Stream.zip(lines)
    |> Enum.into([])
  end
end

# SPDX-License-Identifier: Apache-2.0
