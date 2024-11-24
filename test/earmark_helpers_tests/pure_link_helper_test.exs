defmodule EarmarkParser.Helpers.TestPureLinkHelpers do

  use ExUnit.Case, async: true
  import EarmarkParser.Helpers.PureLinkHelpers, only: [convert_pure_link: 1]
  import EarmarkAstDsl

  describe "Pure Links" do
    test "nothing fancy just a plain link" do
      #                           0....+....1....+...
      result = convert_pure_link("https://a.link.com")
      expected = { a("https://a.link.com", href: "https://a.link.com"), 18}
      assert result == expected
    end

    test "trailing parens are not part of it" do
      #                           0....+....1....+...
      result = convert_pure_link("https://a.link.com)")
      expected = {a("https://a.link.com", href: "https://a.link.com"), 18}
      assert result == expected
    end

    test "closing parens before opening them" do
      #                           0....+....1....+....2....+..
      result = convert_pure_link("https://a.link.com?x=(a)b))")
      expected = {a("https://a.link.com?x=(a)b", href: "https://a.link.com?x=(a)b"), 25}
      assert result == expected
    end

    test "however opening parens are" do
      #                           0....+....1....+...
      result = convert_pure_link("https://a.link.com(")
      expected = {a( "https://a.link.com(", href:  "https://a.link.com("), 19}
      assert result == expected
    end

    test "closing parens inside are ok" do
      #                          0....+....1....+....2....+....3....+....4....+
      result = convert_pure_link("http://www.google.com/search?q=(business))+ok")
      expected = {a( "http://www.google.com/search?q=(business))+ok", href:  "http://www.google.com/search?q=(business))+ok"), 45}
      assert result == expected
    end

    test "closing parens outside are not part of it" do
      #                          0....+....1....+....2....+....3....+....4
      result = convert_pure_link("http://www.google.com/search?q=business)")
      expected = {a("http://www.google.com/search?q=business", href: "http://www.google.com/search?q=business"), 39}
      assert result == expected
    end

    test "parens are legal in query string" do
      #      0....+....1....+....2
      link = "http://test.com?x=("
      result = convert_pure_link(link)
      expected = {a(link, href: link), 19}
      assert result == expected
    end

    test "invalid charecters should not be part of the link" do
      #                          0....+....1....+....2....+
      result = convert_pure_link("https://a.link.com<br/>")
      expected = {a( "https://a.link.com", href:  "https://a.link.com"), 18}
      assert result == expected
    end

    test "trailing parens should be unaffected by unbalanced parens inside" do
      result = convert_pure_link("https://a.link.com/q=foo)+(ok))")
      expected = {tag("a",  "https://a.link.com/q=foo)+(ok)", href:  "https://a.link.com/q=foo)+(ok)"), 30}
      assert result == expected
    end

    test "recognize www. prefix" do
      result = convert_pure_link("www.github.com")
      expected = {tag("a",  "www.github.com", href:  "http://www.github.com"), 14}
      assert result == expected
    end

    test "must start with http:// or https:// or www." do
      result = convert_pure_link("ftp://foo.com")
      expected = nil
      assert result == expected
    end

    test "trailing dot must not be part of the link" do
      result = convert_pure_link("www.github.com.")
      expected = {tag("a",  "www.github.com", href:  "http://www.github.com"), 14}
      assert result == expected
    end
  end
end
#  SPDX-License-Identifier: Apache-2.0
