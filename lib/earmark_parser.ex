        defmodule EarmarkParser do
  @type ast_meta :: map()
  @type ast_tag :: binary()
  @type ast_attribute_name :: binary()
  @type ast_attribute_value :: binary()
  @type ast_attribute :: {ast_attribute_name(), ast_attribute_value()}
  @type ast_attributes :: list(ast_attribute())
  @type ast_tuple :: {ast_tag(), ast_attributes(), ast(), ast_meta()}
  @type ast_node :: binary() | ast_tuple()
  @type ast :: list(ast_node())

  @moduledoc ~S"""

  ### API

  #### EarmarkParser.as_ast

  This is the structure of the result of `as_ast`.

      {:ok, ast, []}                   = EarmarkParser.as_ast(markdown)
      {:ok, ast, deprecation_messages} = EarmarkParser.as_ast(markdown)
      {:error, ast, error_messages}    = EarmarkParser.as_ast(markdown)

  For examples see the functiondoc below.

  #### Options

  Options can be passed into `as_ast/2` according to the documentation of `EarmarkParser.Options`.

      {status, ast, errors} = EarmarkParser.as_ast(markdown, options)

  ## Supports

  Standard [Gruber markdown][gruber].

  [gruber]: <http://daringfireball.net/projects/markdown/syntax>

  ## Extensions

  ### Links

  #### Links supported by default

  ##### Oneline HTML Link tags

      iex(1)> EarmarkParser.as_ast(~s{<a href="href">link</a>})
      {:ok, [{"a", [{"href", "href"}], ["link"], %{verbatim: true}}], []}

  ##### Markdown links

  New style ...

      iex(2)> EarmarkParser.as_ast(~s{[title](destination)})
      {:ok,  [{"p", [], [{"a", [{"href", "destination"}], ["title"], %{}}], %{}}], []}

  and old style

      iex(3)> EarmarkParser.as_ast("[foo]: /url \"title\"\n\n[foo]\n")
      {:ok, [{"p", [], [{"a", [{"href", "/url"}, {"title", "title"}], ["foo"], %{}}], %{}}], []}

  #### Autolinks

      iex(4)> EarmarkParser.as_ast("<https://elixir-lang.com>")
      {:ok, [{"p", [], [{"a", [{"href", "https://elixir-lang.com"}], ["https://elixir-lang.com"], %{}}], %{}}], []}

  #### Additional link parsing via options


  #### Pure links

  **N.B.** that the `pure_links` option is `true` by default

      iex(5)> EarmarkParser.as_ast("https://github.com")
      {:ok, [{"p", [], [{"a", [{"href", "https://github.com"}], ["https://github.com"], %{}}], %{}}], []}

  But can be deactivated

      iex(6)> EarmarkParser.as_ast("https://github.com", pure_links: false)
      {:ok, [{"p", [], ["https://github.com"], %{}}], []}


    #### Wikilinks...

    are disabled by default

      iex(7)> EarmarkParser.as_ast("[[page]]")
      {:ok, [{"p", [], ["[[page]]"], %{}}], []}

    and can be enabled

      iex(8)> EarmarkParser.as_ast("[[page]]", wikilinks: true)
      {:ok, [{"p", [], [{"a", [{"href", "page"}], ["page"], %{wikilink: true}}], %{}}], []}



  ### Github Flavored Markdown

  GFM is supported by default, however as GFM is a moving target and all GFM extension do not make sense in a general context, EarmarkParser does not support all of it, here is a list of what is supported:

  #### Strike Through

      iex(9)> EarmarkParser.as_ast("~~hello~~")
      {:ok, [{"p", [], [{"del", [], ["hello"], %{}}], %{}}], []}

  #### Syntax Highlighting

  All backquoted or fenced code blocks with a language string are rendered with the given
  language as a _class_ attribute of the _code_ tag.

  For example:

      iex(10)> [
      ...(10)>    "```elixir",
      ...(10)>    " @tag :hello",
      ...(10)>    "```"
      ...(10)> ] |> as_ast()
      {:ok, [{"pre", [], [{"code", [{"class", "elixir"}], [" @tag :hello"], %{}}], %{}}], []}

  will be rendered as shown in the doctest above.

  If you want to integrate with a syntax highlighter with different conventions you can add more classes by specifying prefixes that will be
  put before the language string.

  Prism.js for example needs a class `language-elixir`. In order to achieve that goal you can add `language-`
  as a `code_class_prefix` to `EarmarkParser.Options`.

  In the following example we want more than one additional class, so we add more prefixes.

      iex(11)> [
      ...(11)>    "```elixir",
      ...(11)>    " @tag :hello",
      ...(11)>    "```"
      ...(11)> ] |> as_ast(%EarmarkParser.Options{code_class_prefix: "lang- language-"})
      {:ok, [{"pre", [], [{"code", [{"class", "elixir lang-elixir language-elixir"}], [" @tag :hello"], %{}}], %{}}], []}


  #### Footnotes

  **N.B.** Footnotes are disabled by default, use `as_ast(..., footnotes: true)` to enable them


  Footnotes are now a **superset** of GFM Footnotes. This implies some changes

    - Footnote definitions (`[^footnote_id]`) must come at the end of your document (_GFM_)
    - Footnotes that are not referenced are not rendered anymore (_GFM_)
    - Footnote definitions can contain any markup with the exception of footnote definitions

      iex(12)> markdown = [
      ...(12)> "My reference[^to_footnote]",
      ...(12)> "",
      ...(12)> "[^1]: I am not rendered",
      ...(12)> "[^to_footnote]: Important information"]
      ...(12)> {:ok, ast, []} = as_ast(markdown, footnotes: true)
      ...(12)> ast
      [
        {"p", [], ["My reference",
          {"a",
           [{"href", "#fn:to_footnote"}, {"id", "fnref:to_footnote"}, {"class", "footnote"}, {"title", "see footnote"}],
           ["to_footnote"], %{}}
        ], %{}},
        {"div",
         [{"class", "footnotes"}],
         [{"hr", [], [], %{}},
          {"ol", [],
           [{"li", [{"id", "fn:to_footnote"}],
             [{"a", [{"class", "reversefootnote"}, {"href", "#fnref:to_footnote"}, {"title", "return to article"}], ["&#x21A9;"], %{}},
              {"p", [], ["Important information"], %{}}], %{}}
          ], %{}}], %{}}
      ]

    For more complex examples of footnotes, please refer to
    [these tests](https://github.com/RobertDober/earmark_parser/tree/master/test/acceptance/ast/footnotes/multiple_fn_test.exs)

  #### Tables

  Are supported as long as they are preceded by an empty line.

      State | Abbrev | Capital
      ----: | :----: | -------
      Texas | TX     | Austin
      Maine | ME     | Augusta

  Tables may have leading and trailing vertical bars on each line

      | State | Abbrev | Capital |
      | ----: | :----: | ------- |
      | Texas | TX     | Austin  |
      | Maine | ME     | Augusta |

  Tables need not have headers, in which case all column alignments
  default to left.

      | Texas | TX     | Austin  |
      | Maine | ME     | Augusta |

  Currently we assume there are always spaces around interior vertical unless
  there are exterior bars.

  However in order to be more GFM compatible the `gfm_tables: true` option
  can be used to interpret only interior vertical bars as a table if a separation
  line is given, therefore

       Language|Rating
       --------|------
       Elixir  | awesome

  is a table (if and only if `gfm_tables: true`) while

       Language|Rating
       Elixir  | awesome

  never is.

  #### HTML Blocks

  HTML is not parsed recursively or detected in all conditions right now, though GFM compliance
  is a goal.

  But for now the following holds:

  A HTML Block defined by a tag starting a line and the same tag starting a different line is parsed
  as one HTML AST node, marked with %{verbatim: true}

  E.g.

      iex(13)> lines = [ "<div><span>", "some</span><text>", "</div>more text" ]
      ...(13)> EarmarkParser.as_ast(lines)
      {:ok, [{"div", [], ["<span>", "some</span><text>"], %{verbatim: true}}, "more text"], []}

  And a line starting with an opening tag and ending with the corresponding closing tag is parsed in similar
  fashion

      iex(14)> EarmarkParser.as_ast(["<span class=\"superspan\">spaniel</span>"])
      {:ok, [{"span", [{"class", "superspan"}], ["spaniel"], %{verbatim: true}}], []}

  What is HTML?

  We differ from strict GFM by allowing **all** tags not only HTML5 tags this holds for one liners....

      iex(15)> {:ok, ast, []} = EarmarkParser.as_ast(["<stupid />", "<not>better</not>"])
      ...(15)> ast
      [
        {"stupid", [], [], %{verbatim: true}},
        {"not", [], ["better"], %{verbatim: true}}]

  and for multi line blocks

      iex(16)> {:ok, ast, []} = EarmarkParser.as_ast([ "<hello>", "world", "</hello>"])
      ...(16)> ast
      [{"hello", [], ["world"], %{verbatim: true}}]

  #### HTML Comments

  Are recognized if they start a line (after ws and are parsed until the next `-->` is found
  all text after the next '-->' is ignored

  E.g.

      iex(17)> EarmarkParser.as_ast(" <!-- Comment\ncomment line\ncomment --> text -->\nafter")
      {:ok, [{:comment, [], [" Comment", "comment line", "comment "], %{comment: true}}, {"p", [], ["after"], %{}}], []}


  #### Lists

  Lists are pretty much GFM compliant, but some behaviors concerning the interpreation of the markdown inside a List Item's first
  paragraph seem not worth to be interpreted, examples are blockquote in a tight [list item](ttps://babelmark.github.io/?text=*+aa%0A++%3E+Second)
  which we can only have in a [loose one](https://babelmark.github.io/?text=*+aa%0A++%0A++%3E+Second)

  Or a headline in a [tight list item](https://babelmark.github.io/?text=*+bb%0A++%23+Headline) which, again is only available in the
  [loose version](https://babelmark.github.io/?text=*+bb%0A%0A++%23+Headline) in EarmarkParser.

  furthermore [this example](https://babelmark.github.io/?text=*+aa%0A++%60%60%60%0ASecond%0A++%60%60%60) demonstrates how weird
  and definitely not useful GFM's own interpretation can get.

  Therefore we stick to a more predictable approach.

        iex(18)> markdown = [
        ...(18)> "* aa",
        ...(18)> "  ```",
        ...(18)> "Second",
        ...(18)> "  ```" ]
        ...(18)> as_ast(markdown)
        {:ok, [], []}

  Also we do support the immediate style of block content inside lists

        iex(19)> as_ast("* > Nota Bene!")
        {:ok, [], []}

  or

        iex(20)> as_ast("1. # Breaking...")
        {:ok, [], []}


  ### Adding Attributes with the IAL extension

  #### To block elements

  HTML attributes can be added to any block-level element. We use
  the Kramdown syntax: add the line `{:` _attrs_ `}` following the block.

      iex(21)> markdown = ["# Headline", "{:.from-next-line}"]
      ...(21)> as_ast(markdown)
      {:ok, [{"h1", [{"class", "from-next-line"}], ["Headline"], %{}}], []}

  Headers can also have the IAL string at the end of the line

      iex(22)> markdown = ["# Headline{:.from-same-line}"]
      ...(22)> as_ast(markdown)
      {:ok, [{"h1", [{"class", "from-same-line"}], ["Headline"], %{}}], []}

  A special use case is headers inside blockquotes which allow for some nifty styling in `ex_doc`*
  see [this PR](https://github.com/elixir-lang/ex_doc/pull/1400) if you are interested in the technical
  details

      iex(23)> markdown = ["> # Headline{:.warning}"]
      ...(23)> as_ast(markdown)
      {:ok, [{"blockquote", [], [{"h1", [{"class", "warning"}], ["Headline"], %{}}], %{}}], []}

  This also works for headers inside lists

      iex(24)> markdown = ["- # Headline{:.warning}"]
      ...(24)> as_ast(markdown)
      {:ok, [{"ul", [], [{"li", [], [{"h1", [{"class", "warning"}], ["Headline"], %{}}], %{}}], %{}}], []}

  It still works for inline code, as it did before

      iex(25)> markdown = "`Enum.map`{:lang=elixir}"
      ...(25)> as_ast(markdown)
      {:ok, [{"p", [], [{"code", [{"class", "inline"}, {"lang", "elixir"}], ["Enum.map"], %{}}], %{}}], []}


  _attrs_ can be one or more of:

    * `.className`
    * `#id`
    * name=value, name="value", or name='value'

  For example:

      # Warning
      {: .red}

      Do not turn off the engine
      if you are at altitude.
      {: .boxed #warning spellcheck="true"}

  #### To links or images

  It is possible to add IAL attributes to generated links or images in the following
  format.

      iex(26)> markdown = "[link](url) {: .classy}"
      ...(26)> EarmarkParser.as_ast(markdown)
      { :ok, [{"p", [], [{"a", [{"class", "classy"}, {"href", "url"}], ["link"], %{}}], %{}}], []}

  For both cases, malformed attributes are ignored and warnings are issued.

      iex(27)> [ "Some text", "{:hello}" ] |> Enum.join("\n") |> EarmarkParser.as_ast()
      {:error, [{"p", [], ["Some text"], %{}}], [{:warning, 2,"Illegal attributes [\"hello\"] ignored in IAL"}]}

  It is possible to escape the IAL in both forms if necessary

      iex(28)> markdown = "[link](url)\\{: .classy}"
      ...(28)> EarmarkParser.as_ast(markdown)
      {:ok, [{"p", [], [{"a", [{"href", "url"}], ["link"], %{}}, "{: .classy}"], %{}}], []}

  This of course is not necessary in code blocks or text lines
  containing an IAL-like string, as in the following example

      iex(29)> markdown = "hello {:world}"
      ...(29)> EarmarkParser.as_ast(markdown)
      {:ok, [{"p", [], ["hello {:world}"], %{}}], []}

  ## Limitations

    * Block-level HTML is correctly handled only if each HTML
      tag appears on its own line. So

          <div>
          <div>
          hello
          </div>
          </div>

      will work. However. the following won't

          <div>
          hello</div>

    * John Gruber's tests contain an ambiguity when it comes to
      lines that might be the start of a list inside paragraphs.

      One test says that

          This is the text
          * of a paragraph
          that I wrote

      is a single paragraph. The "*" is not significant. However, another
      test has

          *   A list item
              * an another

      and expects this to be a nested list. But, in reality, the second could just
      be the continuation of a paragraph.

      I've chosen always to use the second interpretation—a line that looks like
      a list item will always be a list item.

    * Rendering of block and inline elements.

      Block or void HTML elements that are at the absolute beginning of a line end
      the preceding paragraph.

      Thusly

          mypara
          <hr />

      Becomes

          <p>mypara</p>
          <hr />

      While

          mypara
           <hr />

      will be transformed into

          <p>mypara
           <hr /></p>

  ## Annotations

  **N.B.** this is an experimental feature from v1.4.16-pre on and might change or be removed again

  The idea is that each markdown line can be annotated, as such annotations change the semantics of Markdown
  they have to be enabled with the `annotations` option.

  If the `annotations` option is set to a string (only one string is supported right now, but a list might
  be implemented later on, hence the name), the last occurrence of that string in a line and all text following
  it will be added to the line as an annotation.

  Depending on how that line will eventually be parsed, this annotation will be added to the meta map (the 4th element
  in an AST quadruple) with the key `:annotation`

  In the current version the annotation will only be applied to verbatim HTML tags and paragraphs

  Let us show some examples now:

  ### Annotated Paragraphs

      iex(30)> as_ast("hello %> annotated", annotations: "%>")
      {:ok, [{"p", [], ["hello "], %{annotation: "%> annotated"}}], []}

  If we annotate more than one line in a para the first annotation takes precedence

      iex(31)> as_ast("hello %> annotated\nworld %> discarded", annotations: "%>")
      {:ok, [{"p", [], ["hello \nworld "], %{annotation: "%> annotated"}}], []}

  ### Annotated HTML elements

  In one line

      iex(32)> as_ast("<span>One Line</span> // a span", annotations: "//")
      {:ok, [{"span", [], ["One Line"], %{annotation: "// a span", verbatim: true}}], []}

  or block elements

      iex(33)> [
      ...(33)> "<div> : annotation",
      ...(33)> "  <span>text</span>",
      ...(33)> "</div> : discarded"
      ...(33)> ] |> as_ast(annotations: " : ")
      {:ok, [{"div", [], ["  <span>text</span>"], %{annotation: " : annotation", verbatim: true}}], []}

  ### Commenting your Markdown

  Although many markdown elements do not support annotations yet, they can be used to comment your markdown, w/o cluttering
  the generated AST with comments

      iex(34)> [
      ...(34)> "# Headline --> first line",
      ...(34)> "- item1 --> a list item",
      ...(34)> "- item2 --> another list item",
      ...(34)> "",
      ...(34)> "<http://somewhere/to/go> --> do not go there"
      ...(34)> ] |> as_ast(annotations: "-->")
      {:ok, [
        {"h1", [], ["Headline"], %{}},
        {"ul", [], [{"li", [], ["item1 "], %{}}, {"li", [], ["item2 "], %{}}], %{}},
        {"p", [], [{"a", [{"href", "http://somewhere/to/go"}], ["http://somewhere/to/go"], %{}}, " "], %{annotation: "--> do not go there"}}
        ], []
       }

  """

  alias EarmarkParser.Options
  import EarmarkParser.Message, only: [sort_messages: 1]

  @doc """
      iex(35)> markdown = "My `code` is **best**"
      ...(35)> {:ok, ast, []} = EarmarkParser.as_ast(markdown)
      ...(35)> ast
      [{"p", [], ["My ", {"code", [{"class", "inline"}], ["code"], %{}}, " is ", {"strong", [], ["best"], %{}}], %{}}]



      iex(36)> markdown = "```elixir\\nIO.puts 42\\n```"
      ...(36)> {:ok, ast, []} = EarmarkParser.as_ast(markdown, code_class_prefix: "lang-")
      ...(36)> ast
      [{"pre", [], [{"code", [{"class", "elixir lang-elixir"}], ["IO.puts 42"], %{}}], %{}}]

  **Rationale**:

  The AST is exposed in the spirit of [Floki's](https://hex.pm/packages/floki).
  """
  def as_ast(lines, options \\ %Options{})

  def as_ast(lines, %Options{} = options) do
    context = _as_ast(lines, options)
    messages = sort_messages(context)
    messages1 = Options.add_deprecations(options, messages)

    status =
      case Enum.any?(messages1, fn {severity, _, _} ->
             severity == :error || severity == :warning
           end) do
        true -> :error
        _ -> :ok
      end

    {status, context.value, messages1}
  end

  def as_ast(lines, options) when is_list(options) do
    as_ast(lines, struct(Options, options))
  end

  def as_ast(lines, options) when is_map(options) do
    as_ast(lines, struct(Options, options |> Map.delete(:__struct__) |> Enum.into([])))
  end

  defp _as_ast(lines, options) do
    {blocks, context} = EarmarkParser.Parser.parse_markdown(lines, Options.normalize(options))
    EarmarkParser.AstRenderer.render(blocks, context)
  end

  @doc """
    Accesses current hex version of the `EarmarkParser` application. Convenience for
    `iex` usage.
  """
  def version() do
    with {:ok, version} = :application.get_key(:earmark_parser, :vsn),
      do: to_string(version)
  end
end

# SPDX-License-Identifier: Apache-2.0
