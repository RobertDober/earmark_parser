defmodule Acceptance.Ast.Lists.ListAndInlineCodeTest do
  use Support.AcceptanceTestCase
  import Support.Helpers, only: [as_ast: 1, parse_html: 1]

  describe "List parsing running into EOI inside inline code" do
    test "simple case" do
      markdown = """
      * And
      `Hello
      * World
      """
      ast      = ul(tag("li", "And\n`Hello\n* World"))
      messages = [{:warning, 2, "Closing unclosed backquotes ` at end of input"}]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

    test "link with title" do
      markdown = ~s(* And\n* `Hello\n* World)
      ast      = tag("ul", [tag("li", "And"), tag("li","`Hello\n* World")])
      messages = [{:warning, 2, "Closing unclosed backquotes ` at end of input"}]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

    test "error in spaced part" do
      markdown = ~s(* And\n  `Hello\n   * World)
      ast      = tag("ul", tag("li", "And\n`Hello\n   * World"))
      messages = [{:warning, 2, "Closing unclosed backquotes ` at end of input"}]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

    test "error in doubly spaced part" do
      markdown = """
      * And

        `Hello
         * World
      """
      ast      = ul(li(tags("p",["And",  "`Hello\n * World"])))
      messages = [{:warning, 3, "Closing unclosed backquotes ` at end of input"}]

      assert as_ast(markdown) == {:error, [ast], messages}
    end

    test "even more complex spaced example (checking for one offs)" do
      markdown = """
      Prefix1
      * And
        Prefix2
        `Hello
         * World
      """
      ast      = [p("Prefix1"), tag("ul", tag("li", ["And\nPrefix2\n`Hello\n   * World"]))]
      messages = [{:warning, 4, "Closing unclosed backquotes ` at end of input"}]

      assert as_ast(markdown) == {:error, ast, messages}
    end
  end

  describe "indentation of code (was regtest #85)" do
    test "losing some indent" do
      markdown = "1. one\n\n    ```elixir\n    defmodule```\n"
      html     = "<ol>\n<li><p>one</p>\n<pre><code class=\"elixir\"> defmodule```</code></pre>\n</li>\n</ol>\n"
      ast      = parse_html(html)
      messages = [{:error, 3, "Fenced Code Block opened with ``` not closed at end of input"}]

      assert as_ast(markdown) == {:error, ast, messages}
    end

    test "less aligned fence is not part of the inline code block" do
      markdown = "1. one\n\n    ~~~elixir\n    defmodule\n  ~~~"
      ast      = [tag("ol", tag("li", [p("one"), tag("pre", tag("code", " defmodule", class: "elixir"))])), pre_code("")]
      messages = [{:error, 3, "Fenced Code Block opened with ~~~ not closed at end of input"}, {:error, 5, "Fenced Code Block opened with ~~~ not closed at end of input"}]

      assert as_ast(markdown) == {:error, ast, messages}
    end

    test "more aligned fence is part of the inline code block" do
      markdown = "  1. one\n    ~~~elixir\n    defmodule\n        ~~~"
      ast      = [tag("ol", tag("li", ["one", tag("pre", tag("code", ["defmodule"], [{"class", "elixir"}]))]))]
      messages = []

      assert as_ast(markdown) == {:ok, ast, messages}
    end

  end
end
