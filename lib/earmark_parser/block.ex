defmodule EarmarkParser.Block do
  @moduledoc false

  # TODO: Move each module into a file?
  defmodule Heading do
    @moduledoc false
    defstruct lnb: 0, annotation: nil, attrs: nil, content: nil, level: nil
  end

  defmodule Ruler do
    @moduledoc false
    defstruct lnb: 0, annotation: nil, attrs: nil, type: nil
  end

  defmodule BlockQuote do
    @moduledoc false
    defstruct lnb: 0, annotation: nil, attrs: nil, blocks: []
  end

  defmodule Para do
    @moduledoc false
    defstruct lnb: 0, annotation: nil, attrs: nil, lines: []
  end

  defmodule Code do
    @moduledoc false
    defstruct lnb: 0, annotation: nil, attrs: nil, lines: [], language: nil
  end

  defmodule Html do
    @moduledoc false
    defstruct lnb: 0, annotation: nil, attrs: nil, html: [], tag: nil
  end

  defmodule HtmlOneline do
    @moduledoc false
    defstruct lnb: 0, annotation: nil, attrs: nil, html: ""
  end

  defmodule HtmlComment do
    @moduledoc false
    defstruct lnb: 0, annotation: nil, attrs: nil, lines: []
  end

  defmodule IdDef do
    @moduledoc false
    defstruct lnb: 0, annotation: nil, attrs: nil, id: nil, url: nil, title: nil
  end

  defmodule FnDef do
    @moduledoc false
    defstruct lnb: 0, annotation: nil, attrs: nil, id: nil, number: nil, blocks: []
  end

  defmodule FnList do
    @moduledoc false
    defstruct lnb: 0, annotation: nil, attrs: ".footnotes", blocks: []
  end

  defmodule Ial do
    @moduledoc false
    defstruct lnb: 0, annotation: nil, attrs: nil, content: nil, verbatim: ""
  end

  defmodule List do
    @moduledoc false
    import EarmarkParser.Helpers.LookaheadHelpers, only: [update_inline_code: 2]

    defstruct annotation: nil,
              attrs: nil,
              blocks: [],
              lines: [],
              bullet: "-",
              indent: 0,
              lnb: 0,
              loose?: false,
              pending: {nil, 0},
              spaced?: false,
              start: "",
              type: :ul

    def new(%EarmarkParser.Line.ListItem{} = li) do
      %__MODULE__{
        bullet: li.bullet,
        indent: li.list_indent,
        lnb: li.lnb,
        type: li.type
      }
    end

    def update_pending_state(%__MODULE__{pending: old_pending_state}=list, line) do
      new_pending_state = update_inline_code(old_pending_state, line)
      %{list | pending: new_pending_state}
    end
  end

  defmodule ListItem do
    @moduledoc false
    defstruct attrs: nil,
              blocks: [],
              bullet: "",
              lnb: 0,
              annotation: nil,
              loose?: false,
              spaced?: true,
              type: :ul

    def new(list, blocks \\ []) do
      %__MODULE__{
        blocks: blocks,
        bullet: list.bullet,
        lnb: list.lnb,
        annotation: list.annotation,
        loose?: list.loose?,
        spaced?: list.spaced?,
        type: list.type
      }
    end
  end

  defmodule Table do
    @moduledoc false
    defstruct lnb: 0, annotation: nil, attrs: nil, rows: [], header: nil, alignments: []

    def new_for_columns(n) do
      %__MODULE__{alignments: Elixir.List.duplicate(:left, n)}
    end
  end

  defmodule Text do
    @moduledoc false
    defstruct attrs: nil, lnb: 0, annotation: nil, line: ""
  end

  @type t ::
          %Heading{}
          | %Ruler{}
          | %BlockQuote{}
          | %List{}
          | %ListItem{}
          | %Para{}
          | %Code{}
          | %Html{}
          | %HtmlOneline{}
          | %HtmlComment{}
          | %IdDef{}
          | %FnDef{}
          | %FnList{}
          | %Ial{}
          | %Table{}
          | %Text{}
  @type ts :: list(t)
end

# SPDX-License-Identifier: Apache-2.0
