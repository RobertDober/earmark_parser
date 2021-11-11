
# EarmarkParser A Pure Elixir Markdown Parser (split from Earmark)

[![CI](https://github.com/robertdober/earmark_parser/workflows/CI/badge.svg)](https://github.com/robertdober/earmark_parser/actions)
[![Coverage Status](https://coveralls.io/repos/github/RobertDober/earmark_parser/badge.svg?branch=master)](https://coveralls.io/github/RobertDober/earmark_parser?branch=master)
[![Hex.pm](https://img.shields.io/hexpm/v/earmark_parser.svg)](https://hex.pm/packages/earmark_parser)
[![Hex.pm](https://img.shields.io/hexpm/dw/earmark_parser.svg)](https://hex.pm/packages/earmark_parser)
[![Hex.pm](https://img.shields.io/hexpm/dt/earmark_parser.svg)](https://hex.pm/packages/earmark_parser)


## Table Of Contents

- [Table Of Contents](#table-of-contents)
- [Usage](#usage)
  - [EarmarkParser](#earmarkparser)
  - [API](#api)
    - [EarmarkParser.as_ast](#earmarkparseras_ast)
    - [Options](#options)
- [Supports](#supports)
- [Extensions](#extensions)
  - [Links](#links)
    - [Links supported by default](#links-supported-by-default)
    - [Autolinks](#autolinks)
    - [Additional link parsing via options](#additional-link-parsing-via-options)
    - [Pure links](#pure-links)
    - [Wikilinks...](#wikilinks)
  - [Github Flavored Markdown](#github-flavored-markdown)
    - [Strike Through](#strike-through)
    - [Syntax Highlighting](#syntax-highlighting)
    - [Tables](#tables)
    - [HTML Blocks](#html-blocks)
    - [HTML Comments](#html-comments)
  - [Adding Attributes with the IAL extension](#adding-attributes-with-the-ial-extension)
    - [To block elements](#to-block-elements)
    - [To links or images](#to-links-or-images)
- [Limitations](#limitations)
- [Timeouts](#timeouts)
- [Annotations](#annotations)
  - [Annotated Paragraphs](#annotated-paragraphs)
  - [Annotated HTML elements](#annotated-html-elements)
  - [Commenting your Markdown](#commenting-your-markdown)
  - [EarmarkParser.as_ast/2](#earmarkparseras_ast2)
  - [EarmarkParser.version/0](#earmarkparserversion0)
- [Some Dev Notes](#some-dev-notes)
  - [EarmarkParser.Helpers.Parser](#earmarkparserhelpersparser)
  - [EarmarkParser.Helpers.Parser.char_parser/1](#earmarkparserhelpersparserchar_parser1)
  - [EarmarkParser.Helpers.Parser.char_range_parser/2](#earmarkparserhelpersparserchar_range_parser2)
  - [EarmarkParser.Helpers.Parser.choice/2](#earmarkparserhelpersparserchoice2)
  - [EarmarkParser.Helpers.Parser.digit_parser/1](#earmarkparserhelpersparserdigit_parser1)
  - [EarmarkParser.Helpers.Parser.empty/0](#earmarkparserhelpersparserempty0)
  - [EarmarkParser.Helpers.Parser.lazy/1](#earmarkparserhelpersparserlazy1)
  - [EarmarkParser.Helpers.Parser.many/1](#earmarkparserhelpersparsermany1)
  - [EarmarkParser.Helpers.Parser.many!/3](#earmarkparserhelpersparsermany3)
  - [EarmarkParser.Helpers.Parser.map/2](#earmarkparserhelpersparsermap2)
  - [EarmarkParser.Helpers.Parser.optional/1](#earmarkparserhelpersparseroptional1)
  - [EarmarkParser.Helpers.Parser.satisfy/4](#earmarkparserhelpersparsersatisfy4)
  - [EarmarkParser.Helpers.Parser.sequence/1](#earmarkparserhelpersparsersequence1)
  - [EarmarkParser.Helpers.Parser.skip/1](#earmarkparserhelpersparserskip1)
  - [EarmarkParser.Helpers.Parser.skip!/2](#earmarkparserhelpersparserskip2)
  - [EarmarkParser.Helpers.Parser.up_to/1](#earmarkparserhelpersparserup_to1)
- [Contributing](#contributing)
- [Author](#author)
- [LICENSE](#license)

## Usage

### EarmarkParser


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

```elixir
    iex(1)> EarmarkParser.as_ast(~s{<a href="href">link</a>})
    {:ok, [{"a", [{"href", "href"}], ["link"], %{verbatim: true}}], []}
```

##### Markdown links

New style ...

```elixir
    iex(2)> EarmarkParser.as_ast(~s{[title](destination)})
    {:ok,  [{"p", [], [{"a", [{"href", "destination"}], ["title"], %{}}], %{}}], []}
```

and old style

```elixir
    iex(3)> EarmarkParser.as_ast("[foo]: /url \"title\"\n\n[foo]\n")
    {:ok, [{"p", [], [{"a", [{"href", "/url"}, {"title", "title"}], ["foo"], %{}}], %{}}], []}
```

#### Autolinks

```elixir
    iex(4)> EarmarkParser.as_ast("<https://elixir-lang.com>")
    {:ok, [{"p", [], [{"a", [{"href", "https://elixir-lang.com"}], ["https://elixir-lang.com"], %{}}], %{}}], []}
```

#### Additional link parsing via options


#### Pure links

**N.B.** that the `pure_links` option is `true` by default

```elixir
    iex(5)> EarmarkParser.as_ast("https://github.com")
    {:ok, [{"p", [], [{"a", [{"href", "https://github.com"}], ["https://github.com"], %{}}], %{}}], []}
```

But can be deactivated

```elixir
    iex(6)> EarmarkParser.as_ast("https://github.com", pure_links: false)
    {:ok, [{"p", [], ["https://github.com"], %{}}], []}
```


  #### Wikilinks...

  are disabled by default

```elixir
    iex(7)> EarmarkParser.as_ast("[[page]]")
    {:ok, [{"p", [], ["[[page]]"], %{}}], []}
```

  and can be enabled

```elixir
    iex(8)> EarmarkParser.as_ast("[[page]]", wikilinks: true)
    {:ok, [{"p", [], [{"a", [{"href", "page"}], ["page"], %{wikilink: true}}], %{}}], []}
```



### Github Flavored Markdown

GFM is supported by default, however as GFM is a moving target and all GFM extension do not make sense in a general context, EarmarkParser does not support all of it, here is a list of what is supported:

#### Strike Through

```elixir
    iex(9)> EarmarkParser.as_ast("~~hello~~")
    {:ok, [{"p", [], [{"del", [], ["hello"], %{}}], %{}}], []}
```

#### Syntax Highlighting

All backquoted or fenced code blocks with a language string are rendered with the given
language as a _class_ attribute of the _code_ tag.

For example:

```elixir
    iex(10)> [
    ...(10)>    "```elixir",
    ...(10)>    " @tag :hello",
    ...(10)>    "```"
    ...(10)> ] |> EarmarkParser.as_ast()
    {:ok, [{"pre", [], [{"code", [{"class", "elixir"}], [" @tag :hello"], %{}}], %{}}], []}
```

will be rendered as shown in the doctest above.

If you want to integrate with a syntax highlighter with different conventions you can add more classes by specifying prefixes that will be
put before the language string.

Prism.js for example needs a class `language-elixir`. In order to achieve that goal you can add `language-`
as a `code_class_prefix` to `EarmarkParser.Options`.

In the following example we want more than one additional class, so we add more prefixes.

```elixir
    iex(11)> [
    ...(11)>    "```elixir",
    ...(11)>    " @tag :hello",
    ...(11)>    "```"
    ...(11)> ] |> EarmarkParser.as_ast(%EarmarkParser.Options{code_class_prefix: "lang- language-"})
    {:ok, [{"pre", [], [{"code", [{"class", "elixir lang-elixir language-elixir"}], [" @tag :hello"], %{}}], %{}}], []}
```


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

```elixir
    iex(12)> lines = [ "<div><span>", "some</span><text>", "</div>more text" ]
    ...(12)> EarmarkParser.as_ast(lines)
    {:ok, [{"div", [], ["<span>", "some</span><text>"], %{verbatim: true}}, "more text"], []}
```

And a line starting with an opening tag and ending with the corresponding closing tag is parsed in similar
fashion

```elixir
    iex(13)> EarmarkParser.as_ast(["<span class=\"superspan\">spaniel</span>"])
    {:ok, [{"span", [{"class", "superspan"}], ["spaniel"], %{verbatim: true}}], []}
```

What is HTML?

We differ from strict GFM by allowing **all** tags not only HTML5 tags this holds for one liners....

```elixir
    iex(14)> {:ok, ast, []} = EarmarkParser.as_ast(["<stupid />", "<not>better</not>"])
    ...(14)> ast
    [
      {"stupid", [], [], %{verbatim: true}},
      {"not", [], ["better"], %{verbatim: true}}]
```

and for multi line blocks

```elixir
    iex(15)> {:ok, ast, []} = EarmarkParser.as_ast([ "<hello>", "world", "</hello>"])
    ...(15)> ast
    [{"hello", [], ["world"], %{verbatim: true}}]
```

#### HTML Comments

Are recognized if they start a line (after ws and are parsed until the next `-->` is found
all text after the next '-->' is ignored

E.g.

```elixir
    iex(16)> EarmarkParser.as_ast(" <!-- Comment\ncomment line\ncomment --> text -->\nafter")
    {:ok, [{:comment, [], [" Comment", "comment line", "comment "], %{comment: true}}, {"p", [], ["after"], %{}}], []}
```



### Adding Attributes with the IAL extension

#### To block elements

HTML attributes can be added to any block-level element. We use
the Kramdown syntax: add the line `{:` _attrs_ `}` following the block.

```elixir
    iex(17)> markdown = ["# Headline", "{:.from-next-line}"]
    ...(17)> as_ast(markdown)
    {:ok, [{"h1", [{"class", "from-next-line"}], ["Headline"], %{}}], []}
```

Headers can also have the IAL string at the end of the line

```elixir
    iex(18)> markdown = ["# Headline{:.from-same-line}"]
    ...(18)> as_ast(markdown)
    {:ok, [{"h1", [{"class", "from-same-line"}], ["Headline"], %{}}], []}
```

A special use case is headers inside blockquotes which allow for some nifty styling in `ex_doc`*
see [this PR](https://github.com/elixir-lang/ex_doc/pull/1400) if you are interested in the technical
details

```elixir
    iex(19)> markdown = ["> # Headline{:.warning}"]
    ...(19)> as_ast(markdown)
    {:ok, [{"blockquote", [], [{"h1", [{"class", "warning"}], ["Headline"], %{}}], %{}}], []}
```

This also works for headers inside lists

```elixir
    iex(20)> markdown = ["- # Headline{:.warning}"]
    ...(20)> as_ast(markdown)
    {:ok, [{"ul", [], [{"li", [], [{"h1", [{"class", "warning"}], ["Headline"], %{}}], %{}}], %{}}], []}
```

It still works for inline code, as it did before

```elixir
    iex(21)> markdown = "`Enum.map`{:lang=elixir}"
    ...(21)> as_ast(markdown)
    {:ok, [{"p", [], [{"code", [{"class", "inline"}, {"lang", "elixir"}], ["Enum.map"], %{}}], %{}}], []}
```


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

```elixir
    iex(22)> markdown = "[link](url) {: .classy}"
    ...(22)> EarmarkParser.as_ast(markdown)
    { :ok, [{"p", [], [{"a", [{"class", "classy"}, {"href", "url"}], ["link"], %{}}], %{}}], []}
```

For both cases, malformed attributes are ignored and warnings are issued.

```elixir
    iex(23)> [ "Some text", "{:hello}" ] |> Enum.join("\n") |> EarmarkParser.as_ast()
    {:error, [{"p", [], ["Some text"], %{}}], [{:warning, 2,"Illegal attributes [\"hello\"] ignored in IAL"}]}
```

It is possible to escape the IAL in both forms if necessary

```elixir
    iex(24)> markdown = "[link](url)\\{: .classy}"
    ...(24)> EarmarkParser.as_ast(markdown)
    {:ok, [{"p", [], [{"a", [{"href", "url"}], ["link"], %{}}, "{: .classy}"], %{}}], []}
```

This of course is not necessary in code blocks or text lines
containing an IAL-like string, as in the following example

```elixir
    iex(25)> markdown = "hello {:world}"
    ...(25)> EarmarkParser.as_ast(markdown)
    {:ok, [{"p", [], ["hello {:world}"], %{}}], []}
```

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

## Timeouts

By default, that is if the `timeout` option is not set EarmarkParser uses parallel mapping as implemented in `EarmarkParser.pmap/2`,
which uses `Task.await` with its default timeout of 5000ms.

In rare cases that might not be enough.

By indicating a longer `timeout` option in milliseconds EarmarkParser will use parallel mapping as implemented in `EarmarkParser.pmap/3`,
which will pass `timeout` to `Task.await`.

In both cases one can override the mapper function with either the `mapper` option (used if and only if `timeout` is nil) or the
`mapper_with_timeout` function (used otherwise).

## Annotations

**N.B.** this is an experimental feature from v1.4.16-pre on and might change or be removed again

The idea is that each markdown line can be annotated, as such annotations change the semantics of Markdown
they have to be enabled with the `annotations` option.

If the `annotations` option is set to a string (only one string is supported right now, but a list might
be implemented later on, hence the name), the last occurance of that string in a line and all text following
it will be added to the line as an annotation.

Depending on how that line will eventually be parsed, this annotation will be added to the meta map (the 4th element
in an AST quadruple) with the key `:annotation`

In the current version the annotation will only be applied to verbatim HTML tags and paragraphs

Let us show some examples now:

### Annotated Paragraphs

```elixir
    iex(26)> as_ast("hello %> annotated", annotations: "%>")
    {:ok, [{"p", [], ["hello "], %{annotation: "%> annotated"}}], []}
```

If we annotate more than one line in a para the first annotation takes precedence

```elixir
    iex(27)> as_ast("hello %> annotated\nworld %> discarded", annotations: "%>")
    {:ok, [{"p", [], ["hello \nworld "], %{annotation: "%> annotated"}}], []}
```

### Annotated HTML elements

In one line

```elixir
    iex(28)> as_ast("<span>One Line</span> // a span", annotations: "//")
    {:ok, [{"span", [], ["One Line"], %{annotation: "// a span", verbatim: true}}], []}
```

or block elements

```elixir
    iex(29)> [
    ...(29)> "<div> : annotation",
    ...(29)> "  <span>text</span>",
    ...(29)> "</div> : discarded"
    ...(29)> ] |> as_ast(annotations: " : ")
    {:ok, [{"div", [], ["  <span>text</span>"], %{annotation: " : annotation", verbatim: true}}], []}
```

### Commenting your Markdown

Although many markdown elements do not support annotations yet, they can be used to comment your markdown, w/o cluttering
the generated AST with comments

```elixir
    iex(30)> [
    ...(30)> "# Headline --> first line",
    ...(30)> "- item1 --> a list item",
    ...(30)> "- item2 --> another list item",
    ...(30)> "",
    ...(30)> "<http://somewhere/to/go> --> do not go there"
    ...(30)> ] |> as_ast(annotations: "-->")
    {:ok, [
      {"h1", [], ["Headline"], %{}},
      {"ul", [], [{"li", [], ["item1 "], %{}}, {"li", [], ["item2 "], %{}}], %{}},
      {"p", [], [{"a", [{"href", "http://somewhere/to/go"}], ["http://somewhere/to/go"], %{}}, " "], %{annotation: "--> do not go there"}}
      ], []
     }
```


### EarmarkParser.as_ast/2

    iex(31)> markdown = "My `code` is **best**"
    ...(31)> {:ok, ast, []} = EarmarkParser.as_ast(markdown)
    ...(31)> ast
    [{"p", [], ["My ", {"code", [{"class", "inline"}], ["code"], %{}}, " is ", {"strong", [], ["best"], %{}}], %{}}]



```elixir
    iex(32)> markdown = "```elixir\nIO.puts 42\n```"
    ...(32)> {:ok, ast, []} = EarmarkParser.as_ast(markdown, code_class_prefix: "lang-")
    ...(32)> ast
    [{"pre", [], [{"code", [{"class", "elixir lang-elixir"}], ["IO.puts 42"], %{}}], %{}}]
```

**Rationale**:

The AST is exposed in the spirit of [Floki's](https://hex.pm/packages/floki).

### EarmarkParser.version/0

  Accesses current hex version of the `EarmarkParser` application. Convenience for
  `iex` usage.


## Some Dev Notes

### EarmarkParser.Helpers.Parser

A simple parser combinator

inspired by Saša Jurić's talk [Parsing from first principles](https://www.youtube.com/watch?v=xNzoerDljjo)

A general observation, all combinators, that is all functions that take a parser or list of parsers
as their first argument accept shortcuts for the char_range_parser, meaning that
instead of

```iex
    sequence([
      optional(char_range_parser([?+, ?-])),
      many(char_range_parser([?0..?9]),
      choice([char_range_parser([?a]), char_range_parser([?b])])
```

one can write

```iex
    sequence([
      optional([?+, ?-]),
      many([?0..?9]),
      choice([?a, ?b])])
```

### EarmarkParser.Helpers.Parser.char_parser/1

A parser that succeeds in parsing the next character

```elixir
    iex(1)> char_parser().("a")
    {:ok, ?a, ""}
```

```elixir
    iex(2)> char_parser().("an")
    {:ok, ?a, "n"}
```

```elixir
    iex(3)> char_parser().("")
    {:error, "unexpected end of input in char_parser"}
```

We can name the parser to get a little bit better error messages

```elixir
    iex(4)> char_parser("identifier").("")
    {:error, "unexpected end of input in char_parser identifier"}
```

### EarmarkParser.Helpers.Parser.char_range_parser/2

Parser that succeeds only if the first char of the input is in the indicated
char_range

```elixir
      iex(5)> parser = char_range_parser([?1..?9, ?a, [?b, ?c]])
      ...(5)> parser.("b")
      {:ok, ?b, ""}
      ...(5)> parser.("9a")
      {:ok, ?9, "a"}
      ...(5)> parser.("d")
      {:error, "expected a char in the range [49..57, 97, 'bc']"}
```

The `char_range_parser` can also be called with a string which is transformed to
a charlist with `String.to_charlist`

```elixir
      iex(6)> bin_parser = char_range_parser("01")
      ...(6)> bin_parser.("10a")
      {:ok, ?1, "a"}
      ...(6)> bin_parser.("a")
      {:error, "expected a char in the range '01'"}
```

```elixir
      iex(7)> greek_letter_parser = char_range_parser("αβγδεζηθικλμνξοπρςστυφχψω")
      ...(7)> greek_letter_parser.("σπίτι")
      {:ok, 963, "πίτι"}
```

The last example is of course better written as

```elixir
      iex(8)> greek_letter_parser = char_range_parser(?α..?ω)
      ...(8)> greek_letter_parser.("σπίτι")
      {:ok, 963, "πίτι"}
```

for which reason you can also just pass a range

Be aware of a trap in the utf8 code here `?ί(943)` is not in the specified range

```elixir
      iex(9)> greek_letter_parser = char_range_parser(?α..?ω)
      ...(9)> greek_letter_parser.("ίτι")
      {:error, "expected a char in the range 945..969"}
```


### EarmarkParser.Helpers.Parser.choice/2

A parser that combines a list of parsers in a way to parse the input string
with first succeeding parser

```elixir
    iex(10)> choice([char_parser(), empty()]).("")
    {:ok, "", ""}
```

```elixir
    iex(11)> choice([char_parser(), empty()]).("a")
    {:ok, ?a, ""}
```

As this is a combinator we can take shortcuts for the usage of `char_range_parser`

```elixir
    iex(12)> az_parser = choice(["a", "z"])
    ...(12)> az_parser.("a")
    {:ok, ?a, ""}
    ...(12)> az_parser.("b")
    {:error, ""}
    ...(12)> az_parser.("z")
    {:ok, ?z, ""}
```


### EarmarkParser.Helpers.Parser.digit_parser/1

Parser that only succeeds when a digit is the first char of the input

```elixir
    iex(13)> digit_parser().("a")
    {:error, "expected a char in the range #{?0}..#{?9}"}
```

```elixir
    iex(14)> digit_parser().("42")
    {:ok, ?4, "2"}
```


### EarmarkParser.Helpers.Parser.empty/0

Always succeedes (be careful when combining this parser)

```elixir
      iex(15)> empty().("")
      {:ok, "", ""}
```

```elixir
      iex(16)> empty().("1")
      {:ok, "", "1"}
```

### EarmarkParser.Helpers.Parser.lazy/1

lazy is a parser delaying the execution of a different parser, this is needed to implement
recursive parsing

Let us assume that we want to parse this grammar

      S ← "(" S ")" | ε

and that we want to count the number of opening "(" in the parsed expression
A naive approach would be

```elixir
    def parser do
      sequence([
        parse_range_char([?(]),
        optional(parser()),
        parse_range_char([?)])
      ])
    end
```

but this would create an endless loop as we call parser() immediately
however we can remedy this with the lazy combinator

```elixir
    def parser do
      sequence([
        parse_range_char([?(]),
        optional(lazy(fn -> parser() end),
        parse_range_char([?)])
      ])
    end
```

Will work just fine as can be seen in this [test](test/earmark_helpers_tests/parser_test.exs)

### EarmarkParser.Helpers.Parser.many/1

Parses the input with the given parser as many times it succeeds, it never fails when count == 0
(which it always is in this version), so be careful when combining it

```elixir
    iex(17)> parser = many(digit_parser())
    ...(17)> parser.("12")
    {:ok, "12", ""}
    ...(17)> parser.("2b")
    {:ok, "2", "b"}
    ...(17)> parser.("a")
    {:ok, [], "a"}
```

**N.B.** that it **always** succeeds
if you need at least n > 0 parsing steps to succeed use `many!`

As many is a combinator we can also use the `char_range_parser` shortcut
again

```elixir
    iex(18)> many("01").("01a")
    {:ok, '01', "a"}
```

### EarmarkParser.Helpers.Parser.many!/3

same as many but a given number of parser runs must succeed

```elixir
      iex(19)> two_chars = char_parser() |> many!(2, "need two for tea")
      ...(19)> two_chars.("")
      {:error, "need two for tea"}
      ...(19)> two_chars.("a")
      {:error, "need two for tea"}
      ...(19)> two_chars.("ab")
      {:ok, 'ab', ""}
```

Same shortcut as for `many` is available

```elixir
    iex(20)> many!("01", 2).("01a")
    {:ok, '01', "a"}
    ...(20)> many!("01", 2).("1a")
    {:error, "many! failed with 1 parser steps missing"}
```

### EarmarkParser.Helpers.Parser.map/2

This implemnts the functor interface for parse results

```elixir
    iex(21)> number_parser = digit_parser()
    ...(21)> |> many()
    ...(21)> |> map(fn digits -> digits |> IO.chardata_to_string |> String.to_integer end)
    ...(21)> number_parser.("42a")
    {:ok, 42, "a"}
```

Let us show that the functor treats the error case correctly

```elixir
    iex(22)> parser = char_parser("my_parser") |> map(fn _ -> raise "That will not happen here" end)
    ...(22)> parser.("")
    {:error, "unexpected end of input in char_parser my_parser"}
```

we can use the shortcut specification for a parser here too

```elixir
    iex(23)> parser = map("01", fn x -> if x==?1, do: true end) 
    ...(23)> parser.("1")
    {:ok, true, ""}
```

### EarmarkParser.Helpers.Parser.optional/1

optional(parser) is just a shortcut for choice([parser, empty()]) and therefore always succeeds

```elixir
    iex(24)> optional(digit_parser()).("2")
    {:ok, ?2, ""}
```

```elixir
    iex(25)> optional(digit_parser()).("")
    {:ok, "", ""}
```

again shortcuts are supported

```elixir
    iex(26)> optional(?a).("a")
    {:ok, ?a, ""}
```

```elixir
    iex(27)> optional(?a).("b")
    {:ok, "", "b"}
```

### EarmarkParser.Helpers.Parser.satisfy/4

satisfy is a general purpose filtering refinement of a parser
it takes a perser, a function, an optional error message and an optional name

it creates a parser that parses the input with the passed in parser, if it fails
nothing changes, however if it succeeds the function is called on the result of
the parse and the thusly created parser only succeeds if the function call returns
a truthy value

Here is an example how digit_parser could be implemented (in reality it is implemented
using char_range_parser, which then uses satisfy in a more general way, too long to
be a good doctest)

```elixir
    iex(28)> dparser = char_parser() |> satisfy(&Enum.member?(?0..?9, &1), "not a digit")
    ...(28)> dparser.("1")
    {:ok, ?1, ""}
    ...(28)> dparser.("a")
    {:error, "not a digit"}
```

as satisfy is a combinator we can use shortcuts too

```elixir
    iex(29)> voyel_parser = "abcdefghijklmnopqrstuvwxyz"
    ...(29)> |> satisfy(&Enum.member?([?a, ?e, ?i, ?o, ?u], &1), "expected a voyel")
    ...(29)> voyel_parser.("a")
    {:ok, ?a, ""}
    ...(29)> voyel_parser.("b")
    {:error, "expected a voyel"}
```


### EarmarkParser.Helpers.Parser.sequence/1

sequence combines a list of parser to a parser that succeeds only if all parsers
in the list succeed one after each other

```elixir
    iex(30)> char_range = [?a..?z, ?A..?Z, ?_]
    ...(30)> initial_char_parser = char_range_parser(char_range, "leading identifier char")
    ...(30)> ident_parser = sequence(
    ...(30)>   [ initial_char_parser,
    ...(30)>     choice([initial_char_parser, digit_parser()]) |> many() ])
    ...(30)> ident_parser.("a42-")
    {:ok, [?a, ?4, ?2], "-"}
    ...(30)> ident_parser.("2a42-")
    {:error, ""}
    ...(30)> ident_parser.("_-")
    {:ok, [?_, []], "-"}
```

The result of the last doctest above also shows how many might return an empty list which combines
badly that is why the built in identifier parser maps the result with `&IO.chardata_to_string`

```elixir
    iex(31)> pwd_parser = sequence(["s", "e", "c", "r", "e", "t"])
    ...(31)> pwd_parser.("secret")
    {:ok, 'secret', ""}
    ...(31)> pwd_parser.("secre")
    {:error, "unexpected end of input in char_parser"}
```


### EarmarkParser.Helpers.Parser.skip/1

skip parses over a range of characters but ignoring them in the result
a typical use case is to skip whitespace
**N.B.** that it never fails, if you need to assure the presence of a
character but ignoring it use `skip!`

```elixir
    iex(32)> skip_ws = skip([9, 10, 32])
    ...(32)> skip_ws.("a b")
    {:ok, "", "a b"}
    ...(32)> skip_ws.(" \t\na b")
    {:ok, "", "a b"}
    ...(32)> skip_ws.("  ")
    {:ok, "", ""}
```

the more convient form is to use shortcut strings here too

```elixir
    iex(33)> skip_ws = skip(" \t\n")
    ...(33)> skip_ws.("a b")
    {:ok, "", "a b"}
    ...(33)> skip_ws.(" \t\na b")
    {:ok, "", "a b"}
    ...(33)> skip_ws.("  ")
    {:ok, "", ""}
```

### EarmarkParser.Helpers.Parser.skip!/2

like skip but returns an error if no char in the range was found

```elixir
    iex(34)> skip_ws = skip!([9, 10, 32], "need ws here")
    ...(34)> skip_ws.("a b")
    {:error, "need ws here"}
    ...(34)> skip_ws.(" \t\na b")
    {:ok, "", "a b"}
    ...(34)> skip_ws.("  ")
    {:ok, "", ""}
```

and again...

```elixir
    iex(35)> skip_ws = skip!(" \t\n", "need ws here")
    ...(35)> skip_ws.("a b")
    {:error, "need ws here"}
    ...(35)> skip_ws.(" \t\na b")
    {:ok, "", "a b"}
    ...(35)> skip_ws.("  ")
    {:ok, "", ""}
```

### EarmarkParser.Helpers.Parser.up_to/1

up_to is somehow the contrary to char_range |> many it never fails, because of the many and
parses all characters up to the terminations char sets

```elixir
      iex(36)> no_spaces = up_to([32, 10])
      ...(36)> no_spaces.("a b")
      {:ok, "a", " b"}
      ...(36)> no_spaces.(" b")
      {:ok, "", " b"}
      ...(36)> no_spaces.("ab")
      {:ok, "ab", ""}
```

and the more convenient

```elixir
      iex(37)> no_spaces = up_to("\n ")
      ...(37)> no_spaces.("a b")
      {:ok, "a", " b"}
      ...(37)> no_spaces.(" b")
      {:ok, "", " b"}
      ...(37)> no_spaces.("ab")
      {:ok, "ab", ""}
```


## Contributing

Pull Requests are happily accepted.

Please be aware of one _caveat_ when correcting/improving `README.md`.

The `README.md` is generated by the mix task `readme` from `README.template` and
docstrings by means of `%moduledoc` or `%functiondoc` directives.

Please identify the origin of the generated text you want to correct and then
apply your changes there.

Then issue the mix task `readme`, this is important to have a correctly updated `README.md` after the merge of
your PR.

Thank you all who have already helped with Earmark/EarmarkParser, your names are duely noted in [RELEASE.md](RELEASE.md).

## Author

Copyright © 2014-2021 Dave Thomas, The Pragmatic Programmers
@/+pragdave,  dave@pragprog.com

Copyright © 2020-2021 Robert Dober
robert.dober@gmail.com

## LICENSE

Same as Elixir, which is Apache License v2.0. Please refer to [LICENSE](LICENSE) for details.

<!-- SPDX-License-Identifier: Apache-2.0 -->
