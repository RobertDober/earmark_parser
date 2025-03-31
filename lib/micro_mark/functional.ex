defmodule MicroMark.Functional do
  @moduledoc ~S"""
  
  """
  use MicroMark.Types

  @spec compose(unary_fn(), unary_fn()) :: unary_fn()
  def compose(fn1, fn2) do
    fn input ->
      intermediate = fn1.(input)
      fn2.(intermediate)
    end
  end
  
end
# SPDX-License-Identifier: Apache-2.0
