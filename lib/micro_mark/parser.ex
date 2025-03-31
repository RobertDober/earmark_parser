defmodule MicroMark.Parser do
  @moduledoc ~S"""

  """

  use MicroMark.Types
  alias MicroMark.{Functional, Input, NotYetImplemented, State}
  import Functional, only: [compose: 2]

  @spec parse(State.t()) :: State.t()
  def parse(state) do
    case state.input.content do
      "" -> state
      <<_char::utf8, _rest::binary>> -> parse_text(state |> State.new_head)
      _ -> raise NotYetImplemented, :parsing_structure
    end
  end

  def parse_text(state) do
    # IO.inspect(state, label: :parse_text)
    case state.input.content do
      "" -> parse(state |> State.adjust_ast(&IO.chardata_to_string/1))
      <<"\n", rest::binary>> -> parse_text(state |> State.append_char(10, rest, 1, 1))
      <<char::utf8, rest::binary>> -> parse_text(state |> State.append_char(char, rest))
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
