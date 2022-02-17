defmodule Test.Unit.Ear.Parse.InlineCodeTest do
  use Support.EarTestCase

  describe "in one line" do
    test "nothing around" do
      result = parse("`alpha`")
      expected = ok("p", [block("pre", "alpha", class: "inline")])
      assert result == expected
    end
  end

end
#  SPDX-License-Identifier: Apache-2.0
