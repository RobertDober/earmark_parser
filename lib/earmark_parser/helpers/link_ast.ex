defmodule EarmarkParser.Helpers.LinkAst do
  @moduledoc ~S"""
  """

  defstruct type: :link, parsed: [], text: "", title: nil, url: ""

  def new(opts \\ []) do
    struct!(__MODULE__, opts)
  end

  def finalize(%{parsed: parsed} = ast, _content) do
    %{ast | parsed: IO.chardata_to_string(parsed)}
  end

  def determine_type({:lit, "!"}), do: new(type: :image, parsed: [?!])
  def determine_type(_), do: new(type: :link)
end

#  SPDX-License-Identifier: Apache-2.0
