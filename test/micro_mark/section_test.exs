defmodule Test.MicroMark.SectionTest do
  use Support.MicroMarkCase

  # A section starts with a line "# <text>" and continues on until a new block level element is encountered
  describe "section" do
    test "empty, no section" do
      assert parse("") == []
    end

    test "one section" do
      assert parse("# hello") == [{:section, ["hello"]}]
    end

    test "two sections" do
      assert parse("# hello\n# world") == [{:section, ["hello"]}, {:section, ["world"]}]
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
