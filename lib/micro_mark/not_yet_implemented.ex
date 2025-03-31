defmodule MicroMark.NotYetImplemented do
  @moduledoc false

  defexception [:message]

  @type t :: %__MODULE__{message: binary()}
  @impl true
  @spec exception(term()) :: t
  def exception(value) do
    %__MODULE__{message: "The function #{value} is not yet implemented"}
  end
end

# SPDX-License-Identifier: Apache-2.0
