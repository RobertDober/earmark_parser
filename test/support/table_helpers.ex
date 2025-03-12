defmodule Support.TableHelpers do
  import EarmarkAstDsl

  @moduledoc ~S"""
  Extends AstDsl for tables
  """

  def tbody(cells) do
    tag("tbody", tag("tr", cells))
  end

  def thead(cells) do
    tag("thead", tag("tr", cells))
  end

  def td(content, align \\ "left") do
    tag("td", [content], style: "text-align: #{align};")
  end

  def th(content, align \\ "left") do
    tag("th", [content], style: "text-align: #{align};")
  end
end

# SPDX-License-Identifier: Apache-2.0
