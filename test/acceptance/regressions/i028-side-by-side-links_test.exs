defmodule Test.Acceptance.Regressions.I028Test do
  use ExUnit.Case

  use ExUnit.Case, async: true
  import Support.Helpers, only: [as_ast: 1]
  import EarmarkAstDsl

  describe "correct behavior" do
    test "simple image link" do
      markdown = """
      ![img][href]

      [href]: some_url
      """
      ast      = [ p(img([src: "some_url", alt: "img", title: ""])) ]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
    test "side by side" do
      markdown = """
      ![Crate][crate_img][crate]

      [crate_img]:   https://img.shields.io/crates/v/calm_io.svg "Crate Version Display"
      [crate]:       https://crates.io/crates/calm_io "Crate Link"
      """
      ast      = [ p(
                   [img(src:  "https://img.shields.io/crates/v/calm_io.svg", alt: "Crate", title: "Crate Version Display"),
                    a(["crate", href:  "https://crates.io/crates/calm_io", title:  "Crate Link"])]) ]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
    test "two side by side" do
      markdown = """
      ![Crate][crate_img][crate]
      ![Second][second_img][second_link]

      [crate_img]:   https://img.shields.io/crates/v/calm_io.svg "Crate Version Display"
      [crate]:       https://crates.io/crates/calm_io "Crate Link"
      [second_img]:  image_url "ImgTitle"
      [second_link]: link_url "LinkTitle"
      """
      ast      = [ p(
                   [
                     img(src:  "https://img.shields.io/crates/v/calm_io.svg", alt: "Crate", title: "Crate Version Display"),
                     a(["crate", href:  "https://crates.io/crates/calm_io", title:  "Crate Link"]), "\n",
                     img(src:  "image_url", alt: "Second", title: "ImgTitle"),
                     a(["second_link", href:  "link_url", title:  "LinkTitle"]),

                  ]) ]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
    test "image as link content" do
      markdown = """
      [![Crate][crate_img]][crate]

      [crate]:       crate_url "Link"
      [crate_img]:   crate_image_url "Image"
      """
      ast = [
        p( a([img(src: "create_image_url", alt: "Crate", title: "Image"), href: "crate_url", title: "Link", alt: "crate"]) )
      ]
    end
  end

  describe "error suffix removed from enclosing p" do
    test "simple image link with suffix" do
      markdown = """
      ![img][href][world](url)

      [href]: some_url
      """
      ast      = [ p(img(src: "some_url", alt: "img", title: "")), a("url", "world") ]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
    test "simple image link with suffix and space" do
      markdown = """
      ![img][href] [world](url)

      [href]: some_url
      """
      ast      = [ p(img(src: "some_url", alt: "img", title: "")), " ", a("url", "world") ]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  describe "two side by sides" do
    test "image as link content" do
      markdown = """
      [![Img1][img1]][lnk1]

      [lnk1]:       lnk1_url "Link1"
      [img1]:       img1_url "Image1"
      """
      ast = [
        p([
          a([img(src: "img1_url", alt: "Img1", title: "Image1"), href: "lnk1_url", title: "Link1", alt: "lnk1"]),
        ])
      ]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end
  end

  defp a(href, content), do: tag("a", [content], [href: href])
  defp a([content|atts]), do: tag("a", [content], atts)
  defp img(atts), do: tag("img", [], atts)
end
