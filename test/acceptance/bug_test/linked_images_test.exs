defmodule Acceptance.BugTest.LinkedImagesTest do
  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1]
  import EarmarkAstDsl, only: [p: 1, tag: 3]

  test "consecutive reference-style linked images" do
    markdown = """
    [![Badge 1][img1]][url1] [![Badge 2][img2]][url2]

    [img1]: https://google.com/logo.png
    [img2]: https://yahoo.com/logo.png
    [url1]: https://google.com
    [url2]: https://yahoo.com
    """

    expected_ast = [
      p([
        tag("a", [tag("img", [], src: "https://google.com/logo.png", alt: "Badge 1", title: "")],
          href: "https://google.com",
          title: ""
        ),
        " ",
        tag("a", [tag("img", [], src: "https://yahoo.com/logo.png", alt: "Badge 2", title: "")],
          href: "https://yahoo.com",
          title: ""
        )
      ])
    ]

    assert as_ast(markdown) == {:ok, expected_ast, []}
  end

  test "single reference-style linked image" do
    markdown = """
    [![Badge 1][img1]][url1]

    [img1]: https://google.com/logo.png
    [url1]: https://google.com
    """

    expected_ast = [
      p([
        tag("a", [tag("img", [], src: "https://google.com/logo.png", alt: "Badge 1", title: "")],
          href: "https://google.com",
          title: ""
        )
      ])
    ]

    assert as_ast(markdown) == {:ok, expected_ast, []}
  end

  test "normal multiple images" do
    markdown = """
    [![Badge 1](https://google.com/logo.png)](https://google.com) [![Badge 2](https://yahoo.com/logo.png)](https://yahoo.com)
    """

    expected_ast = [
      p([
        tag("a", [tag("img", [], src: "https://google.com/logo.png", alt: "Badge 1")], href: "https://google.com"),
        " ",
        tag("a", [tag("img", [], src: "https://yahoo.com/logo.png", alt: "Badge 2")], href: "https://yahoo.com")
      ])
    ]

    assert as_ast(markdown) == {:ok, expected_ast, []}
  end
end
