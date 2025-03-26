defmodule Support.NimbleTests do
  @moduledoc ~S"""
  Makes asserting on NimbleParsec results simpler
  """
  defmacro parsed_error(parsed, expected) do
    quote do
    {:error, message, _, _, _, _} = unquote(parsed) # |> IO.inspect() 
      assert message == unquote(expected)
    end
  end

  defmacro parsed_ok(parsed, expected) do
    quote do
    {:ok, result, _, _, _, _} = unquote(parsed) # |> IO.inspect() 
      assert result == unquote(expected)
    end
  end
end
# SPDX-License-Identifier: Apache-2.0
