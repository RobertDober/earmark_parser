defmodule V2.Support.Helpers do
  
  def as_ast2(markdown, options \\ []) do
    EarmarkParser2.as_ast2(markdown, options)
  end
end
