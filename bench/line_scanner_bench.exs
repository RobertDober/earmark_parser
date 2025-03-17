import Bench.GetModuledocs
import EarmarkParser.LineScanner, only: [type_of: 2]


docs = load_moduledocs()
IO.inspect(docs)


IO.puts("\n\e[1m#{Enum.count(docs)} lines of moduledocs found")

scan_lines = fn -> 
  docs
  |> Enum.map(&type_of(&1, true))
end
Benchee.run(
  %{"line_scanner" => scan_lines} 
)
# SPDX-License-Identifier: Apache-2.0
