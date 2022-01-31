defmodule Test.Debug.DebugListsTest do
  use Support.AcceptanceTestCase
  import Support.AstHelpers, only: [ast_from_md: 1]

  describe "debugging the list parser's structural problem" do
    test "ASAP" do
      markdown = """
      * Header

        Text 1

        * Inner

        Text 2
      """
      markdown |> ast_from_md |> IO.inspect
    end
  end
end
#  SPDX-License-Identifier: Apache-2.0
