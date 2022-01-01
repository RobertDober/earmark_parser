defmodule EarmarkParser.Block do
  @moduledoc false

  @type t ::
          %__MODULE__.Heading{}
          | %__MODULE__.Ruler{}
          | %__MODULE__.BlockQuote{}
          | %__MODULE__.List{}
          | %__MODULE__.ListItem{}
          | %__MODULE__.Para{}
          | %__MODULE__.Code{}
          | %__MODULE__.Html{}
          | %__MODULE__.HtmlOneline{}
          | %__MODULE__.HtmlComment{}
          | %__MODULE__.IdDef{}
          | %__MODULE__.FnDef{}
          | %__MODULE__.FnList{}
          | %__MODULE__.Ial{}
          | %__MODULE__.Table{}
          | %__MODULE__.Text{}
  @type ts :: list(t)
end
# SPDX-License-Identifier: Apache-2.0
