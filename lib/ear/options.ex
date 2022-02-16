defmodule Ear.Options do


  # What we use to render
  defstruct gfm: true,
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
            pure_links: true



  @doc false
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
    end
  end
  def normalize(options), do: struct(__MODULE__, options) |> normalize()

  @doc false
  def plugin_for_prefix(options, plugin_name) do
    Map.get(options.plugins, plugin_name, false)
  end

end

# SPDX-License-Identifier: Apache-2.0
