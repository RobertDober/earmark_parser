defmodule Test.Functional.Inline.Converter.SingleConversionTest do
  use Support.InlineConverterCase

  describe "autolinks:" do
    test "autolink, http" do
      assert convert("<http:/mysite>") == [{"a", [{"href", "http:/mysite"}], ["http:/mysite"], %{}}] 
    end
    test "autolink, mailto" do
      assert convert("<http@mysite>") == [{"a", [{"href", "mailto:http@mysite"}], ["http@mysite"], %{}}]
    end
  end

  describe "escape:" do
    test "escape" do
      assert convert("a\\_b") == ~W[a_b] 
    end
    test "escape at beginning" do
      assert convert("\\_b") == ~W[_b] 
    end
    test "escape an escape" do
      assert convert("a\\\\_b") == ~W[a\_b] 
    end
  end

  describe "simple tags" do
    test "strikethrough" do
      assert convert("~~alpha~~") == [{"del", [], ["alpha"], %{}}]
    end
    test "no strikethrough" do
      assert convert("~~ alpha~~") == ["~~ alpha~~"]
    end
  end

end
# SPDX-License-Identifier: Apache-2.0
