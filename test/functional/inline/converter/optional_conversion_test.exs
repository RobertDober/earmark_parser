defmodule Test.Functional.Inline.Converter.OptionalConversionTest do
  use Support.InlineConverterCase

  describe "line breaks:" do
    test "classic br" do
      assert convert("  \n ") == [" ", {"br", [], [], %{}}]
    end

    test "no br" do
      assert convert(" \na") == [" \na"]
    end

    test "hard breaks" do
      assert convert(" \na", breaks: true) == ["a", {"br", [], [], %{}}]
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
