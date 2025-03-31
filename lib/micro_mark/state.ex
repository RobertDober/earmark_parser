defmodule MicroMark.State do
  @moduledoc ~S"""
  """
  use MicroMark.Types
  alias MicroMark.Input

  defstruct ast: [], input: %Input{}, errors: []

  @type t :: %__MODULE__{ast: ast(), input: Input.t(), errors: binaries()}

  @spec adjust_ast(t(), (ast() -> ast())) :: t()
  def adjust_ast(%__MODULE__{ast: [ast_node | ast]} = state, adjuster) do
    new_ast_node = adjuster.(ast_node)

    # IO.inspect(ast, label: :before_adjust)
    %{
      state
      | ast: [new_ast_node | ast]
        # |> IO.inspect() 
    }
  end

  @spec append_char(t(), natural(), binary(), natural(), natural()) :: t()
  def append_char(%__MODULE__{ast: [head|tail]}=state, char, rest, colinc \\ 1, lnbinc \\ 0) do
    %{
      state
      | ast: [[head, char]|tail],
        input: Input.update(state.input, rest, lnbinc, colinc)
    }
  end

  @spec new(binary(), positive(), positive()) :: t()
  def new(content, lnb \\ 1, col \\ 1) do
    %__MODULE__{input: Input.new(content, lnb, col)}
  end

  @spec new_head(t()) :: t()
  def new_head(%__MODULE__{} = state) do
    %{
      state
      | ast: [[] | state.ast]
    }
  end

  @spec new_line(t()) :: t()
  def new_line(%__MODULE__{} = state) do
    %{
      state
      | input: Input.new_line(state.input)
    }
  end

  @spec push(t(), any(), binary(), natural(), natural()) :: t()
  def push(state, element, rest, colinc \\ 1, lnbinc \\ 0) do
    new_element = _make_ast_node(element)

    %{
      state
      | ast: [new_element | state.ast],
        input: Input.update(state.input, rest, lnbinc, colinc)
    }
  end

  @spec result(t()) :: result()
  def result(res)

  def result(%__MODULE__{ast: ast, errors: []}) do
    {:ok, ast}
  end

  def result(%__MODULE__{} = res) do
    {:error, res.errors}
  end

  @spec _make_ast_node(any) :: ast_node
  defp _make_ast_node(element)

  defp _make_ast_node(element) when is_integer(element) do
    [element]
  end

  defp _make_ast_node(element) do
    element
  end
end

# SPDX-License-Identifier: Apache-2.0
