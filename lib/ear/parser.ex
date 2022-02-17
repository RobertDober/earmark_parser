defmodule Ear.Parser do
  @moduledoc ~S"""
  Implements version 1.5.* of the Parser
  """
  alias Ear.{Line, State}

  def parse(lines, options) do
    state = lines
    |> State.new(options)
    |> parse()
    |> State.result
  end

  def parse(state) do
    case State.next(state) do
      %{token: nil}=state1 -> state1 |> State.close_block
      state2 -> _parse(state2)
    end
  end

  @doc false
  def _parse(state) do
    case state.token() do
      %Line.Blank{} -> state |> State.close_block |> parse()
      %Line.Text{} -> state|>  State.add_text |> parse()
      token -> state |> State.add_error("unexpected token #{inspect token}") |> State.next |> parse()
    end
  end

end

# SPDX-License-Identifier: Apache-2.0
