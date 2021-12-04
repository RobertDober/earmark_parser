defmodule Functional.Scanner.LineTypeTest do
  use ExUnit.Case, async: true
  alias EarmarkParser.Line
  import EarmarkParser.Options, only: [normalize: 1]

  # @moduletag :dev

  @all_but_leading_ws ~r{\S.*}


  id1 = ~S{[ID1]: http://example.com  "The title"}
  id2 = ~S{[ID2]: http://example.com  'The title'}
  id3 = ~S{[ID3]: http://example.com  (The title)}
  id4 = ~S{[ID4]: http://example.com}
  id5 = ~S{[ID5]: <http://example.com>  "The title"}
  id6 = ~S{ [ID6]: http://example.com  "The title"}
  id7 = ~S{  [ID7]: http://example.com  "The title"}
  id8 = ~S{   [ID8]: http://example.com  "The title"}
  id9 = ~S{    [ID9]: http://example.com  "The title"}

  id10 = ~S{[ID10]: /url/ "Title with "quotes" inside"}
  id11 = ~S{[ID11]: http://example.com "Title with trailing whitespace" }
  id12 = ~S{[ID12]: ]hello}

 # Leave Blanks at the beginning, they will be dropped for IAL tests
  test_cases =
    [
      {"", %Line.Blank{}, nil},
      {"", %Line.Blank{}, "annotated"},
      {"        ", %Line.Blank{}, nil},
      {"        ", %Line.Blank{}, " still annotated"},
      {"<!-- comment -->", %Line.HtmlComment{complete: true}, nil},
      {"<!-- comment -->", %Line.HtmlComment{complete: true}, "does it make sense?"},
      {"<!-- comment", %Line.HtmlComment{complete: false}, nil},
      {"<!-- comment", %Line.HtmlComment{complete: false}, " or does it not?"},
      {"- -", %Line.ListItem{type: :ul, bullet: "-", content: "-", list_indent: 2}, nil},
      {"- -", %Line.ListItem{type: :ul, bullet: "-", content: "-", list_indent: 2}, "annotation of a list item"},
      {"- - -", %Line.Ruler{type: "-"}, nil},
      {"- - -", %Line.Ruler{type: "-"}, "ruler 3 elements"},
      {"--", %Line.SetextUnderlineHeading{level: 2}, nil},
      {"--", %Line.SetextUnderlineHeading{level: 2}, "underline level 2"},
      {"---", %Line.Ruler{type: "-"}, nil},
      {"---", %Line.Ruler{type: "-"}, "ruler 3 elements, again"},
      {"* *", %Line.ListItem{type: :ul, bullet: "*", content: "*", list_indent: 2}, nil},
      {"* *", %Line.ListItem{type: :ul, bullet: "*", content: "*", list_indent: 2}, "1 2 3"},
      {"* * *", %Line.Ruler{type: "*"}, nil},
      {"* * *", %Line.Ruler{type: "*"}, " 3 stars"},
      {"**", %Line.Text{content: "**", line: "**"}, nil},
      {"**", %Line.Text{content: "**", line: "**"}, "this is just a text"},
      {"**", %Line.Text{content: "**", line: "**"}, ""},
      {"***", %Line.Ruler{type: "*"}, nil},
      {"***", %Line.Ruler{type: "*"}, "***"},
      {"_ _", %Line.Text{content: "_ _"}, nil},
      {"_ _ _", %Line.Ruler{type: "_"}, nil},
      {"__", %Line.Text{content: "__"}, nil},
      {"___", %Line.Ruler{type: "_"}, nil},
      {"# H1", %Line.Heading{level: 1, content: "H1"}, nil},
      {"# H1", %Line.Heading{level: 1, content: "H1"}, "H1"},
      {"## H2", %Line.Heading{level: 2, content: "H2"}, nil},
      {"## H2", %Line.Heading{level: 2, content: "H2"}, "H2"},
      {"### H3", %Line.Heading{level: 3, content: "H3"}, nil},
      {"### H3", %Line.Heading{level: 3, content: "H3"}, "H3"},
      {"#### H4", %Line.Heading{level: 4, content: "H4"}, nil},
      {"#### H4", %Line.Heading{level: 4, content: "H4"}, "H4"},
      {"##### H5", %Line.Heading{level: 5, content: "H5"}, nil},
      {"##### H5", %Line.Heading{level: 5, content: "H5"}, "H5"},
      {"###### H6", %Line.Heading{level: 6, content: "H6"}, nil},
      {"###### H6", %Line.Heading{level: 6, content: "H6"}, "H6"},
      {"####### H7", %Line.Text{content: "####### H7"}, nil},
      {"> quote", %Line.BlockQuote{content: "quote"}, nil},
      {"> quote", %Line.BlockQuote{content: "quote"}, "annotated"},
      {">    quote", %Line.BlockQuote{content: "   quote"}, nil},
      {">    quote", %Line.BlockQuote{content: "   quote"}, "annotated"},
      {">quote", %Line.BlockQuote{content: "quote"}, nil},
      {">quote", %Line.BlockQuote{content: "quote"}, "annotated"},
      {" >  quote", %Line.BlockQuote{content: " quote"}, nil},
      {" >  quote", %Line.BlockQuote{content: " quote"}, "annotated"},
      {" >", %Line.BlockQuote{content: ""}, nil},
      {" >", %Line.BlockQuote{content: ""}, "annotated"},

      # 1234567890123
      {"   a", %Line.Text{content: "a", line: "   a"}, nil},
      {"   a", %Line.Text{content: "a", line: "   a"}, "annotated"},
      {"    b", %Line.Indent{level: 1, content: "b"}, nil},
      {"    b", %Line.Indent{level: 1, content: "b"}, "annotated"},
      {"      c", %Line.Indent{level: 1, content: "  c"}, nil},
      {"      c", %Line.Indent{level: 1, content: "  c"}, "annotated"},
      {"        d", %Line.Indent{level: 2, content: "d"}, nil},
      {"        d", %Line.Indent{level: 2, content: "d"}, "annotated"},
      {"          e", %Line.Indent{level: 2, content: "  e"}, nil},
      {"          e", %Line.Indent{level: 2, content: "  e"}, "annotated"},
      {"    - f", %Line.Indent{level: 1, content: "- f"}, nil},
      {"    - f", %Line.Indent{level: 1, content: "- f"}, "annotated"},
      {"     *  g", %Line.Indent{level: 1, content: " *  g"}, nil},
      {"     *  g", %Line.Indent{level: 1, content: " *  g"}, "annotated"},
      {"      012) h", %Line.Indent{level: 1, content: "  012) h"}, nil},
      {"      012) h", %Line.Indent{level: 1, content: "  012) h"}, "annotated"},
      {"```", %Line.Fence{delimiter: "```", language: "", line: "```"}, nil},
      {"```", %Line.Fence{delimiter: "```", language: "", line: "```"}, "annotated"},
      {"``` java", %Line.Fence{delimiter: "```", language: "java", line: "``` java"}, nil},
      {"``` java", %Line.Fence{delimiter: "```", language: "java", line: "``` java"}, "annotated"},
      {" ``` java", %Line.Fence{delimiter: "```", language: "java", line: " ``` java"}, nil},
      {" ``` java", %Line.Fence{delimiter: "```", language: "java", line: " ``` java"}, "annotated"},
      {"```java", %Line.Fence{delimiter: "```", language: "java", line: "```java"}, nil},
      {"```java", %Line.Fence{delimiter: "```", language: "java", line: "```java"}, "annotated"},
      {"```language-java", %Line.Fence{delimiter: "```", language: "language-java"}, nil},
      {"```language-java", %Line.Fence{delimiter: "```", language: "language-java"}, "annotated"},
      {"```language-élixir", %Line.Fence{delimiter: "```", language: "language-élixir"}, nil},
      {"```language-élixir", %Line.Fence{delimiter: "```", language: "language-élixir"}, "annotated"},
      {"   `````", %Line.Fence{delimiter: "`````", language: "", line: "   `````"}, nil},
      {"   `````", %Line.Fence{delimiter: "`````", language: "", line: "   `````"}, "annotated"},
      {"~~~", %Line.Fence{delimiter: "~~~", language: "", line: "~~~"}, nil},
      {"~~~", %Line.Fence{delimiter: "~~~", language: "", line: "~~~"}, "annotated"},
      {"~~~ java", %Line.Fence{delimiter: "~~~", language: "java", line: "~~~ java"}, nil},
      {"~~~ java", %Line.Fence{delimiter: "~~~", language: "java", line: "~~~ java"}, "annotated"},
      {"  ~~~java", %Line.Fence{delimiter: "~~~", language: "java", line: "  ~~~java"}, nil},
      {"  ~~~java", %Line.Fence{delimiter: "~~~", language: "java", line: "  ~~~java"}, "annotated"},
      {"~~~ language-java", %Line.Fence{delimiter: "~~~", language: "language-java"}, nil},
      {"~~~ language-java", %Line.Fence{delimiter: "~~~", language: "language-java"}, "annotated"},
      {"~~~ language-élixir", %Line.Fence{delimiter: "~~~", language: "language-élixir"}, nil},
      {"~~~ language-élixir", %Line.Fence{delimiter: "~~~", language: "language-élixir"}, "annotated"},
      {"~~~~ language-élixir", %Line.Fence{delimiter: "~~~~", language: "language-élixir"}, nil},
      {"~~~~ language-élixir", %Line.Fence{delimiter: "~~~~", language: "language-élixir"}, "annotated"},
      {"``` hello ```", %Line.Text{content: "``` hello ```"}, nil},
      {"``` hello ```", %Line.Text{content: "``` hello ```"}, "annotated"},
      {"```hello```", %Line.Text{content: "```hello```"}, nil},
      {"```hello```", %Line.Text{content: "```hello```"}, "annotated"},
      {"```hello world", %Line.Text{content: "```hello world"}, nil},
      {"```hello world", %Line.Text{content: "```hello world"}, "annotated"},
      {"<pre>", %Line.HtmlOpenTag{tag: "pre", content: "<pre>"}, nil},
      {"<pre>", %Line.HtmlOpenTag{tag: "pre", content: "<pre>"}, "annotated"},
      {"<pre class='123'>", %Line.HtmlOpenTag{tag: "pre", content: "<pre class='123'>"}, nil},
      {"<pre class='123'>", %Line.HtmlOpenTag{tag: "pre", content: "<pre class='123'>"}, "annotated"},
      {"</pre>", %Line.HtmlCloseTag{tag: "pre"}, nil},
      {"</pre>", %Line.HtmlCloseTag{tag: "pre"}, "annotated"},
      {"   </pre>", %Line.HtmlCloseTag{indent: 3, tag: "pre"}, nil},
      {"   </pre>", %Line.HtmlCloseTag{indent: 3, tag: "pre"}, "annotated"},
      {"<pre>a</pre>", %Line.HtmlOneLine{tag: "pre", content: "<pre>a</pre>"}, nil},
      {"<pre>a</pre>", %Line.HtmlOneLine{tag: "pre", content: "<pre>a</pre>"}, "annotated"},
      {"<area>", %Line.HtmlOneLine{tag: "area", content: "<area>"}, nil},
      {"<area>", %Line.HtmlOneLine{tag: "area", content: "<area>"}, "annotated"},
      {"<area/>", %Line.HtmlOneLine{tag: "area", content: "<area/>"}, nil},
      {"<area/>", %Line.HtmlOneLine{tag: "area", content: "<area/>"}, "annotated"},
      {"<area class='a'>", %Line.HtmlOneLine{tag: "area", content: "<area class='a'>"}, nil},
      {"<area class='a'>", %Line.HtmlOneLine{tag: "area", content: "<area class='a'>"}, "annotated"},
      {"<br>", %Line.HtmlOneLine{tag: "br", content: "<br>"}, nil},
      {"<br>", %Line.HtmlOneLine{tag: "br", content: "<br>"}, "annotated"},
      {"<br/>", %Line.HtmlOneLine{tag: "br", content: "<br/>"}, nil},
      {"<br/>", %Line.HtmlOneLine{tag: "br", content: "<br/>"}, "annotated"},
      {"<br class='a'>", %Line.HtmlOneLine{tag: "br", content: "<br class='a'>"}, nil},
      {"<br class='a'>", %Line.HtmlOneLine{tag: "br", content: "<br class='a'>"}, "annotated"},
      {"<hr />", %Line.HtmlOneLine{tag: "hr", content: "<hr />"}, nil},
      {"<hr />", %Line.HtmlOneLine{tag: "hr", content: "<hr />"}, "annotated"},
      {"<hr/>", %Line.HtmlOneLine{tag: "hr", content: "<hr/>"}, nil},
      {"<hr/>", %Line.HtmlOneLine{tag: "hr", content: "<hr/>"}, "annotated"},
      {"<hr class='a'>", %Line.HtmlOneLine{tag: "hr", content: "<hr class='a'>"}, nil},
      {"<hr class='a'>", %Line.HtmlOneLine{tag: "hr", content: "<hr class='a'>"}, "annotated"},
      {"<img>", %Line.HtmlOneLine{tag: "img", content: "<img>"}, nil},
      {"<img>", %Line.HtmlOneLine{tag: "img", content: "<img>"}, "annotated"},
      {"<img/>", %Line.HtmlOneLine{tag: "img", content: "<img/>"}, nil},
      {"<img/>", %Line.HtmlOneLine{tag: "img", content: "<img/>"}, "annotated"},
      {"<img class='a'>", %Line.HtmlOneLine{tag: "img", content: "<img class='a'>"}, nil},
      {"<img class='a'>", %Line.HtmlOneLine{tag: "img", content: "<img class='a'>"}, "annotated"},
      {"<wbr>", %Line.HtmlOneLine{tag: "wbr", content: "<wbr>"}, nil},
      {"<wbr>", %Line.HtmlOneLine{tag: "wbr", content: "<wbr>"}, "annotated"},
      {"<wbr/>", %Line.HtmlOneLine{tag: "wbr", content: "<wbr/>"}, nil},
      {"<wbr/>", %Line.HtmlOneLine{tag: "wbr", content: "<wbr/>"}, "annotated"},
      {"<wbr class='a'>", %Line.HtmlOneLine{tag: "wbr", content: "<wbr class='a'>"}, nil},
      {"<wbr class='a'>", %Line.HtmlOneLine{tag: "wbr", content: "<wbr class='a'>"}, "annotated"},
      {"<h2>Headline</h2>", %Line.HtmlOneLine{tag: "h2", content: "<h2>Headline</h2>"}, nil},
      {"<h2>Headline</h2>", %Line.HtmlOneLine{tag: "h2", content: "<h2>Headline</h2>"}, "annotated"},
      {"<h2 id='headline'>Headline</h2>", %Line.HtmlOneLine{tag: "h2", content: "<h2 id='headline'>Headline</h2>"}, nil},
      {"<h2 id='headline'>Headline</h2>", %Line.HtmlOneLine{tag: "h2", content: "<h2 id='headline'>Headline</h2>"}, "annotated"},
      {"<h3>Headline", %Line.HtmlOpenTag{tag: "h3", content: "<h3>Headline"}, nil},
      {"<h3>Headline", %Line.HtmlOpenTag{tag: "h3", content: "<h3>Headline"}, "annotated"},
      {id1, %Line.IdDef{id: "ID1", url: "http://example.com", title: "The title"}, nil},
      {id1, %Line.IdDef{id: "ID1", url: "http://example.com", title: "The title"}, "annotated"},
      {id2, %Line.IdDef{id: "ID2", url: "http://example.com", title: "The title"}, nil},
      {id2, %Line.IdDef{id: "ID2", url: "http://example.com", title: "The title"}, "annotated"},
      {id3, %Line.IdDef{id: "ID3", url: "http://example.com", title: "The title"}, nil},
      {id3, %Line.IdDef{id: "ID3", url: "http://example.com", title: "The title"}, "annotated"},
      {id4, %Line.IdDef{id: "ID4", url: "http://example.com", title: ""}, nil},
      {id4, %Line.IdDef{id: "ID4", url: "http://example.com", title: ""}, "annotated"},
      {id5, %Line.IdDef{id: "ID5", url: "http://example.com", title: "The title"}, nil},
      {id5, %Line.IdDef{id: "ID5", url: "http://example.com", title: "The title"}, "annotated"},
      {id6, %Line.IdDef{id: "ID6", url: "http://example.com", title: "The title"}, nil},
      {id6, %Line.IdDef{id: "ID6", url: "http://example.com", title: "The title"}, "annotated"},
      {id7, %Line.IdDef{id: "ID7", url: "http://example.com", title: "The title"}, nil},
      {id7, %Line.IdDef{id: "ID7", url: "http://example.com", title: "The title"}, "annotated"},
      {id8, %Line.IdDef{id: "ID8", url: "http://example.com", title: "The title"}, nil},
      {id8, %Line.IdDef{id: "ID8", url: "http://example.com", title: "The title"}, "annotated"},
      {id9, %Line.Indent{ content: "[ID9]: http://example.com  \"The title\"", level: 1, line: "    [ID9]: http://example.com  \"The title\"" }, nil},
      {id9, %Line.Indent{ content: "[ID9]: http://example.com  \"The title\"", level: 1, line: "    [ID9]: http://example.com  \"The title\"" }, "annotated"},
      {id10, %Line.IdDef{id: "ID10", url: "/url/", title: "Title with \"quotes\" inside"}, nil},
      {id11, %Line.IdDef{id: "ID11", url: "http://example.com", title: "Title with trailing whitespace"}, nil},
      {id11, %Line.IdDef{id: "ID11", url: "http://example.com", title: "Title with trailing whitespace"}, "annotated"},
      {id12, %Line.IdDef{id: "ID12", url: "]hello", title: ""}, nil},
      {id12, %Line.IdDef{id: "ID12", url: "]hello", title: ""}, "annotated"},
      {"* ul1", %Line.ListItem{type: :ul, bullet: "*", content: "ul1", list_indent: 2}, nil},
      {"* ul1", %Line.ListItem{type: :ul, bullet: "*", content: "ul1", list_indent: 2}, "annotated"},
      {"+ ul2", %Line.ListItem{type: :ul, bullet: "+", content: "ul2", list_indent: 2}, nil},
      {"+ ul2", %Line.ListItem{type: :ul, bullet: "+", content: "ul2", list_indent: 2}, "annotated"},
      {"- ul3", %Line.ListItem{type: :ul, bullet: "-", content: "ul3", list_indent: 2}, nil},
      {"- ul3", %Line.ListItem{type: :ul, bullet: "-", content: "ul3", list_indent: 2}, "annotated"},
      {"*     ul4", %Line.ListItem{type: :ul, bullet: "*", content: "    ul4", list_indent: 6}, nil},
      {"*     ul4", %Line.ListItem{type: :ul, bullet: "*", content: "    ul4", list_indent: 6}, "annotated"},
      {"*ul5", %Line.Text{content: "*ul5"}, nil},
      {"*ul5", %Line.Text{content: "*ul5"}, "annotated"},
      {"1. ol1", %Line.ListItem{type: :ol, bullet: "1.", content: "ol1", list_indent: 3}, nil},
      {"1. ol1", %Line.ListItem{type: :ol, bullet: "1.", content: "ol1", list_indent: 3}, "annotated"},
      {"12345.      ol2", %Line.ListItem{type: :ol, bullet: "12345.", content: "     ol2", list_indent: 7}, nil},
      {"12345.      ol2", %Line.ListItem{type: :ol, bullet: "12345.", content: "     ol2", list_indent: 7}, "annotated"},
      {"12345)      ol3", %Line.ListItem{type: :ol, bullet: "12345)", content: "     ol3", list_indent: 7}, nil},
      {"12345)      ol3", %Line.ListItem{type: :ol, bullet: "12345)", content: "     ol3", list_indent: 7}, "annotated"},
      {"1234567890. ol4", %Line.Text{content: "1234567890. ol4"}, nil},
      {"1234567890. ol4", %Line.Text{content: "1234567890. ol4"}, "annotated"},
      {"1.ol5", %Line.Text{content: "1.ol5"}, nil},
      {"1.ol5", %Line.Text{content: "1.ol5"}, "annotated"},
      {"=", %Line.SetextUnderlineHeading{level: 1}, nil},
      {"=", %Line.SetextUnderlineHeading{level: 1}, "annotated"},
      {"========", %Line.SetextUnderlineHeading{level: 1}, nil},
      {"========", %Line.SetextUnderlineHeading{level: 1}, "annotated"},
      {"-", %Line.SetextUnderlineHeading{level: 2}, nil},
      {"-", %Line.SetextUnderlineHeading{level: 2}, "annotated"},
      {"= and so", %Line.Text{content: "= and so"}, nil},
      {"= and so", %Line.Text{content: "= and so"}, "annotated"},
      {"   (title)", %Line.Text{content: "(title)", line: "   (title)"}, nil},
      {"   (title)", %Line.Text{content: "(title)", line: "   (title)"}, "annotated"},
      {"{: .attr }", %Line.Ial{attrs: ".attr", verbatim: " .attr "}, nil},
      {"{: .attr }", %Line.Ial{attrs: ".attr", verbatim: " .attr "}, "annotated"},
      {"{:.a1 .a2}", %Line.Ial{attrs: ".a1 .a2", verbatim: ".a1 .a2"}, nil},
      {"{:.a1 .a2}", %Line.Ial{attrs: ".a1 .a2", verbatim: ".a1 .a2"}, "annotated"},
      {"  | a | b | c | ", %Line.TableLine{content: "  | a | b | c | ", columns: ~w{a b c}}, nil},
      {"  | a | b | c | ", %Line.TableLine{content: "  | a | b | c | ", columns: ~w{a b c}}, "annotated"},
      {"  | a         | ", %Line.TableLine{content: "  | a         | ", columns: ~w{a}}, nil},
      {"  | a         | ", %Line.TableLine{content: "  | a         | ", columns: ~w{a}}, "annotated"},
      {"  a | b | c  ", %Line.TableLine{content: "  a | b | c  ", columns: ~w{a b c}}, nil},
      {"  a | b | c  ", %Line.TableLine{content: "  a | b | c  ", columns: ~w{a b c}}, "annotated"},
      {"  a \\| b | c  ", %Line.TableLine{content: "  a \\| b | c  ", columns: ["a | b", "c"]}, nil},
      {"  a \\| b | c  ", %Line.TableLine{content: "  a \\| b | c  ", columns: ["a | b", "c"]}, "annotated"},

      #
      # Footnote Definitions but no footnote option
      #
      {"[^1]: bar baz",
       %EarmarkParser.Line.Text{
         content: "[^1]: bar baz",
         line: "[^1]: bar baz",
         lnb: 42
       }, nil},
      {"[^1]: bar baz",
       %EarmarkParser.Line.Text{
         content: "[^1]: bar baz",
         line: "[^1]: bar baz",
         lnb: 42
       }, "annotated"},
    ]
    |> Enum.with_index

  @annotation "%%"
  describe "scan with annotations" do
    test_cases
    |> Enum.map(fn {{input, token, annotation}, test_nb} ->
      tag = "ann_#{test_nb}" |> String.to_atom()
      annotation_ = if annotation, do: Enum.join([@annotation, annotation])
      input_ = "#{input}#{annotation_}"
      name = "test: #{test_nb} (#{input_})"
      result =
        EarmarkParser.LineScanner.type_of({input_, 1729}, normalize(annotations: @annotation), false)
      indent = input |> String.replace(@all_but_leading_ws, "") |> String.length()
      expected = struct(token, annotation: annotation_, line: input, indent: indent, lnb: 1729)

      @tag tag
      test name do
        assert unquote(Macro.escape(result)) == unquote(Macro.escape(expected))
      end
    end)
  end

  describe "scan without annotations" do
    test_cases
    |> Enum.reject(fn {{_, _, annotation}, _} -> annotation end)
    |> Enum.map(fn {{input, token, _nil}, test_nb} ->
      tag = "noann_#{test_nb}" |> String.to_atom()
      name = "test: #{test_nb} (#{input})"
      result =
        EarmarkParser.LineScanner.type_of({input, 1731}, false)
      indent = input |> String.replace(@all_but_leading_ws, "") |> String.length()
      expected = struct(token, line: input, indent: indent, lnb: 1731)

      @tag tag
      test name do
        assert unquote(Macro.escape(result)) == unquote(Macro.escape(expected))
      end
    end)
  end

  ial_test_cases = [
      {"# H1", %Line.Heading{level: 1, content: "H1"}, nil},
      {"# H1", %Line.Heading{level: 1, content: "H1"}, "H1"},
      {"## H2", %Line.Heading{level: 2, content: "H2"}, nil},
      {"## H2", %Line.Heading{level: 2, content: "H2"}, "H2"},
      {"### H3", %Line.Heading{level: 3, content: "H3"}, nil},
      {"### H3", %Line.Heading{level: 3, content: "H3"}, "H3"},
      {"#### H4", %Line.Heading{level: 4, content: "H4"}, nil},
      {"#### H4", %Line.Heading{level: 4, content: "H4"}, "H4"},
      {"##### H5", %Line.Heading{level: 5, content: "H5"}, nil},
      {"##### H5", %Line.Heading{level: 5, content: "H5"}, "H5"},
      {"###### H6", %Line.Heading{level: 6, content: "H6"}, nil},
      {"###### H6", %Line.Heading{level: 6, content: "H6"}, "H6"},
    ]

  @ial "{:.ial_class}"
  describe "scan with IAL" do
    ial_test_cases
    |> Enum.with_index
    |> Enum.map(fn {{input, token, _nil}, test_nb} ->
      tag = "ial_#{test_nb}" |> String.to_atom()
      name = "test: #{test_nb} (#{input})"
      input_ = "#{input}#{@ial}"
      result =
        EarmarkParser.LineScanner.type_of({input_, 1774}, false)
      indent = input |> String.replace(@all_but_leading_ws, "") |> String.length()
      expected = struct(token, ial: ".ial_class", line: input, indent: indent, lnb: 1774)

      @tag tag
      test name do
        assert unquote(Macro.escape(result)) == unquote(Macro.escape(expected))
      end
    end)
  end

  block_ial_test_cases = [
      {"> quote", %Line.BlockQuote{content: "quote"}},
      {">    quote", %Line.BlockQuote{content: "   quote"}},
      {">quote", %Line.BlockQuote{content: "quote"}},
      {" >  quote", %Line.BlockQuote{content: " quote"}},
      {" >", %Line.BlockQuote{content: ""}},
      ]
  describe "IAL needs to be passed through content" do
    block_ial_test_cases
    |> Enum.with_index
    |> Enum.map(fn {{input, token}, test_nb} ->
      tag = "block_ial_#{test_nb}" |> String.to_atom()
      name = "test: #{test_nb} (#{input})"
      input_ = "#{input}#{@ial}"
      result =
        EarmarkParser.LineScanner.type_of({input_, 1774}, false)
      indent = input |> String.replace(@all_but_leading_ws, "") |> String.length()
      expected = struct(token, content: token.content <> @ial, ial: ".ial_class", line: input, indent: indent, lnb: 1774)

      @tag tag
      test name do
        assert unquote(Macro.escape(result)) == unquote(Macro.escape(expected))
      end
    end)
  end

  not_ial_test_cases =
  [
    {"--", %Line.Text{annotation: nil, indent: 0, line: "--{:.not-ial}", lnb: 1905, content: "--{:.not-ial}"}},
    {"* * *", %Line.ListItem{
              annotation: nil,
              ial: nil,
              indent: 0,
              line: "* * *{:.not-ial}",
              lnb: 1905,
              type: :ul,
              bullet: "*",
              content: "* *{:.not-ial}",
              initial_indent: 0,
              list_indent: 2
            }},
  ]

  describe "not IAL" do
    not_ial_test_cases
    |> Enum.with_index
    |> Enum.map(fn {{input, token}, test_nb} ->
      tag = "not_ial_#{test_nb + 1}" |> String.to_atom()
      name = "test: #{test_nb + 1} (#{input})"
      input_ = "#{input}{:.not-ial}"
      result =
        EarmarkParser.LineScanner.type_of({input_, 1905}, false)
      indent = input |> String.replace(@all_but_leading_ws, "") |> String.length()
      expected = struct(token, line: input_, indent: indent, lnb: 1905)

      @tag tag
      test name do
        assert unquote(Macro.escape(result)) == unquote(Macro.escape(expected))
      end
    end)
  end

  describe "debugging" do
    # test "rescan" do
    #   token =
    #     EarmarkParser.LineScanner.type_of(
    #       {"      %% hello", 1729},
    #       normalize(annotations: "%%"),
    #       false
    #     )

    #   assert token == %Line.Blank{annotation: "%% hello", indent: 6, line: "  ", lnb: 1729}
    # end

    # test "no rescan" do
    #   token = EarmarkParser.LineScanner.type_of({"  ", 1729}, normalize(annotations: "%%"), false)
    #   assert token == %Line.Blank{indent: 2, line: "  ", lnb: 1729}
    # end

    # test "ial" do
    #   token = EarmarkParser.LineScanner.type_of({"> ## Hello {:.inside-bq}", 1728},false) |> IO.inspect()
    #   expected = struct(token, content: "## Hello {:.inside-bq}")

    #   assert token == expected
    # end
  end
end

# SPDX-License-Identifier: Apache-2.0
