defmodule MicroMark.Input do
  @moduledoc ~S"""

  """
  use MicroMark.Types
  defstruct content: "", lnb: 1, col: 1

  @type t :: %__MODULE__{content: binary(), lnb: positive(), col: positive()}

  @spec new(binary(), positive(), positive()) :: t()
  def new(content, lnb \\ 1, col \\ 1) do
    %__MODULE__{content: content, lnb: lnb, col: col}
  end

  @spec new_line(t()) :: t()
  def new_line(input) do
    %{
      input
      | lnb: input.lnb + 1,
        col: 1
    }
  end

  @spec update(t(), binary?(), natural(), natural()) :: t()
  def update(input, content, lnbinc, colinc) do
    new_col =
      if lnbinc == 0 do
        input.col + colinc
      else
        colinc 
      end

    colinc1 = 
    %{
      input
      | content: content || input.content,
        col: new_col,
        lnb: input.lnb + lnbinc
    }
  end
end

# SPDX-License-Identifier: Apache-2.0
