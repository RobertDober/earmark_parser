defmodule EarmarkParser.Ast.Inline.Converters.CodeConverter do
  import EarmarkParser.Helpers.StringHelpers, only: [tokenize: 2]

  @moduledoc false

  @tokens [bt: ~r{\A `+ }xu, text: ~r{\A [^`]+ }xu]

  def convert_code(src) do
    case tokenize(@tokens, src) do
      {:bt, head, rest} -> _parse_to_head(head, rest, [])
      _ -> nil
    end
  end

  defp _parse_to_head(head, input, content) do
    case tokenize(@tokens, input) do
      {:bt, ^head, rest} -> {IO.chardata_to_string(content), rest}
      {_, text, rest} -> _parse_to_head(head, rest, [content, text])
      _ -> nil
    end
  end
end

# SPDX-License-Identifier: Apache-2.0
