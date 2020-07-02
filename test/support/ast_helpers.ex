defmodule Support.AstHelpers do
  import EarmarkAstDsl

  def li(content, atts \\ []), do: tag("li", content, atts)
  def ul(content, atts \\ []), do: tag("ul", content, atts)
  def ol(content, atts \\ []), do: tag("ol", content, atts)
end
