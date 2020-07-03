defmodule EarmarkParser.Lexer do
  alias EarmarkParser.Helpers.LeexHelpers, as: LH
  @moduledoc false

  def tokenize(line, lnb: lnb) do
    LH.elex line, lnb: lnb, with: :token_lexer
  end
  

end
