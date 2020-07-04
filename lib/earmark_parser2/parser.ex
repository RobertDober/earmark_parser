defmodule EarmarkParser2.Parser do
  alias EarmarkParser2.AstCtxt
  @moduledoc false


  def parse(tokens, options) do
    _parse(tokens, %AstCtxt{options: options})
  end
end
