defmodule Test.GfmSpec do
  use Support.AcceptanceTestCase

  describe "how to compare the testsuite with an AST" do
    test "Let us _parse_ an excerpt of a spec and compare to a simple AST" do

      {:ok, io} = File.open("test/spec.txt", [:utf8])
      IO.inspect(io, label: "IO>>>")
      lines = IO.stream(io, :line)
      IO.inspect(lines
      |> Enum.take(3),  label: "\nLINES>>>")
      
      # assert Enum.length(lines) > 1000
      
    end
  end
end
# SPDX-License-Identifier: Apache-2.0
