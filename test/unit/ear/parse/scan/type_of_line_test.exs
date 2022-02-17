defmodule Test.Unit.Ear.Parse.Scan.TypeOfLineTest do
  use ExUnit.Case, async: true
  alias Ear.Line
  import Ear.LineScanner, only: [type_of: 1]

  describe "opening inline" do
    test "in the middle" do
      result = type_of("a `b")

      assert result == {%Line.Text{line: "a `b", indent: 0, content: "a "}, "`b"}
    end
  end

end
# SPDX-License-Identifier: Apache-2.0
