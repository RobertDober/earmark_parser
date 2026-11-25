defmodule EarmarkParser.Parser.MetadataParser do
  alias EarmarkParser.Peg

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
    expr ::= number | string | atom | list | keyword_list

    number ::= [-+]? [[:digit:]]+ ('.' [[:digit:]]+)?

    string ::= '"' ('\"' | !'"')* '"'

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
  @typep content_t :: [String.t()]

  # @spec parse(content_t()) :: metadata_t()
  # def parse(content) do
  #   peg = Peg.new(content)
  #   case Peg.parse(peg, expr_parser()) do
  #     {:ok, ast, _} -> {:ok, ast}
  #     error -> error
  #   end
  # end

  # defp expr_parser do
  #   Peg.Parsers.int_parser()
  # end
end

# SPDX-License-Identifier: Apache-2.0
