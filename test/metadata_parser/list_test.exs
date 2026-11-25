defmodule Test.MetadataParser.ListTest do
  use Support.MetadataTestCase

  describe "lists" do
    test "an empty list" do
      assert_parse(" [  ]", [])
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
