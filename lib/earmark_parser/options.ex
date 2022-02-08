defmodule EarmarkParser.Options do

  use EarmarkParser.Types

  # What we use to render
  defstruct renderer: EarmarkParser.HtmlRenderer,
            # Inline style options
            gfm: true,
            gfm_tables: false,
            breaks: false,
            footnotes: false,
            footnote_offset: 1,
            wikilinks: false,
            parse_inline: true,

            # allow for annotations
            annotations: nil,
            # additional prefies for class of code blocks
            code_class_prefix: nil,

            # Filename and initial line number of the markdown block passed in
            # for meaningful error messages
            file: "<no file>",
            line: 1,
            # [{:error|:warning, lnb, text},...]
            messages: MapSet.new([]),
            pure_links: true,

            # deprecated
            pedantic: false,
            smartypants: false,
            timeout: nil

  @type t :: %__MODULE__{
        breaks: boolean,
        code_class_prefix: maybe(String.t),
        footnotes: boolean,
        footnote_offset: number,
        gfm: boolean,
        messages: MapSet.t,
        pedantic: boolean,
        pure_links: boolean,
        smartypants: boolean,
        wikilinks: boolean,
        parse_inline: boolean
  }

  @doc false
  def add_deprecations(options, messages)
  def add_deprecations(%__MODULE__{smartypants: true}=options, messages) do
    add_deprecations(%{options|smartypants: false},
      [{:deprecated, 0, "The smartypants option has no effect anymore and will be removed in EarmarkParser 1.5"}|messages])
  end
  def add_deprecations(%__MODULE__{timeout: timeout}=options, messages) when timeout != nil do
    add_deprecations(%{options|timeout: nil},
      [{:deprecated, 0, "The timeout option has no effect anymore and will be removed in EarmarkParser 1.5"}|messages])
  end
  def add_deprecations(%__MODULE__{pedantic: true}=options, messages) do
    add_deprecations(%{options|pedantic: false},
      [{:deprecated, 0, "The pedantic option has no effect anymore and will be removed in EarmarkParser 1.5"}|messages])
  end
  def add_deprecations(_options, messages), do: messages

  @doc ~S"""
  Use normalize before passing it into any API function

        iex(1)> options = normalize(annotations: "%%")
        ...(1)> options.annotations
        ~r{\A(.*)(%%.*)}
  """
  def normalize(options)
  def normalize(%__MODULE__{}=options) do
    case options.annotations do
      %Regex{} -> options
      nil      -> options
      _ -> %{options | annotations: Regex.compile!("\\A(.*)(#{Regex.escape(options.annotations)}.*)")}
    end |> _deprecate_old_messages()
  end
  def normalize(options), do: struct(__MODULE__, options) |> normalize()

  @doc false
  def plugin_for_prefix(options, plugin_name) do
    Map.get(options.plugins, plugin_name, false)
  end

  defp _deprecate_old_messages(opitons)
  defp _deprecate_old_messages(%__MODULE__{messages: %MapSet{}}=options), do: options
  defp _deprecate_old_messages(%__MODULE__{messages: messages}=options) do
    %{ options |
      messages:
      MapSet.new([{:deprecated, 0, "messages is an internal option that is ignored and will be removed from the API in v1.5.0"}])}
  end
end

# SPDX-License-Identifier: Apache-2.0
