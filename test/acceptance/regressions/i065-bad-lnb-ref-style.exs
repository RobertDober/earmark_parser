defmodule Test.Acceptance.Regressions.I065BadLnbRefStyleTest do

  use ExUnit.Case

  @min_case """
  * top

    * one[][foo] `

  [foo]: # "bar"
  """

  test "line number too great" do
    {:error, _ast, [message]} = EarmarkParser.as_ast(@min_case)
    assert message == {:warning, 3, "Closing unclosed backquotes ` at end of input"}
  end

  @max_case """
  * top 
    `

    * zero

    * one[][foo]

    * two

    * three

  [foo]: # "bar"
  """
  test "top was off by four" do
    {:error, _ast, [message]} = EarmarkParser.as_ast(@max_case)
    assert message == {:warning, 2, "Closing unclosed backquotes ` at end of input"}
  end

  @nonreg_case """
  * top

    * a

    * b`
  """
  test "line number ok" do
    {:error, _ast, [message]} = EarmarkParser.as_ast(@nonreg_case)
    assert message == {:warning, 5, "Closing unclosed backquotes ` at end of input"}
  end

  @level_1 """
  * hello

  * world `
  """
  test "level1" do
    {:error, _ast, [message]} = EarmarkParser.as_ast(@level_1)
    assert message == {:warning, 3, "Closing unclosed backquotes ` at end of input"}
  end
end
#  SPDX-License-Identifier: Apache-2.0
