defmodule Test.Functional.Inline.Converter.ComplexConversionTest do
  use Support.InlineConverterCase

  describe "link_and_image:" do
    test "image inside link" do
      markdown = "[![moon](moon.jpg)](/uri)\n"

      expected = [
        "\n",
        {"a", [{"href", "/uri"}], [{"img", [{"src", "moon.jpg"}, {"alt", "moon"}], [], %{}}], %{}}
      ]

      assert convert(markdown) == expected
    end
  end

  describe "footnotes" do
    test "defined footnote" do
      markdown = " foo[^1] again"

      expected = [
        " again",
        {"a",
         [{"href", "#fn:1"}, {"id", "fnref:1"}, {"class", "footnote"}, {"title", "see footnote"}],
         ["1"], %{}},
        " foo"
      ]

      assert convert_with_footnotes(markdown, "1") == expected
    end

    test "undefined footnote" do
      markdown = " foo[^1] again"
      expected = [" foo[^1] again"]
      assert convert_with_footnotes(markdown, "2") == expected
    end
  end

  describe "pure links" do
    @link "http://www.google.com/search?q=business"

    test "a link inside parens" do
      markdown = "(#{@link})"

      expected = [
        ")",
        {"a", [{"href", "http://www.google.com/search?q=business"}],
         ["http://www.google.com/search?q=business"], %{}},
        "("
      ]

      assert convert(markdown) == expected
    end

    test " a link" do
      expected = [
        {"a", [{"href", "http://www.google.com/search?q=business"}],
         ["http://www.google.com/search?q=business"], %{}}
      ]

      assert convert(@link) == expected
    end
  end

  describe "reflink:" do
    test "image with title" do
      markdown = "[foo]: /url \"title\"\n\n![foo]\n"
      expected = ["[foo]: /url \"title\"\n\n![foo]\n"]
      assert convert(markdown) == expected
    end

    test "no image, url and title" do
      markdown = "[] [reference]"
      expected = [{"a", [{"href", "url1"}, {"title", "title1"}], [], %{}}]
      assert convert_with_reflink(markdown, "reference", "url1", "title1") == expected
    end

    test "no image, no title" do
      markdown = "[text] []"
      expected = ["[text] []"]
      assert convert_with_reflink(markdown, "reference", "url3", "title3") == expected
    end

    test "image" do
      markdown = "![text] [reference]\n[reference]: some_url 'a title'"

      expected = [
        ": some_url 'a title'",
        {"a", [{"href", "url2"}, {"title", "title2"}], ["reference"], %{}},
        "\n",
        {"img", [{"src", "url2"}, {"alt", "text"}, {"title", "title2"}], [], %{}}
      ]

      assert convert_with_reflink(markdown, "reference", "url2", "title2") == expected
    end
  end

  describe "wikilinks" do
    test "if enabled" do
      markdown = "[[page]]"
      expected = [a("page", [href: "page"], %{wikilink: true})]

      assert convert(markdown, wikilinks: true) == expected
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
