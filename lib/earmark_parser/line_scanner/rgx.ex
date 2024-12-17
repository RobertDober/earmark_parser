defmodule EarmarkParser.LineScanner.Rgx do
  @moduledoc ~S"""
  Exposes the regular expressions needed in the scanner in a more readable
  and optilized way by forcing them to be compiled at compile time in this
  module and then inlining them by means of exposed functions.
  """

  @compile {:inline,
    block_quote_matches: 1,
    bullet_list_item_matches: 1,
    dash_ruler_matches: 1,
    fence_matches: 1,
    footnote_def_matches: 1,
    heading_matches: 1,
    html_close_tag_matches: 1,
    html_comment_matches: 1,
    html_comment_start_matches: 1,
    html_one_line_matches: 1,
    html_open_tag_matches: 1,
    html_self_closing_matches: 1,
    ial_matches: 1,
    id_def_matches: 1,
    indent_matches: 1,
    numbered_list_item_matches: 1,
    set_ext_underline_matches: 1,
    star_ruler_matches: 1,
    table_column_rgx: 0,
    table_first_column_rgx: 0,
    table_header_rgx: 0,
    table_line_matches: 1,
    underline_ruler_matches: 1,
    void_tag_matches: 1,
    void_tag_rgx: 0,
  }

  @block_quote ~r/\A > \s? (.*)/x
  def block_quote_matches(content), do: Regex.run(@block_quote, content)

  @bullet_list_item ~r/\A ([-*+]) \s (\s*) (.*)/x
  def bullet_list_item_matches(content), do: Regex.run(@bullet_list_item, content)

  @dash_ruler ~r/\A (?:-\s?){3,} \z/x
  def dash_ruler_matches(content), do: Regex.run(@dash_ruler, content)
  
  @fence ~r/\A (\s*) (`{3,} | ~{3,}) \s* ([^`\s]*) \s* \z/ux
  def fence_matches(content), do: Regex.run(@fence, content)

  @footnote_def ~r/\A \[\^([^\s\]]+)\] : \s+ (.*)/x
  def footnote_def_matches(content), do: Regex.run(@footnote_def, content)

  @heading ~r/\A(\#{1,6})\s+(?|(.*?)\s*#*\s*\z|(.*))/u
  # @heading ~r/\A
  # (\#{1,6}) \s+ 
  #   (?|(.*?) \s* #* \s* \z
  #   |
  #   (.*))/ux
  def heading_matches(content), do: Regex.run(@heading, content)

  @html_close_tag ~r/\A < \/ ([-\w]+?) >/x
  def html_close_tag_matches(content), do: Regex.run(@html_close_tag, content)

  @html_comment_start ~r/\A <!-- .*? \z/x
  def html_comment_start_matches(content), do: Regex.run(@html_comment_start, content)
  
  @html_comment ~r/\A <! (?: -- .*? -- \s* )+ > \z/x
  def html_comment_matches(content), do: Regex.run(@html_comment, content)
  
  @html_one_line ~r/\A < ([-\w]+?) (?:\s.*)? > .* <\/\1>/x
  def html_one_line_matches(content), do: Regex.run(@html_one_line, content)

  @html_open_tag ~r/\A < ([-\w]+?) (?:\s.*)? >/x
  def html_open_tag_matches(content), do: Regex.run(@html_open_tag, content)

  @html_self_closing ~r/\A < ([-\w]+?) (?:\s.*)? \/> .*/x
  def html_self_closing_matches(content), do: Regex.run(@html_self_closing, content)

  @set_ext_underline ~r/\A (=|-)+ \s* \z/x
  def set_ext_underline_matches(content), do: Regex.run(@set_ext_underline, content)

  @ial ~r/\A {: (\s*[^}]+) } \s* \z/x
  def ial_matches(content), do: Regex.run(@ial, content)

  @id_title_part ~S"""
        (?|
             " (.*)  "         # in quotes
          |  ' (.*)  '         #
          | \( (.*) \)         # in parens
        )
  """
  @id_def ~r'''
     ^\[([^^].*?)\]:            # [someid]:
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
  def id_def_matches(content), do: Regex.run(@id_def, content)

  @indent ~r'''
    \A ( (?: \s{4})+ ) (\s*)                       # 4 or more leading spaces
    (.*)                                  # the rest
  '''x
  def indent_matches(content), do: Regex.run(@indent, content)

  @numbered_list_item ~r/\A (\d{1,9} [.)] ) \s (\s*) (.*)/x
  def numbered_list_item_matches(content), do: Regex.run(@numbered_list_item, content)

  @star_ruler ~r/\A (?:\*\s?){3,} \z/x
  def star_ruler_matches(content), do: Regex.run(@star_ruler, content)

  @table_column ~r/\A (\s*) .* \| /x
  def table_column_rgx, do: @table_column

  @table_first_column ~r/\A (\s*) .* \s \| \s /x
  def table_first_column_rgx, do: @table_first_column

  @table_header ~r/\[\[ .*? \]\]/x
  def table_header_rgx, do: @table_header

  @table_line ~r/\A \| (?: [^|]+ \|)+ \s* \z/x
  def table_line_matches(content), do: Regex.run(@table_line, content)

  @underline_ruler ~r/\A (?:_\s?){3,} \z/x
  def underline_ruler_matches(content), do: Regex.run(@underline_ruler, content)

  @void_tags ~w{area br hr img wbr}
  @void_tag ~r'''
      ^<( #{Enum.join(@void_tags, "|")} )
        .*?
        >
  '''x
  def void_tag_rgx, do: @void_tag
  def void_tag_matches(content), do: Regex.run(@void_tag, content)
end
# SPDX-License-Identifier: Apache-2.0
