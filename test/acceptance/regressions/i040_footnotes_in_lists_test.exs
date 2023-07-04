defmodule Test.Acceptance.Regressions.I040FootnotesInListsTest do
  use Support.AcceptanceTestCase

  @min_case """
  * here is a footnote in a list[^1]

  end
  [^1]: my footnote from the list
  """
  test "min case" do
    {:ok, ast, []} = EarmarkParser.as_ast(@min_case, footnotes: true)

    expected = [
      {"ul", [],
       [
         {"li", [],
          [
            "here is a footnote in a list",
            {"a",
             [
               {"href", "#fn:1"},
               {"id", "fnref:1"},
               {"class", "footnote"},
               {"title", "see footnote"}
             ], ["1"], %{}}
          ], %{}}
       ], %{}},
      {"p", [], ["end"], %{}},
      {"div", [{"class", "footnotes"}],
       [
         {"hr", [], [], %{}},
         {"ol", [],
          [
            {"li", [{"id", "fn:1"}],
             [
               {"a",
                [
                  {"class", "reversefootnote"},
                  {"href", "#fnref:1"},
                  {"title", "return to article"}
                ], ["&#x21A9;"], %{}},
               {"p", [], ["my footnote from the list"], %{}}
             ], %{}}
          ], %{}}
       ], %{}}
    ]

    assert_asts_are_equal(ast, expected)
  end

  @ok_case """
  here is a footnote in a list[^1]

  [^1]: my footnote from the list
  """
  test "ok case" do
    {:ok, ast, []} = EarmarkParser.as_ast(@ok_case, footnotes: true)

    expected = [
      {"p", [],
       [
         "here is a footnote in a list",
         {"a",
          [
            {"href", "#fn:1"},
            {"id", "fnref:1"},
            {"class", "footnote"},
            {"title", "see footnote"}
          ], ["1"], %{}}
       ], %{}},
      {"div", [{"class", "footnotes"}],
       [
         {"hr", [], [], %{}},
         {"ol", [],
          [
            {"li", [{"id", "fn:1"}],
             [
               {"a",
                [
                  {"class", "reversefootnote"},
                  {"href", "#fnref:1"},
                  {"title", "return to article"}
                ], ["&#x21A9;"], %{}},
               {"p", [], ["my footnote from the list"], %{}}
             ], %{}}
          ], %{}}
       ], %{}}
    ]

    assert_asts_are_equal(ast, expected)
  end
end
