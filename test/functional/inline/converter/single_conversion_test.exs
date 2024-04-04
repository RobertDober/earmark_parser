defmodule Test.Functional.Inline.Converter.SingleConversionTest do
  use Support.InlineConverterCase

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

  describe "autolinks:" do
    test "autolink, http" do
      assert convert("<http:/mysite>") == [{"a", [{"href", "http:/mysite"}], ["http:/mysite"], %{}}] 
    end
    test "autolink, mailto" do
      assert convert("<http@mysite>") == [{"a", [{"href", "mailto:http@mysite"}], ["http@mysite"], %{}}]
    end
  end

  describe "Which converter????:" do
    test "image with title" do
      markdown = "[foo]: /url \"title\"\n\n![foo]\n"
      expected = ["[foo]: /url \"title\"\n\n![foo]\n"]
      assert convert(markdown) == expected
    end
  end

  describe "reflink:" do
    test "no image" do
      markdown = "[Hello](greetings.com)"
      expected = [{"a", [{"href", "greetings.com"}], ["Hello"], %{}}]
      assert convert(markdown) == expected
    end
    
  end
end
# SPDX-License-Identifier: Apache-2.0
