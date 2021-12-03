defmodule Support.FootnoteHelpers do
  import EarmarkAstDsl
  @moduledoc false

  def footnote(number) do
    a("#{number}", href: "#fn:#{number}", id: "fnref:#{number}", class: "footnote", title: "see footnote")
  end

  def footnotes(content) do
    tag("div", [tag("hr")|content], class: "footnotes")
  end

  def reverse_footnote(number) do
    a("&#x21A9;",
      class: "reversefootnote",
      href: "#fnref:#{number}",
      title: "return to article")
  end
end
#  SPDX-License-Identifier: Apache-2.0
