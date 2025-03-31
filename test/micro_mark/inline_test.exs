defmodule Test.MicroMark.InlineTest do
  use Support.MicroMarkCase

  # A section starts with a line "# <text>" and continues on until a new block level element is encountered

  describe "text" do
    test "no inline" do
      assert parse("just text") == ["just text"]
    end
  end

  describe "emphasis" do
    test "... in the middle" do
      assert parse("just _important_ text") == ["just ", {:emph, ["important"]}, " text"]
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
