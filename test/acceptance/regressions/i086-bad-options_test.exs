defmodule Test.Acceptance.Regressions.I086BadOptionsTest do
  use ExUnit.Case

  describe "cannot corrupt the internal messages option" do
    test "messages as a list → deprecation warning and no exception" do
      ast = [{"p", [], ["some text"], %{}}]
      messages = [{:deprecated, 0, "messages is an internal option that is ignored and will be removed from the API in v1.5.1"}]

      assert EarmarkParser.as_ast("some text", messages: []) == {:ok, ast, messages}
    end

    test "messages as a non empty list → deprecation warning, no exception and message ignored  " do
      ast = [{"p", [], ["some text"], %{}}]
      messages = [{:deprecated, 0, "messages is an internal option that is ignored and will be removed from the API in v1.5.1"}]

      assert EarmarkParser.as_ast("some text", messages: [{:error, 0, "blue screen"}]) == {:ok, ast, messages}
    end

    test "default options still ok" do
      assert EarmarkParser.as_ast("some text") == {:ok, [{"p", [], ["some text"], %{}}], []}
    end
  end
end
#  SPDX-License-Identifier: Apache-2.0
