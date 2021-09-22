defmodule Test.Acceptance.Ast.MetadataTest do
  use ExUnit.Case
  import Support.Helpers, only: [as_ast: 1, as_ast: 2, parse_html: 1]

  describe "just no metadata, but option is allowed" do
    test "with annotations" do
      assert as_ast("hello", EarmarkParser.Options.normalize(annotations: "%%"))
    end
  end
end
