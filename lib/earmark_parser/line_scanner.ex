defmodule EarmarkParser.LineScanner do

  @moduledoc false

  alias EarmarkParser.{Helpers, Line, Options}

  # This is the re that matches the ridiculous "[id]: url title" syntax

  @id_title_part ~S"""
        (?|
             " (.*)  "         # in quotes
          |  ' (.*)  '         #
          | \( (.*) \)         # in parens
        )
  """

  @id_title_part_re ~r[^\s*#{@id_title_part}\s*$]x

  @id_re ~r'''
     ^\[(.+?)\]:            # [someid]:
     \s+
     (?|
         < (\S+) >          # url in <>s
       |   (\S+)            # or without
     )
     (?:
        \s+                   # optional title
        #{@id_title_part}
     )?
     \s*
  $
  '''x

  @indent_re ~r'''
    \A ( (?: \s{4})+ ) (\s*)                       # 4 or more leading spaces
    (.*)                                  # the rest
  '''x

  @void_tags ~w{area br hr img wbr}
  @void_tag_rgx ~r'''
      ^<( #{Enum.join(@void_tags, "|")} )
        .*?
        >
  '''x
  @doc false
  def void_tag?(tag), do: Regex.match?(@void_tag_rgx, "<#{tag}>")

  @doc false
  # We want to add the original source line into every
  # line we generate. We also need to expand tabs before
  # proceeding

  # (_,atom() | tuple() | #{},_) -> ['Elixir.B']
  def scan_lines(lines, options \\ %Options{}, recursive \\ false)

  def scan_lines(lines, options, recursive) do
    lines_with_count(lines, options.line - 1)
    |> with_lookahead(options, recursive)
  end

  defp lines_with_count(lines, offset) do
    Enum.zip(lines, offset..(offset + Enum.count(lines)))
  end

  defp with_lookahead([line_lnb | lines], options, recursive) do
    case type_of(line_lnb, options, recursive) do
      %Line.Fence{delimiter: delimiter, indent: indent} = fence ->
        stop =
          # We should stop on another code block, any close html tag,
          # or on less indent if there is any indentation.
          case indent do
            0 ->
              ~r/\A(\s*)(#{delimiter})\s*([^`\s]*)\s*\z|\A(\s{0,3})<\/([-\w]+?)>/u

            _ ->
              ~r/\A(\s*)(#{delimiter})\s*([^`\s]*)\s*\z|\A(\s{0,3})<\/([-\w]+?)>|\A\s{#{indent - 1}}[^\s]/u
          end

        [fence | lookahead_until_match(lines, stop, options, recursive)]

      %Line.HtmlComment{complete: false} = html_comment ->
        [html_comment | lookahead_until_match(lines, ~r/-->/u, options, recursive)]

      other ->
        [other | with_lookahead(lines, options, recursive)]
    end
  end

  defp with_lookahead([], _options, _recursive), do: []

  defp lookahead_until_match([{line, lnb} | lines], regex, options, recursive) do
    if line =~ regex do
      [type_of({line, lnb}, options, recursive) | with_lookahead(lines, options, recursive)]
    else
      [%{create_text(line) | lnb: lnb} | lookahead_until_match(lines, regex, options, recursive)]
    end
  end

  defp lookahead_until_match([], _, _, _), do: []

  def type_of(line, recursive)
      when is_boolean(recursive),
      do: type_of(line, %Options{}, recursive)

  def type_of({line, lnb}, options = %Options{annotations: annotations}, recursive) do
    {line1, annotation} = line |> Helpers.expand_tabs() |> Helpers.remove_line_ending(annotations)
    %{_type_of(line1, options, recursive) | annotation: annotation, lnb: lnb}
  end

  @doc false
  # Used by the block parser to test if a line following an IdDef
  # is a possible title
  def matches_id_title(content) do
    case Regex.run(@id_title_part_re, content) do
      [_, title] -> title
      _ -> nil
    end
  end

  defp _type_of(line, options = %Options{}, recursive) do
    {ial, stripped_line} = Helpers.extract_ial(line)
    {content, indent} = count_indent(line, 0)
    lt_four? = indent < 4

    cond do
      content == "" ->
        create_text(line, content, indent)

      lt_four? && !recursive && Regex.run(~r/\A <! (?: -- .*? -- \s* )+ > \z/x, content) ->
        %Line.HtmlComment{complete: true, indent: indent, line: line}

      lt_four? && !recursive && Regex.run(~r/\A <!-- .*? \z/x, content) ->
        %Line.HtmlComment{complete: false, indent: indent, line: line}

      lt_four? && Regex.run(~r/^ (?:-\s?){3,} $/x, content) ->
        %Line.Ruler{type: "-", indent: indent, line: line}

      lt_four? && Regex.run(~r/^ (?:\*\s?){3,} $/x, content) ->
        %Line.Ruler{type: "*", indent: indent, line: line}

      lt_four? && Regex.run( ~r/\A (?:_\s?){3,} \z/x, content) ->
        %Line.Ruler{type: "_", indent: indent, line: line}

      match = Regex.run(~R/^(#{1,6})\s+(?|([^#]+)#*\s*$|(.*))/u, stripped_line) ->
        [_, level, heading] = match
        %Line.Heading{level: String.length(level), content: String.trim(heading), indent: 0, ial: ial, line: stripped_line}

      match = lt_four? && Regex.run(~r/\A>\s?(.*)/, content) ->
        [_, quote] = match
        %Line.BlockQuote{content: quote, indent: indent, ial: ial, line: stripped_line}

      match = Regex.run(@indent_re, line) ->
        [_, spaces, more_spaces, rest] = match
        sl = byte_size(spaces)
        %Line.Indent{level: div(sl, 4), content: more_spaces <> rest, indent: byte_size(more_spaces) + sl, line: line}

      match = Regex.run(~r/\A(\s*)(`{3,}|~{3,})\s*([^`\s]*)\s*\z/u, line) ->
        [_, leading, fence, language] = match
        %Line.Fence{delimiter: fence, language: _attribute_escape(language), indent: byte_size(leading), line: line}

      # Although no block tags I still think they should close a preceding para as do many other
      # implementations.
      match = !recursive && Regex.run(@void_tag_rgx, line) ->
        [_, tag] = match
        %Line.HtmlOneLine{tag: tag, content: line, indent: 0, line: line}

      match = !recursive && Regex.run(~r{\A<([-\w]+?)(?:\s.*)?>.*</\1>}, line) ->
        [_, tag] = match
        %Line.HtmlOneLine{tag: tag, content: line, indent: 0, line: line}

      match = !recursive && Regex.run(~r{\A<([-\w]+?)(?:\s.*)?/>.*}, line) ->
        [_, tag] = match
        %Line.HtmlOneLine{tag: tag, content: line, indent: 0, line: line}

      match = !recursive && Regex.run(~r/^<([-\w]+?)(?:\s.*)?>/, line) ->
        [_, tag] = match
        %Line.HtmlOpenTag{tag: tag, content: line, indent: 0, line: line}

      match = lt_four? && !recursive && Regex.run(~r/\A<\/([-\w]+?)>/, content) ->
        [_, tag] = match
        %Line.HtmlCloseTag{tag: tag, indent: indent, line: line}

      match = lt_four? && Regex.run(@id_re, content) ->
        [_, id, url | title] = match
        title = if(length(title) == 0, do: "", else: hd(title))
        %Line.IdDef{id: id, url: url, title: title, indent: indent, line: line}

      match = options.footnotes && Regex.run(~r/\A\[\^([^\s\]]+)\]:\s+(.*)/, line) ->
        [_, id, first_line] = match
        %Line.FnDef{id: id, content: first_line, indent: 0, line: line}

      match = lt_four? && Regex.run(~r/^([-*+])\s(\s*)(.*)/, content) ->
        [_, bullet, spaces, text] = match

        %Line.ListItem{
          type: :ul,
          bullet: bullet,
          content: spaces <> text,
          indent: indent,
          list_indent: String.length(bullet <> spaces) + indent + 1,
          line: line
        }

      match = lt_four? && Regex.run(~r/^(\d{1,9}[.)])\s(\s*)(.*)/, content) ->
        [_, bullet, spaces, text] = match

        # TODO: Rewrite this mess
        sl = byte_size(spaces)
        sl1 = if sl > 3, do: 1, else: sl + 1
        sl2 = sl1 + byte_size(bullet)

        %Line.ListItem{
          type: :ol,
          bullet: bullet,
          content: spaces <> text,
          indent: indent,
          list_indent: indent + sl2,
          line: line
        }

      match = Regex.run(~r/^ \| (?: [^|]+ \|)+ \s* $ /x, content) ->
        [body] = match

        body =
          body
          |> String.trim()
          |> String.trim("|")

        columns = split_table_columns(body)
        %Line.TableLine{content: line, columns: columns, is_header: _determine_if_header(columns), indent: indent, line: line}

      Regex.run(~r/\A (\s*) .* \s \| \s /x, line) ->
        columns = split_table_columns(line)
        %Line.TableLine{content: line, columns: columns, is_header: _determine_if_header(columns), indent: indent, line: line}

      options.gfm_tables && Regex.run( ~r/\A (\s*) .* \| /x, line) ->
        columns = split_table_columns(line)
        %Line.TableLine{
          content: line,
          columns: columns,
          is_header: _determine_if_header(columns),
          needs_header: true,
          indent: indent,
          line: line}

      match = Regex.run(~r/^(=|-)+\s*$/, line) ->
        [_, type] = match
        level = if(String.starts_with?(type, "="), do: 1, else: 2)
        %Line.SetextUnderlineHeading{level: level, indent: 0, line: line}

      match = lt_four? && Regex.run(~r<^{:(\s*[^}]+)}\s*$>, content) ->
        [_, ial] = match
        %Line.Ial{attrs: String.trim(ial), verbatim: ial, indent: indent, line: line}

      true ->
        create_text(line, content, indent)
    end
  end

  defp create_text(line) do
    {content, indent} = count_indent(line, 0)
    create_text(line, content, indent)
  end

  defp create_text(line, "", indent),
    do: %Line.Blank{indent: indent, line: line}

  defp create_text(line, content, indent),
    do: %Line.Text{content: content, indent: indent, line: line}

  defp count_indent(<<space, rest::binary>>, indent) when space in [?\s, ?\t],
    do: count_indent(rest, indent + 1)

  defp count_indent(rest, indent),
    do: {rest, indent}

  defp _attribute_escape(string), do:
    string
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")


  # Not sure yet if we shall enforce all tags, in that case we shall enlargen @block_tags to @html_tags
  # @block_tags ~w< address article aside blockquote canvas dd div dl fieldset figcaption h1 h2 h3 h4 h5 h6 header hgroup li main nav noscript ol output p pre section table tfoot ul video>
  #             |> Enum.into(MapSet.new())
  # defp block_tag?(tag), do: MapSet.member?(@block_tags, tag)

  @column_rgx ~r{\A[\s|:-]+\z}
  defp _determine_if_header(columns) do
    columns
    |> Enum.all?(fn col -> Regex.run(@column_rgx, col) end)
  end
  defp split_table_columns(line) do
    line
    |> String.split(~r{(?<!\\)\|})
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn col -> Regex.replace(~r{\\\|}, col, "|") end)
  end
end
