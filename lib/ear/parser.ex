defmodule Ear.Parser do
  @moduledoc ~S"""
  Implements version 1.5.* of the Parser
  """
  alias Ear.{Line, State}

  def parse(lines, options) do
    state = lines
    |> State.new(options)

    parse({:ok, state})
    |> State.result
  end

  def parse(state_tuple)
  def parse({:ok, state}), do: _parse(state)
  def parse({_, state}), do: state |> State.close_ast

  @doc false
  def _parse(state) do
    case state.token do
      %Line.Blank{} -> state |> State.close_para |> parse()
      %Line.Text{} -> state |> State.add_text |> parse()
      token -> {:error, state |> State.add_error("unexpected token #{inspect token}")}
    end
  end

end

# SPDX-License-Identifier: Apache-2.0
