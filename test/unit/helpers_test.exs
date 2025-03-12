defmodule HelpersTest do
  use ExUnit.Case, async: true
  import EarmarkParser.Helpers

  doctest EarmarkParser.Helpers, import: true

  describe "expand_tabs" do
    test "expand_tab spaces only(1)" do
      assert expand_tabs(" ") == " "
    end

    test "expand_tab spaces only" do
      assert expand_tabs("   ") == "   "
    end

    test "expand_tab tabs only" do
      assert expand_tabs("\t\t") == "        "
    end

    test "expand_tab mixed, 1 space" do
      assert expand_tabs(" \t ") == "     "
    end

    test "expand_tab mixed, 2 spaces" do
      assert expand_tabs("  \t ") == "     "
    end

    test "expand_tab mixed, 3 spaces" do
      assert expand_tabs("   \t ") == "     "
    end
  end

  describe "extract_ial" do
    test "no ial, empty" do
      input = ""
      assert extract_ial(input) == {nil, input}
    end

    test "spaces in IAL" do
      input = "Some Text"
      ial = ".jze ezf \""
      assert extract_ial("#{input}{:#{ial}}") == {ial, input}
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
