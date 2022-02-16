defmodule Support.EarHelpers do

  def ok_result(ast)
  def ok_result(ast) when is_list(ast) do
    {:ok, ast, []}
  end
  def ok_result(ast), do: ok_result([ast])

end
#  SPDX-License-Identifier: Apache-2.0
