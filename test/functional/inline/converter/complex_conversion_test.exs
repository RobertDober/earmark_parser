defmodule Test.Functional.Inline.Converter.ComplexConversionTest do

  use Support.InlineConverterCase

  describe "link_and_image:" do
    test "image inside link" do
      markdown = "[![moon](moon.jpg)](/uri)\n"
      expected = ["\n", {"a", [{"href", "/uri"}], [{"img", [{"src", "moon.jpg"}, {"alt", "moon"}], [], %{}}], %{}}]
      assert convert(markdown) == expected
    end
  end
end
# SPDX-License-Identifier: Apache-2.0
