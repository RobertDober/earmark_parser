defmodule Acceptance.Regressions.I002AcceptAnyStructAsOptionTest do
  use ExUnit.Case

  import EarmarkParser, only: [as_ast: 2]

  defmodule MyStruct do
    defstruct pure_links: false
  end

  describe "can parse with MyStruct" do
    @markdown "see https://my.site.com"
    test "pure_links deactivated" do
      ast = [{"p", [], [@markdown], %{}}]

      assert as_ast(@markdown, %MyStruct{}) == {:ok, ast, []}
    end

    test "or activated" do
      ast =
        [{"p", ~c"", ["see ", {"a", [{"href", "https://my.site.com"}], ["https://my.site.com"], %{}}], %{}}]

      assert as_ast(@markdown, %MyStruct{pure_links: true}) == {:ok, ast, []}
    end
  end
end
