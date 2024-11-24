defmodule EarmarkParser.Helpers.StringHelpers do

  @moduledoc false

  @doc """
  Remove the leading part of a string
  """
  def behead(str, ignore) when is_integer(ignore) do
    String.slice(str, ignore..-1)
  end

  def behead(str, leading_string) do
    behead(str, String.length(leading_string))
  end

end
# SPDX-License-Identifier: Apache-2.0
