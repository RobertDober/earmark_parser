defmodule EarmarkParser.Parser.MetadataParser do
  alias __MODULE__.Peg

  @moduledoc ~S"""
  This parses metadata in Comments

  Metadata starts with a comment of this form: `~r{\A\s*<!---\s+Metadata(\s+.*)?\z}`
  The captured text becomes the description of the metadata (`nil` if absent)

  This parser is called with the lines following the _Metadata Declaration_ up to
  the last line of the comment.

  Starting in the next line a simple subset of Elixir is parsed as the metadata that
  will be provided in the AST node of the comment.

  Literals are enclosed in `'`, and `[[...]]` expressions are considered to parse what
  matches them when compiled to a `Regexp`

  ```elixir
    expr ::= number | binary | atom | list | keyword_list

    number ::= [-+]? [[:digit:]]+ ('.' [[:digit:]]+)?

    binary ::= '"' ('\"' | !'"')* '"'

    atom ::= ':' identifier        ; HINT: use :false, :nil and :true
    identifier ::= alpha' alnum'*
    alpha' ::= [[:alpha:]_]
    alnum' ::= [[:alnum:]_]

    list ::= '[' (expr (',' expr)*)? ']'
    
    keyword_list ::= '[' (keyword_entry (',' keyword_entry)*)? ']'
    keyword_entry ::= keyword [[:space::]]+ <expr>
    keyword ::= identifier ':'

  ```

  """

  @type metadata_t :: {:ok, any()} | {:error, binary()}
  @typep content_t :: String.t() | [String.t()]

  @spec parse(content_t()) :: metadata_t()
  def parse(lines_or_content)

  def parse(lines) when is_list(lines) do
    lines |> Enum.join(" ") |> parse()
  end

  def parse(content) do
    case Peg.parse(content) do
      {:ok, ast, _} -> {:ok, ast}
      error -> error
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
