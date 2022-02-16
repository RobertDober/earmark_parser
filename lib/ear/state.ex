defmodule Ear.State do
  @moduledoc ~S"""
  The global parse state (replaces Context for most purposes)
  """

  alias Ear.{Ast, Line, LineScanner, Options}

  defstruct ast: [], # Will become a list of Ast tuples
    input: [],
    lnb: 0,
    messages: MapSet.new,
    needed_indent: 0,
    options: %Options{},
    token: nil # Ear.Line.*

  @self __MODULE__

  def close_ast(%@self{ast: ast}=state) do
    %{state | ast: Ast.close_ast(ast)}
  end

  def new(input, options)
  def new(input, %Options{}=options) do
    %@self{
      input: input,
      options: options} |> make_token
  end
  def new(input, options) do
    new(input, options |> Options.normalize)
  end


  def add_error(%@self{messages: messages, lnb: lnb}=state, message) do
    %{state|messages: MapSet.put(messages, {:error, lnb, message})}
  end

  def add_text(%@self{token: token, ast: ast}=state) do
    ast_ = Ast.add_text(ast, token.content)
    %{state|ast: ast_} |> next()
  end

  def make_errors(messages \\ []) do
    {:error, MapSet.new(messages)}
  end

  def make_token(state)
  def make_token(%{input: []}=state) do
    %{state|token: nil}
  end
  def make_token(%{input: [h|t]}=state) do
    token = LineScanner.type_of(h, state.options, false)
    _push_token(state, token, t)
  end

  def next(state)
  def next(%{input: []}=state), do: {:eos, state}
  def next(%{needed_indent: 0}=state) do
    {:ok, make_token(state)|>_debug()}
  end
  def next(%{input: [h|t], needed_indent: needed_indent}=state) do
    case LineScanner.type_of(h, state.options, false) do
      %Line.Blank{} = token -> {:ok, _push_token(state, token, t)}
      token -> if token.indent >= needed_indent do
        token_ = h |> String.slice(needed_indent..-1) |> LineScanner.type_of(false)
        {:ok, _push_token(state, token_, t)}
      else
        {:outdent, state}
      end

    end
  end

  def result(state)
  def result(%__MODULE__{ast: ast, messages: messages}) do
    {_status(messages), Ast.normalize(ast), Enum.sort(messages)}
  end

  defp _debug(%@self{}=state) do
    fields = System.get_env("DBG")
    if fields do
      IO.inspect(_fields(state, fields))
      state
    else
      state
    end
  end

  defp _error?(message)

  defp _error?({:warning, _, _}), do: false
  defp _error?(_), do: true

  defp _fields(state, fields) do
    fields
    |> String.split(",")
    |> Enum.reduce(%{}, fn n, a -> n_ = n |> String.to_atom; Map.put(a, n_, Map.get(state, n_)) end)
  end

  defp _push_token(%{lnb: lnb}=state, token, input), do: %{state|input: input, lnb: lnb + 1, token: token}

  defp _status(messages) do
    if Enum.any?(messages, &_error?/1) do
      :error
    else
      :ok
    end
  end

end
# SPDX-License-Identifier: Apache-2.0
